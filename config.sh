#!/bin/bash

sed -i "s|host = <host>|host = ${REMOTE_HOST}|g" sni-injector/settings.ini

sed -i "s|server_name = <host>|server_name = ${SNI_HOST}|g" sni-injector/settings.ini

printf "#!/bin/bash \n ssh -A -C -o \"ProxyCommand=ncat --proxy 127.0.0.1:9092 %%h %%p\" \$REMOTE_USER@\$REMOTE_HOST -p \$REMOTE_PORT -g -CND 1081 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\n"  > sni-injector/ssh.sh

chmod +x sni-injector/ssh.sh

