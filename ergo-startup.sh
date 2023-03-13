#!/bin/bash

## Minimal Config
echo "
    ergo {
        node {
            mining = false
        }

    }" > ergo.conf
        
## Node start command
echo "
#!/bin/sh  
while true  
do
          java -jar -Xmx1G ergo.jar --mainnet -c ergo.conf > server.log 2>&1 &
            sleep 100
    done" > start.sh
    
chmod +x start.sh

## Download .jar
echo "- Retrieving latest node release.."
LATEST_ERGO_RELEASE=$(curl -s "https://api.github.com/repos/ergoplatform/ergo/releases/latest" | awk -F '"' '/tag_name/{print $4}')
LATEST_ERGO_RELEASE_NUMBERS=$(echo ${LATEST_ERGO_RELEASE} | cut -c 2-)
ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/${LATEST_ERGO_RELEASE}/ergo-${LATEST_ERGO_RELEASE_NUMBERS}.jar
echo "- Downloading Latest known Ergo release: ${LATEST_ERGO_RELEASE}."
curl --silent -L ${ERGO_DOWNLOAD_URL} --output ergo.jar

## Start node
echo "

Starting the node..."
echo "

"
echo "Please visit https://127.0.0.0.9053/panel to view sync progress." 

sh start.sh

sleep 30

get_heights(){

    check_status "localhost:9053/info"

    if [[ ${pyv:0:1} == "3" ]]; then 
        API_HEIGHT2==$(\
                curl --silent --max-time 10 --output -X GET "https://api.ergoplatform.com/api/v1/networkState" -H "accept: application/json" )

        HEADERS_HEIGHT=$(\
            curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" \
            | python -c "import sys, json; print(json.load(sys.stdin)['headersHeight']);"\
        )

        HEIGHT=$(\
        curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json"   \
        | python -c "import sys, json; print(json.load(sys.stdin)['parameters']['height']);"\
        )
        
        FULL_HEIGHT=$(\
        curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json"   \
        | python -c "import sys, json; print(json.load(sys.stdin)['fullHeight']);"\
        )               
        
    fi

    if [[ ${pyv:0:1} == "2" ]]; then                
       API_HEIGHT2==$(\
                curl --silent --max-time 10 --output -X GET "https://api.ergoplatform.com/api/v1/networkState" -H "accept: application/json" )

        HEADERS_HEIGHT=$(\
            curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json" \
            | python -c "import sys, json; print json.load(sys.stdin)['headersHeight'];"\
        )

        HEIGHT=$(\
        curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json"   \
        | python -c "import sys, json; print json.load(sys.stdin)['parameters']['height'];"\
        )
        
        FULL_HEIGHT=$(\
        curl --silent --max-time 10 --output -X GET "http://localhost:9053/info" -H "accept: application/json"   \
        | python -c "import sys, json; print json.load(sys.stdin)['fullHeight'];"\
        )
    fi

    
    API_HEIGHT=${API_HEIGHT2:92:6}
    # Calculate %
    if [ -n "$API_HEIGHT" ] && [ "$API_HEIGHT" -eq "$API_HEIGHT" ] 2>/dev/null; then
        
        
        if [ -n "$HEADERS_HEIGHT" ] && [ "$HEADERS_HEIGHT" -eq "$HEADERS_HEIGHT" ] 2>/dev/null; then
            let expr PERCENT_HEADERS=$(( ( ($API_HEIGHT - $HEADERS_HEIGHT) * 100) / $API_HEIGHT   )) 
        fi

        if [ -n "$HEIGHT" ] && [ "$HEIGHT" -eq "$HEIGHT" ] 2>/dev/null; then
            let expr PERCENT_BLOCKS=$(( ( ($API_HEIGHT - $HEIGHT) * 100) / $API_HEIGHT   ))
        fi        
        
        # if height==headersHeight then we are syncronised. 
        if [ -n "$HEADERS_HEIGHT" ] && [ "$HEADERS_HEIGHT" -eq "$HEIGHT" ] 2>/dev/null; then
            echo "HeadersHeight == Height"
            echo "Node is syncronised"
            exit 1

        fi

        # If HeadersHeight < Height then something has gone wrong
        if [ -n "$HEADERS_HEIGHT" ] && [ "$HEADERS_HEIGHT" -lt "$HEIGHT" ] 2>/dev/null; then
            echo "HeadersHeight < Height"
            echo "Mis-sync!"
            exit 1

        fi
   
        

    fi
    
} 
    
print_console() {
    while sleep 1
        do
        clear
        
        printf "%s    \n\n" \
        "To use the API, enter your password ('$API_KEY') on 127.0.0.1:9053/panel under 'Set API key'."\
        "Please follow the next steps on docs.ergoplatform.org to initialise your wallet."  \
        "For best results please disable any sleep mode while syncing"  \
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