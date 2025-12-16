"""
@Descripttion: test Various reduction
@version: V1.0
@Author: HZW
@Date: 2025-03-27 20:00
"""

import math
import numpy as np
'''
N:NTT的数组点长,N=2^n
S:步长,S=2^s
Q:蝶形单元数量或者存储单元数量,Q=2^q
'''

#---Conflict-free parallel memory access scheme for FFT processors
def stride_permulation(N, S):
    mask=N-1
    shift= int(math.log2(N))
    for i in range(N):
        print("i=",i,"PNS=",((i * S) & mask) + ((i * S)>>shift))

# list= [2**i for i in range(5)]
# print("list=", list)
# for i in list:
#     print("Step=", i)      
#     stride_permulation(32, i)
    
    
def lnq(n,q,i):
    return (n+q-math.gcd(q,n%q)-i-1)//q


def conflict_free_address_scheme(N, Q, address):
    """
    计算冲突无关的并行内存访问方案中的模块地址(m)和行地址(r)
    
    参数:
        N (int): 点长 (必须是2的幂)
        Q (int): 存储体(bank)数量 (必须是2的幂)
        address (int): 输入地址 (0 到 N-1)
    
    返回:
        tuple: (module, row) - 模块地址和行地址
    """
    # 计算n和q: N=2^n, Q=2^q
    n = int(np.log2(N))
    q = int(np.log2(Q))
    
    bin_str = bin(address)[2:].zfill(n)
    a = [int(bit) for bit in bin_str]  # a[0]是MSB，a[n-1]是LSB
    a=a[::-1]  # 反转以便a[0]是LSB，a[n-1]是MSB
    

    r_bits = []
    for i in range(0, n - q):
        r_bits.append(str(a[i+q]))
    row = int(''.join(r_bits[::-1]), 2) if r_bits else 0
    
    m_bits = []
    if q > 0:  # 当q=0时，只有一个存储体，模块地址为0
        for i in range(q):
            n_mod_q = n % q
            gcd_val = math.gcd(q, n_mod_q) if n_mod_q != 0 else q
            numerator = n + q - gcd_val - i - 1
            l = numerator // q  
            
            # 计算m_i = XOR_{j=0}^{l} a[(j*q + i) mod n]
            xor_val = 0
            for j in range(0, l + 1):
                index = (j * q + i) % n
                xor_val ^= a[index]
            m_bits.append(str(xor_val))
        module = int(''.join(m_bits[::-1]), 2)
    else:
        module = 0
    
    return module, row


def scheme(N, Q):
    print(f"\n测试 N={N} (n={int(np.log2(N))}), Q={Q} (q={int(np.log2(Q))})")
    for addr in range(N):
        module, row = conflict_free_address_scheme(N, Q, addr)
        bin_addr = bin(addr)[2:].zfill(int(np.log2(N)))
        print(f"地址 {addr} ({bin_addr}): 模块={module}, 行={row}")


#CFNTT: Scalable Radix-2/4 NTT Multiplication Architecture with an Efficient Conflict-free Memory Mapping Scheme
def conflict_free_mapping(a, N,offset, R, P,mode):
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
    T = int(math.log2(N))
    
    # 3. 计算bank编号的位数 M = log_r(B)
    M = int(math.log2(B))
    
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
    k = int(math.log2(R))
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
    T = int(math.log2(N))
    M = int(math.log2(B))
    C = T - M
    k = int(math.log2(R))

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


if __name__ == "__main__":
    # scheme(16,4)
    # stride_permulation(N=32, S=1)
    # stride_permulation(N=32, S=2)
    # stride_permulation(N=32, S=4)
    # stride_permulation(N=32, S=8)
    # stride_permulation(N=32, S=16)
    # q=int(math.log2(16))
    # n=int(math.log2(256))
    # for i in range(q):
    #     print("i:",i,"hnm(i):",lnq(n,q,i))
    
    
    # # 测试用例1: r=2, R=4, d=1, N=16
    # print("Test case 1: r=2, R=4, d=1, N=16")
    # for a in range(32):
    #     # BI, BA = conflict_free_mapping(a, 32, 2, 2, 2)
    #     a4 = (a >> 4) & 1
    #     a3 = (a >> 3) & 1
    #     a2 = (a >> 2) & 1
    #     a1 = (a >> 1) & 1
    #     a0 = a & 1
    #     BA=a>>2
    #     BI=(((a4+a3+a2)%2)*2+2*a1+a0)%4
    #     print(f"a={a:2d} -> BI={BI}, BA={BA}")
        
        

    N=256
    d=2
    for a in range(N):
        BI, BA = conflict_free_mapping(a, N, 0, 2, d,mode=0)
        print(f"a={a:2d} -> BI={BI}, BA={BA}")
        # a_index = conflict_free_map_inverse(BI, BA, N, 2, d)
        # print(f"映射后的索引: {a_index==a}")
        
    
    
# def DIT_NTT(N):
#     """ In-place NTT """
#     r = 1
#     for p in range(int(math.log2(N))-1,-1,-1):      
#         J = 2**p
#         for k in range(0,int(N/(2*J))):
#             r+=1
#             for j in range(J):
#                 print("ie:",2*k*J+j,"io:",2*k*J+j+J,"k:",k)
#         print("stage:",p)
        
# DIT_NTT(8)
