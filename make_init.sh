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
## <https:##www.gnu.org/licenses/>.



set -o errexit
set -o pipefail
set -o nounset
IFS=$'\n\t'



declare DIR=$(pwd)



# directories and files for root certificates

mkdir ${DIR}/root/
cd ${DIR}/root/

mkdir ./certs/
mkdir ./crl/
mkdir ./csr/
mkdir ./newcerts/
mkdir ./private/
chmod 700 ./private/
touch ./index.txt
echo 'unique_subject = no' > ./index.txt.attr
echo 1000 > ./serial
echo 1000 > ./crlnumber

cp /etc/ssl/openssl.cnf ./openssl.cnf



# directories and files for intermediate certificates

mkdir ${DIR}/intermediate/
cd ${DIR}/intermediate/

mkdir ./certs/
mkdir ./crl/
mkdir ./csr/
mkdir ./newcerts/
mkdir ./private/
chmod 700 ./private/
touch ./index.txt
echo 'unique_subject = no' > ./index.txt.attr
echo 1000 > ./serial
echo 1000 > ./crlnumber

cp /etc/ssl/openssl.cnf ./openssl.cnf



# directories and files for server certifictes

mkdir ${DIR}/server/
cd ${DIR}/server/

mkdir ./certs/
mkdir ./crl/
mkdir ./csr/
mkdir ./newcerts/
mkdir ./private/
chmod 700 ./private/
touch ./index.txt
echo 'unique_subject = no' > ./index.txt.attr
echo 1000 > ./serial
echo 1000 > ./crlnumber

cp /etc/ssl/openssl.cnf ./openssl.cnf



# directories for oscp certificates

mkdir ${DIR}/ocsp/
cd ${DIR}/ocsp/

mkdir ./certs/
mkdir ./crl/
mkdir ./csr/
mkdir ./newcerts/
mkdir ./private/
chmod 700 ./private/
touch ./index.txt
echo 'unique_subject = no' > ./index.txt.attr
echo 1000 > ./serial
echo 1000 > ./crlnumber

cp /etc/ssl/openssl.cnf ./openssl.cnf
