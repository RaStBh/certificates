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

chmod ${MODE_LOOSE} ./intermediate/openssl.cnf.tmp

cp ./intermediate/openssl.cnf.tmp
   ./intermediate/openssl.${TS}.cnf

sed -i "s/{{{TS}}}/${TS}/g" ./intermediate/openssl.${TS}.cnf

chmod ${MODE_STRICT} ./intermediate/openssl.${TS}.cnf



# create intermediate key

openssl genrsa -aes256 \
               -out ./intermediate/private/intermediate.key.${TS}.pem \
               4096

chmod ${MODE_STRICT} ./intermediate/private/intermediate.key.${TS}.pem



# create intermediate certificate signing request

openssl req -config ./intermediate/openssl.${TS}.cnf \
            -new \
            -sha256 \
            -key ./intermediate/private/intermediate.key.${TS}.pem \
            -out ./intermediate/csr/intermediate.csr.${TS}.pem

chmod ${MODE_STRICT} ./intermediate/csr/intermediate.csr.${TS}.pem



# verify intermediate certificate signing request

openssl req -noout \
	    -text \
	    -in ./intermediate/csr/intermediate.csr.${TS}.pem \
	    > ./intermediate/csr/intermediate.csr.${TS}.pem.txt

chmod ${MODE_STRICT} ./intermediate/csr/intermediate.csr.${TS}.pem.txt

less ./intermediate/csr/intermediate.csr.${TS}.pem.txt



# create intermediate certificate (signed by root)

openssl ca -config ./root/openssl.${TS}.cnf \
	   -cert root/certs/root.cert.${TS}.pem \
           -keyfile root/private/root.key.${TS}.pem \
           -extensions v3_intermediate_ca \
           -days 3650 \
           -notext \
           -md sha256 \
           -in ./intermediate/csr/intermediate.csr.${TS}.pem \
           -out ./intermediate/certs/intermediate.cert.${TS}.pem

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate.cert.${TS}.pem

openssl x509 -inform pem \
	     -in ./intermediate/certs/intermediate.cert.${TS}.pem \
             -outform der \
	     -out ./intermediate/certs/intermediate.cert.${TS}.der

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate.cert.${TS}.der

cp ./intermediate/certs/intermediate.cert.${TS}.pem \
   ./intermediate/certs/intermediate.cert.${TS}.crt

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate.cert.${TS}.crt



# verify intermediate certificate (signed by root)

openssl x509 -noout \
	     -text \
	     -in ./intermediate/certs/intermediate.cert.${TS}.pem \
             > ./intermediate/certs/intermediate.cert.${TS}.pem.txt

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate.cert.${TS}.pem.txt

less ./intermediate/certs/intermediate.cert.${TS}.pem.txt



# verify intermediate certificate (signed by root) against root certificate

openssl verify -CAfile ./root/certs/root.cert.${TS}.pem \
	               ./intermediate/certs/intermediate.cert.${TS}.pem \
	               > ./intermediate/certs/intermediate.cert.${TS}.pem.cafile

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate.cert.${TS}.pem.cafile

less ./intermediate/certs/intermediate.cert.${TS}.pem.cafile



# generate intermediate certificate chain file

cat ./intermediate/certs/intermediate.cert.${TS}.pem \
    ./root/certs/root.cert.${TS}.pem \
    > ./intermediate/certs/intermediate-chain.cert.${TS}.pem

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate-chain.cert.${TS}.pem

openssl x509 -inform pem \
             -in ./intermediate/certs/intermediate-chain.cert.${TS}.pem \
             -outform der \
             -out ./intermediate/certs/intermediate-chain.cert.${TS}.der

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate-chain.cert.${TS}.der

cp ./intermediate/certs/intermediate-chain.cert.${TS}.pem \
   ./intermediate/certs/intermediate-chain.cert.${TS}.crt

chmod ${MODE_SCRICT} ./intermediate/certs/intermediate-chain.cert.${TS}.crt



# veryfy intermediate certificate chain file

less ./intermediate/certs/intermediate-chain.cert.${TS}.pem



# reload
