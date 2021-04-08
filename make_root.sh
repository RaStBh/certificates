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

chmod ${MODE_STRICT} ./root/openssl.cnf.tmp

cp ./root/openssl.cnf.tmp \
   ./root/openssl.${TS}.cnf

sed -i "s/{{{TS}}}/${TS}/g" ./root/openssl.${TS}.cnf

chmod ${MODE_STRICT} ./root/openssl.${TS}.cnf



# create root key

openssl genrsa -aes256 \
               -out ./root/private/root.key.${TS}.pem \
               4096

chmod ${MODE_STRICT} ./root/private/root.key.${TS}.pem



# create ??? certificate signing request



# verify ??? certificate signing request



# create root certificate (signed by root)

openssl req -config ./root/openssl.${TS}.cnf \
            -key ./root/private/root.key.${TS}.pem \
            -new \
            -x509 \
            -days 36500 \
            -sha256 \
            -extensions v3_ca \
            -out ./root/certs/root.cert.${TS}.pem

chmod ${MODE_STRICT} ./root/certs/root.cert.${TS}.pem

openssl x509 -inform pem \
	     -in ./root/certs/root.cert.${TS}.pem \
	     -outform der \
             -out ./root/certs/root.cert.${TS}.der

chmod ${MODE_STRICT} ./root/certs/root.cert.${TS}.der

cp ./root/certs/root.cert.${TS}.pem \
   ./root/certs/root.cert.${TS}.crt

chmod ${MODE_STRICT} ./root/certs/root.cert.${TS}.crt



# verify server certificate (signed by root)

openssl x509 -noout \
	     -text \
	     -in ./root/certs/root.cert.${TS}.pem \
	     > ./root/certs/root.cert.${TS}.pem.txt

chmod ${MODE_STRICT} ./root/certs/root.cert.${TS}.pem.txt

less ./root/certs/root.cert.${TS}.pem.txt



# verify ??? certificate (signed by ???) against ??? certificate



# generate ??? certificate chain file



# veryfy ??? certificate chain file



# reload
