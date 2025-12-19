sudo mount -o remount,rw /
mount | grep ' / '

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

docker compose version


To check if Docker Compose is installed and working, you can use these commands:

***

### ✅ 1. Verify Docker Compose Version

Run:

```bash
docker compose version
```

If installed correctly, you’ll see something like:

    Docker Compose version v2.x.x

***

### ✅ 2. Test with a Simple Compose File

Create a file named `docker-compose.yml`:

```yaml
version: '3'
services:
  hello:
    image: hello-world
```

Run:

```bash
docker compose up
```

You should see the `hello-world` container run successfully.

***

### ✅ 3. Check Plugin Location

If you installed manually:

```bash
ls /usr/local/lib/docker/cli-plugins/
```

You should see `docker-compose` there.

***

Do you want me to give you **a quick command to confirm both Docker and Compose are working together**, or **a full test scenario with Nginx using Compose**?
