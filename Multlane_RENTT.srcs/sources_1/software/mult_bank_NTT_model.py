"""
@Descripttion: mult-bank NTT model (本程序只考虑基2,迭代型)
@version: V1.0
@Author: HZW
@Date: 2025-6-16 10:30
"""

from time import perf_counter
import pandas as pd
import random
from math import log2
import numpy as np
import os
import shutil

#-------------------------------全局参数设置----------------------------------
q = 3329     # 模数
n = 8   
zeta = 17    # NTT变换中使用的单位根

N = 2**n  # 多项式环的维度（256）
P = 2     # 并行蝶形单元数量
inv2 = 3303  # inverse of 2

# TF=[]
# for i in range(0, N//2):
#     TF.append(pow(zeta, i, q)) # 预计算twiddle factor
# print("TF:",TF)
TF=[1, 17, 289, 1584, 296, 1703, 2319, 2804, 1062, 1409, 650, 1063, 1426, 939, 2647, 1722, 2642, 1637, 1197, 375, 3046, 1847, 1438, 1143, 2786, 756, 2865, 2099, 2393, 733, 2474, 2110, 2580, 583, 3253, 2037, 1339, 2789, 807, 403, 193, 3281, 2513, 2773, 535, 2437, 1481, 1874, 1897, 2288, 2277, 2090, 2240, 1461, 1534, 2775, 569, 3015, 1320, 2466, 1974, 268, 1227, 885, 1729, 2761, 331, 2298, 2447, 1651, 1435, 1092, 1919, 2662, 1977, 319, 2094, 2308, 2617, 1212, 630, 723, 2304, 2549, 56, 952, 2868, 2150, 3260, 2156, 33, 561, 2879, 2337, 3110, 2935, 3289, 2649, 1756, 3220, 1476, 1789, 452, 1026, 797, 233, 632, 757, 2882, 2388, 648, 1029, 848, 1100, 2055, 1645, 1333, 2687, 2402, 886, 1746, 3050, 1915, 2594, 821, 641, 910, 2154]
#------------------------- Naive In-place NTT --------------------------
# 位反序函数
def brv(x):
    """ Reverses a 7-bit number """
    return int(''.join(reversed(bin(x)[2:].zfill(n-1))), 2)

def In_place_NTT(a):
    """ In-place NTT """
    k = 1
    w=[]
    a_hat=a.copy()
    for i in range(1, n):      
        # print("stage:",i-1)
        m = 2**(n-i)
        for s in range(0, N,2*m):
            
            zeta1 = pow(zeta, brv(k), q)
            w.append(zeta1)
            k+=1
            for j in range(s,s+m):
                T =  zeta1 * a_hat[j+m] % q
                a_hat[j+m] = (a_hat[j] - T) % q
                a_hat[j]   = (a_hat[j] + T) % q
                # print("ie:",j,"io:",j+m,"k:",k-1)
        # print("stage:",i)
    # print("w:",w)
    return a_hat 

def op21(a):
    if a & 1 == 0:
        r = (a >> 1) % q
    else:
        r = ((a >> 1) + ((q + 1)>>1)) % q
    return r

def In_place_INTT(f):
    """ In-place INTT """
    k = 127
    a_hat=f.copy()
    for i in range(n-1, 0, -1):
        m = 2**(n-i)
        for s in range(0, N, 2*m):
            zeta1 = pow(zeta, brv(k), q)
            k-=1
            for j in range(s,s+ m):
                t = a_hat[j]
                a_hat[j] = op21(t + a_hat[j+m]) % q
                a_hat[j+m] = op21(zeta1*( a_hat[j+m]-t)) % q
    return a_hat

