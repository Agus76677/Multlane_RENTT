"""
@Descripttion: Parallel NTT and INTT implementation with in-place transformation
@version: V1.0
@Author: HZW
@Date: 2025-03-27 20:00
"""

from time import perf_counter
import pandas as pd
import random
from math import log2


q = 3329     # 模数
nBits = 8   
zeta = 17    # NTT变换中使用的单位根

n = 2**nBits  # 多项式环的维度（256）
inv2 = 3303  # inverse of 2
# TF=[]
# for i in range(0, n//2):
#     TF.append(pow(zeta, i, q)) # 预计算twiddle factor
# print("TF:",TF)
TF=[1, 17, 289, 1584, 296, 1703, 2319, 2804, 1062, 1409, 650, 1063, 1426, 939, 2647, 1722, 2642, 1637, 1197, 375, 3046, 1847, 1438, 1143, 2786, 756, 2865, 2099, 2393, 733, 2474, 2110, 2580, 583, 3253, 2037, 1339, 2789, 807, 403, 193, 3281, 2513, 2773, 535, 2437, 1481, 1874, 1897, 2288, 2277, 2090, 2240, 1461, 1534, 2775, 569, 3015, 1320, 2466, 1974, 268, 1227, 885, 1729, 2761, 331, 2298, 2447, 1651, 1435, 1092, 1919, 2662, 1977, 319, 2094, 2308, 2617, 1212, 630, 723, 2304, 2549, 56, 952, 2868, 2150, 3260, 2156, 33, 561, 2879, 2337, 3110, 2935, 3289, 2649, 1756, 3220, 1476, 1789, 452, 1026, 797, 233, 632, 757, 2882, 2388, 648, 1029, 848, 1100, 2055, 1645, 1333, 2687, 2402, 886, 1746, 3050, 1915, 2594, 821, 641, 910, 2154]
    
# TF=[1729, 2580, 3289, 2642, 630, 1897, 848, 1062, 1919, 193, 797, 2786, 3260, 569, 1746, 296, 2447, 1339, 1476, 3046, 56, 2240, 1333, 1426, 2094, 535, 2882, 2393, 2879, 1974, 821, 289, 331, 3253, 1756, 1197, 2304, 2277, 2055, 650, 1977, 2513, 632, 2865, 33, 1320, 1915, 2319, 1435, 807, 452, 1438, 2868, 1534, 2402, 2647, 2617, 1481, 648, 2474, 3110, 1227, 910, 17, 2761, 583, 2649, 1637, 723, 2288, 1100, 1409, 2662, 3281, 233, 756, 2156, 3015, 3050, 1703, 1651, 2789, 1789, 1847, 952, 1461, 2687, 939, 2308, 2437, 2388, 733, 2337, 268, 641, 1584, 2298, 2037, 3220, 375, 2549, 2090, 1645, 1063, 319, 2773, 757, 2099, 561, 2466, 2594, 2804, 1092, 403, 1026, 1143,2150, 2775, 886, 1722, 1212, 1874, 1029, 2110, 2935, 885, 2154]


# 位反序函数
def brv(x):
    """ Reverses a 7-bit number """
    return int(''.join(reversed(bin(x)[2:].zfill(nBits-1))), 2)

def log_base(x, base):
    """
    计算以2的幂次为底的对数
    :param x: 被取对数的数
    :param base: 底(必须为2的幂次)
    :return: 对数值
    """
    if base & (base - 1) != 0 or base <= 1:
        raise ValueError("base 必须为大于1的2的幂次")
    return int(log2(x) / log2(base))


def In_place_NTT(a):
    """ In-place NTT """
    k = 1
    w=[]
    a_hat=a.copy()
    for i in range(1, nBits):      
        # print("stage:",i-1)
        m = 2**(nBits-i)
        for s in range(0, n,2*m):
            
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
    for i in range(nBits-1, 0, -1):
        m = 2**(nBits-i)
        for s in range(0, n, 2*m):
            zeta1 = pow(zeta, brv(k), q)
            k-=1
            for j in range(s,s+ m):
                t = a_hat[j]
                a_hat[j] = op21(t + a_hat[j+m]) % q
                a_hat[j+m] = op21(zeta1*( a_hat[j+m]-t)) % q
  
    return a_hat


