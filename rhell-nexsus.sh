#!/bin/bash
# Nexus Repository Manager 3 installation script for RHEL

set -e

echo "🔧 Updating system and installing prerequisites..."
yum update -y
yum install -y wget tar firewalld java-17-openjdk-headless

echo "🚀 Starting and enabling firewalld..."
systemctl enable firewalld
systemctl start firewalld

echo "📁 Creating application directory..."
mkdir -p /app && cd /app

echo "📦 Downloading Nexus Repository Manager..."
NEXUS_VERSION=nexus-3.79.1-04
NEXUS_TAR=${NEXUS_VERSION}-linux-x86_64.tar.gz
wget https://download.sonatype.com/nexus/3/${NEXUS_TAR}

echo "📂 Extracting Nexus..."
tar -xvf ${NEXUS_TAR}
mv ${NEXUS_VERSION} nexus

echo "👤 Creating nexus user if not exists..."
id -u nexus &>/dev/null || adduser nexus

echo "🔐 Setting permissions..."
chown -R nexus:nexus /app/nexus
mkdir -p /app/sonatype-work
chown -R nexus:nexus /app/sonatype-work

echo "⚙️ Configuring Nexus to run as nexus user..."
echo 'run_as_user="nexus"' > /app/nexus/bin/nexus.rc

echo "📝 Creating systemd service file..."
tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
WorkingDirectory=/app/nexus
Environment=JAVA_HOME=/app/nexus/jdk/temurin_17.0.13_11_linux_x86_64/jdk-17.0.13+11
ExecStart=/bin/bash /app/nexus/bin/nexus start
ExecStop=/bin/bash /app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

echo "🔄 Reloading systemd and enabling Nexus service..."
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "🌐 Opening firewall port 8081..."
firewall-cmd --permanent --add-port=8081/tcp
firewall-cmd --reload

echo "✅ Nexus installation complete. Checking service status..."
systemctl status nexus --no-pager




nexus Container

[root@rhel-vm ~]# sudo mkdir -p /nexus-data
[root@rhel-vm ~]# sudo chown -R 200:200 /nexus-data
[root@rhel-vm ~]# docker run -d --name nexus -p 8087:8081 -v /nexus-data:/nexus-data sonatype/nexus3
