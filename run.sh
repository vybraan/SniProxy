 #!/bin/bash

if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "SSH_AUTH_SOCK is not set. Make sure the SSH agent is running on the host."
    exit 1
fi

# config script
/work/config.sh

# Install any missing dependencies 
source /work/sni-injector/.venv/bin/activate
cd /work/sni-injector
pip install -r requirements.txt 

python3 /work/sni-injector/main.py &

echo "Waiting for main.py to start..."
while ! pgrep -f "main.py" > /dev/null; do
    sleep 1
done
echo "main.py is running."

echo "Checking if port 9092 is open..."
while ! nc -zv 127.0.0.1 9092 2>/dev/null; do
    echo "Waiting for port 9092 to be open..."
    sleep 1
done
echo "Port 9092 is now available."

# Run SSH tunneling
/work/sni-injector/ssh.sh

