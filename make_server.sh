#!/bin/bash



## Scripts  to generate  wildcard  certificates using  the OpenSSL  command-line
## tools.
##
## Copyright (C) 2021 Ralf Stephan (RaSt) <me@ralf-stephan.name>
##
## This script is free software: you  can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation, either  version 3 of the  License, or (at your  option) any later
## version.
##
## This script is  distributed in the hope  that it will be  useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR  A PARTICULAR  PURPOSE.   See the  GNU General  Public  License for  more
## details.
##
## You should have received a copy of  the GNU General Public License along with
## this     program     in     the     file    COPYING.      If     not,     see
## <https://www.gnu.org/licenses/>.



set -o errexit
set -o pipefail
set -o nounset
IFS=$'\n\t'



declare DIR=$(pwd)

declare MODE_STRICT=400
declare MODE_LOOSE=600

if [[ -z "${TS}" ]]; then
    echo 'set environment variable TS'
    exit
else
    echo 'TS = "'${TS}'"'
fi

cd ${DIR}

chmod ${MODE_SCRICT} ./server/openssl.cnf.tmp

cp ./server/openssl.cnf.tmp \
   ./server/openssl.${TS}.cnf

sed -i "s/{{{TS}}}/${TS}/g" ./server/openssl.${TS}.cnf

chmod ${MODE_SCRICT} ./server/openssl.${TS}.cnf



# create server key

openssl genrsa -out ./server/private/server.key.${TS}.pem \
               2048

chmod ${MODE_SCRICT} ./server/private/server.key.${TS}.pem



# create server certificate signing request

openssl req -config ./server/openssl.${TS}.cnf \
            -new \
            -sha256 \
            -extensions v3_req \
            -key ./server/private/server.key.${TS}.pem \
            -out ./server/csr/server.csr.${TS}.pem

chmod ${MODE_SCRICT} ./server/csr/server.csr.${TS}.pem



# verify server certificate signing request

openssl req -noout \
	    -text \
	    -in ./server/csr/server.csr.${TS}.pem \
	    > ./server/csr/server.csr.${TS}.pem.txt

chmod ${MODE_SCRICT} ./server/csr/server.csr.${TS}.pem.txt

less ./server/csr/server.csr.${TS}.pem.txt



# create server certificate (signed by ???)

openssl ca -config ./intermediate/openssl.${TS}.cnf \
           -cert intermediate/certs/intermediate.cert.${TS}.pem \
           -keyfile intermediate/private/intermediate.key.${TS}.pem \
           -extensions server_cert \
           -days 365 \
           -notext \
           -md sha256 \
           -in ./server/csr/server.csr.${TS}.pem \
           -out ./server/certs/server.cert.${TS}.pem

chmod ${MODE_SCRICT} ./server/certs/server.cert.${TS}.pem

openssl x509 -inform pem \
             -in ./server/certs/server.cert.${TS}.pem \
             -outform der \
             -out ./server/certs/server.cert.${TS}.der

chmod ${MODE_SCRICT} ./server/certs/server.cert.${TS}.der

cp ./server/certs/server.cert.${TS}.pem \
   ./server/certs/server.cert.${TS}.crt

chmod ${MODE_SCRICT} ./server/certs/server.cert.${TS}.crt



# verify server certificate (signed by ???)

openssl x509 -noout \
             -text \
             -in ./server/certs/server.cert.${TS}.pem \
             > ./server/certs/server.cert.${TS}.pem.txt

chmod ${MODE_SCRICT} ./server/certs/server.cert.${TS}.pem.txt

less ./server/certs/server.cert.${TS}.pem.txt



# verify server certificate (signed by intermediate) against root certificate

openssl verify -CAfile ./intermediate/certs/intermediate-chain.cert.${TS}.pem \
                       ./server/certs/server.cert.${TS}.pem \
                       > ./server/certs/server.cert.${TS}.pem.cafile

chmod ${MODE_SCRICT} ./server/certs/server.cert.${TS}.pem.cafile

less ./server/certs/server.cert.${TS}.pem.cafile



# generate server certificate chain file

cat ./server/certs/server.cert.${TS}.pem \
    ./intermediate/certs/intermediate.cert.${TS}.pem \
    ./root/certs/root.cert.${TS}.pem \
    > ./server/certs/server-chain.cert.${TS}.pem

chmod ${MODE_SCRICT} ./server/certs/server-chain.cert.${TS}.pem

openssl x509 -inform pem \
             -in ./server/certs/server-chain.cert.${TS}.pem \
             -outform der \
             -out ./server/certs/server-chain.cert.${TS}.der

chmod ${MODE_SCRICT} ./server/certs/server-chain.cert.${TS}.der

cp ./server/certs/server-chain.cert.${TS}.pem \
   ./server/certs/server-chain.cert.${TS}.crt

chmod ${MODE_SCRICT} ./server/certs/server-chain.cert.${TS}.crt



# veryfy server certificate chain file

less ./server/certs/server-chain.cert.${TS}.pem



exit



