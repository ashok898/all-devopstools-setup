# --- Install prerequisites ---
sudo yum install -y wget git

# --- Install Java 21 manually (Adoptium tarball) ---
cd /opt
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
tar -xvzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
ln -sfn jdk-21.0.5+11 jdk-21

# Register Java with alternatives
sudo alternatives --install /usr/bin/java java /opt/jdk-21/bin/java 1
sudo alternatives --install /usr/bin/javac javac /opt/jdk-21/bin/javac 1
sudo alternatives --set java /opt/jdk-21/bin/java
sudo alternatives --set javac /opt/jdk-21/bin/javac

# Verify Java
java -version

# --- Install Jenkins ---
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins

# --- Configure Jenkins service to use Java 21 ---
sudo systemctl edit jenkins
# Add inside override file:
# [Service]
# Environment="JAVA_HOME=/opt/jdk-21"
# ExecStart=
# ExecStart=/opt/jdk-21/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --httpPort=8080 --webroot=/var/cache/jenkins/war

sudo systemctl daemon-reload

# --- Open firewall port ---
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# --- Start Jenkins ---
sudo systemctl reset-failed jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

# --- Get initial admin password ---
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# --- Access Jenkins UI ---
# Open browser: http://<server-ip>:8080
