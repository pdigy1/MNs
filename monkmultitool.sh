#!/bin/bash
#Coin info #update here#
coinname=monkey
coinnamed=monkeyd
coinnamecli=monkey-cli
ticker=monkey
coindir=monkey
binaries='https://yadi.sk/d/_6xPQjA0vey8wA'
snapshot='https://yadi.sk/d/hg2Z1ayGrjghdg'
port=37233
rpcport=37232
pass=`pwgen 14 1 b`
rpcuser=`pwgen 14 1 b`
rpcpass=`pwgen 36 1 b`
#Tool menu
echo -e '\e[4mStarting monkey MultiNode tools\e[24m'
echo "Installing script dependancies"
apt install zip unzip -y -y
echo "Making sure your VPS is up to date"
apt update -y
echo "zip tool downloaded and apt update completed"
echo -e '\e[4mWelcome to the monkey Multitools\e[24m'
echo "Please pick a number from the list to start tool"
echo "1 - Wallet update"
echo "2 - Chain repair"
echo "3 - Remove MasterNode"
echo "4 - Masternode install"
read start
case $start in
#Tools
    1) echo "Starting MasterNode wallet update tool"
    echo "Checking home directory for MN alias's"
    ls /home
    echo "Above are the alias names for installed MN's"
    echo "please enter masternode alias name"
    read alias
    echo "Please enter updated wallet download zip link in full"
    echo "Here is the V 2.0 wallet link used in this script"
    echo "$binaries"
    read bin
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    cd /usr/local/bin
    wget $bin -O ${coinname}.zip
    unzip ${coinname}.zip
    rm ${coinname}.zip
    chmod +x ${coinnamecli} ${coinnamed}
    systemctl start $alias
    echo "Binaries updated for $alias"
    echo "Please wait a moment and then check version number with $alias getinfo"
    echo "If you are running multiple $ticker MNs you will need to restart the other nodes!"
    echo "Example restart command below"
    echo "systemctl restart $alias"
    exit
    ;;
    2) echo "Starting chain repair tool"
    echo "Checking home directory for MN alias's"
    ls /home
    echo "Above are the alias names for installed MN's"
    echo "Please enter MN alias name"
    read alias
    echo "Please enter bootstrap/snapshot zip link in full"
    echo "Here is the snapshot this script uses for MN install"
    echo "$snapshot"
    read snap
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    cd /home/$alias
    wget $snap -O ${coindir}.zip
    find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
    unzip ${coindir}.zip
    rm ${coindir}.zip
    cd /home
    chown -R $alias $alias
    systemctl start $alias
    echo "Snapshot updated for $alias"
    echo "Please wait for a while.. and then use $alias getinfo to check block height against explorer"
    exit
    ;;
    3) echo "Starting Removal tool"
    echo "Checking home directory for MN alias's"
    ls /home
    echo "Above are the alias names for installed MN's"
    echo "please enter MN alias name"
    read alias
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    systemctl disable $alias
    rm /usr/local/bin/$alias
    rm /etc/systemd/system/$alias.service
    deluser $alias
    rm -r /home/$alias
    echo "$alias removed"
    exit
    ;;
    4)  echo "Starting monkey MasterNode install"
    ;;
    esac
