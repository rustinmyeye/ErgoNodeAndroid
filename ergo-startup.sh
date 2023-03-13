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
echo "Starting the node..."
echo "Monitor the .log files for any errors"
echo "Please visit https://127.0.0.0.9053/panel to view sync progress." 
echo "                          ;8@@X X.                          
  .  . .  .  . .  .  .t8 @8X88@X8@St8;.  .  . .  . .  . .  .
   .       .    .:8tS8@8SS888@888S8XX8@St8;.         .      
     .  .    ..@ 88XX88@8888X8X888@888S8XX8 8; .  .     . . 
 .       .;8tS8@88@8888888888;::88888S8@888XX@X 8@.   .     
   .  ..t888XX88@8888@8;.:;.  ..::  SX88888888X@S888.    .  
  .    8@88@8888X888.;. :.   .  .    :%  S8@88888888.  .    
    . tXS88@88888.. ..  .  .        ..   ;: ;88@8888 ;     .
  .  . %8888@ t;.   ..   .    .              ;.888@888%  .  
     8X888@8%     .   .   .     .  .          . 8@88@8;.    
  . tX88888t.:  .   8888888888 888 88888@   .  .@88888 t. . 
   : X88888: ..    ;88XSX@XXXXX%8SSS8SS8          8888@8X   
   8X88888%:  . .   8X8888@888@888@88888;         8@88X@8.  
 .tXS8888@.    .   .8@888888888888 8 888;    .    :%X88@8: .
 . %8888S    .   . :. 8X8888X8X % X;t              t8888@8  
 8S88888       .  .  : %88@888X8t...       .  .     X8888@8t
tX888888.   .       .    8X8888888t              . ..8S8888S
SS888@%:..    . .  .    :t  @88@XX8S;      . .    . ;%888888
.8X888%.   .              S8X88@@88t.          .     ;888S8%
 X888XX . .  .  . . .   .8XX@88S8@S     . .  .   .  .8X@888;
. 88888       .       .88888888SX.:  .         .   .8S88888.
 tX@888 % . .    .  . 8@888888@   ..   .  . .    . t888888t 
  8X88X@8t     .    % S@888@8888XX@@@8@S      .   .8X88888: 
 . 8@@8@88. .     ..Xt8888X@X%XXXXX8@X888 .  .  . 8S88888:  
  .:SS@8@8.. .  .  .XX8@88888888888888@8         t@@88@8S   
    8@888@8S.     .:8@@88888 @88888888@8t     . .8S8888@    
   . t@@88S8; .      .      :  ;     ; S.       8S88888t. . 
 .    8X8888    . .            .        ..  .  %888888%.    
     t88888888;   .  .                   .  .t8 @8@888. .  .
     . :888XXX8S 88:.                 . :X8S88X888888;      
  .     8XX8@8@@SS@S88:.         .  ..S8@XS@88888888t.. . . 
   . . :%8888888888XS@X888S      :@8S@@88888888S888S  .     
        .;   :888XX888SXXS@8X88%88X8X88888888XXt ::    . .  
  . .  .      t: t88888888@@8%%X88888888888::  :    .       
        .        .  :X888888@8888@88888%Xt:.. .. .   . . .  
   .  .              :;   S8888 888% %:..  . .  .  .        "

sh start.sh
