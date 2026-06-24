#!/usr/bin/env python3
import os
import shutil

src_dir = "/Users/ztc/Desktop/App/GentleCompanion"
app_dir = "/Users/ztc/Desktop/GentleCompanion.app"

# 清理旧 app
if os.path.exists(app_dir):
    shutil.rmtree(app_dir)

# 创建 app 目录结构
os.makedirs(f"{app_dir}/Contents/MacOS")
os.makedirs(f"{app_dir}/Contents/Resources")

# 复制可执行文件
shutil.copy(f"{src_dir}/.build/x86_64-apple-macosx/debug/GentleCompanion", f"{app_dir}/Contents/MacOS/GentleCompanion")
os.chmod(f"{app_dir}/Contents/MacOS/GentleCompanion", 0o755)

# 复制资源包
bundle_path = f"{src_dir}/.build/x86_64-apple-macosx/debug/GentleCompanion_GentleCompanion.bundle"
if os.path.exists(bundle_path):
    shutil.copytree(bundle_path, f"{app_dir}/Contents/Resources/GentleCompanion_GentleCompanion.bundle")

# 复制 Assets.xcassets
assets_src = f"{src_dir}/Assets.xcassets"
if os.path.exists(assets_src):
    shutil.copytree(assets_src, f"{app_dir}/Contents/Resources/Assets.xcassets")

# 复制 Info.plist
info_plist_src = f"{src_dir}/Info.plist"
if os.path.exists(info_plist_src):
    shutil.copy(info_plist_src, f"{app_dir}/Contents/Info.plist")

# 创建 AppIcon（如果有）
for ext in [".png", ".icns"]:
    icon_src = f"{src_dir}/Resources/AppIcon{ext}"
    if os.path.exists(icon_src):
        shutil.copy(icon_src, f"{app_dir}/Contents/Resources/AppIcon{ext}")

# 复制 entitlements
entitlements_src = f"{src_dir}/GentleCompanion.entitlements"
if os.path.exists(entitlements_src):
    shutil.copy(entitlements_src, f"{app_dir}/Contents/Resources/GentleCompanion.entitlements")

print(f"✅ 打包完成: {app_dir}")

# 验证 mp3 文件
import glob
mp3_files = glob.glob(f"{app_dir}/Contents/Resources/**/*.mp3", recursive=True)
print(f"📁 音效文件: {[os.path.basename(f) for f in mp3_files]}")

# 验证可执行文件
exec_path = f"{app_dir}/Contents/MacOS/GentleCompanion"
if os.path.exists(exec_path):
    print(f"✅ 可执行文件: {exec_path}")
