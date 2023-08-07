#!/bin/bash 
  
 echo "- Retrieving latest node release." 
             LATEST_ERGO_RELEASE=$(curl -s "https://api.github.com/repos/ergoplatform/ergo/releases/latest" | awk -F '"' '/tag_name/{print $4}') 
             LATEST_ERGO_RELEASE_NUMBERS=$(echo ${LATEST_ERGO_RELEASE} | cut -c 2-) 
             ERGO_DOWNLOAD_URL=https://github.com/ergoplatform/ergo/releases/download/${LATEST_ERGO_RELEASE}/ergo-${LATEST_ERGO_RELEASE_NUMBERS}.jar 
             echo "- Downloading Latest known Ergo release: ${LATEST_ERGO_RELEASE}." 
             curl --silent -L ${ERGO_DOWNLOAD_URL} --output ergo.jar 
  
 sleep 2 
  
 clear 
  
 export BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2" 
  
 # Set some environment variables 
 set_environment(){ 
     export KEY=ee7OHzUHWFBB8eeBf9PD9BQk2 
    } 
  
 set_configuration(){ 
         echo "ergo { 
    networkType = "mainnet" 
    node.stateType = "digest" 
    node.blocksToKeep = 1440 
    node.nipopow.nipopowBootstrap = true     
 } 
  
 scorex { 
     restApi { 
         apiKeyHash = "$BLAKE_HASH" 
     } 
 }" > ergo.conf 
  
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
     #set_configuration 
     start_node 
 print_console 
 else  
     # If no .log file - we assume first run 
     first_run  
 fi 
 } 
  
 print_console() { 
  
         printf "%s    \n\n" \ 
             "View the Ergo node panel at 127.0.0.1:9053/panel" \ 
             "Your unique API key is: $API_KEY" \ 
             "To start the node in the future, use ./ergo" 
  
            sleep 300
 } 
  
 start_node(){ 
     tmux new-session -d -s node_session './start' 
 } 
  
 first_run() { 
 echo "#!/bin/sh   
 while true   
 do 
           java -jar ergo.jar --mainnet -c ergo.conf 
             sleep 100 
     done" > start 
  
 chmod +x start 
  
 KEY=ee7OHzUHWFBB8eeBf9PD9BQk2 
  
 BLAKE_HASH="d3bce9a53e3fbaba4a0cb92f9e419bb47123c07ab31f626362e2658e7dcfc7c2" 
  
 set_configuration 
  
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
  
         tmux new-session -d -s node 'java -jar ergo.jar --mainnet -c ergo.conf' 
         echo "- Node has started... Setting blake hash" 
         sleep 10 
  
         export BLAKE_HASH=$(curl --silent -X POST "http://localhost:9053/utils/hash/blake2b" -H "accept: application/json" -H "Content-Type: application/json" -d "\"$API_KEY\"") 
         echo "$BLAKE_HASH" > blake.conf 
         echo "BLAKE_HASH:$BLAKE_HASH" 
  
         curl -X POST --max-time 10 "http://127.0.0.1:9053/node/shutdown" -H "api_key: $KEY" 
         sleep 10 
         tmux kill-session -t node 
  
         set_configuration 
  
 clear 
  
         main_thing 
  
 } 
  
 main_thing