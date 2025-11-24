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

++++++++++++++++++++++++++++++++++++++++++++++++or++++++++++++++++++++++++++++++++++++++++++++++++

 # --- Update system ---
   59  sudo yum update -y
   60  # --- Remove old versions if any ---
   61  sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
   62  # --- Enable Docker CE repo ---
   63  sudo yum install -y yum-utils
   64  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   65  # --- Install Docker Engine ---
   66  sudo yum install -y docker-ce docker-ce-cli containerd.io
   67  # --- Start and enable Docker service ---
   68  sudo systemctl start docker
   69  sudo systemctl enable docker
   70  sudo systemctl status docker
   71  cd ..
   72  cd .
   73  docker --version
   74  docker login



