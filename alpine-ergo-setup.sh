#!/bin/bash

clear

# If run-alpine.sh exists, run it and exit
if [ -f "./run-alpine.sh" ]; then
    ./run-alpine.sh
    exit
fi

echo "Checking system memory to determine node type..."

sleep 2

# Check total and available system memory in MB
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')

# Convert thresholds to MB
TOTAL_THRESHOLD=5120  # 5GB
AVAILABLE_THRESHOLD=1843  # 1.8GB

# Determine which script to run
if [ "$TOTAL_MEM" -gt "$TOTAL_THRESHOLD" ]; then
    NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/nipopow-ergo-node.sh"
    NODE_TYPE="NiPoPoW Ergo Node"
elif [ "$AVAILABLE_MEM" -lt "$AVAILABLE_THRESHOLD" ]; then
    NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/stateless-ergo-node.sh"
    NODE_TYPE="Stateless Ergo Node"
else
    NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/nipopow-ergo-node.sh"
    NODE_TYPE="NiPoPoW Ergo Node"
fi

# Display memory info and selected node type
echo "----------------------------------------"
echo "Total Memory: ${TOTAL_MEM}MB"
echo "Available Memory: ${AVAILABLE_MEM}MB"
echo "Selected Node Type: $NODE_TYPE"
echo "----------------------------------------"
sleep 5

# Download and set up Alpine scripts
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/init-alpine.sh -o init-alpine.sh
chmod +x init-alpine.sh
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/run-alpine.sh -o run-alpine.sh
chmod +x run-alpine.sh

# Initialize Alpine
./init-alpine.sh
clear

# Append the selected script to .profile
echo "
apk add bash curl
sh <(curl -s $NODE_SCRIPT)
" >> .alpinelinux_container/root/.profile

# Run Alpine
./run-alpine.sh
