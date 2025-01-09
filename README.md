# SNI Injector Proxy Container for [sni-injector](https://github.com/miyurudassanayake/sni-injector)

The container allows for proxying network traffic over SSH using Server Name Indication (SNI). This setup requires SSH agent forwarding to authenticate with a remote SSH server.

---

## Prerequisites

- Docker and Docker Compose are required.
  
- SSH Agent: The container needs access to your local SSH agent to forward SSH keys for authentication to the remote server.

---

## Environment Variables

The following environment variables must be set:

- `REMOTE_HOST`: The SSH host that the proxy will connect to. This can be a remote server running an SSH service.
- `SNI_HOST`: The SNI (Server Name Indication) host and port to connect to (bughost).
- `REMOTE_USER`: The SSH username for the remote host.
- `REMOTE_PORT`: The port number on the remote host (e.g., `2022` for SSH over stunnel).
- `SSH_AUTH_SOCK`: The socket used by the SSH agent for forwarding the SSH key into the container.
###### More information on how this works check the official [application](https://github.com/miyurudassanayake/sni-injector) documentation 
---

## Running the Container

You can run the container using either Docker Compose or Docker directly.

---

### 1. Running with Docker Compose

Step 1: Clone the Repositories

Start by cloning the repository that contains the Docker configuration:

```bash
git clone https://github.com/josh/sni-proxy.git
cd sni-proxy
```

Step 2: Modify `docker-compose.yml`

In the `docker-compose.yml` file, set the following environment variables according to your setup. These are required for the container to function:

```yaml
version: '3'

services:
  proxy:
    container_name: proxy
    image: vybraan/sni-proxy:latest  # Use my Docker image
    volumes:
      - ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}  # Forward SSH agent socket
    environment:
      REMOTE_HOST: "example.com"   # SSH host (e.g., a remote server with stunnel)
      SNI_HOST: "facebook.com:8080"  # SNI Host
      REMOTE_USER: "myuser"        # SSH Username
      REMOTE_PORT: "2022"          # SSH port (e.g., stunnel over HTTPS)
      SSH_AUTH_SOCK: ${SSH_AUTH_SOCK}  # Forward SSH key
    stdin_open: true
    tty: true
    restart: always
```

Step 3: Start the Container

Run the container interactively with the following command:

```bash
docker-compose up
```

Or start it in detached mode:

```bash
docker-compose up -d
```

---

### 2. Running with Docker (`docker run`)

Step 1: Build the Docker Image

If you want to build the Docker image yourself:

```bash
git clone https://github.com/josh/sni-proxy.git
cd sni-proxy
docker build -t sni-proxy .
```

Step 2: Run the Container with Docker

Run the container, forwarding the SSH agent socket to allow key forwarding into the container. Use the following command:

```bash
docker run -v $SSH_AUTH_SOCK:$SSH_AUTH_SOCK \
  -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
  -e REMOTE_HOST="example.com" \
  -e SNI_HOST="facebook.com:8080" \
  -e REMOTE_USER="myuser" \
  -e REMOTE_PORT="2022" \
  sni-proxy
```

Replace the environment variable values with your own.

---

## SSH Agent Setup

The container needs access to your local SSH agent to forward keys for authentication. The steps to configure the SSH agent are outlined below.

### Step 1: Start the SSH Agent

If the SSH agent is not running, start it by running the following command:

```bash
eval $(ssh-agent -s)
```

This will start the SSH agent and return an `SSH_AUTH_SOCK` value.

### Step 2: Add Your SSH Key to the Agent

Add your SSH private key to the agent:

```bash
ssh-add /path/to/your/ssh/key
```

Verify that the key has been added correctly:

```bash
ssh-add -l
```

This will list all the SSH keys that are currently loaded in the agent.

### Step 3: Verify the SSH_AUTH_SOCK Variable

Ensure that the `SSH_AUTH_SOCK` environment variable is set correctly.

To check if the variable is set, run:

```bash
echo $SSH_AUTH_SOCK
```

If the output is empty, ensure that the SSH agent is running and the key is added.

---

## Using the Proxy

Once the container is running, you can use the proxy to route traffic through the SSH tunnel and SNI proxy.

The container listens on port 1080 as socks5 proxy. To route traffic through the proxy:

### Client Configuration

- Browser Configuration:
  Set your browser's socks5 proxy to `localhost:1080`. # localhost if you published the port

- Pacman Command:
  To test the proxy with `curl`, use:

  ```bash
  export http_proxy=socks://127.0.0.1:1080
  export https_proxy=$http_proxy
  sudo -E pacman -Syu
  ```
---

## Customization

You can customize the container by modifying the following files:

- `config.sh`: Adjust the proxy settings, paths, and other configuration details.
- `run.sh`: Customize the startup script for additional setup steps.

