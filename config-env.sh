#!/bin/bash

# GitHub 原始文件地址（修正链接格式）
BASE_URL="https://raw.githubusercontent.com/mulei1288/config-tools/main"

# 创建 bin 目录（如果不存在）
mkdir -p "$HOME/bin"

# 添加到 PATH（如果尚未添加）
if ! grep -q "export PATH=\"\$HOME/bin:\$PATH\"" /etc/profile 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' | sudo tee -a /etc/profile > /dev/null
fi

# 立即生效（可选，仅当前会话）
export PATH="$HOME/bin:$PATH"

# 下载函数，带重试机制
download_file() {
    local filename=$1
    local url="${BASE_URL}/${filename}"
    local dest="$HOME/bin/${filename}"
    
    echo "正在下载 ${filename}..."
    
    # 尝试使用 curl 或 wget
    for i in {1..3}; do
        if command -v curl &> /dev/null; then
            if curl -sSL -f -o "$dest" "$url"; then
                chmod +x "$dest"
                echo "✓ ${filename} 下载成功"
                return 0
            fi
        elif command -v wget &> /dev/null; then
            if wget -q -O "$dest" "$url"; then
                chmod +x "$dest"
                echo "✓ ${filename} 下载成功"
                return 0
            fi
        else
            echo "错误：需要 curl 或 wget"
            exit 1
        fi
        
        if [ $i -lt 3 ]; then
            echo "重试下载 ${filename}... (第 $i 次)"
            sleep 2
        fi
    done
    
    echo "✗ ${filename} 下载失败"
    return 1
}

# 下载文件
download_file "s"
download_file "rcp"

echo "安装完成！请重新登录或运行 'source /etc/profile' 使配置生效"
echo "工具安装位置: $HOME/bin/"
