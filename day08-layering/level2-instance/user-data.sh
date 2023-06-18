sudo yum update -y
sudo yum install git httpd -y 
git clone https://github.com/gabrielecirulli/2048.git
cp -R 2048/* /var/www/html
systemctl start httpd && systemctl enable httpd

