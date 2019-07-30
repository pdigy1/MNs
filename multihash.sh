#!/bin/bash
echo "Starting HASH setup"
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/n6-XOKyuyy4Pfg -O /usr/local/bin/hashd
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/X5b5Tkqx1OjWpA -O /usr/local/bin/hash-cli
chmod +x /usr/local/bin/hash*
chmod +x hash-cli hashd
#node addressing/interrogation
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/hash-cli -conf=/home/$alias/.hash/hash.conf -datadir=/home/$alias/.hash \$@" >> $alias
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
echo "#PIDFile=/home/$alias/.hash/.hash.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/hashd -daemon -conf=/home/$alias/.hash/hash.conf -datadir=/home/$alias/.hash">> $alias.service
echo "ExecStop=-/usr/local/bin/hash-cli -conf=/home/$alias/.hash/hash.conf -datadir=/home/$alias/.hash stop" >> $alias.service
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
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/qiLeOWADsbDaiA -O hashsnapshot.zip
unzip hashsnapshot.zip
rm hashsnapshot.zip
#make conf file
cd .hash
echo "rpcuser=$rpcuser" >> hash.conf
echo "rpcpassword=$rpcpass" >> hash.conf
echo "rpcport=$rpc" >> hash.conf
echo "rpcallowip=127.0.0.1" >> hash.conf
echo "port=$port" >> hash.conf
echo "listen=1" >> hash.conf
echo "server=1" >> hash.conf
echo "daemon=0" >> hash.conf
echo "txindex=1" >> hash.conf
echo "maxconnections=64" >> hash.conf
echo "bind=$ipadd" >> hash.conf
echo "masternode=1" >> hash.conf
echo "masternodeaddr=$ipadd:$port" >> hash.conf
echo "masternodeprivkey=$key" >> hash.conf
echo "addnode=5.189.168.79:4188" >> hash.conf
echo "addnode=dnsseed.hashnodes.com" >> hash.conf
echo "addnode=dnsseed2.hashnodes.com" >> hash.conf
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
