# Update system
sudo yum update -y

# Enable Docker from amazon-linux-extras (Amazon Linux 2)
sudo amazon-linux-extras enable docker

# Install Docker
sudo yum install -y docker

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# Add ec2-user to docker group (optional, avoid sudo)
sudo usermod -aG docker ec2-user
# Log out and back in for group change to take effect

# Verify Docker
docker --version

# Run test container
sudo docker run hello-world
