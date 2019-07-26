#!/bin/bash
echo "Starting Ichiba setup"
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
wget https://github.com/IchibaCoin/ICHIBA/releases/download/v1.0/IchibaCoin-.Daemon_Ubuntu-16.04.tar.gz  -O ichibav1daemon.tar.gz
tar -xf ichibav1daemon.tar.gz # replace tar -xf with unzip for .zip
chmod +x ichibacoin-cli ichibacoind
rm ichibav1daemon.tar.gz #replace with coinbinaries.zip if zip
#node addressing/interrogation
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/stakecube-cli -conf=/home/$alias/.ichibacoin/ichibacoin.conf -datadir=/home/$alias/.ichibacoin \$@" >> $alias
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
#cd /home/$alias
#wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/xpOG8ZBlf4Syqw -O StakeCubeCore.zip
#unzip StakeCubeCore.zip
#rm StakeCubeCore.zip
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
