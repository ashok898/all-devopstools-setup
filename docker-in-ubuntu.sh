# --- Update system ---
sudo apt update && sudo apt upgrade -y

# --- Install prerequisites ---
sudo apt install -y ca-certificates curl gnupg lsb-release

# --- Add Docker’s official GPG key ---
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# --- Set up Docker repo ---
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Install Docker Engine ---
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Start and enable Docker ---
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# --- Verify Docker ---
docker --version

# --- Run test container ---
sudo docker run hello-world
