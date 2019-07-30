#!/bin/bash
echo "Starting ICHIBA setup"
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/-VkbXJk4qtXUag -O /usr/local/bin/ichibacoind
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/NQ_IxdaFnT3WYQ -O /usr/local/bin/ichibacoin-cli
chmod +x /usr/local/bin/ichibacoin*
chmod +x ichibacoin-cli ichibacoind
#node addressing/interrogation
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/ichibacoin-cli -conf=/home/$alias/.ichibacoin/ichibacoin.conf -datadir=/home/$alias/.ichibacoin \$@" >> $alias
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
echo "#PIDFile=/home/$alias/.ichibacoin/.ichibacoin.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/ichibacoind -daemon -conf=/home/$alias/.ichibacoin/ichibacoin.conf -datadir=/home/$alias/.ichibacoin">> $alias.service
echo "ExecStop=-/usr/local/bin/ichibacoin-cli -conf=/home/$alias/.ichibacoin/ichibacoin.conf -datadir=/home/$alias/.ichibacoin stop" >> $alias.service
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/0J5104UOF9985w -O ichibacoinsnapshot.zip
unzip ichibacoinsnapshot.zip
rm ichibacoinsnapshot.zip
#make conf file
cd .ichibacoin
echo "rpcuser=$rpcuser" >> ichibacoin.conf
echo "rpcpassword=$rpcpass" >> ichibacoin.conf
echo "rpcport=$rpc" >> ichibacoin.conf
echo "rpcallowip=127.0.0.1" >> ichibacoin.conf
echo "port=$port" >> ichibacoin.conf
echo "listen=1" >> ichibacoin.conf
echo "server=1" >> ichibacoin.conf
echo "daemon=0" >> ichibacoin.conf
echo "txindex=1" >> ichibacoin.conf
echo "maxconnections=64" >> ichibacoin.conf
echo "bind=$ipadd" >> ichibacoin.conf
echo "masternode=1" >> ichibacoin.conf
echo "masternodeaddr=$ipadd:$port" >> ichibacoin.conf
echo "masternodeprivkey=$key" >> ichibacoin.conf
echo "addnode=104.238.147.206:2219" >> ichibacoin.conf
echo "addnode=107.191.40.206:2219" >> ichibacoin.conf
echo "addnode=45.77.145.216:2219" >> ichibacoin.conf
echo "addnode=194.87.238.79:2219" >> ichibacoin.conf
echo "addnode=107.191.40.206:2219" >> ichibacoin.conf
echo "addnode=94.60.71.161:2219" >> ichibacoin.conf
echo "addnode=74.141.92.7:2219" >> ichibacoin.conf
echo "addnode=95.46.16.74:2219" >> ichibacoin.conf
echo "addnode=45.77.137.132:2219" >> ichibacoin.conf
echo "addnode=95.179.224.158:2219" >> ichibacoin.conf
echo "addnode=95.216.74.158:2219" >> ichibacoin.conf
echo "addnode=95.216.73.213:2219" >> ichibacoin.conf
echo "addnode=157.230.86.136:2219" >> ichibacoin.conf
echo "addnode=138.68.29.129:2219" >> ichibacoin.conf
echo "addnode=140.82.60.51:2219" >> ichibacoin.conf
echo "addnode=159.65.108.161:2219" >> ichibacoin.conf
echo "addnode=159.69.248.162:2219" >> ichibacoin.conf
echo "addnode=199.247.11.50:2219" >> ichibacoin.conf
echo "addnode=217.69.6.156:2219" >> ichibacoin.conf
echo "addnode=45.32.234.220:2219" >> ichibacoin.conf
echo "addnode=46.101.177.32:2219" >> ichibacoin.conf
echo "addnode=46.166.139.73:2219" >> ichibacoin.conf
echo "addnode=51.158.116.210:2219" >> ichibacoin.conf
echo "addnode=74.141.92.7:2219" >> ichibacoin.conf
echo "addnode=80.64.210.13:2219" >> ichibacoin.conf
echo "addnode=95.179.135.165:2219" >> ichibacoin.conf
echo "addnode=95.216.53.33:2219" >> ichibacoin.conf
echo "addnode=138.197.150.216:2219" >> ichibacoin.conf
echo "addnode=136.243.80.213:2219" >> ichibacoin.conf
echo "addnode=188.68.43.197:2219" >> ichibacoin.conf
echo "addnode=136.243.40.223:2219" >> ichibacoin.conf
echo "addnode=80.64.210.10:2219" >> ichibacoin.conf
echo "addnode=217.69.6.156:2219" >> ichibacoin.conf
echo "addnode=45.32.234.220:2219" >> ichibacoin.conf
echo "addnode=95.216.38.85:2219" >> ichibacoin.conf
echo "addnode=45.32.7.4:2219" >> ichibacoin.conf
echo "addnode=212.174.87.195:2219" >> ichibacoin.conf
echo "addnode=167.86.97.8:2219" >> ichibacoin.conf
echo "addnode=46.98.13.228:2219" >> ichibacoin.conf
echo "addnode=194.44.175.186:2219" >> ichibacoin.conf
echo "addnode=167.86.88.222:2219" >> ichibacoin.conf
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
