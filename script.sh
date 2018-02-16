#installation des clés publiques/privées
eval `ssh-agent -s`
chmod 0600 /root/key_rsa
ssh-add /root/key_rsa
rm -rf /root/key_rsa
	
#Git en master
mkdir $HOME_GIT
cd $HOME_GIT
git init
git pull $URL_GIT

sh $HOME_GIT/install/install.sh

rm -rf /root/script.sh
touch /root/script.sh
