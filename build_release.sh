#!/bin/bash

# 构建和打包发布版本的脚本

set -e

# 项目路径
PROJECT_DIR="/Users/zhangtiancheng/Desktop/App/GentleCompanion"
OUTPUT_DIR="/Users/zhangtiancheng/Desktop/App/Release"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "=== 开始构建发布版本 ==="

# 清理之前的构建
cd "$PROJECT_DIR"
echo "清理构建目录..."
swift package clean

# 构建发布版本
echo "构建发布版本..."
swift build -c release

# 复制应用到输出目录
echo "复制应用到输出目录..."
cp -r ".build/release/GentleCompanion" "$OUTPUT_DIR/"

# 复制资源文件
echo "复制资源文件..."
cp -r "Resources" "$OUTPUT_DIR/"
cp "Info.plist" "$OUTPUT_DIR/"
cp "GentleCompanion.entitlements" "$OUTPUT_DIR/"

# 签名应用 (需要替换为实际的签名信息)
echo "签名应用..."
# 注意：这里需要使用你自己的开发者证书
# codesign --deep --force --sign "你的开发者证书" --entitlements "GentleCompanion.entitlements" "$OUTPUT_DIR/GentleCompanion"

# 创建DMG文件
echo "创建DMG文件..."
DMG_NAME="GentleCompanion_Release.dmg"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"

# 创建临时目录用于DMG构建
TEMP_DMG_DIR="$OUTPUT_DIR/temp_dmg"
mkdir -p "$TEMP_DMG_DIR"
cp -r "$OUTPUT_DIR/GentleCompanion" "$TEMP_DMG_DIR/"
cp -r "$OUTPUT_DIR/Resources" "$TEMP_DMG_DIR/"

# 创建DMG
hdiutil create -fs HFS+ -volname "温柔点" -srcfolder "$TEMP_DMG_DIR" "$DMG_PATH"

# 压缩DMG
echo "压缩DMG文件..."
hdiutil convert "$DMG_PATH" -format UDZO -o "$OUTPUT_DIR/GentleCompanion_Release_Compressed.dmg"

# 清理临时文件
rm -rf "$TEMP_DMG_DIR"

# 验证构建结果
echo "=== 构建完成 ==="
echo "应用路径: $OUTPUT_DIR/GentleCompanion"
echo "DMG文件: $OUTPUT_DIR/GentleCompanion_Release_Compressed.dmg"

echo "构建和打包过程已完成！"
echo "接下来的步骤："
echo "1. 在App Store Connect中创建应用记录"
echo "2. 使用Transporter应用上传构建"
echo "3. 准备应用审核材料"
echo "4. 提交应用审核"
