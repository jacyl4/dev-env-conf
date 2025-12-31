# Debian 13 最小安装系统 - Cinnamon 桌面安装计划

## 前置条件

- Debian 13 (Trixie) 最小安装系统
- 具有 root 权限或 sudo 权限
- 网络连接正常

## 安装步骤

### 1. 更新系统

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. 安装 Cinnamon 桌面环境

```bash
sudo apt install cinnamon-desktop-environment -y
```

此元包将安装完整的 Cinnamon 桌面，包括：
- Cinnamon 核心组件
- Nemo 文件管理器
- 必要的 GTK 主题和图标
- 系统设置工具

### 3. 安装显示管理器 (可选但推荐)

```bash
sudo apt install lightdm lightdm-gtk-greeter -y
```

设置 lightdm 为默认显示管理器：
```bash
sudo dpkg-reconfigure lightdm
```

### 4. 安装常用字体 (推荐)

```bash
sudo apt install fonts-noto fonts-noto-cjk -y
```

### 5. 安装网络管理器 (如未安装)

```bash
sudo apt install network-manager network-manager-gnome -y
```

### 6. 重启系统

```bash
sudo reboot
```

## 可选组件

### 安装音频支持

```bash
sudo apt install pulseaudio pavucontrol -y
```

### 安装 VMware 虚拟机工具

```bash
sudo apt install open-vm-tools open-vm-tools-desktop -y
```

此工具提供：
- 主机与虚拟机之间的剪贴板共享
- 自动调整分辨率
- 共享文件夹支持
- 时间同步

## 验证安装

重启后应自动进入 Cinnamon 桌面登录界面。如果使用命令行登录，可手动启动：

```bash
startx
```

或确保 `~/.xinitrc` 包含：
```bash
exec cinnamon-session
```

## 故障排除

- 如果显示管理器未启动：`sudo systemctl enable lightdm`
- 查看日志：`journalctl -xe`
- 检查显卡驱动是否正确安装
