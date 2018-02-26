#installation des clés publiques/privées
eval `ssh-agent -s`
chmod 0600 /root/key_rsa
ssh-add /root/key_rsa
	
#Git 
cd /home/
git clone $URL_GIT

#set hostname
echo $HOSTNAME > /etc/hostname

sh $HOME_GIT/install/install.sh

rm -rf /root/script.sh
touch /root/script.sh
