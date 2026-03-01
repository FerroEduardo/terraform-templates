#!/bin/bash

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install Docker Engine, CLI, containerd, buildx plugin and docker-compose plugin:
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Start Docker
sudo systemctl start docker

# Create a simple site directory and index.html to replace the container default
mkdir -p /home/ubuntu/site
cat > /home/ubuntu/site/index.html <<'EOF'
<!doctype html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,initial-scale=1">
		<title>Terraform Test</title>
	</head>
	<body>
		<h1>Hi from Terraform!</h1>
	</body>
</html>
EOF

docker run --name nginx -d -p 80:80 -v /home/ubuntu/site:/usr/share/nginx/html:ro nginx:latest