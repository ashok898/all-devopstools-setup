# Update system
sudo apt update && sudo apt upgrade -y

# Install prerequisites
sudo apt install -y wget unzip postgresql postgresql-contrib

# Start PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create SonarQube DB and user
sudo -u postgres psql -c "CREATE DATABASE sonarqube;"
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"

# Download SonarQube
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.5.0.90531.zip
sudo unzip sonarqube-10.5.0.90531.zip
sudo ln -sfn sonarqube-10.5.0.90531 sonarqube

# Configure DB connection
sudo sed -i 's/^#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/^#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|^#sonar.jdbc.url=jdbc:postgresql.*|sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|' /opt/sonarqube/conf/sonar.properties

# Start SonarQube
/opt/sonarqube/bin/linux-x86-64/sonar.sh start

# Verify SonarQube
curl http://localhost:9000
