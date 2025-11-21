# --- Update system ---
sudo apt update && sudo apt upgrade -y

# --- Install prerequisites ---
sudo apt install -y wget git curl gnupg2 software-properties-common

# --- Install Java 21 (Adoptium tarball, since Ubuntu repos may not yet have OpenJDK 21) ---
cd /opt
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
tar -xvzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
sudo ln -sfn /opt/jdk-21.0.5+11 /opt/jdk-21

# Register Java
sudo update-alternatives --install /usr/bin/java java /opt/jdk-21/bin/java 1
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk-21/bin/javac 1
sudo update-alternatives --set java /opt/jdk-21/bin/java
sudo update-alternatives --set javac /opt/jdk-21/bin/javac

# Verify Java
java -version

# --- Install Jenkins ---
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# --- Configure Jenkins service to use Java 21 ---
sudo systemctl edit jenkins
# [Service]
# Environment="JAVA_HOME=/opt/jdk-21"
# ExecStart=
# ExecStart=/opt/jdk-21/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --httpPort=8080 --webroot=/var/cache/jenkins/war

sudo systemctl daemon-reload

# --- Start Jenkins ---
sudo systemctl reset-failed jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

# --- Get initial admin password ---
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
