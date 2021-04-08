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

chmod ${MODE_STRICT} ./ocsp/openssl.cnf

cp ./ocsp/openssl.cnf.tmp \
   ./ocsp/openssl.${TS}.cnf

sed -i "s/{{{TS}}}/${TS}/g" ./ocsp/openssl.${TS}.cnf

chmod ${MODE_STRICT} ./ocsp/openssl.${TS}.cnf



# create ocsp key

openssl genrsa -aes256 \
        -out ./ocsp/private/ocsp.server.key.pem \
	4096

chmod ${MODE_STRICT} ./ocsp/private/ocsp.server.key.pem



# create ocsp certificate signing request

openssl req -config ./ocsp/openssl.${TS}.cnf \
            -new \
            -sha256 \
            -key ./ocsp/private/ocsp.server.key.pem \
            -out ./ocsp/csr/ocsp.server.csr.${TS}.pem

chmod ${MODE_STRICT} ./ocsp/csr/ocsp.server.csr.${TS}.pem



# verify ocsp certificate signing request

openssl req -noout \
            -text \
            -in ./ocsp/csr/ocsp.server.csr.${TS}.pem \
            > ./ocsp/csr/ocsp.server.csr.${TS}.pem.txt

chmod ${MODE_STRICT} ./ocsp/csr/ocsp.server.csr.${TS}.pem.txt

less ./ocsp/csr/ocsp.server.csr.${TS}.pem.txt



# create ocsp certificate (signed by ???)

openssl ca -config ./intermediate/openssl.${TS}.cnf \
           -cert intermediate/certs/intermediate.cert.${TS}.pem \
           -keyfile intermediate/private/intermediate.key.${TS}.pem \
           -extensions ocsp \
           -days 3650 \
           -notext \
           -md sha256 \
           -in ./ocsp/csr/ocsp.server.csr.${TS}.pem \
           -out ./ocsp/certs/ocsp.server.cert.${TS}.pem

chmod ${MODE_STRICT} ./ocsp/certs/ocsp.server.cert.${TS}.pem

openssl x509 -inform pem \
             -in ./ocsp/certs/ocsp.server.cert.${TS}.pem \
             -outform der \
             -out ./ocsp/certs/ocsp.server.cert.${TS}.der

chmod ${MODE_STRICT} ./ocsp/certs/ocsp.server.cert.${TS}.der

cp ./ocsp/certs/ocsp.server.cert.${TS}.pem \
   ./ocsp/certs/ocsp.server.cert.${TS}.crt

chmod ${MODE_STRICT} ./ocsp/certs/ocsp.server.cert.${TS}.crt



# verify ocsp certificate (signed by intermediate)

openssl x509 -noout \
             -text \
             -in ./ocsp/certs/ocsp.server.cert.${TS}.pem \
             > ./ocsp/certs/ocsp.server.cert.${TS}.pem.txt

chmod ${MODE_STRICT} ./ocsp/certs/ocsp.server.cert.${TS}.pem.txt

less ./ocsp/certs/ocsp.server.cert.${TS}.pem.txt



# verify ??? certificate (signed by ???) against ??? certificate

openssl verify -CAfile ./intermediate/certs/intermediate-chain.cert.${TS}.pem \
                       ./ocsp/certs/ocsp.server.cert.${TS}.pem \
                       > ./ocsp/certs/ocsp.server.cert.${TS}.pem.cafile

chmod ${MODE_STRICT} ./ocsp/certs/ocsp.server.cert.${TS}.pem.cafile

less ./ocsp/certs/ocsp.server.cert.${TS}.pem.cafile



# generate ??? certificate chain file



# veryfy ??? certificate chain file



# reload
