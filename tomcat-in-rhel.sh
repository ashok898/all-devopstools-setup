# --- Update system ---
sudo yum update -y

# --- Install prerequisites ---
sudo yum install -y wget tar

# --- Download Tomcat (example: 10.1.24) ---
cd /opt
wget https://downloads.apache.org/tomcat/tomcat-10/v10.1.24/bin/apache-tomcat-10.1.24.tar.gz

# --- Extract and set stable path ---
tar -xvzf apache-tomcat-10.1.24.tar.gz
ln -sfn apache-tomcat-10.1.24 tomcat

# --- Configure environment variables ---
echo 'export CATALINA_HOME=/opt/tomcat' | sudo tee /etc/profile.d/tomcat.sh
echo 'export PATH=$CATALINA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/tomcat.sh
source /etc/profile.d/tomcat.sh

# --- Start Tomcat ---
$CATALINA_HOME/bin/startup.sh

# --- Verify Tomcat ---
curl http://localhost:8080
