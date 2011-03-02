#!/bin/sh

#echo
#echo "Installing Mono on Nginx with Razor support"
#echo

mkdir -p /srv/www/monodocs

#echo
#echo "Taking care of dependencies"
#echo

zypper --non-interactive addrepo http://ftp.novell.com/pub/mono/download-stable/openSUSE_11.3 mono-stable
zypper --non-interactive addrepo http://download.opensuse.org/repositories/openSUSE:/Factory:/Contrib/openSUSE_11.3/ openSUSE:Factory:Contrib 
zypper --non-interactive refresh --repo mono-stable
zypper --non-interactive refresh --repo openSUSE:Factory:Contrib 
zypper --non-interactive dist-upgrade --repo mono-stable
zypper --non-interactive dist-upgrade --repo openSUSE:Factory:Contrib 
zypper --non-interactive install mono unzip xsp4 nginx monotools-server mono-data mono-data-sqlite mono-data-oracle mono-data-postgresql mono-mvc mono-nunit mono-tools mono-extras mono-addins mono-web mono-cyclic libgdiplus0

#echo
#echo "Configuring system"
#echo

chkconfig --add nginx

#echo
#echo "removing previous mono deamon (if existing)"
#echo

chkconfig --del monoserve
rm /etc/init.d/monoserve

#echo
#echo "creating mono deamon"
#echo

cp ./monoserve.sh /etc/init.d/monoserve
chmod +x /etc/init.d/monoserve
chkconfig --add monoserve

#echo
#echo "update nginx configuration"
#echo

rm /etc/nginx/nginx.conf
cp ./nginx.conf /etc/nginx/nginx.conf
rm /etc/nginx/fastcgi_params
cp ./fastcgi_params /etc/nginx/sites-available/fastcgi_params

rm /srv/www/monodocs/monosites.conf
cp ./monosites.conf /srv/www/monodocs/monosites.conf

#echo
#echo "configuration end, adding default content"
#echo

rm -r /src/www/monodocs/default
cp ./default /src/www/monodocs/default
cp ./libs/* /src/www/monodocs/default/bin/
cp ./Default.aspx /src/www/monodocs/default/

/etc/init.d/nginx restart 
/etc/init.d/monoserve start
