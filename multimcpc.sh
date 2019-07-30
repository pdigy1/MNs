#!/bin/bash
echo "Starting MCPC setup"
#script dependancys #do not remove#
echo "Instaling script dependancys"
apt-get install pwgen -y
apt install zip unzip -y -y
apt update -y
echo "Installed script dependancys"
echo "Setting needed varibles for script"
#get inputs
echo "Please enter MN alias. Example <TICKER+MNNUMBER>"
read alias
echo "Alias set to $alias"
echo "generating password for MN alias/user"
pass=`pwgen 14 1 b`
echo "Password for $alias is $pass"
echo "Enter MN key"
read key
echo "MN key entered"
echo "Finding IP/bind address"
ipadd=$(curl http://ifconfig.me/ip)
echo "your ip is $ipadd"
echo "IP/bind set to $ipadd"
echo "Enter port number"
read port
echo "Port set to $port"
echo "Enter RPC port number"
read rpc
echo "RPC set to $rpc"
#conf file info
rpcuser=`pwgen 18 1 b`
rpcpass=`pwgen 36 1 b`
#add user
adduser "$alias" <<EOF
$pass
$pass
/
/
/
/
/
/
/
EOF
#commands to install node. install node binaries
cd /usr/local/bin
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/EnnNekmBY2-oGg -O /usr/local/bin/MCPCoind
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/ewzzKKXMSGRscg -O /usr/local/bin/MCPCoin-cli
chmod +x /usr/local/bin/MCPCoin*
chmod +x MCPCoin-cli MCPCoind
#node addressing/interrogation
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/MCPCoin-cli -conf=/home/$alias/.MCPCoin/MCPCoin.conf -datadir=/home/$alias/.MCPCoin \$@" >> $alias
chmod +x $alias
cd /etc/systemd/system
#Setup service
echo "[Unit]" >> $alias.service
echo "Description=SCC service" >> $alias.service
echo "After=network.target" >> $alias.service
echo "" >> $alias.service
echo "[Service]" >> $alias.service
echo "User=$alias" >> $alias.service
echo "Group=root" >> $alias.service
echo "" >> $alias.service
echo "Type=forking" >> $alias.service
echo "#PIDFile=/home/$alias/.MCPCoin/.MCPCoin.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/MCPCoind -daemon -conf=/home/$alias/.MCPCoin/MCPCoin.conf -datadir=/home/$alias/.MCPCoin">> $alias.service
echo "ExecStop=-/usr/local/bin/MCPCoin-cli -conf=/home/$alias/.MCPCoin/MCPCoin.conf -datadir=/home/$alias/.MCPCoin stop" >> $alias.service
echo "" >> $alias.service
echo "Restart=always" >> $alias.service
echo "PrivateTmp=true" >> $alias.service
echo "TimeoutStopSec=60s" >> $alias.service
echo "TimeoutStartSec=10s" >> $alias.service
echo "StartLimitInterval=120s" >> $alias.service
echo "StartLimitBurst=5" >> $alias.service
echo "" >> $alias.service
echo "[Install]" >> $alias.service
echo "WantedBy=multi-user.target" >> $alias.service
systemctl enable $alias
#update chain files get snapshot
cd /home/$alias
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/8jG5_i3Ldhurbw -O MCPCoinsnapshot.zip
unzip MCPCoinsnapshot.zip
rm MCPCoinsnapshot.zip
#make conf file
cd .MCPCoin
echo "rpcuser=$rpcuser" >> MCPCoin.conf
echo "rpcpassword=$rpcpass" >> MCPCoin.conf
echo "rpcport=$rpc" >> MCPCoin.conf
echo "rpcallowip=127.0.0.1" >> MCPCoin.conf
echo "port=$port" >> MCPCoin.conf
echo "listen=1" >> MCPCoin.conf
echo "server=1" >> MCPCoin.conf
echo "daemon=0" >> MCPCoin.conf
echo "txindex=1" >> MCPCoin.conf
echo "maxconnections=64" >> MCPCoin.conf
echo "bind=$ipadd" >> MCPCoin.conf
echo "masternode=1" >> MCPCoin.conf
echo "masternodeaddr=$ipadd:$port" >> MCPCoin.conf
echo "masternodeprivkey=$key" >> MCPCoin.conf
echo "addnode=104.156.239.129:49540" >> MCPCoin.conf
echo "addnode=104.238.190.11:36890" >> MCPCoin.conf
echo "addnode=107.191.49.185:49451" >> MCPCoin.conf
echo "addnode=108.61.177.39:42098" >> MCPCoin.conf
echo "addnode=108.61.177.39:58926" >> MCPCoin.conf
echo "addnode=109.81.209.35:22424" >> MCPCoin.conf
echo "addnode=109.81.209.35:32725" >> MCPCoin.conf
echo "addnode=121.115.127.150:52337" >> MCPCoin.conf
echo "addnode=136.244.101.219:45324" >> MCPCoin.conf
echo "addnode=136.244.87.153:53660" >> MCPCoin.conf
echo "addnode=136.244.87.153:52998" >> MCPCoin.conf
echo "addnode=144.202.36.203:36362" >> MCPCoin.conf
echo "addnode=144.202.36.203:41814" >> MCPCoin.conf
echo "addnode=144.202.36.203:44352" >> MCPCoin.conf
echo "addnode=144.202.36.203:57402" >> MCPCoin.conf
echo "addnode=148.251.152.211:58412" >> MCPCoin.conf
echo "addnode=149.248.53.113:42516" >> MCPCoin.conf
#Set permisions and firewall rules
cd /home
chown -R $alias $alias
ufw allow $port/tcp comment "$alias port"
ufw allow $rpc/tcp comment "$alias RPC port"
systemctl start $alias
echo "MN setup complete"
echo ""
echo " PLEASE MAKE SURE ALL THE BELOW INFORMATION HAS BEEN SAVED ON THE SHEET! "
echo ""
echo " MN alias and user name = $alias "
echo " Password for $alias = $pass "
echo " MN bind/IP = $bind "
echo " MN port = $port "
echo " MN RPCport = $rpc "
echo " MN key = $key " echo "" echo " PLEASE MAKE SURE ALL THE ABOVE INFORMATION HAS BEEN SAVED ON THE SHEET! "
echo "run <alias> getinfo or <alias> masternode status to check the node"
