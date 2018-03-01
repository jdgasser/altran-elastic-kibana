#parametrage mysql 
service mysql restart
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

#config kibana
sed -i "s/\#server.port/server.port/g" /etc/kibana/kibana.yml
sed -i "s/\#server.host/server.host/g" /etc/kibana/kibana.yml
sed -i "s/\"localhost\"/\"0.0.0.0\"/g" /etc/kibana/kibana.yml
sed -i "s/\#elasticsearch.url/elasticsearch.url/g" /etc/kibana/kibana.yml
sed -i "s/\#elasticsearch.username\:\ \"user\"/\elasticsearch.username\:\ \"elastic\"/g" /etc/kibana/kibana.yml
sed -i "s/\#elasticsearch.password\:\ \"user\"/\elasticsearch.password\:\ \"elastic\"/g" /etc/kibana/kibana.yml
touch /var/log/kibana.log
chown kibana:kibana /var/log/kibana.log

#config elastic
cd /usr/share/elasticsearch
echo y | ./bin/elasticsearch-plugin install x-pack
service elasticsearch restart
sleep 15
{ echo elastic && sleep 2 ; echo elastic && sleep 2; echo kibana && sleep 2; echo kibana && sleep 2; echo logstash && sleep 2; echo logstash && sleep 2; } | ./bin/x-pack/setup-passwords interactive -b
service kibana restart

sed -i "s/PORT_MYSQL/'$PORT_MYSQL'/g" /etc/logstash/conf.d/logstash.conf

rm -rf /root/script.sh
touch /root/script.sh
