curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/$(curl -s https://dl.k8s.io/release/stable.txt)/2025-01-01/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
