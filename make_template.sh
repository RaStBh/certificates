#!/bin/bash



set -e

declare DIR=$(pwd)

if [[ -z "${TS}" ]]; then
    echo 'set environment variable TS'
    exit
else
    echo 'TS = "'${TS}'"'
fi

cd ${DIR}



create ??? key

create ??? certificate signing request

verify ??? certificate signing request

create ??? certificate (signed by ???)

verify ??? certificate (signed by ???)

verify ??? certificate (signed by ???) against ??? certificate

generate ??? certificate chain file

veryfy ??? certificate chain file

reload

check

openssl s_client -showcerts -servername localhost -connect localhost:443 | less
openssl s_client -showcerts -servername mod.localhost -connect mod.localhost:443 | less
