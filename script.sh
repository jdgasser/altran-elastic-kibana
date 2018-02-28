#parametrage mysql 
mysqladmin password root
sed -i "s/bind-address/\#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

#installation silencieuse de phpmyadmin
APP_PASS="root"
ROOT_PASS="root"
APP_DB_PASS="root"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ROOT_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_DB_PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
apt-get install -y phpmyadmin
service apache2 restart

sed -i "s/XXXX/$HOSTNAME/g" /root/.bashrc



rm -rf /root/script.sh
touch /root/script.sh
