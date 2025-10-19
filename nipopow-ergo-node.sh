#!/bin/sh

clear
echo "Downloading stuff... please wait :)"
apk add gcompat openjdk11 python3 wget tmux curl --quiet

tmux kill-session -t node_session 2>/dev/null
clear

export BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2"
PEER_CHECK_INTERVAL=10
MAX_CHECKS=2
CHECK_COUNT=0
ROUND_COUNT=0

set_environment(){
    export KEY=ee7OHzUHWFBB8eeBf9PD9BQk2
    let j=0
    dt=$(date '+%d/%m/%Y %H:%M:%S')
    let i=0
    let PERCENT_BLOCKS=100
    let PERCENT_HEADERS=100
}

set_configuration(){
    echo 'ergo {
  node {
    utxo {
      utxoBootstrap = true
    }
    nipopow {
      nipopowBootstrap = true
      p2pNipopows = 2
    }
  }
}

scorex {
  network {
    maxConnections = 1000
    magicBytes = [1, 0, 2, 4]
    bindAddress = "0.0.0.0:9030"
    nodeName = "ErgoNodeAndroid NiPoPoW"
  }

  restApi {
    apiKeyHash = "'$BLAKE_HASH'"
  }
}
' > ergo.conf
}

download_ergo() {
    ERGO_DOWNLOAD_URL="https://github.com/ergoplatform/ergo/releases/download/v5.1.2/ergo-5.1.2.jar"
    echo "Downloading Ergo release: 5.1.2 RocksDB..."
    curl --silent -L "${ERGO_DOWNLOAD_URL}" --output ergo.jar
    echo "Download complete: ergo.jar"
}

main_thing(){
    set_environment
    count=$(ls -1 blake.conf 2>/dev/null | wc -l)
    if [ $count != 0 ]; then   
        API_KEY=$(cat "api.conf")
        echo "
Configuration is ok. Starting up..."
        BLAKE_HASH=$(cat "blake.conf")
        echo ""
        set_configuration
        start_node
    else 
        first_run 
    fi
    monitor_console
}

start_node(){
    tmux new-session -d -s node_session 'java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf'
    while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1; done

    echo "- Node has started. Searching for peers..."
    end_time=$(($(date +%s) + 120))

    while [ $(date +%s) -lt $end_time ]; do
        PEERS=$(curl --silent --max-time 10 "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin).get('peersCount'));")
        echo -ne "- Number of connected peers: $PEERS"'\r'
    done
    echo ""
}

first_run() {
    KEY=ee7OHzUHWFBB8eeBf9PD9BQk2
    BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2"

    download_ergo
    echo "
Generating unique API key..."
    sleep 2

    length=25
    export API_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1)
    echo "$API_KEY" > api.conf

    tmux new-session -d -s new_session 'java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf'
    echo "- Node has started... Setting blake hash and finding peers"
    sleep 20

    end_time=$(($(date +%s) + 100))
    while [ $(date +%s) -lt $end_time ]; do
        PEERS=$(curl --silent --max-time 10 "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin).get('peersCount'));")
        echo -ne "- Number of connected peers: $PEERS"'\r'
    done
    echo ""

    export BLAKE_HASH=$(curl --silent -X POST "http://localhost:9053/utils/hash/blake2b" -H "accept: application/json" -H "Content-Type: application/json" -d "\"$API_KEY\"")
    echo "$BLAKE_HASH" > blake.conf
    echo "BLAKE_HASH:$BLAKE_HASH"

    curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $KEY"
    sleep 10
    tmux kill-session -t new_session
    clear
    set_configuration
    main_thing
}

monitor_console() {
    LOG_FILE="ergo.log"
    [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"

    while true; do
        clear
        echo "-------------------------------------------------------------"
        echo "Ergo Node Console Status"
        echo "Updated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "-------------------------------------------------------------"

        # Headers height
        HEADERS_LINE=$(grep -F "best header" "$LOG_FILE" | tail -n 1)
        if [ -n "$HEADERS_LINE" ]; then
            HEADERS_HEIGHT=$(echo "$HEADERS_LINE" | grep -oE 'height = [0-9]+' | awk '{print $3}')
            echo "Headers height: ${HEADERS_HEIGHT:-N/A}"
        else
            echo "Headers height: N/A"
        fi

        # Block height
        BLOCKS_LINE=$(grep -F "Full block applied" "$LOG_FILE" | tail -n 1)
        if [ -n "$BLOCKS_LINE" ]; then
            BLOCKS_HEIGHT=$(echo "$BLOCKS_LINE" | grep -oE 'height = [0-9]+' | awk '{print $3}')
            echo "Block height: ${BLOCKS_HEIGHT:-N/A}"
        else
            echo "Block height: N/A"
        fi

        # NiPoPoW chunks
        CHUNKS_LINE=$(grep -E "Downloaded.*out of" "$LOG_FILE" | tail -n 1)
        if [ -n "$CHUNKS_LINE" ]; then
            DOWNLOADED=$(echo "$CHUNKS_LINE" | grep -oE '[0-9]+' | head -n1)
            TOTAL=$(echo "$CHUNKS_LINE" | grep -oE '[0-9]+' | tail -n1)
            if [ -n "$DOWNLOADED" ] && [ -n "$TOTAL" ]; then
                PERCENT=$(awk -v d="$DOWNLOADED" -v t="$TOTAL" 'BEGIN { if(t>0) printf "%.2f", (d/t)*100; else print "0" }')
                if [ "$DOWNLOADED" = "$TOTAL" ]; then
                    echo "NiPoPoW chunks: 100% (all chunks downloaded)"
                else
                    echo "NiPoPoW chunks: ${PERCENT}% (${DOWNLOADED} / ${TOTAL})"
                fi
            else
                echo "NiPoPoW chunks: 0% (no progress yet)"
            fi
        else
            echo "NiPoPoW chunks: 0% (no progress yet)"
        fi

        echo "-------------------------------------------------------------"
        sleep 5
    done
}

set_environment
set_configuration
main_thing
