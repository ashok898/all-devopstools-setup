# --- Update system ---
sudo yum update -y

# --- Remove old versions if any ---
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# --- Enable Docker CE repo ---
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# --- Install Docker Engine ---
sudo yum install -y docker-ce docker-ce-cli containerd.io

# --- Start and enable Docker service ---
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# --- Verify Docker installation ---
docker --version

# --- Run test container ---
sudo docker run hello-world
