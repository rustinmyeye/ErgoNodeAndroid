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
    nodeName = "📱 ErgoNodeAndroid NiPoPoW 📱"
  }

  restApi {
    apiKeyHash = "'$BLAKE_HASH'"
  }
}
' > ergo.conf
}

download_ergo() {
    ERGO_DOWNLOAD_URL="https://github.com/ergoplatform/ergo/releases/download/v5.1.2/ergo-5.1.2.jar"
    echo "📦 Downloading Ergo release: 5.1.2 RocksDB..."
    curl --silent -L "${ERGO_DOWNLOAD_URL}" --output ergo.jar
    echo "✅ Download complete: ergo.jar"
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
    print_console   
}

start_node(){
    tmux new-session -d -s node_session 'java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf'
    while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1; done

    echo "- Node has started. Searching for peers..."
    end_time=$(($(date +%s) + 30))

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
    sleep 10

    end_time=$(($(date +%s) + 30))
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

check_status(){
    LRED="\033[1;31m"
    LGREEN="\033[1;32m"
    NC='\033[0m'

    string=$(curl -sf --max-time 20 "${1}")

    if [ -z "$string" ]; then
        echo -e "${LRED}${1} is down${NC}"        
        tmux kill-session -t node_session
        main_thing
    else
        echo -e "${LGREEN}${1} is online${NC}"
    fi
}

get_heights(){
    check_status "localhost:9053/info"
    API_HEIGHT=$(curl --silent --max-time 10 "https://api.ergoplatform.com/api/v1/networkState" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['height']);")
    HEADERS_HEIGHT=$(curl --silent --max-time 10 "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['headersHeight']);")
    HEIGHT=$(curl --silent --max-time 10 "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['parameters']['height']);")
    FULL_HEIGHT=$(curl --silent --max-time 10 "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['fullHeight']);")

    API_HEIGHT=${API_HEIGHT:-0}

    if [ "$API_HEIGHT" -gt 0 ]; then
        if [ "$HEADERS_HEIGHT" -eq "$HEIGHT" ]; then
            echo "HeadersHeight == Height"
            echo "Node is synchronized"
            exit 1
        elif [ "$HEADERS_HEIGHT" -lt "$HEIGHT" ]; then
            echo "HeadersHeight < Height"
            echo "Mis-sync!"
            exit 1
        else
            PERCENT_HEADERS=$(( ( ($API_HEIGHT - $HEADERS_HEIGHT) * 100) / $API_HEIGHT ))
            PERCENT_BLOCKS=$(( ( ($API_HEIGHT - $HEIGHT) * 100) / $API_HEIGHT ))
        fi
    fi
}

print_console(){
    while sleep 1
    do
        clear
        printf "%s    \n\n" \
        "View the Ergo node panel at 127.0.0.1:9053/panel" \
        "
Your unique API key is: $API_KEY" \
        "
Sync Progress;" \
        "### Headers: ~$(( 100 - $PERCENT_HEADERS ))% Complete ($HEADERS_HEIGHT/$API_HEIGHT) ###" \
        "### Blocks:  ~$(( 100 - $PERCENT_BLOCKS ))% Complete ($HEIGHT/$API_HEIGHT) ###"
        
        echo " "

        line=$(grep 'Downloaded or waiting' ergo.log | tail -n 1)

if [ -n "$line" ]; then
  echo "NiPoPoW Bootstrap Progress:"
  echo ""
  echo "$line" | awk -F'- ' '{print $2}' | \
  sed -E 's/Downloaded or waiting ([0-9]+) chunks out of ([0-9]+).*/### Chunks Downloaded \1\/\2 ###/'
fi

        echo " "

        PEERS=$(curl --silent --max-time 10 "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['peersCount']);")
        echo "Number of connected peers: $PEERS"

        dt=$(date '+%d/%m/%Y %H:%M:%S')
        echo "$dt: HEADERS: $HEADERS_HEIGHT, HEIGHT: $HEIGHT" >> height.log
        get_heights
    done
}

set_environment
set_configuration
main_thing