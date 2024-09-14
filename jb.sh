#!/bin/bash

# 更新系统并升级软件包
echo "正在更新系统..."
apt update && apt upgrade -y

# 备份原有的 sources.list 文件
echo "备份原有的 sources.list 文件..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 替换为清华源
echo "替换为清华源..."
cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

# 更新软件源
echo "更新软件源..."
apt update

# 安装 Docker
echo "正在安装 Docker..."
apt remove docker docker-engine docker.io containerd runc -y
apt install apt-transport-https ca-certificates curl gnupg lsb-release -y

# 添加 Docker 的 GPG 密钥
echo "添加 Docker 的 GPG 密钥..."
curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 配置 Docker 的 APT 源为清华源
echo "配置 Docker 的 APT 源为清华源..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新 Docker 源并安装 Docker
echo "更新 Docker 源并安装 Docker..."
apt update
apt install docker-ce docker-ce-cli containerd.io -y

# 设置 Docker 使用清华加速器
echo "设置 Docker 使用清华加速器..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://registry.tuna.tsinghua.edu.cn"]
}
EOF

# 重启 Docker 服务
echo "重启 Docker 服务..."
systemctl daemon-reload
systemctl restart docker

# 清理系统
echo "清理系统..."
apt autoremove -y
apt autoclean

# 显示完成信息
echo "系统更新并更换源为清华源完成，Docker 也已更换为清华源。"
