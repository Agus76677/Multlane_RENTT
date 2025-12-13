"""
@Descripttion: Mixed Radix NTT implementation
@version: V1.0
@Author: HZW
@Date: 2025-06-13 11:00
"""

#---Hardware Architecture for CRYSTALS-Kyber With a Novel Conflict-Free Memory Access Pattern
import numpy as np

# =============================================
# 算法2: KCF-MM (Conflict-Free Memory Mapping)
# =============================================
def kcf_mm(BN, IBN, index, mode):
    """
    KCF-MM内存映射算法
    输入:
        BN: Bank Number (0,1,2)
        IBN: In-Bank Number (区域号)
        index: 8位索引 (0-255)
        mode: 模式标志 (0或1)
    输出:
        (BNr, IBNr, CN, addr): 映射后的地址元组
    """
    BNr = BN
    IBNr = IBN
    tmpAddr = index >> 1        # 右移1位 (相当于除以2)
    tmpMsb = index & 1          # 获取最低有效位
    # print(f"BNr={BNr}, IBNr={IBNr}, tmpAddr={tmpAddr}, tmpMsb={tmpMsb}")
    # 计算addr: (tmpMsb << 5) + (tmpAddr >> 2)
    addr = (tmpMsb << 5)+(tmpAddr >> 2)
    
    # 计算tmpCn (4次循环累加)
    tmpCn = 0
    temp = tmpAddr
    for _ in range(4):
        tmpCn += temp & 3       # 取最后2位
        temp >>= 2              # 右移2位
    
    # 加入tmpMsb的影响
    tmpCn += (tmpMsb << 1)
    # 模式调整
    if mode != 0:
        tmpCn += 1
    
    # 计算列号 (取模4)
    CN = tmpCn & 3
    return (BNr, IBNr, CN, addr)


# =============================================
# 算法3: 写入错误多项式
# =============================================
def write_error_poly(s_coeffs, BN, IBN, mode):
    """
    将错误多项式写入Bank0/Bank1
    输入:
        s_coeffs: 多项式系数列表 (256个元素)
        BN: Bank Number
        IBN: In-Bank Number
        mode: 模式标志
    """
    # 初始化内存 (模拟)
    memory = {}
    # 处理64组数据 (每组4个系数)
    for i in range(64):
        indices = []
        data = []
        
        # 生成当前组的4个索引和对应数据
        for k in range(4):
            index_val = 4 * i + k
            # BRAR2N转换 (简化模拟)
            converted_index = index_val  # 实际实现需位反转
            
            # 使用KCF-MM计算内存地址
            Tk = kcf_mm(BN, IBN, converted_index, mode)
            indices.append(Tk)
            data.append(s_coeffs[index_val])
        
        # 写入内存 (模拟)
        for idx, d in zip(indices, data):
            memory[idx] = d
    
    return memory


def BR4R2N(addr):
    """
    将正常顺序地址转换为 radix-4 位反转顺序 (BR4R2N)
    输入: 8位地址 (a7, a6, a5, a4, a3, a2, a1, a0)
    输出: (a1, a3, a2, a5, a4, a7, a6, a0)
    """
    # 提取输入地址的每个比特位
    a7 = (addr >> 7) & 1
    a6 = (addr >> 6) & 1
    a5 = (addr >> 5) & 1
    a4 = (addr >> 4) & 1
    a3 = (addr >> 3) & 1
    a2 = (addr >> 2) & 1
    a1 = (addr >> 1) & 1
    a0 = addr & 1
    
    # 按BR4R2N规则重新组合比特位
    result = (
        (a1 << 7) |  # 新bit7 = a1
        (a3 << 6) |  # 新bit6 = a3
        (a2 << 5) |  # 新bit5 = a2
        (a5 << 4) |  # 新bit4 = a5
        (a4 << 3) |  # 新bit3 = a4
        (a7 << 2) |  # 新bit2 = a7
        (a6 << 1) |  # 新bit1 = a6
        a0           # 新bit0 = a0
    )
    return result


def BR2(addr):
    """
    将正常顺序地址转换为 radix-4 位反转顺序 (BR4R2N)
    输入: 8位地址 (a7, a6, a5, a4, a3, a2, a1, a0)
    输出: (a1, a3, a2, a5, a4, a7, a6, a0)
    """
    # 提取输入地址的每个比特位
    a7 = (addr >> 7) & 1
    a6 = (addr >> 6) & 1
    a5 = (addr >> 5) & 1
    a4 = (addr >> 4) & 1
    a3 = (addr >> 3) & 1
    a2 = (addr >> 2) & 1
    a1 = (addr >> 1) & 1
    a0 = addr & 1
    
    # 按BR2规则重新组合比特位
    result = (
        (a1 << 7) |  
        (a2 << 6) |  
        (a3 << 5) |  
        (a4 << 4) |  
        (a5 << 3) |  
        (a6 << 2) |  
        (a7 << 1) |  
        a0           
    )
    return result



def write_error_poly_address(BN, IBN, index, mode):
    """
    将错误多项式写入Bank0/Bank1
    输入:
        BN: Bank Number
        IBN: In-Bank Number
        mode: 模式标志
    """
    index_BR4R2N = BR4R2N(index)
    # 使用KCF-MM计算内存地址
    Tk = kcf_mm(BN, IBN, index_BR4R2N, mode)
       
    return Tk


