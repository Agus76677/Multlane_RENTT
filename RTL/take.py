import os

# 以当前脚本所在目录作为 RTL 根路径
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(ROOT_DIR, "all_verilog_concat.txt")

# 想要打包的后缀名，可以视情况加上 ".sv"
TARGET_EXTS = (".v",".py")

# 可选：忽略的目录（比如仿真结果、Git 等）
IGNORE_DIRS = {".git", "sim", "work", "out", "build"}

def collect_verilog_files(root):
    verilog_files = []
    for dirpath, dirnames, filenames in os.walk(root):
        # 过滤一些不需要进入的目录
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]

        for name in filenames:
            if name.lower().endswith(TARGET_EXTS):
                full_path = os.path.join(dirpath, name)
                rel_path = os.path.relpath(full_path, root)
                verilog_files.append((rel_path, full_path))
    # 按相对路径排序，保证生成顺序稳定
    verilog_files.sort(key=lambda x: x[0])
    return verilog_files

def main():
    files = collect_verilog_files(ROOT_DIR)
    print(f"发现 {len(files)} 个 Verilog 文件，将写入 {OUTPUT_FILE}")

    with open(OUTPUT_FILE, "w", encoding="utf-8") as out_f:
        for rel_path, full_path in files:
            header = f"// ===== {rel_path} =====\n\n"
            out_f.write(header)
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as src_f:
                    out_f.write(src_f.read())
            except Exception as e:
                # 某个文件读取失败时做个标记，方便你排查
                out_f.write(f"\n// [WARNING] Failed to read {rel_path}: {e}\n")

            out_f.write("\n\n\n")  # 文件之间空几行，阅读舒服一点

    print("打包完成。")

if __name__ == "__main__":
    main()
