#!/bin/bash

clear

# If run-alpine.sh exists, run it and exit
if [ -f "./run-alpine.sh" ]; then
    ./run-alpine.sh
    exit
fi

echo "🔍 Checking system memory to determine recommended node type..."
sleep 2

# Check total and available system memory in MB
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')

# Thresholds (in MB)
TOTAL_THRESHOLD=5120  # 5GB recommended for NiPoPoW
AVAILABLE_THRESHOLD=1843  # 1.8GB minimum for basic operation

# Default auto-selection logic
if [ "$TOTAL_MEM" -gt "$TOTAL_THRESHOLD" ]; then
    AUTO_NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/nipopow-ergo-node.sh"
    AUTO_NODE_TYPE="NiPoPoW Ergo Node"
elif [ "$AVAILABLE_MEM" -lt "$AVAILABLE_THRESHOLD" ]; then
    AUTO_NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/stateless-ergo-node.sh"
    AUTO_NODE_TYPE="Stateless Ergo Node"
else
    AUTO_NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/nipopow-ergo-node.sh"
    AUTO_NODE_TYPE="NiPoPoW Ergo Node"
fi

# Display detected system info
echo "----------------------------------------"
echo "🧠  Total Memory:     ${TOTAL_MEM} MB"
echo "💾  Available Memory: ${AVAILABLE_MEM} MB"
echo "----------------------------------------"
echo "Recommended Node Type: $AUTO_NODE_TYPE"
echo

# Warn user if NiPoPoW may be too heavy
if [ "$TOTAL_MEM" -lt "$TOTAL_THRESHOLD" ]; then
    echo "⚠️  WARNING: NiPoPoW node requires at least 5GB of RAM for stable operation."
    echo "   Your system has ${TOTAL_MEM}MB — you may experience crashes or slow sync."
    echo
fi

# Prompt user to select a node type
echo "Please choose which node type to install:"
echo "1) NiPoPoW Ergo Node (recommended for >=5GB RAM)"
echo "2) Stateless Ergo Node (lightweight option)"
echo
echo "⏳ Auto-selecting '$AUTO_NODE_TYPE' in 10 seconds..."
echo

read -t 20 -p "Enter choice (1 or 2): " NODE_CHOICE
echo

if [ "$NODE_CHOICE" == "1" ]; then
    NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/nipopow-ergo-node.sh"
    NODE_TYPE="NiPoPoW Ergo Node"
elif [ "$NODE_CHOICE" == "2" ]; then
    NODE_SCRIPT="https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/stateless-ergo-node.sh"
    NODE_TYPE="Stateless Ergo Node"
else
    NODE_SCRIPT="$AUTO_NODE_SCRIPT"
    NODE_TYPE="$AUTO_NODE_TYPE"
    echo "💡 No input received — proceeding with auto-selected: $NODE_TYPE"
fi

sleep 2
clear

echo "----------------------------------------"
echo "✅ Node Type Selected: $NODE_TYPE"
echo "----------------------------------------"
sleep 3

# Download and set up Alpine scripts
echo "⬇️  Downloading Alpine initialization scripts..."
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/init-alpine.sh -o init-alpine.sh
chmod +x init-alpine.sh
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/run-alpine.sh -o run-alpine.sh
chmod +x run-alpine.sh

# Initialize Alpine
./init-alpine.sh
clear

# Append the selected node setup command to .profile
echo "
apk add bash curl
sh <(curl -s $NODE_SCRIPT)
" >> .alpinelinux_container/root/.profile

# Run Alpine environment
./run-alpine.sh
