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
            ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/v5.1.2/ergo-5.1.2.jar
            #echo "- Downloading Latest known Ergo release: ${LATEST_ERGO_RELEASE}."
            echo "- Downloading Ergo release: 5.1.2 RocksDB."
            curl --silent -L ${ERGO_DOWNLOAD_URL} --output ergo.jar

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
        echo "ergo {
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
    upnpEnabled = true
    nodeName = "ErgoNodeAndroid-NiPoPoW"
    knownPeers = [
      "ergonode.duckdns.org:9030",
      "213.239.193.208:9030",
      "159.65.11.55:9030",
      "165.227.26.175:9030",
      "159.89.116.15:9030",
      "136.244.110.145:9030",
      "94.130.108.35:9030",
      "51.75.147.1:9020",
      "221.165.214.185:9030",
      "217.182.197.196:9030",
      "173.212.220.9:9030",
      "176.9.65.58:9130",
      "213.152.106.56:9030"
    ]
  }

  restApi {
    apiKeyHash = "$BLAKE_HASH"
  }
}
" > ergo.conf

}

main_thing(){
    set_environment
    # Check for the prescence of log files
    count=`ls -1 blake.conf 2>/dev/null | wc -l`
    if [ $count != 0 ]; then   
    API_KEY=$(cat "api.conf")
    echo "
  Configuration is ok. Starting up..."
    BLAKE_HASH=$(cat "blake.conf")
    echo "
"
    set_configuration
    start_node
else 
    # If no .log file - we assume first run
    first_run 
fi

print_console   

}

start_node(){
    tmux new-session -d -s node_session 'java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf'
    while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1; done;  # wait for node be ready with progress bar

    echo "- Node has started. Searching for peers..."
    end_time=$(($(date +%s) + 120))

while [ $(date +%s) -lt $end_time ]; do
    PEERS=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin).get('peersCount'));")
    echo -ne "- Number of connected peers: $PEERS"'\r'
done
        echo "
        "

}

# Set basic config for boot, boot & get the hash and then re-set config 
first_run() {
KEY=ee7OHzUHWFBB8eeBf9PD9BQk2
BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2"
#set_configuration
### Download the latest .jar file                                                                    
        if [ ! -e *.jar ]; then 
            echo "- Retrieving latest node release."
            LATEST_ERGO_RELEASE=$(curl -s "https://api.github.com/repos/ergoplatform/ergo/releases/latest" | awk -F '"' '/tag_name/{print $4}')
            LATEST_ERGO_RELEASE_NUMBERS=$(echo ${LATEST_ERGO_RELEASE} | cut -c 2-)
            ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/${LATEST_ERGO_RELEASE}/ergo-${LATEST_ERGO_RELEASE_NUMBERS}.jar
            echo "- Downloading Latest known Ergo release: ${LATEST_ERGO_RELEASE}."
            curl --silent -L ${ERGO_DOWNLOAD_URL} --output ergo.jar
        fi 

        echo "
Generating unique API key..."
        sleep 2

       length=25
        export API_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1)
        echo "$API_KEY" > api.conf

        #export key=$(cat api.conf)

        tmux new-session -d -s new_session 'java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf'
        echo "- Node has started... Setting blake hash and finding peers"
        if ! ping -c 1 http://localhost:9053/info &> /dev/null; then
        echo "
        "
        sleep 20
    fi

    end_time=$(($(date +%s) + 100))

while [ $(date +%s) -lt $end_time ]; do
    PEERS=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin).get('peersCount'));")
    echo -ne "- Number of connected peers: $PEERS"'\r'
done

        echo "
        "

        export BLAKE_HASH=$(curl --silent -X POST "http://localhost:9053/utils/hash/blake2b" -H "accept: application/json" -H "Content-Type: application/json" -d "\"$API_KEY\"")
        echo "$BLAKE_HASH" > blake.conf
        echo "BLAKE_HASH:$BLAKE_HASH"

        #areyou_there

        curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $KEY"
        sleep 10
        tmux kill-session -t new_session
        #rm -rf .ergo
        clear
        # Add blake hash
        #echo "Your unique API key will be added to the configuration when you close the app completely and restart"
        set_configuration
        #error_log
        #print_console
        main_thing

}

func_kill(){
    case "$(uname -s)" in

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        echo 'MS Windows'
        netstat -ano | findstr :9053
        taskkill /PID 9053 /F
        ;;

    armv7l*|aarch64)
        #echo "on Pi!"
        #kill
        curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $API_KEY"
        sleep 10
        tmux kill-session -t node_session
        sleep 10
        ;;
    *) #Other
        #kill -9 $(lsof -t -i:9053)
        #kill -9 $(lsof -t -i:9030)
        curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $API_KEY"
        sleep 10
        tmux kill-session -t node_session
        sleep 10
        ;;
    esac

}

error_log(){
    inputFile=ergo.log

    if grep -E 'ERROR\|WARN' "$inputFile" ; then
        echo "WARN/ERROR:" $egrep
        echo "$egrep" >> error.log
    elif grep -E 'Got GetReaders request in state (None,None,None,None)\|port' "$inputFile" ; then
        echo "Readers not ready. If this keeps happening we'll attempt to restart: $i"
        ((i=i+1)) 
    elif grep -E 'Invalid z bytes' "$inputFile" ; then
        echo "zBYTES error:" $egrep
        echo "$egrep" >> error.log

    fi

    if [ $i -gt 10 ]; then
        i=0
        echo i: $i
        #func_kill
        curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $API_KEY"
        tmux kill-session -t node_session
        main_thing

    fi

}

check_status(){
    LRED="\033[1;31m" # Light Red
    LGREEN="\033[1;32m" # Light Green
    NC='\033[0m' # No Color

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

    API_HEIGHT=$(curl --silent --max-time 10 --output -X GET "https://api.ergoplatform.com/api/v1/networkState" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['height']);")
    HEADERS_HEIGHT=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['headersHeight']);")
    HEIGHT=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['parameters']['height']);")
    FULL_HEIGHT=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['fullHeight']);")

    API_HEIGHT=${API_HEIGHT:-0}

    # Calculate %
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

## Display info to user    
print_console(){
    while sleep 1
        do
        clear

        printf "%s    \n\n" \
        "View the Ergo node panel at 127.0.0.1:9053/panel"\
        "
Your unique API key is: $API_KEY"  \
        " "  \
        "
Sync Progress;"\
        "### Headers: ~$(( 100 - $PERCENT_HEADERS ))% Complete ($HEADERS_HEIGHT/$API_HEIGHT) ### "\
        "### Blocks:  ~$(( 100 - $PERCENT_BLOCKS ))% Complete ($HEIGHT/$API_HEIGHT) ### "


        PEERS=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['peersCount']);")
        echo "Number of connected peers:$PEERS"

        echo ""

        wget -q --spider http://google.com

        if [ $? -eq 0 ]; then
            echo ""
        else
            echo "You are not connected to the internet!"
            print_console
    fi

        dt=$(date '+%d/%m/%Y %H:%M:%S');
        echo "$dt: HEADERS: $HEADERS_HEIGHT, HEIGHT:$HEIGHT" >> height.log

        get_heights  

    done
}

# Set some environment variables
        set_environment

        # pipes initial config > ergo.conf
        set_configuration

        main_thing
