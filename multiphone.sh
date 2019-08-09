#!/bin/bash
echo "Starting PHONE setup"
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/Xlspo4p_zttqkQ -O /usr/local/bin/phonecoind
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/SJV2jq7QajQF2Q -O /usr/local/bin/phonecoin-cli
chmod +x /usr/local/bin/phonecoin*
chmod +x phonecoin-cli phonecoind
#node addressing/interrogation
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/phonecoin-cli -conf=/home/$alias/.phonecoin/phonecoin.conf -datadir=/home/$alias/.phonecoin \$@" >> $alias
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
echo "#PIDFile=/home/$alias/.phonecoin/.phonecoin.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/phonecoind -daemon -conf=/home/$alias/.phonecoin/phonecoin.conf -datadir=/home/$alias/.phonecoin">> $alias.service
echo "ExecStop=-/usr/local/bin/phonecoin-cli -conf=/home/$alias/.phonecoin/phonecoin.conf -datadir=/home/$alias/.phonecoin stop" >> $alias.service
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/CIxH25oB-ho_dA -O phonecoin.zip
unzip phonecoin.zip
rm phonecoin.zip
#make conf file
cd .phonecoin
echo "rpcuser=$rpcuser" >> phonecoin.conf
echo "rpcpassword=$rpcpass" >> phonecoin.conf
echo "rpcport=$rpc" >> phonecoin.conf
echo "rpcallowip=127.0.0.1" >> phonecoin.conf
echo "port=$port" >> phonecoin.conf
echo "listen=1" >> phonecoin.conf
echo "server=1" >> phonecoin.conf
echo "daemon=0" >> phonecoin.conf
echo "txindex=1" >> phonecoin.conf
echo "maxconnections=64" >> phonecoin.conf
echo "bind=$ipadd" >> phonecoin.conf
echo "masternode=1" >> phonecoin.conf
echo "masternodeaddr=$ipadd:$port" >> phonecoin.conf
echo "masternodeprivkey=$key" >> phonecoin.conf
echo "addnode=5.189.168.79:4188" >> phonecoin.conf
echo "addnode=dnsseed.phonecoinnodes.com" >> phonecoin.conf
echo "addnode=dnsseed2.phonecoinnodes.com" >> phonecoin.conf
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
