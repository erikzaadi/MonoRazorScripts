#!/bin/sh

echo
echo "Installing Mono on Nginx with Razor support"
echo

mkdir -p /srv/www/monodocs

echo
echo "Taking care of dependencies"
echo

zypper -n addrepo http://ftp.novell.com/pub/mono/download-stable/openSUSE_11.4 mono-stable
zypper -n addrepo http://download.opensuse.org/repositories/server:/http/openSUSE_11.4/ http-server
zypper -n --gpg-auto-import-keys refresh --repo mono-stable
zypper -n --gpg-auto-import-keys refresh --repo http-server 
zypper -n dist-upgrade --repo mono-stable
zypper -n dist-upgrade --repo http-server 
zypper -n install unzip nginx-1.0 monotools-server mono-data mono-data-sqlite mono-data-oracle mono-data-postgresql mono-mvc mono-nunit mono-tools mono-extras mono-addins mono-web libgdiplus0

echo
echo "Configuring system"
echo

chkconfig --add nginx

echo
echo "removing previous mono deamon (if existing)"
echo

chkconfig --del monoserve
rm /etc/init.d/monoserve

echo
echo "creating mono deamon"
echo

cp ./monoserve.sh /etc/init.d/monoserve
chmod +x /etc/init.d/monoserve
chkconfig --add monoserve

echo
echo "update nginx configuration"
echo

rm /etc/nginx/nginx.conf
cp ./nginx.conf /etc/nginx/nginx.conf
rm /etc/nginx/fastcgi_params
cp ./fastcgi_params /etc/nginx/fastcgi_params

rm /srv/www/monodocs/monosites.conf
cp ./monosites.conf /srv/www/monodocs/monosites.conf

echo
echo "configuration end, adding default content"
echo

rm -r /srv/www/monodocs/default
cp -r ./default /srv/www/monodocs/default
cp ./libs/* /srv/www/monodocs/default/bin/
cp ./Default.aspx /srv/www/monodocs/default/

/etc/init.d/nginx restart 
/etc/init.d/monoserve start
echo
echo "Done.. Enjoy!"
echo
