#!/bin/bash
openssl ecparam -list_curves

# generate private keys for a curve
openssl ecparam -name prime256v1 -genkey -noout -out key-gw.pem
openssl ecparam -name prime256v1 -genkey -noout -out key-proxy.pem

# optional: generate corresponding public key
#openssl ec -in key.pem -pubout -out public-key.pem

# create self-signed certificates
openssl req -new -x509 -key key-gw.pem -out cert-gw.pem -days 365 -subj "/C=AU/CN=fleetspeak-server" -addext "subjectAltName = DNS:fleetspeak-server"
openssl req -new -x509 -key key-proxy.pem -out cert-proxy.pem -days 365 -subj "/C=AU/CN=fleetspeak-proxy" -addext "subjectAltName = DNS:fleetspeak-proxy"

export FRONTEND_PEM="$(cat cert-gw.pem | sed 's/^/      /g' | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/\$/\\$/g')"
export FRONTEND_CERT=$(sed ':a;N;$!ba;s/\n/\\\\n/g' cert-gw.pem)
export FRONTEND_KEY=$(sed ':a;N;$!ba;s/\n/\\\\n/g' key-gw.pem)

echo $FRONTEND_PEM
echo $FRONTEND_CERT
echo $FRONTEND_KEY

sed -i "s@FRONTEND_CERTIFICATE@${FRONTEND_PEM}@" ./config/grr-server/server.local.yaml

sed -i 's@FRONTEND_CERTIFICATE@'"$FRONTEND_CERT"'@' ./config/fleetspeak-frontend/components.textproto
sed -i 's@FRONTEND_CERTIFICATE@'"$FRONTEND_CERT"'@' ./config/grr-client/config.textproto

sed -i 's@FRONTEND_KEY@'"$FRONTEND_KEY"'@' ./config/fleetspeak-frontend/components.textproto
