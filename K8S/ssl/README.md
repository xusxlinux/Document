
mkdir -pv /usr/local/src/ssl
cd /usr/local/src/ssl
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64


chmod +x cfssl*
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl_linux-amd64 /usr/local/bin/cfssl


echo "PATH=$PATH:/usr/local/bin/" >> /etc/profile
source /etc/profile
