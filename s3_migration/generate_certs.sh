#!/bin/bash

if [[ -z $1 ]]; then
  echo "Provide a serial id."
  exit 1
fi

#Simple Helper script to Generate a client and server set of pems.

# ROOT
openssl req -out ca.pem -new -x509 

# SERIAL
echo $1 > file.srl

# SERVER
openssl genrsa -out server.key 1024 
openssl req -key server.key -new -out server.req 
openssl x509 -req -in server.req -CA CA.pem -CAkey privkey.pem -CAserial file.srl -out server.pem 

# CLIENT
openssl genrsa -des3 -out client.key 1024 
openssl genrsa -out client.key 1024 
openssl req -key client.key -new -out client.req 
openssl x509 -req -in client.req -CA CA.pem -CAkey privkey.pem -CAserial file.srl -out client.pem 
