#!/bin/bash

# 配置多个 API 接口
declare -A APIs=(
    ["NAVAREA_IV"]="https://msi.nga.mil/api/publications/smaps?navArea=4&status=active&category=14&output=xml"
    ["NAVAREA_XII"]="https://msi.nga.mil/api/publications/smaps?navArea=12&status=active&category=14&output=xml"
    ["HYDROLANT"]="https://msi.nga.mil/api/publications/smaps?navArea=A&status=active&category=14&output=xml"
    ["HYDROPAC"]="https://msi.nga.mil/api/publications/smaps?navArea=P&status=active&category=14&output=xml"
    ["HYDROARC"]="https://msi.nga.mil/api/publications/smaps?navArea=C&status=active&category=14&output=xml"
)

# 数据目录
DATA_DIR="data"

# 创建数据目录
mkdir -p "$DATA_DIR"

echo "开始获取多个接口数据..."
echo "=========================================="

# 成功和失败计数
success_count=0
fail_count=0

# 遍历所有接口
for name in "${!APIs[@]}"; do
    url="${APIs[$name]}"
    output_file="$DATA_DIR/${name}.xml"

    echo "📡 获取 $name 数据..."
    echo "   URL: $url"
    echo "   保存到: $output_file"

    # 使用 curl 获取数据
    if curl -s -S \
        --max-time 30 \
        --retry 2 \
        --retry-delay 3 \
        -H "User-Agent: GitHub-Action-Multi-Updater/1.0" \
        -o "$output_file" \
        "$url"; then

        # 检查文件是否非空
        if [ -s "$output_file" ]; then
            file_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "unknown")
            echo "   ✅ 成功 (大小: ${file_size} bytes)"
            ((success_count++))
        else
            echo "   ❌ 文件为空"
            ((fail_count++))
        fi
    else
        echo "   ❌ 请求失败"
        ((fail_count++))
    fi

    echo "------------------------------------------"
    sleep 1  # 稍微延迟，避免请求过快
done

echo "📊 完成报告:"
echo "   成功: $success_count"
echo "   失败: $fail_count"
echo "   总计: $((success_count + fail_count))"

# 如果有失败则返回错误码
if [ $fail_count -gt 0 ]; then
    exit 1
else
    exit 0
fi