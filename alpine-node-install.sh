#!/bin/sh
# Shell script for installing Ergo Node on any platform.
# markglasgow@gmail.com 
# -------------------------------------------------------------------------
# Totally butchered by rustinmyeye. 
# It's now a shell script for installing on Ergo Node app for Android
# -------------------------------------------------------------------------

## Minimal Config - no api key hash
echo "
    ergo {
        node {
            mining = false
        }

    }" > ergo.conf
        
## Create node start script
echo "
#!/bin/sh  
while true
do
java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf > server.log 2>&1 &
    sleep 100
done" > start.sh
    
chmod +x start.sh

## Download ergo.jar
echo "- Retrieving latest node release.."
LATEST_ERGO_RELEASE=$(curl -s "https://api.github.com/repos/ergoplatform/ergo/releases/latest" | awk -F '"' '/tag_name/{print $4}')
LATEST_ERGO_RELEASE_NUMBERS=$(echo ${LATEST_ERGO_RELEASE} | cut -c 2-)
ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/${LATEST_ERGO_RELEASE}/ergo-${LATEST_ERGO_RELEASE_NUMBERS}.jar
echo "- Downloading Latest known Ergo release: ${LATEST_ERGO_RELEASE}."
curl --silent -L ${ERGO_DOWNLOAD_URL} --output ergo.jar

##Start node in tmux and detach
echo "Starting the node..."

tmux new-session -d -s my_session 'sh start.sh && sleep 5'

export BLAKE_HASH="324dcf027dd4a30a932c441f365a25e86b173defa4b8e58948253471b81b72cf"

# Set some environment variables
set_environment(){
    export API_KEY="dummy"
    
    let j=0
    
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    let i=0
    let PERCENT_BLOCKS=100
    let PERCENT_HEADERS=100
    
}

## Start node error log
start_node(){
    #java -jar $JVM_HEAP_SIZE ergo.jar --mainnet -c ergo.conf > server.log 2>&1 & 
    echo "#### Waiting for a response from the server. ####"
    while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1 && error_log; done;  # wait for node be ready with progress bar
    
}

## Error log
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
        killall -9 java
        sh start.sh
        
    fi

}

## Node online?
check_status(){
    LRED="\033[1;31m" # Light Red
    LGREEN="\033[1;32m" # Light Green
    NC='\033[0m' # No Color

    string=$(curl -sf --max-time 20 "${1}")
    
    if [ -z "$string" ]; then
        echo -e "${LRED}${1} is down${NC}"
        #func_kill
        killall -9 java
        #start_node should start automatically because of while loop
        print_console
    else
       echo -e "${LGREEN}${1} is online${NC}"
    fi
}

## grab heights and node height vs full height calculation 
get_heights() {
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
print_console() {
    while sleep 1
        do
        clear
        
        printf "%s    \n\n" \
        "View the Ergo node panel at 127.0.0.1:9053/panel"\
        "You can add this node to Ergo Wallet app's node and api connections when it is 100% synced"  \
        "For best results please enable wakelock mode while syncing"  \
        "Sync Progress;"\
        "### Headers: ~$(( 100 - $PERCENT_HEADERS ))% Complete ($HEADERS_HEIGHT/$API_HEIGHT) ### "\
        "### Blocks:  ~$(( 100 - $PERCENT_BLOCKS ))% Complete ($HEIGHT/$API_HEIGHT) ### "
        
        echo ""
        error_log
        dt=$(date '+%d/%m/%Y %H:%M:%S');
        echo "$dt: HEADERS: $HEADERS_HEIGHT, HEIGHT:$HEIGHT" >> height.log

        get_heights  
      
    done
}

# Set some environment variables, start log, and print console
set_environment     

start_node

sleep 30

print_console

# Launch in browser
#sleep 60

#adb shell am start -a android.intent.action.VIEW -d http://127.0.0.1:9053/panel
#python3${ver:0:1} -mwebbrowser http://127.0.0.1:9053/panel 
#python3${ver:0:1} -mwebbrowser http://127.0.0.1:9053/info 
