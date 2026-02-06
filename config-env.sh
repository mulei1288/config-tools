#!/bin/bash

# 使用方法：
# wget -qO- https://ghfast.top/https://raw.githubusercontent.com/mulei1288/config-tools/main/config-env.sh | bash

# GitHub 原始文件地址（修正链接格式）
PROXY_PREFIX=https://ghfast.top
BASE_URL="${PROXY_PREFIX}/https://raw.githubusercontent.com/mulei1288/config-tools/main"

# 下载函数，带重试机制
download_file() {
    local filename=$1
    local url="${BASE_URL}/file/bin/${filename}"
    local dest="/usr/local/bin/${filename}"
    
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