#naive PWM
def PWM(a_hat, b_hat):
    """ Pointwise multiplication """
    h_hat = [None]*N
    for i in range(0, N//2):
        a0 = a_hat[2*i]
        a1 = a_hat[2*i+1]
        b0 = b_hat[2*i]
        b1 = b_hat[2*i+1]
        gama = pow(zeta, 2*brv(i)+1, q)
        h_hat[2*i] =  (a1 * b1*gama + a0 * b0) % q
        h_hat[2*i+1] = (a0 * b1 + a1 * b0) % q
        
    return h_hat
#--------------------------CFNTT，无冲突内存映射-------------------------------
def conflict_free_map(a, N,offset,R, P,mode):
    """
    实现算法7:冲突自由内存映射方案
    
    参数:
        a (int): 旧地址（要映射的地址）
        N (int): 数据点总数(必须是2的幂)
        offset (int):bank的基地址偏移量,0或者1
        R (int): NTT的基数(radix,必须是2的幂)
        P (int): 并行蝶形单元数量
        mode: 0,原始映射, 1,将bI循环移位P个位置
    返回:
        tuple: (bank_index, bank_address)
    """
    d=P
    # 1. 计算bank数量 B = R × d
    B = R * d
    
    # 2. 计算总位数 T = log_r(N)（基数r=R，因为R是2的幂）
    T = int(log2(N))
    
    # 3. 计算bank编号的位数 M = log_r(B)
    M = int(log2(B))
    
    # 4. 计算步长位数 C = T - M
    C = T - M
    
    # 5. 将地址a表示为二进制
    a_bin = bin(a)[2:].zfill(T)
    
    # 6. 将地址分为高位部分和低位部分
    # 高位部分: [a_{T-1}, ..., a_{T-C}] (C位)
    # 低位部分: [a_{M-1}, ..., a_0] (M位)
    high_part = a_bin[:C] if C > 0 else ''
    low_part = a_bin[-M:] if M > 0 else ''
    
    # 7. 将低位部分转换为整数b
    b = int(low_part, 2) if low_part else 0
    
    # 8. 将高位部分转换为R进制（每log2(R)位一组）
    k = int(log2(R))
    if C % k != 0:
        # 高位部分位数需要是k的倍数，不足则补零
        padding = k - (C % k)
        high_part = '0' * padding + high_part
        C += padding
    
    # 9. 将高位部分分组并转换为R进制数字
    groups = [high_part[i:i+k] for i in range(0, len(high_part), k)]
    r_digits = [int(group, 2) for group in groups]
    # 10. 计算步数 SN = (b_{m-1} + b_{m-2} + ... + b_0) mod R
    SN = sum(r_digits) % R
    # 11. 计算bank索引 BI = (b + SN × d) mod B
    BI = (b + SN * d) % B
    
    if mode==1:
        # 将bI循环移位P个位置
        BI = (BI + P) % B
    else:
        # 直接使用计算得到的BI
        pass

    # 12. 计算bank地址 BA = 高位部分的整数值
    BA = int(high_part, 2)  if high_part else 0
    BA = BA + offset*N//(2*P)  # 添加偏移量
    return BI, BA


def conflict_free_map_inverse(BI, BA, N, R, d):
    """
    已知 bank_index(BI) 和 bank_address(BA)，逆推出原始地址 a
    """
    B = R * d
    T = int(log2(N))
    M = int(log2(B))
    C = T - M
    k = int(log2(R))

    # 1. 高位部分补齐到C位
    high_part = bin(BA)[2:].zfill(C) if C > 0 else ''
    
    # 2. 高位分组，转为R进制
    if C % k != 0:
        padding = k - (C % k)
        high_part = '0' * padding + high_part
        C += padding
    groups = [high_part[i:i+k] for i in range(0, len(high_part), k)]
    r_digits = [int(group, 2) for group in groups]
    
    # 3. 计算SN
    SN = sum(r_digits) % R

    # 4. 逆推出b
    # BI = (b + SN * d) % B  ==>  b = (BI - SN * d) % B
    b = (BI - SN * d) % B

    # 5. 低位部分补齐到M位
    low_part = bin(b)[2:].zfill(M) if M > 0 else ''

    # 6. 拼接高位和低位
    a_bin = high_part[-C:] + low_part  # high_part可能有补零，取最后C位
    a_bin = a_bin.zfill(T)  # 补齐到T位

    # 7. 转为十进制
    a = int(a_bin, 2)
    return a

#--------------------------多银行存储格式转换-------------------------------
def list_to_bank(A, N, P, mode):
    """
    将列表A转换为多银行存储格式
    输入:
        A: 列表,长度为N
        N: 多项式环的维度(必须是2的幂)
        P: 并行蝶形单元数量
    输出:
        bank_data: 多bank存储格式,二维数组,row--BI,col--BA
    """
    num_bank = 2 * P  # 假设bank数量为2*P
    bank_len = N // num_bank
    bank_data = [[0 for _ in range(bank_len)] for _ in range(num_bank)]
    for i in range(N):
        BI, BA = conflict_free_map(i, N, 0, 2, P, mode)
        bank_data[BI][BA] = A[i]
    return bank_data

def bank_to_list(bank_data, N, P):
    """
    将多bank二维数组格式转换回列表
    """
    num_bank = 2 * P
    bank_len = N // num_bank
    A = [0] * N
    for BI in range(num_bank):
        for BA in range(bank_len):
            a_index = conflict_free_map_inverse(BI, BA, N, 2, P)
            A[a_index] = bank_data[BI][BA]
    return A
#--------------------------多通道NTT和INTT实现-------------------------------
def parallel_NTT(bank,P=32,mode=0):
    """ Parallel NTT """
    v=N//2
    bank_hat=bank.copy()
    for i in range(0, n-1):
        # print("stage:",i)
        for s in range(0, v, P):
            # print("s:",s)
            for b in range(0,P//2):          #这层可以完全循环展开
                j0=(s+2*b)>>(n-1-i)          #获取s+b的高位
                k0=(s+2*b)&((v>>i)-1)        #获取s+b的低位
                j1=(s+2*b+1)>>(n-1-i)        #获取s+b的高位
                k1=(s+2*b+1)&((v>>i)-1)      #获取s+b的低位
                ie0=j0*(1<<(n-i))+k0         #通过位拼接实现
                io0=ie0+(1<<(n-i-1))         #同样通过位拼接实现，并且只需反转第n-i-1位
                iw0=j0+((1<<i))
                iw_brv0=brv(iw0)
                ie1=j1*(1<<(n-i))+k1         #通过位拼接实现
                io1=ie1+(1<<(n-i-1))         #同样通过位拼接实现，并且只需反转第n-i-1位
                iw1=j1+((1<<i))
                iw_brv1=brv(iw1)
                BI_e0,BA_e0=conflict_free_map(ie0, N, 0, 2, P, mode)
                BI_o0,BA_o0=conflict_free_map(io0, N, 0, 2, P, mode)
                BI_e1,BA_e1=conflict_free_map(ie1, N, 0, 2, P, mode)
                BI_o1,BA_o1=conflict_free_map(io1, N, 0, 2, P, mode)
                # print("b:",b,"j:",j,"k:",k,"ie:",ie,"io:",io,"iw:",iw)
                T0=TF[iw_brv0]*bank_hat[BI_o0][BA_o0]
                T1=TF[iw_brv1]*bank_hat[BI_o1][BA_o1]
                # print(f"bank_hat[{BI_e}][{BA_e}],{bank_hat[BI_e][BA_e]},bank_hat[{BI_o}][{BA_o}]: {bank_hat[BI_o][BA_o]},TF: {TF[iw_brv]}")
                bank_hat[BI_o0][BA_o0]=(bank_hat[BI_e0][BA_e0]-T0)%q
                bank_hat[BI_e0][BA_e0]=(bank_hat[BI_e0][BA_e0]+T0)%q
                bank_hat[BI_o1][BA_o1]=(bank_hat[BI_e1][BA_e1]-T1)%q
                bank_hat[BI_e1][BA_e1]=(bank_hat[BI_e1][BA_e1]+T1)%q
    return bank_hat

def parallel_INTT(bank,P=32,mode=0):
    """ parallel INTT """
    v=N//2
    bank_hat=bank.copy()
    for i in range(n-2, -1, -1):
        # print("stage:",i)
        for s in range(0, v, P):
            # print("s:",s)
            for b in range(0,P//2):#这层可以完全循环展开
                j0=(s+2*b)>>(n-1-i)
                k0=(s+2*b)&((v>>i)-1)
                j1=(s+2*b+1)>>(n-1-i)
                k1=(s+2*b+1)&((v>>i)-1)
                ie0=j0*(1<<(n-i))+k0  #低位索引
                io0=ie0+(1<<(n-i-1)) #高位索引
                iw0=(1<<(i+1))-1-j0
                iw_brv0=brv(iw0)
                ie1=j1*(1<<(n-i))+k1  #低位索引
                io1=ie1+(1<<(n-i-1)) #高位索引
                iw1=(1<<(i+1))-1-j1
                iw_brv1=brv(iw1)
                BI_e0,BA_e0=conflict_free_map(ie0, N, 0, 2, P, mode)
                BI_o0,BA_o0=conflict_free_map(io0, N, 0, 2, P, mode)
                BI_e1,BA_e1=conflict_free_map(ie1, N, 0, 2, P, mode)
                BI_o1,BA_o1=conflict_free_map(io1, N, 0, 2, P, mode)
                # print("b:",b,"j:",j0,"k:",k0,"ie:",ie0,"io:",io0,"iw:",iw0)
                t0 = bank_hat[BI_e0][BA_e0]
                t1 = bank_hat[BI_e1][BA_e1]
                # print(f"bank_hat[{BI_e0}][{BA_e0}],{bank_hat[BI_e0][BA_e0]},bank_hat[{BI_o0}][{BA_o0}]: {bank_hat[BI_o0][BA_o0]},TF: {TF[iw_brv0]}")
                bank_hat[BI_e0][BA_e0] = op21(t0 + bank_hat[BI_o0][BA_o0]) % q
                bank_hat[BI_o0][BA_o0] = op21(TF[iw_brv0]*( bank_hat[BI_o0][BA_o0]-t0)) % q
                bank_hat[BI_e1][BA_e1] = op21(t1 + bank_hat[BI_o1][BA_o1]) % q
                bank_hat[BI_o1][BA_o1] = op21(TF[iw_brv1]*( bank_hat[BI_o1][BA_o1]-t1)) % q
                # print(f"bank_hat[{BI_e0}][{BA_e0}],{bank_hat[BI_e0][BA_e0]},bank_hat[{BI_o0}][{BA_o0}]: {bank_hat[BI_o0][BA_o0]}")
                
    return bank_hat

#karatsuba PWM0,PWM1
def PWM0(a0,a1,b0,b1):
    s0 = (a0 + a1) % q
    s1 = (b0 + b1) % q
    m0 = (a0 * b0) % q
    m1 = (a1 * b1) % q
    return  s0,s1,m0,m1,

def PWM1(s0,s1,m0,m1,i):
    # h0 = (m0 + m1 * pow(zeta, 2*brv(i)+1, q)) % q
    index=(2*brv(i)+1)
    tw=TF[index & 0x7F]
    if index>>7: 
        tw=q-tw
    # print("tw:",tw)
    h0 = (m0 + m1 * tw) % q
    h1 = (s0 * s1-m0-m1) % q
    return h0, h1

def parallel_PWM(bank,P,N):
    """_summary_
    Args:
        P:并行数
        bank:bank_f||bank_g
    """
    #PWM0
    for i in range(N//(2*P)): #一个多项式在bank中的的行数
        # print("stage:",i)
        for k in range(2):
            # print("s:",k)
            for b in range(P//2): # P//2，PE组数，两个PE为一组，这层循环可以完全展开
                # print("b:",b,"ie:",2*b+k*P+i*2*P,"io:",2*b+k*P+i*2*P+1)
                BI_a0,BA_a0=conflict_free_map(2*b+k*P+i*2*P,   N, 0, 2, P, mode=0)
                BI_a1,BA_a1=conflict_free_map(2*b+1+k*P+i*2*P, N, 0, 2, P, mode=0)
                BI_b0,BA_b0=conflict_free_map(2*b+k*P+i*2*P,   N, 1, 2, P, mode=1)
                BI_b1,BA_b1=conflict_free_map(2*b+1+k*P+i*2*P, N, 1, 2, P, mode=1)
                a0=bank[BI_a0][BA_a0]
                a1=bank[BI_a1][BA_a1]
                b0=bank[BI_b0][BA_b0]
                b1=bank[BI_b1][BA_b1]
                # print(f"a0:{a0},a1:{a1},b0:{b0},b1:{b1}")
                bank[BI_a0][BA_a0],bank[BI_a1][BA_a1],bank[BI_b0][BA_b0],bank[BI_b1][BA_b1]=PWM0(a0,a1,b0,b1)
                # print(f"bank[{BI_a0}][{BA_a0}]:{bank[BI_a0][BA_a0]},bank[{BI_a1}][{BA_a1}]:{bank[BI_a1][BA_a1]},bank[{BI_b0}][{BA_b0}]:{bank[BI_b0][BA_b0]},bank[{BI_b1}][{BA_b1}]:{bank[BI_b1][BA_b1]}")
    # ploy_h_pwm0= bank_to_list(bank, N, P)
    # np.savetxt("./testbench_data/ploy_h_pwm0.txt",  ploy_h_pwm0, fmt="%d", delimiter=",")
    #PWM1
    for i in range(N//(2*P)): #一个多项式在bank中的的行数
        # print("stage:",i)
        for k in range(2):
            # print("s:",k)
            for b in range(P//2): # P//2，PE组数，两个PE为一组，这层循环可以完全展开
                # print("b:",b,"ie:",2*b+k*P+i*2*P,"io:",2*b+k*P+i*2*P+1)
                BI_s0,BA_s0=conflict_free_map(2*b+k*P+i*2*P,   N, 0, 2, P, mode=0)#s0
                BI_s1,BA_s1=conflict_free_map(2*b+1+k*P+i*2*P, N, 0, 2, P, mode=0)#s1
                BI_m0,BA_m0=conflict_free_map(2*b+k*P+i*2*P,   N, 1, 2, P, mode=1)#m0
                BI_m1,BA_m1=conflict_free_map(2*b+1+k*P+i*2*P, N, 1, 2, P, mode=1)#m1
                s0=bank[BI_s0][BA_s0]
                s1=bank[BI_s1][BA_s1]
                m0=bank[BI_m0][BA_m0]
                m1=bank[BI_m1][BA_m1]
                # print(f"s0:{s0},s1:{s1},m0:{m0},m1:{m1}")
                i_idx=b+k*P//2+i*P
                bank[BI_s0][BA_s0],bank[BI_s1][BA_s1]=PWM1(s0,s1,m0,m1,i_idx)
                # print(f"bank[{BI_s0}][{BA_s0}]:{bank[BI_s0][BA_s0]},bank[{BI_s1}][{BA_s1}]:{bank[BI_s1][BA_s1]}")
    return bank

##--------------------------Check RAW -------------------------
def check_raw(N,P,L):
  """
  N:NTT点长,N=2^n
  P:PE数量,P=2^k1
  L:流水线级数
  i: 第几个stage
  """
  n=int(log2(N))
  flag=0
  for i in range(n-1):
    t1=((N/(2*P)-L-1)*P)//2**(n-1-i) * 2**(n-i)+(N/(2*P)-L-1)*P%(2**(n-1-i))
    if t1>(1<<(n-2-i)) and N/(2*P)>L+1:
        flag+=0
    else:
        # print(f"Gi: {t1},Gi+1:{(1<<(n-2-i))},C:{N/(2*P)},L+1:{L+1},i:{i}")
        flag+=1
  return flag

def check_raw_example():
    """
    检查所有可能的kyber中P,L组合
    """
    P_list=[2**i for i in range(1,8)]  # PE数量列表
    L_list=[i for i in range(1,9)]    # 流水线级数列表
    N=256
    for P in P_list:
        for L in L_list:
            # print(f"N={N}, P={P}, L={L}")
            flag = check_raw(N, P, L)
            print(f"N={N}, P={P}, L={L} -> RAW冲突数量: {flag}")
                                                            
#--------------------------软件模型测试代码-------------------------------
def main():
    """
    num测试测试
    """
    num=100
    b = [0] * 256
    b[0] = 1
    fftb = In_place_NTT(b)
    
    bank_b = list_to_bank(b,N,P,mode=1) #g
    fftb_bank= parallel_NTT(bank_b,P,mode=1)
    # fftb1= bank_to_list(fftb_bank, N, P)
    for _ in range(0, num):
        f = []
        for i in range(256):
            f.append(random.randint(0, 3328))
            # f.append(i)
        ffta = In_place_NTT(f)
        # print("ffta:", ffta)
        
        bank_a = list_to_bank(f,N,P,mode=0)
        ffta_bank= parallel_NTT(bank_a,P,mode=0)
        # ffta1 = bank_to_list(ffta_bank, N, P)
        
        temp=PWM(ffta, fftb)
        product=In_place_INTT(temp)
        # print("product:", product)
        
        
        bank = np.hstack((ffta_bank, fftb_bank))
        # print("bank:",bank)
        temp1=parallel_PWM(bank,P,N)
        
        bank_temp= temp1[:, :temp1.shape[1]//2]  # 只取前半部分
        # print("bank_temp:", bank_temp)
        
        # bank_temp   = list_to_bank(temp1, N, P)
        product_bank = parallel_INTT(bank_temp, P)
        product1= bank_to_list(product_bank, N, P)
        if product != product1:
            print("product:",product)
            print("product1:",product1)
            print("error")
        else:
            # print("product:",product)
            # print("product1:",product1)
            print("pass")
            
            
#-------------------------------硬件测试数据bin文件生成-----------------------------------
#bank_to_bin
def save_bank_rows_as_bin(bank_input, prefix='bank_row'):
    for idx, row in enumerate(bank_input):
        filename = f"{prefix}_{idx}.bin"
        with open(filename, "w") as f:
            # 每个元素转为12位二进制字符串，拼接后写入一行
            for x in row:
                binary_row = ''.join(format(x & 0xFFF, '012b'))
                f.write(binary_row + '\n')
        print(f"Binary file written to {filename}")
        
def write_binary_file_res(filename, matrix):
    """
    将有符号整数矩阵转换为二进制格式并写入文件。
    参数:
    - filename: 输出的 .bin 文件名
    - matrix: 输入的有符号整数矩阵 (numpy array)
    """
    with open(filename, "w") as f:
        for row in matrix:
            # 将每个元素转换为12位二进制字符串
            binary_row = ''.join([format(x & 0xFFF, '012b') for x in row])
            # 写入文件
            f.write(binary_row + '\n')
    print(f"Binary file written to {filename}")
        
        
def TF_ROM_data(P):
    """_summary_
    Args:
        P: PE数量
    Returns:
        TF_ROM: twiddle factor ROM数据
    """
    col = P  
    row = 2*N*7//(2*P)+N//P
    TF_ROM_data = [[0 for _ in range(col)] for _ in range(row)]
    #NTT
    for i in range(0, n-1):
        for s in range(0, N//2, P):
            for b in range(0,P):     
                j=(s+b)>>(n-1-i)     
                iw=j+((1<<i))
                iw_brv=brv(iw)
                cnt=(i*(N//2)//P)+(s//P)
                TF_ROM_data[cnt][b]=TF[iw_brv]
    #INTT
    for i in range(n-2, -1, -1):
        for s in range(0, N//2, P):
            for b in range(0,P):
                j=(s+b)>>(n-1-i)
                iw=(1<<(i+1))-1-j
                iw_brv=brv(iw)
                cnt=(i*(N//2)//P)+(s//P)+(n-1)*(N//(2*P))
                TF_ROM_data[cnt][b]=TF[iw_brv]
    # PWM1 
    for i in range(N//(2*P)): 
        for k in range(2):
            for b in range(P//2): # P//2，PE组数，两个PE为一组，这层循环可以完全展开
                i_idx=b+k*P//2+i*P
                index=2*brv(i_idx)+1
                tw=TF[index & 0x7F]
                if index>>7: 
                    tw=q-tw
                cnt=2*i+k+2*(n-1)*(N//(2*P))
                TF_ROM_data[cnt][2*b+1]=tw
    return TF_ROM_data
                
    
def generate_test_data():
    """
    生成测试数据
    """
    # 清除 ./testbench_data/ 目录下的所有文件
    testbench_dir = './testbench_data/'
    
    # 确保目录存在
    if os.path.exists(testbench_dir):
        # 列出目录中的所有文件并删除
        for filename in os.listdir(testbench_dir):
            file_path = os.path.join(testbench_dir, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                print(f'清除文件 {file_path} 时出错：{e}')
        print(f"已清除 {testbench_dir} 目录下的所有文件")
    else:
        # 如果目录不存在，创建它
        os.makedirs(testbench_dir)
        print(f"创建了 {testbench_dir} 目录")
    
    # 生成多项式g,f
    g = [0] * 256
    g[0] = 1
    np.savetxt("./testbench_data/ploy_g.txt", g, fmt="%d", delimiter=",")
    f = []
    for i in range(256):
        f.append(i)
    np.savetxt("./testbench_data/ploy_f.txt", f, fmt="%d", delimiter=",")
    
    #将多项式g，f转换为多bank存储格式,并写入bin
    bank_f= list_to_bank(f,N,P,mode=0) #f
    bank_g= list_to_bank(g,N,P,mode=1) #g
    bank_input = np.hstack((bank_f, bank_g))
    save_bank_rows_as_bin(bank_input, prefix="./testbench_data/bank_input")
    
    bank_g = list_to_bank(g,N,P,mode=1) #g
    g_hat_bank= parallel_NTT(bank_g,P,mode=1)
    ploy_g_hat= bank_to_list(g_hat_bank, N, P)
    np.savetxt("./testbench_data/ploy_g_hat.txt", ploy_g_hat, fmt="%d", delimiter=",")

    bank_f = list_to_bank(f,N,P,mode=0)
    f_hat_bank= parallel_NTT(bank_f,P,mode=0)
    ploy_f_hat= bank_to_list(f_hat_bank, N, P)
    np.savetxt("./testbench_data/ploy_f_hat.txt", ploy_f_hat, fmt="%d", delimiter=",")

    bank = np.hstack((f_hat_bank, g_hat_bank))
    temp1=parallel_PWM(bank,P,N)
    h_hat_bank= temp1[:, :temp1.shape[1]//2]  # 只取前半部分
    ploy_h_hat= bank_to_list(h_hat_bank, N, P)
    np.savetxt("./testbench_data/ploy_h_hat.txt",  ploy_h_hat, fmt="%d", delimiter=",")

    h_bank = parallel_INTT(h_hat_bank, P)
    ploy_h= bank_to_list(h_bank, N, P)
    np.savetxt("./testbench_data/ploy_h.txt", ploy_h, fmt="%d", delimiter=",")
    
    #TF_ROM数据
    TF_ROM  = TF_ROM_data(P)
    np.savetxt("./testbench_data/TF_ROM.txt", TF_ROM, fmt="%d", delimiter=",")
    write_binary_file_res("./testbench_data/TF_ROM.bin", TF_ROM)

def conflict_free_map_test():
    print("Addr",0, "PE",4,"mode",0,"offset", 0,   conflict_free_map(0,  256,0, 2, 4, 0))
    print("Addr",52,"PE",4,"mode",0,"offset",0,   conflict_free_map(52, 256,0, 2, 4, 0))
    print("Addr",0, "PE",4,"mode", 0,"offset",1,   conflict_free_map(0,  256,1, 2, 4, 0))
    print("Addr",52,"PE",4,"mode",0,"offset",1,   conflict_free_map(52, 256,1, 2, 4, 0))
    print("Addr",0, "PE",4, "mode",1,"offset", 0,  conflict_free_map(0,  256,0, 2, 4, 1))
    print("Addr",52,"PE",4,"mode",1,"offset",0,   conflict_free_map(52, 256,0, 2, 4, 1))

#-------------------------------数据对比-----------------------------------
def compare_results(bank_file_prefix="./testbench_data/bank", reference_file="./testbench_data/ploy_f_hat.txt", P=2, N=256):
    """
    比较bank文件和参考文件中的数据是否匹配
    
    参数:
        bank_file_prefix: bank文件的前缀路径,如"./testbench_data/bank"
        reference_file: 参考文件的路径，如"./testbench_data/ploy_f_hat.txt"
        P: 并行蝶形单元数量
        N: 多项式环的维度
    """
    # 读取 bank0_result.txt 到 bank2P_result.txt
    bank = []
    for i in range(2*P):
        filename = f"{bank_file_prefix}_{i}.txt"
        try:
            # 假设文件中每行一个数字
            with open(filename, 'r') as f:
                row = [int(line.strip()) for line in f if line.strip()]
                bank.append(row)
            print(f"成功读取 {filename}")
        except Exception as e:
            print(f"读取 {filename} 出错: {e}")
            return
    
    # 将二维数组转为一维列表
    result_list = bank_to_list(bank, N, P)
    
    # 读取参考文件作为对比
    try:
        with open(reference_file, 'r') as f:
            # 尝试按行读取
            content = f.read().strip()
            # 检查是否包含逗号（逗号分隔格式）
            if ',' in content:
                reference = [int(x.strip()) for x in content.split(',') if x.strip()]
            else:
                # 否则按行分隔
                reference = [int(x.strip()) for x in content.splitlines() if x.strip()]
        print(f"成功读取 {reference_file}")
    except Exception as e:
        print(f"读取 {reference_file} 出错: {e}")
        return
    
    # 对比两个列表
    if len(result_list) != len(reference):
        print(f"长度不匹配: result={len(result_list)}, reference={len(reference)}")
        return
    
    all_match = True
    print("result_list:", result_list[:10], "...") # 只打印前10个元素
    print("reference:", reference[:10], "...")    # 只打印前10个元素
    for i, (a, b) in enumerate(zip(result_list, reference)):
        if a != b:
            print(f"不匹配 位置 {i}: result={a}, reference={b}")
            all_match = False
            break
    
    if all_match:
        print("Success! 所有数据完全匹配")
    else:
        print("Failed! 数据不匹配")

          
if __name__ == '__main__':
    # main()                 #测试算法模型
    # print("test over")
    generate_test_data()     #生成测试数据
    # check_raw_example()    #检查RAW冲突数量
    # conflict_free_map_test() #测试冲突自由映射

    # 对比
    # compare_results("./testbench_data/bankf", "./testbench_data/ploy_f_hat.txt"  ,P)
    # compare_results("./testbench_data/bankg", "./testbench_data/ploy_g_hat.txt"  ,P)
    # compare_results("./testbench_data/bankhat", "./testbench_data/ploy_h_hat.txt",P)
    # compare_results("./testbench_data/bankh", "./testbench_data/ploy_h.txt"      ,P)