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

## Prepare node

java -jar -Xmx3G ergo.jar --mainnet -c ergo.conf > server.log 2>&1 &
echo "#### Waiting for a response from the server. ####"
while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1 && echo -n '.';  done;  # wait for node be ready with progress bar

## Kill
#curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $API_KEY"
killall -9 java 2>/dev/null

##Start node
echo "

Starting the node..."
echo "

"
echo "Please visit https://127.0.0.0.9053/panel to view sync progress." 
while ! curl --output /dev/null --silent --head --fail http://localhost:9053; do sleep 1 && error_log; done;  # wait for node be ready with progress bar
sh start.sh