#get user input alias and bind set varible#
echo "Checking home directory for MN alias's"
ls /home
echo "Above are the alias names for installed MN's"
echo -e '\e[4mPlease enter MN alias. Example mn3\e[24m'
read alias
echo -e '\e[4mEnter masternode key\e[24m'
read key
echo -e '\e[4mPlease enter port number. Default is '$port' for MultiNode use unique\e[24m'
read port
echo -e '\e[4mPlease enter RPC port number. Default is '$rpcport' for MultiNode use unique\e[24m'
read rpcport
#Install dependancies
apt install libboost-all-dev -y -y
add-apt-repository ppa:bitcoin/bitcoin -y -y
apt update  -y -y
apt-get install libdb4.8-dev libdb4.8++-dev -y -y
apt install libminiupnpc-dev -y -y
apt install libzmq5 -y -y
#script dependency's #do not remove#
echo "Installing install script dependency's"
apt-get install pwgen -y
apt update
echo "Installed script dependency's"
echo "Setting needed variables for script"
#checks IP against site and set IP/bind variable#
echo "Finding IP address"
ipadd=$(curl http://ifconfig.me/ip)
echo "your ip is $ipadd"
echo "Auto variables set"
#setup user#
echo "Setting up user $alias"
adduser "$alias" <<EOF
echo ${pass}
echo ${pass}
/
/
/
/
/
/
/
EOF
echo "User $alias setup"
#Install node binaries#
echo "Installing node binaries for $alias"
cd /usr/local/bin
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/_6xPQjA0vey8wA -O ${coinname}.zip
unzip ${coinname}.zip
chmod +x ${coinnamecli} ${coinnamed}
rm ${coinanme}.zip
echo "$alias node binaries installed"
#Node intergration#
echo "Node Intergration"
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir \$@" >> $alias
chmod +x $alias
cd /etc/systemd/system
echo "Node Intergration done"
#Setup service#
echo "Setting up service"
echo "[Unit]" >> $alias.service
echo "Description=$ticker service" >> $alias.service
echo "After=network.target" >> $alias.service
echo "" >> $alias.service
echo "[Service]" >> $alias.service
echo "User=$alias" >> $alias.service
echo "Group=root" >> $alias.service
echo "" >> $alias.service
echo "Type=forking" >> $alias.service
echo "#PIDFile=/home/$alias/.$coindir/.$coinname.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/$coinnamed -daemon -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir">> $alias.service
echo "ExecStop=-/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir stop" >> $alias.service
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
echo "Service setup and enabled"
#update chain files get snapshot#
echo "Downloading $coinname snapshot"
cd /home/$alias
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/hg2Z1ayGrjghdg -O ${coindir}.zip
unzip ${coindir}.zip
rm ${coindir}.zip
echo "$coinname snapshot downloaded and unpacked"
#make conf file#
echo "Creating $coinname conf file"
cd .$coindir
echo "rpcuser="$rpcuser"" >> $coinname.conf
echo "rpcpassword="$rpcpass"" >> $coinname.conf
echo "rpcport=$rpcport" >> $coinname.conf
echo "rpcallowip=127.0.0.1" >> $coinname.conf
echo "port=$port" >> $coinname.conf
echo "listen=1" >> $coinname.conf
echo "server=1" >> $coinname.conf
echo "daemon=0" >> $coinname.conf
echo "txindex=1" >> $coinname.conf
echo "maxconnections=64" >> $coinname.conf
echo "bind=$ipadd" >> $coinname.conf
echo "masternode=1" >> $coinname.conf
echo "masternodeaddr=$ipadd:$port" >> $coinname.conf
echo "masternodeprivkey=$key" >> $coinname.conf
# echo "addnode=5.189.168.79:4188" >> $coinname.conf
# echo "addnode=dnsseed.monkeynodes.com" >> $coinname.conf
# echo "addnode=dnsseed2.monkeynodes.com" >> $coinname.conf
echo "$coinname conf file created"
#Set permisions and firewall rules#
echo "Setting permissions and firewall rules"
cd /home
chown -R $alias $alias
ufw allow $port/tcp comment "$alias port"
ufw allow $rpcport/tcp comment "$alias RPC port"
systemctl start $alias
echo "Permissions and firewall rules set"
echo "$ticker MN setup completed"
#Closeing/finish text#
echo -e '\e[4mMasternode setup complete for '$alias'\e[24m'
echo ""
echo "Alias name = $alias"
echo "IP/Bind = $ipadd"
echo "Port = $port"
echo "rpcport = $rpcport"
echo "MN key = $key"
echo "Password = $pass"
echo ""
echo "Please note that the port number in masternode.conf within your control/desktop wallet has to be 4188 but can be different on VPS"
echo "Please also note that if you are installing multiple MN's you will need to setup swap space"
echo -e '\e[4mEnter the information below into your masternode.conf file in control wallet with the addition of the collateral_output_txid\e[24m'
echo -e '\e[4m'$alias' '$ipadd':37233 '$key'\e[24m'
echo ""
echo -e '\e[4mThen save masternode.conf, restart your control wallet and start your new '$ticker' MasterNode\e[24m'
echo -e '\e[4mWait for sync and then use '$alias' getinfo or '$alias' getmasternodestatus to check node\e[24m'
echo ""
echo "For more information or support please visit the monkey Masternode-support channel on Discord"
echo "https://discord.gg/xxjZzJE"
exit
