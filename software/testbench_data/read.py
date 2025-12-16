from pathlib import Path

def main():
    root = Path.cwd()                 # 当前路径
    out_path = root / "file_list.txt" # 输出文件

    files = sorted([p.name for p in root.iterdir() if p.is_file()])

    out_path.write_text("\n".join(files) + "\n", encoding="utf-8")
    print(f"已写入 {len(files)} 个文件名到: {out_path}")

if __name__ == "__main__":
    main()
