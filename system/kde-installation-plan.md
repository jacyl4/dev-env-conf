# Debian 13 安装 KDE 桌面环境 (X11 + 性能优化)

## 前提条件
- Debian 13 (Trixie) 最小化安装
- 具有 root 权限
- 网络连接正常

---

## 第一步：更新系统

```bash
apt update && apt upgrade -y
```

---

## 第二步：安装 X11 显示服务器

```bash
apt install -y xorg xserver-xorg
```

---

## 第三步：安装 KDE Plasma 桌面环境

选择以下其中一种安装方式：

### 方式 A：最小化安装（推荐，节省空间）
```bash
apt install -y plasma-desktop sddm
```

### 方式 B：标准安装（包含更多 KDE 应用）
```bash
apt install -y kde-plasma-desktop sddm
```

### 方式 C：完整安装（全部 KDE 应用）
```bash
apt install -y kde-full sddm
```

---

## 第四步：强制 SDDM 使用 X11（禁用 Wayland）

### 4.1 创建/编辑 SDDM 配置文件

```bash
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/x11.conf << 'EOF'
[General]
DisplayServer=x11

[Wayland]
SessionDir=/dev/null
EOF
```

### 4.2 确保 Plasma 会话使用 X11

```bash
# 创建环境变量配置
cat > /etc/environment.d/99-force-x11.conf << 'EOF'
XDG_SESSION_TYPE=x11
EOF

# 或者直接写入 /etc/environment
echo 'XDG_SESSION_TYPE=x11' >> /etc/environment
```

### 4.3 禁用 Wayland 会话文件（可选但推荐）

```bash
# 移除 Wayland 会话入口
mv /usr/share/wayland-sessions/plasma.desktop /usr/share/wayland-sessions/plasma.desktop.disabled 2>/dev/null || true
```

---

## 第五步：减少 KDE 特效提升性能

### 5.1 创建全局 KDE 性能优化配置

为所有用户创建默认配置：

```bash
mkdir -p /etc/skel/.config

# 禁用桌面特效
cat > /etc/skel/.config/kwinrc << 'EOF'
[Compositing]
# 完全禁用混成器（最大性能提升）
Enabled=false

# 或者使用 XRender 后端（比 OpenGL 更轻量）
# Enabled=true
# Backend=XRender
# GLCore=false
# OpenGLIsUnsafe=false

# 禁用动画
AnimationSpeed=0

# 禁用窗口缩略图
HiddenPreviews=6

# 降低刷新率以节省资源
RefreshRate=60

[Windows]
# 禁用窗口几何信息显示
GeometryTip=false

[Plugins]
# 禁用各种特效插件
blurEnabled=false
contrastEnabled=false
desktopgridEnabled=false
diminactiveEnabled=false
kwin4_effect_fadeEnabled=false
kwin4_effect_fadingpopupsEnabled=false
kwin4_effect_frozenappEnabled=false
kwin4_effect_loginEnabled=false
kwin4_effect_logoutEnabled=false
kwin4_effect_maximizeEnabled=false
kwin4_effect_morphingpopupsEnabled=false
kwin4_effect_scaleEnabled=false
kwin4_effect_screenedgeEnabled=false
kwin4_effect_slidingpopupsEnabled=false
kwin4_effect_translucencyEnabled=false
kwin4_effect_windowapertureEnabled=false
maabordarEnabled=false
magiclampEnabled=false
minimizeanimationEnabled=false
overviewEnabled=false
sheetEnabled=false
slideEnabled=false
slidingpopupsEnabled=false
snaphelperEnabled=false
squashEnabled=false
wobblywindowsEnabled=false
zoomEnabled=false
EOF

# Plasma 桌面性能优化
cat > /etc/skel/.config/plasmarc << 'EOF'
[Theme]
# 使用简单主题
name=breeze-light

[PlasmaViews][Panel 0][Defaults]
# 降低面板更新频率
thickness=28
EOF

# 禁用 Baloo 文件索引（节省大量资源）
cat > /etc/skel/.config/baloofilerc << 'EOF'
[Basic Settings]
Indexing-Enabled=false
EOF

# 减少 KRunner 历史和插件
cat > /etc/skel/.config/krunnerrc << 'EOF'
[General]
FreeFloating=false
HistoryEnabled=false
RetainPriorSearch=false

[Plugins]
CharacterRunnerEnabled=false
DictionaryEnabled=false
Kill RunnerEnabled=false
PowerDevilEnabled=false
Spell CheckerEnabled=false
babordarEnabled=false
bookmarksEnabled=false
browsertabsEnabled=false
calculatorEnabled=false
desktopsessionsEnabled=false
helprunnerEnabled=false
kabordarEnabled=false
konsabordarEnabled=false
kwinEnabled=false
locationsEnabled=false
org.kde.activitiesEnabled=false
org.kde.datetimeEnabled=false
org.kde.windowedwidgetsEnabled=false
placesEnabled=false
plasma-desktopEnabled=false
recentdocumentsEnabled=false
shellEnabled=false
webshortcutsEnabled=false
windowsEnabled=false
EOF
```

