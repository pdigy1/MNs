#!/bin/bash
echo "Starting ESBC setup"
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/mVGfNe1tVgY6Gg -O /usr/local/bin/esbcoind
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/SUOPO8OO5qvJGQ -O /usr/local/bin/esbcoin-cli
chmod +x /usr/local/bin/esbcoin*
chmod +x esbcoin-cli esbcoind
#node addressing/interrogation
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/esbcoin-cli -conf=/home/$alias/.esbcoin/esbcoin.conf -datadir=/home/$alias/.esbcoin \$@" >> $alias
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
echo "#PIDFile=/home/$alias/.esbcoin/.esbcoin.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/esbcoind -daemon -conf=/home/$alias/.esbcoin/esbcoin.conf -datadir=/home/$alias/.esbcoin">> $alias.service
echo "ExecStop=-/usr/local/bin/esbcoin-cli -conf=/home/$alias/.esbcoin/esbcoin.conf -datadir=/home/$alias/.esbcoin stop" >> $alias.service
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/DhI8xbvF2TY4Ng -O esbcoin.zip
unzip esbcoin.zip
rm esbcoin.zip
#make conf file
cd .esbcoin
echo "rpcuser=$rpcuser" >> esbcoin.conf
echo "rpcpassword=$rpcpass" >> esbcoin.conf
echo "rpcport=$rpc" >> esbcoin.conf
echo "rpcallowip=127.0.0.1" >> esbcoin.conf
echo "port=$port" >> esbcoin.conf
echo "listen=1" >> esbcoin.conf
echo "server=1" >> esbcoin.conf
echo "daemon=1" >> esbcoin.conf
echo "txindex=1" >> esbcoin.conf
echo "maxconnections=64" >> esbcoin.conf
echo "bind=$ipadd" >> esbcoin.conf
echo "masternode=1" >> esbcoin.conf
echo "masternodeaddr=$ipadd:$port" >> esbcoin.conf
echo "masternodeprivkey=$key" >> esbcoin.conf
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
