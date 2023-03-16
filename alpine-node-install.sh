#!/bin/bash

export BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2"

# Set some environment variables
set_environment(){
    export KEY=ee7OHzUHWFBB8eeBf9PD9BQk2
    PEER_CHECK_INTERVAL=10
    MAX_CHECKS=6
    CHECK_COUNT=0
        
    let j=0
    #OS=$(uname -m)

    
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    let i=0
    let PERCENT_BLOCKS=100
    let PERCENT_HEADERS=100
    
}
    
set_configuration(){
        echo "
                ergo {
                    node {
                        # Full options available at 
                        # https://github.com/ergoplatform/ergo/blob/master/src/main/resources/application.conf
                        
                        mining = false
                        # Skip validation of transactions in the mainnet before block 417,792 (in v1 blocks).
                        # Block 417,792 is checkpointed by the protocol (so its UTXO set as well).
                        # The node still applying transactions to UTXO set and so checks UTXO set digests for each block.
                        #skipV1TransactionsValidation = true
                    }
                }      
                        
                scorex {
                    restApi {
                        # Hex-encoded Blake2b256 hash of an API key. 
                        # Should be 64-chars long Base16 string.
                        # below is the hash of the string 'hello'
                        # replace with your actual hash 
                        apiKeyHash = "$BLAKE_HASH"
                        
                    }
                
                }
        " > ergo.conf

}

main_thing(){
    # Check for the prescence of log files
    count=`ls -1 blake.conf 2>/dev/null | wc -l`
    if [ $count != 0 ]; then   
    API_KEY=$(cat "api.conf")
    echo "
Configuration is ok"
    BLAKE_HASH=$(cat "blake.conf")
    echo "
Searching for peers"
    set_configuration
    start_node
else 
    # If no .log file - we assume first run
    first_run 
fi
   
# Launch in browser
#python${ver:0:1} -mwebbrowser http://127.0.0.1:9053/panel 
#python${ver:0:1} -mwebbrowser http://127.0.0.1:9053/info 
# Print to console
#error_log
print_console   

}


areyou_there() {
    IM_HERE=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['peersCount']);")
  
  if [ $IM_HERE -lt 1 ]; then
    echo "No peers available. Waiting for ${PEER_CHECK_INTERVAL} seconds..."
    sleep ${PEER_CHECK_INTERVAL}
    CHECK_COUNT=$((CHECK_COUNT + 1))
    if [ $CHECK_COUNT -eq $MAX_CHECKS ]; then
      echo "No peers found after ${MAX_CHECKS} checks. Restarting"
      tmux kill-session -t node_session
      set_configuration
      set_environment
      main_thing
    else
      areyou_there
    fi
  else
    echo "Found $IM_HERE peers!"
    sleep 2
  fi
}

start_node(){
    tmux new-session -d -s node_session 'java -jar -Xmx1g ergo.jar --mainnet -c ergo.conf'
    echo "Node has started... waiting for peers"sleep 60
    #echo "
    
#### Waiting for a response from the server. ####"
    areyou_there
    while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1 && error_log; done;  # wait for node be ready with progress bar

}

# Set basic config for boot, boot & get the hash and then re-set config 
first_run() {

### Download the latest .jar file                                                                    
        if [ ! -e *.jar ]; then 
            echo "- Retrieving latest node release.."
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
        
        tmux new-session -d -s node_session 'java -jar ergo.jar --mainnet -c ergo.conf'
        echo "Node has started... getting blake hash."
        sleep 15
        
        
        export BLAKE_HASH=$(curl --silent -X POST "http://localhost:9053/utils/hash/blake2b" -H "accept: application/json" -H "Content-Type: application/json" -d "\"$API_KEY\"")
        echo "$BLAKE_HASH" > blake.conf
        echo "BLAKE_HASH:$BLAKE_HASH"
        
        #areyou_there
        
        curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $KEY"
        sleep 10
        tmux kill-session -t node_session

        # Add blake hash
        set_configuration
        
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
    
    if egrep 'ERROR\|WARN' "$inputFile" ; then
        echo "WARN/ERROR:" $egrep
        echo "$egrep" >> error.log
    elif egrep 'Got GetReaders request in state (None,None,None,None)\|port' "$inputFile" ; then
        echo "Readers not ready. If this keeps happening we'll attempt to restart: $i"
        ((i=i+1)) 
    elif egrep 'Invalid z bytes' "$inputFile" ; then
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
        func_kill
        
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
You can add this node to Ergo Wallet app's node and api connections when 100% synced

Your unique API key is: $API_KEY"  \
        "
For best results please enable wakelock mode while syncing"  \
        "
        Sync Progress;"\
        "### Headers: ~$(( 100 - $PERCENT_HEADERS ))% Complete ($HEADERS_HEIGHT/$API_HEIGHT) ### "\
        "### Blocks:  ~$(( 100 - $PERCENT_BLOCKS ))% Complete ($HEIGHT/$API_HEIGHT) ### "
        
        PEERS=$(curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" | python3 -c "import sys, json; print(json.load(sys.stdin)['peersCount']);")
        echo "Number of connected peers:$PEERS"
        
        echo ""
        
        error_log
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