### 5.2 已有用户应用优化

对于已存在的用户，复制配置到其主目录：

```bash
# 替换 USERNAME 为实际用户名
# cp /etc/skel/.config/kwinrc /home/USERNAME/.config/
# cp /etc/skel/.config/plasmarc /home/USERNAME/.config/
# cp /etc/skel/.config/baloofilerc /home/USERNAME/.config/
# chown -R USERNAME:USERNAME /home/USERNAME/.config/
```

---

## 第六步：启用并启动 SDDM

```bash
# 设置 SDDM 开机自启
systemctl enable sddm

# 设置默认启动到图形界面
systemctl set-default graphical.target

# 立即启动（或重启系统）
systemctl start sddm
# 或
reboot
```

---

## 第七步：登录后进一步优化（可选）

登录 KDE 后，可以通过图形界面进一步优化：

### 7.1 系统设置 → 显示和监视器 → 合成器
- 设置动画速度为"即时"
- 或直接禁用合成器

### 7.2 系统设置 → 搜索 → 文件搜索
- 禁用文件搜索功能

### 7.3 系统设置 → 开机和关机 → 桌面会话
- 启动时恢复空白会话

---

## 快速执行脚本

将以下内容保存为脚本一键执行：

```bash
#!/bin/bash
set -e

echo "=== 更新系统 ==="
apt update && apt upgrade -y

echo "=== 安装 X11 和 KDE ==="
apt install -y xorg xserver-xorg plasma-desktop sddm

echo "=== 配置 X11 ==="
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/x11.conf << 'EOF'
[General]
DisplayServer=x11

[Wayland]
SessionDir=/dev/null
EOF

echo 'XDG_SESSION_TYPE=x11' >> /etc/environment

echo "=== 配置性能优化 ==="
mkdir -p /etc/skel/.config

cat > /etc/skel/.config/kwinrc << 'EOF'
[Compositing]
Enabled=false
AnimationSpeed=0

[Plugins]
blurEnabled=false
kwin4_effect_fadeEnabled=false
slidingpopupsEnabled=false
wobblywindowsEnabled=false
EOF

cat > /etc/skel/.config/baloofilerc << 'EOF'
[Basic Settings]
Indexing-Enabled=false
EOF

echo "=== 启用 SDDM ==="
systemctl enable sddm
systemctl set-default graphical.target

echo "=== 安装完成，重启生效 ==="
echo "执行 reboot 重启系统"
```

---

## 验证安装

重启后，检查是否运行在 X11 下：

```bash
# 应该显示 x11
echo $XDG_SESSION_TYPE

# 或使用
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```

---

## 故障排除

### 问题：SDDM 无法启动
```bash
# 检查日志
journalctl -u sddm -b

# 检查 X11 日志
cat /var/log/Xorg.0.log
```

### 问题：显卡驱动问题
```bash
# Intel 显卡
apt install -y xserver-xorg-video-intel

# AMD 显卡
apt install -y xserver-xorg-video-amdgpu

# NVIDIA 显卡
apt install -y nvidia-driver
```

### 问题：恢复 Wayland（如果需要）
```bash
rm /etc/sddm.conf.d/x11.conf
sed -i '/XDG_SESSION_TYPE/d' /etc/environment
mv /usr/share/wayland-sessions/plasma.desktop.disabled /usr/share/wayland-sessions/plasma.desktop
```