# keys
#
# ./root/private/root.key.1617302341.pem
#
# ./intermediate/private/intermediate.key.1617302341.pem
#
# ./server/private/server.key.1617302341.pem
#
cp ./server/private/server.key.1617302341.pem /etc/ssl/private/
chmod 640 /etc/ssl/private/server/private/server.key.1617302341.pem
chown root:ssl-cert /etc/ssl/private/server/private/server.key.1617302341.pem
#
# ./ocsp/private/ocsp.server.key.pem
#
# restart apache
#
sudo systemctl reload apache2



# certificate as .pem
#
# ./root/certs/root.cert.1617302341.pem
#
# ./intermediate/certs/intermediate.cert.1617302341.pem
#
# ./server/certs/server.cert.1617302341.pem
#
#cp ./server/certs/server.cert.1617302341.pem /etc/ssl/certs/
#chmod 644 /etc/ssl/certs/server/certs/server.cert.1617302341.pem
#chown root:root /etc/ssl/certs/server/certs/server.cert.1617302341.pem
#
# ./ocsp/certs/ocsp.server.cert.1617302341.pem
#
# restart apache
#
#sudo systemctl reload apache2



# certificate as .der
#
# ./root/certs/root.cert.1617302341.der
#
# ./intermediate/certs/intermediate.cert.1617302341.der
#
# ./server/certs/server.cert.1617302341.der
#
# ./ocsp/certs/ocsp.server.cert.1617302341.der
#
# restart apache
#
#sudo systemctl reload apache2



# certificate as .crt
#
# ./root/certs/root.cert.1617302341.crt
#
cp ./server/certs/server.cert.1617302341.crt /usr/share/ca-certificates/server/
chmod 644 /usr/share/ca-certificates/server/server.cert.1617302341.crt
chown root:root /usr/share/ca-certificates/server/server.cert.1617302341.crt
#
# ./intermediate/certs/intermediate.cert.1617302341.crt
#
cp ./intermediate/certs/intermediate.cert.1617302341.crt /usr/share/ca-certificates/server/
chmod 644 /usr/share/ca-certificates/server/intermediate/certs/intermediate.cert.1617302341.crt
chown root:root /usr/share/ca-certificates/server/intermediate/certs/intermediate.cert.1617302341.crt
#
# ./server/certs/server.cert.1617302341.crt
#
cp ./server/certs/server.cert.1617302341.crt /usr/share/ca-certificates/server/
chmod 644 /usr/share/ca-certificates/server/server/certs/server.cert.1617302341.crt
chown root:root /usr/share/ca-certificates/server/server/certs/server.cert.1617302341.crt
#
# ./ocsp/certs/ocsp.server.cert.1617302341.crt
#
cp ./ocsp/certs/ocsp.server.cert.1617302341.crt /usr/share/ca-certificates/server/
chmod 644 /usr/share/ca-certificates/server/ocsp/certs/ocsp.server.cert.1617302341.crt
chown root:root /usr/share/ca-certificates/server/ocsp/certs/ocsp.server.cert.1617302341.crt
#
# reconfigure certificates
#
sudo dpkg-reconfigure ca-certificates



# certificate chain as .pem



# certificate chain as .der



# certificate chain as .crt
#
# ./root/certs/root-chain.cert.1617302341.crt
#
# ./intermediate/certs/intermediate-chain.cert.1617302341.crt
#
# ./server/certs/server-chain.cert.1617302341.crt
cp ./server/certs/server-chain.cert.1617302341.crt /etc/apache2/ssl.crt/server-chain.cert.1617302341.crt
chmod 644 /etc/apache2/ssl.crt/server-chain.cert.1617302341.crt
chown root:root /etc/apache2/ssl.crt/server-chain.cert.1617302341.crt
#
# ./ocsp/certs/ocsp-chain.cert.1617302341.crt
#
sudo systemctl reload apache2



# check
#
# openssl s_client -showcerts -servername localhost -connect localhost:443 | less
#
# openssl s_client -showcerts -servername mod.localhost -connect mod.localhost:443 | less





# all directories

find ./* -type d -exec chmod 700 {} \;

# all files

find ./* -type f -exec chmod ${MODE_STRICT} {} \;

# all keys

find ./* -type f -name '*.key.*' -exec chmod ${MODE_STRICT} {} \;

# scripts

find ./* -type f -name '*.sh' -exec chmod 700 {} \;

# README, COPYING

chmod ${MODE_LOOSE} ./README
chmod ${MODE_LOOSE} ./COPYING

# configuration files

find ./* -type f -name 'openssl.*' -exec chmod ${MODE_LOOSE} {} \;

# databease files

find ./* -type f -name 'crlnumber' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'crlnumber.old' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'index.txt' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'index.txt.old' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'index.txt.attr' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'index.txt.attr.old' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'serial' -exec chmod ${MODE_LOOSE} {} \;
find ./* -type f -name 'serial.old' -exec chmod ${MODE_LOOSE} {} \;

find ./* -type f -name '*~' -exec rm {} \;
