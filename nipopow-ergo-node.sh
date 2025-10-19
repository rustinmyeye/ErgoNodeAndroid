#!/bin/sh

#download things
echo "Downloading stuff... please wait :)"
#apk --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ add android-tools --quiet
apk add gcompat openjdk11 python3 wget tmux curl --quiet


tmux kill-session -t node_session
clear

#Maybe will use this beleow to grab the latest rocksdb release, but not sure if it is good enough yet. Need a new rocksdb release to test i guess.
# echo "- Retrieving latest Ergo release that explicitly mentions RocksDB."

# # Fetch all releases and find the latest one mentioning "RockDB" in the body
# LATEST_ROCKSDB_RELEASE=$(curl -s "https://api.github.com/repos/ergoplatform/ergo/releases" | \
#     jq -r '[.[] | select(.body | test("(?i)rockdb|rocksdb"))][0]')

# # Extract the version tag
# LATEST_TAG=$(echo "$LATEST_ROCKSDB_RELEASE" | jq -r '.tag_name')

# if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" = "null" ]; then
#     echo "No RocksDB-specific release found."
#     exit 1
# fi

# echo "- Latest Ergo RocksDB release: $LATEST_TAG"

# # Extract the correct JAR file URL
# ROCKSDB_JAR_URL=$(echo "$LATEST_ROCKSDB_RELEASE" | jq -r '.assets[] | select(.name | test("\\.jar$")) | .browser_download_url' | head -n 1)

# if [ -z "$ROCKSDB_JAR_URL" ] || [ "$ROCKSDB_JAR_URL" = "null" ]; then
#     echo "No JAR file found for $LATEST_TAG."
#     exit 1
# fi

# echo "- Downloading: $ROCKSDB_JAR_URL"
# curl --silent -L "$ROCKSDB_JAR_URL" --output rocksdb-ergo.jar
# echo "- Download complete: rocksdb-ergo.jar"


#echo "- Retrieving latest node release."
            #LATEST_ERGO_RELEASE=$(curl -s "https://api.github.com/repos/ergoplatform/ergo/releases/latest" | awk -F '"' '/tag_name/{print $4}')
            #LATEST_ERGO_RELEASE_NUMBERS=$(echo ${LATEST_ERGO_RELEASE} | cut -c 2-)
            #ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/${LATEST_ERGO_RELEASE}/ergo-${LATEST_ERGO_RELEASE_NUMBERS}.jar
            #ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/v5.1.2/ergo-5.1.2.jar
            #echo "- Downloading Latest known Ergo release: ${LATEST_ERGO_RELEASE}."
            #echo "- Downloading Ergo release: 5.1.2 RocksDB."
            #curl --silent -L ${ERGO_DOWNLOAD_URL} --output ergo.jar

export BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2"
       PEER_CHECK_INTERVAL=10
       MAX_CHECKS=2
       CHECK_COUNT=0
       ROUND_COUNT=0
# Set some environment variables
set_environment(){
    export KEY=ee7OHzUHWFBB8eeBf9PD9BQk2


    let j=0
    #OS=$(uname -m)


    dt=$(date '+%d/%m/%Y %H:%M:%S');
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
    apiKeyHash = "$BLAKE_HASH"
  }
}
' > ergo.conf

}

# Download Ergo JAR
download_ergo() {
    ERGO_DOWNLOAD_URL="https://github.com/ergoplatform/ergo/releases/download/v5.1.2/ergo-5.1.2.jar"
    echo "📦 Downloading Ergo release: 5.1.2 RocksDB..."
    curl --silent -L "${ERGO_DOWNLOAD_URL}" --output ergo.jar
    echo "✅ Download complete: ergo.jar"
}

# Start the node in tmux
start_node() {
    tmux new-session -d -s node_session "java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf"

    echo "⏳ Waiting for node to become ready..."
    while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1; done
    echo "✅ Node started. Searching for peers..."

    end_time=$(( $(date +%s) + 120 ))
    while [ $(date +%s) -lt $end_time ]; do
        PEERS=$(curl --silent --max-time 10 -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin).get('peersCount'))")
        echo -ne "🌐 Connected peers: $PEERS\r"
        sleep 2
    done
    echo ""
}

# First-run setup
first_run() {
    download_ergo

    echo "🗝️ Generating unique API key..."
    sleep 1
    export API_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 25 | head -n 1)
    echo "$API_KEY" > api.conf

    start_node

    echo "🔑 Setting Blake hash..."
    export BLAKE_HASH=$(curl --silent -X POST "http://localhost:9053/utils/hash/blake2b" -H "accept: application/json" -H "Content-Type: application/json" -d "\"$API_KEY\"")
    echo "$BLAKE_HASH" > blake.conf

    # Restart node with updated config
    curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $KEY"
    sleep 5
    tmux kill-session -t node_session
    clear

    set_configuration
    main_thing
}

# Monitor node sync status and peers
print_console() {
    while sleep 1; do
        clear
        echo "📊 Ergo Node Panel: http://127.0.0.1:9053/panel"
        echo "🔑 Your unique API key: $API_KEY"
        echo "-----------------------------"

        API_HEIGHT=$(curl --silent --max-time 10 https://api.ergoplatform.com/api/v1/networkState -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['height']);")
        HEADERS_HEIGHT=$(curl --silent --max-time 10 http://localhost:9053/info -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['headersHeight']);")
        HEIGHT=$(curl --silent --max-time 10 http://localhost:9053/info -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['parameters']['height']);")
        FULL_HEIGHT=$(curl --silent --max-time 10 http://localhost:9053/info -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['fullHeight']);")

        PERCENT_HEADERS=$(( ( ($API_HEIGHT - $HEADERS_HEIGHT) * 100) / API_HEIGHT ))
        PERCENT_BLOCKS=$(( ( ($API_HEIGHT - $HEIGHT) * 100) / API_HEIGHT ))

        echo "⛓️  Sync Progress:"
        echo "   Headers: ~$((100 - PERCENT_HEADERS))% ($HEADERS_HEIGHT/$API_HEIGHT)"
        echo "   Blocks:  ~$((100 - PERCENT_BLOCKS))% ($HEIGHT/$API_HEIGHT)"

        PEERS=$(curl --silent --max-time 10 http://localhost:9053/info -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['peersCount']);")
        echo "🌐 Connected peers: $PEERS"

        dt=$(date '+%d/%m/%Y %H:%M:%S')
        echo "$dt: HEADERS=$HEADERS_HEIGHT, HEIGHT=$HEIGHT" >> height.log
    done
}

# Main logic
main_thing() {
    set_environment
    if [ -f "blake.conf" ]; then
        BLAKE_HASH=$(cat blake.conf)
        echo "🔧 Configuration found. Starting node..."
        set_configuration
        start_node
    else
        first_run
    fi

    print_console
}

# Run script
set_environment
set_configuration
main_thing