def PWM(a_hat, b_hat):
    """ Pointwise multiplication """
    h_hat = [None]*n
    for i in range(0, n//2):
        a0 = a_hat[2*i]
        a1 = a_hat[2*i+1]
        b0 = b_hat[2*i]
        b1 = b_hat[2*i+1]
        gama = pow(zeta, 2*brv(i)+1, q)
        h_hat[2*i] =  (a1 * b1*gama + a0 * b0) % q
        h_hat[2*i+1] = (a0 * b1 + a1 * b0) % q
        
    return h_hat

# # twiddle factor
def In_place_NTT_print():
    """ In-place NTT """
    k = 1
    c_loop=0
    for i in range(1, nBits):
        m = 2**(nBits-i)
        print("stage:",i-1)
        
        for s in range(0, n,2*m):
            
            zeta1 = pow(zeta, brv(k), q)
            c_tw=k
            # print("tw_h:",hex(zeta1),"k:",k, "brv(k):",brv(k), "tw:",zeta1)
         
            for j in range(s,s+ m):
                print("j:",j,"k:",k-1,"ie:",j,"io:",j+m,"iw:",brv(k))
                # c_loop+=1
            k+=1
                
            
            
def In_place_INTT_print():
    """ In-place INTT """
    k = 127
    for i in range(nBits-1, 0, -1):
        m = 2**(nBits-i)
        print("stage:",7-i)
        for s in range(0, n, 2*m):
            print("s:",s)
            for j in range(s,s+ m):
                print("j:",j,"k:",k-1,"ie:",j,"io:",j+m,"iw:",brv(k))
            k-=1

#----CFNTT: Scalable Radix-2/4 NTT Multiplication Architecture with an Efficient Conflict-free Memory Mapping Scheme
def scalable_NTT(a, n, R,d):
    """
    :param a: 输入多项式系数列表
    :param n: 多项式环的维度(必须是2的幂)
    :param R: 基数 (R = r^k, r是素数)
    :param d: 并行蝶形单元数/步长
    :return: NTT变换后的系数列表
    """
    for p in range(log_base(n,R)-1,-1,-1):
        print("stage:",p)
        J=R**p
        if J<d:
            for k in range(int(n/(R*d))):
                print("k:",k)
                for i in range(int(d/J)):
                    for j in range(J):
                        print("k",k,"i:",i,"j:",j,"ie:",k*R*d+i*R*J+j,"io:",k*R*d+i*R*J+j+J)
        else:
            for k in range(int(n/(R*J))):
                print("k:",k)
                for i in range(int(J/d)):
                    for j in range(d):
                        print("k",k,"i:",i,"j:",j,"ie:",k*R*J+i*d+j,"io:",k*R*J+i*d+j+J)
                      


#-----------------my parallel NTT-------------------    
def parallel_NTT(A):
    """ Parallel NTT """
    l=nBits
    v=n//2
    B=32
    j=[0]*B
    k=[0]*B
    ie=[0]*B
    io=[0]*B
    iw=[0]*B
    T=[0]*B
    A_hat=A.copy()
    for i in range(0, l-1):
        # print("stage:",i)
        for s in range(0, v, B):
            # print("s:",s)
            for b in range(0,B):
                j[b]=(s+b)>>(l-1-i)
                k[b]=(s+b)&((v>>i)-1)
                ie[b]=j[b]*(1<<(l-i))+k[b]
                io[b]=ie[b]+(1<<(l-i-1))
                iw[b]=j[b]+((1<<i)-1)
                # print("b:",b,"j:",j[b],"k:",k[b],"ie:",ie[b],"io:",io[b],"iw:",iw[b])
            
            for b in range(0,B):
                T[b]=TF[iw[b]]*A_hat[io[b]]
                A_hat[io[b]]=(A_hat[ie[b]]-T[b])%q
                A_hat[ie[b]]=(A_hat[ie[b]]+T[b])%q
    
    return A_hat

def parallel_NTT1(A,B=32):
    """ Parallel NTT """
    l=nBits
    v=n//2
    A_hat=A.copy()
    for i in range(0, l-1):
        print("stage:",i)
        for s in range(0, v, B):
            print("s:",s)
            for b in range(0,B):
                j=(s+b)>>(l-1-i)      #获取s+b的高位
                k=(s+b)&((v>>i)-1)    #获取s+b的低位
                ie=j*(1<<(l-i))+k     #通过位拼接实现
                io=ie+(1<<(l-i-1))    #同样通过位拼接实现，并且只需反转第l-i-1位
                iw=j+((1<<i))
                iw_brv=brv(iw)
                print("b:",b,"j:",j,"k:",k,"ie:",ie,"io:",io,"iw:",iw)
                T=TF[iw_brv]*A_hat[io]
                A_hat[io]=(A_hat[ie]-T)%q
                A_hat[ie]=(A_hat[ie]+T)%q
                print(f"A_hat[{ie}]: {A_hat[ie]}, A_hat[{io}]: {A_hat[io]}, TF: {TF[iw_brv]}")
    return A_hat

def parallel_INTT(A,B=32):
    """ parallel INTT """
    l=nBits
    v=n//2
    A_hat=A.copy()
    for i in range(l-2, -1, -1):
        print("stage:",6-i)
        for s in range(0, v, B):
            print("s:",s)
            for b in range(0,B):
                j=(s+b)>>(l-1-i)
                k=(s+b)&((v>>i)-1)
                ie=j*(1<<(l-i))+k
                io=ie+(1<<(l-i-1))
                iw=(1<<(i+1))-1-j
                iw_brv=brv(iw)
                # print("b:",b,"j:",j,"k:",k,"ie:",ie,"io:",io,"iw:",iw)
                t = A_hat[ie]
                A_hat[ie] = op21(t + A_hat[io]) % q
                A_hat[io] = op21(TF[iw_brv]*( A_hat[io]-t)) % q
    return A_hat


def parallel_NTT1_to_excel(A, B=32, output_file="io_ie_data.xlsx"):
    """ Parallel NTT with io and ie saved to Excel """
    l = nBits
    v = n // 2
    A_hat = A.copy()
    data = []  # 用于存储 io 和 ie 的数据

    for i in range(0, l-1):
        # print("stage:", i)
        for s in range(0, v, B):
            # print("s:", s)
            for b in range(0, B):
                j = (s + b) >> (l - 1 - i)
                k = (s + b) & ((v >> i) - 1)
                ie = j * (1 << (l - i)) + k
                io = ie + (1 << (l - i - 1))
                iw = j + ((1 << i))
                iw_brv = brv(iw)
                T = TF[iw_brv] * A_hat[io]
                A_hat[io] = (A_hat[ie] - T) % q
                A_hat[ie] = (A_hat[ie] + T) % q
                # print("b:", b, "j:", j, "k:", k, "ie:", ie, "io:", io, "iw_brv:", iw_brv,"data_tw:", TF[iw_brv],"A_hat[io]:",  A_hat[io], "A_hat[ie]:", A_hat[ie])

                # 将 io 和 ie 的值存储到 data 列表中
                data.append({"stage": i, "s": s, "b": b, "ie": ie, "io": io})

    # 将数据写入 Excel 文件
    df = pd.DataFrame(data)
    df.to_excel(output_file, index=False)
    print(f"Data saved to {output_file}")

    return A_hat

#--------------------------Check RAW -------------------------
PE=8
L=4
N=256
for i in range(7):
    ie=((N/(2*PE)-L-1)*PE)//2**(7-i) * 2**(8-i)+(N/(2*PE)-L-1)*PE%(2**(7-i))
    print("i:",i,"ie:",ie)
    
    
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
        print(f"Gi: {t1},Gi+1:{(1<<(n-2-i))},C:{N/(2*P)},L+1:{L+1},i:{i}")
        flag+=1
  return flag

#-Rethinking Parallel Memory Access Pattern in Number Theoretic Transform Design
def check_raw_other(N,P,L):
    flag=0
    if(N/(4*P)+L+1<N/(2*P)):
        flag+=0 
    else:
        flag+=1
    return flag

# P_list=[2**i for i in range(1,7)]  # PE数量列表
# L_list=[i for i in range(1,9)]     # 流水线级数列表
# N=256
# for P in P_list:
#     for L in L_list:
#         print(f"N={N}, P={P}, L={L}")
#         flag = check_raw(N, P, L)
#         flag_other = check_raw_other(N, P, L)
#         print(f"N={N}, P={P}, L={L} -> RAW冲突数量: {flag}, -> 其他方法冲突数量: {flag_other}")
#
        

#-------------------------------main------------------------------

def main1():
    # print("---------------------------------NTT_index------------------------------")
    # In_place_NTT_print()
    # print("---------------------------------INTT_index------------------------------")
    # In_place_INTT_print()

    f = []
    for i in range(256):
        f.append(i)
    hex_string1 = ''.join([format(x, '03X') for x in reversed(f[0:128])])
    print("拼接后的16进制字符串:", hex_string1)
    hex_string2 = ''.join([format(x, '03X') for x in reversed(f[128:])])
    print("拼接后的16进制字符串:", hex_string2)
    b = [0] * 256
    b[0] = 1

    print("f:",f)
    t0 = perf_counter()
    ffta = In_place_NTT(f)
    print("NTT time:",perf_counter() - t0)
    print("ffta = ",ffta)
    
    t0 = perf_counter()
    A = In_place_INTT(ffta)
    print("INTT time:",perf_counter() - t0)
    print("A = ",A)

    
    t0 = perf_counter()
    fftA = parallel_NTT1(f,2)
    print("parallel_NTT time:",perf_counter() - t0)
    print("fftA = ",fftA)
    hex_string1 = ''.join([format(x, '03X') for x in reversed(fftA[0:128])])
    print("拼接后的16进制字符串:", hex_string1)
    hex_string2 = ''.join([format(x, '03X') for x in reversed(fftA[128:])])
    print("拼接后的16进制字符串:", hex_string2)
    
    t0 = perf_counter()
    A = parallel_INTT(fftA,2)
    print("parallel_INTT time:",perf_counter() - t0)
    print("A = ",A)
    
    
    # scalable_NTT(f,256,2,8)
    
    # for B in range(0,7):
    #     t0 = perf_counter()
    #     fftB = parallel_NTT1(f,1<<B)
    #     print("core number:",B, "parallel_NTT1 time:",perf_counter() - t0)
    #     print("fftB = ",fftB)


    fftb = In_place_NTT(b)
    print("fftb = ",fftb)

    # t1 = perf_counter()
    # temp=PWM(ffta, fftb)
    # print("PWM time:",perf_counter() - t1)

    # t2 = perf_counter()
    # fftc=In_place_INTT(temp)
    # print("INTT time:",perf_counter() - t2)
    # print("fftc = ",fftc)
    
# for i in range(0, n//2):
#     gama = pow(zeta, 2*brv(i)+1, q)
#     # gama1 = 3329-pow(zeta, brv(i), q)
#     print("i:",i,"2*brv(i):",2*brv(i)+1,"brv(i):",brv(i))

def main():
    """
    N测试测试
    """
    N=1000
    b = [0] * 256
    b[0] = 1
    fftb = In_place_NTT(b)
    fftb1= parallel_NTT1(b)
    for _ in range(0, N):
        f = []
        for i in range(256):
            f.append(random.randint(0, 3328))
        ffta = In_place_NTT(f)
        ffta1= parallel_NTT1(f)
        temp=PWM(ffta, fftb)
        temp1=PWM(ffta1, fftb1)
        product=In_place_INTT(temp)
        product1=parallel_INTT(temp1)
        if product != product1:
            print("product:",product)
            print("product1:",product1)
            print("error")
        else:
            print("pass")


if __name__ == '__main__':
    main1()
#     # main()
#     # print("test over")