def write_A_poly_address(BN, IBN, index, mode):
    """
    将错误多项式写入Bank0/Bank1
    输入:
        BN: Bank Number
        IBN: In-Bank Number
        mode: 模式标志
    """
    index_BR2 = BR2(index)
    # 使用KCF-MM计算内存地址
    Tk = kcf_mm(BN, IBN, index_BR2, mode)
       
    return Tk


# =============================================
# 算法5: KCF-NTT (混合基2/4 NTT)
# =============================================
def kcf_ntt(input_poly, BN, IBN, mode):
    """
    混合基2/4 NTT算法
    输入:
        input_poly: 输入多项式 (256个系数)
        BN: Bank Number
        IBN: In-Bank Number
        mode: 模式标志
    输出:
        NTT变换后的多项式
    """
    # 初始化内存 (模拟)
    memory = {}
    for i in range(256):
        T = kcf_mm(BN, IBN, i, mode)
        memory[T] = input_poly[i]
    
    # 常数定义
    q = 3329  # 模数
    zeta = 17  # 根 (简化示例)
    
    # KCF-NTT0部分 (基4运算)
    for i in range(3):  # 0,1,2
        for j in range(4**i):
            # 预计算旋转因子 (简化)
            tw = [pow(zeta, -((2*k+1)*32//(4**(i+1))), q) for k in range(4)]

            for k in range(32 // (4**(i+1))):
                base_indices = [k * 4**(i+1) + r * 4**i + j for r in range(4)]
                
                for p in range(2):  # 0,1
                    # 获取4个系数的地址
                    T_list = []
                    for r in range(4):
                        idx = base_indices[r] * 2 + p
                        T = kcf_mm(BN, IBN, idx, mode)
                        T_list.append(T)
                    
                    # 从内存读取数据
                    r_data = [memory[T] for T in T_list]
                    
                    # 基4蝶形运算 (简化实现)
                    w_data = radix4_bfly(r_data, tw, q)
                    
                    # 写回内存
                    for T, d in zip(T_list, w_data):
                        memory[T] = d
    
    # KCF-NTT1部分 (基2运算)
    for i in range(64):
        bias = [0, 128, 1, 129]
        T_list = []
        for r in range(4):
            idx = 2 * i + bias[r]
            T = kcf_mm(BN, IBN, idx, mode)
            T_list.append(T)
        
        # 从内存读取数据
        r_data = [memory[T] for T in T_list]
        
        # 基2蝶形运算 (简化实现)
        tw_val = pow(zeta, 2*i+1, q)
        w_data = radix2_bfly(r_data, tw_val, q)
        
        # 写回内存
        for T, d in zip(T_list, w_data):
            memory[T] = d
    
    # 从内存中提取结果
    output_poly = [0]*256
    for i in range(256):
        T = kcf_mm(BN, IBN, i, mode)
        output_poly[i] = memory[T]
    
    return output_poly

# -------------------------
# 辅助函数：基4蝶形运算
# -------------------------
def radix4_bfly(data, tw, q):
    """简化版基4蝶形运算"""
    a, b, c, d = data
    b_tw = (b * tw[1]) % q
    c_tw = (c * tw[2]) % q
    d_tw = (d * tw[3]) % q
    
    # 第一层蝶形
    a1 = (a + b_tw) % q
    b1 = (a - b_tw) % q
    c1 = (c_tw + d_tw) % q
    d1 = (c_tw - d_tw) % q
    
    # 第二层蝶形
    w0 = (a1 + c1) % q
    w1 = (b1 + 1j*d1) % q  # 简化处理
    w2 = (a1 - c1) % q
    w3 = (b1 - 1j*d1) % q  # 简化处理
    
    return [w0, w1, w2, w3]

# -------------------------
# 辅助函数：基2蝶形运算
# -------------------------
def radix2_bfly(data, tw, q):
    """简化版基2蝶形运算"""
    a, b, c, d = data
    b_tw = (b * tw) % q
    d_tw = (d * tw) % q
    
    w0 = (a + b_tw) % q
    w1 = (a - b_tw) % q
    w2 = (c + d_tw) % q
    w3 = (c - d_tw) % q
    
    return [w0, w1, w2, w3]


# =============================================
# 测试代码
# =============================================
if __name__ == "__main__":
    # 创建测试数据
    input_data = list(range(256))
   
    print("测试算法2 (KCF-MM):")
    for i in range(256):  # 测试前10个索引
        # address = kcf_mm(0, 0, i, 0)
        address=write_error_poly_address(0, 0, i, 0)
        # address=write_A_poly_address(0, 0, i, 1)
        print(f"映射结果: index={i}, BNr={address[0]}, IBNr={address[1]}, CN={address[2]}, addr={address[3]}")

    # print("\n测试算法3 (写入错误多项式):")
    # mem = write_error_poly(input_data, 0, 0, 0)
    # print(f"写入内存条目数: {len(mem)}")
    
    # print("\n测试算法5 (KCF-NTT):")
    # ntt_result = kcf_ntt(input_data, 0, 0, 0)
    # print(f"NTT结果长度: {len(ntt_result)}")
    # print(f"前5个系数: {ntt_result[:5]}")