# Update system
sudo apt update && sudo apt upgrade -y

# Install prerequisites
sudo apt install -y wget tar

# Download Maven (use Apache archive for stable link)
cd /opt
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz

# Extract and set stable path
sudo tar -xvzf apache-maven-3.9.9-bin.tar.gz
sudo ln -sfn apache-maven-3.9.9 maven

# Configure environment variables
echo 'export M2_HOME=/opt/maven' | sudo tee /etc/profile.d/maven.sh
echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Verify Maven
mvn -version
