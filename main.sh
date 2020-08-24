#!/bin/bash

if [[ ! -z "${STATIC_URL}" ]]
then
    echo "[+] Static URL is: ${STATIC_URL}"
else
    echo "ERROR: must define STATIC_URL in environment"
    exit 1
fi

if [[ ! -z "${WEBSOCKET_URL}" ]]
then
    echo "[+] Websocket url at route /api is: ${WEBSOCKET_URL}"
else
    echo "ERROR: must define WEBSOCKET_URL in environment"
    exit 1
fi

cat > /etc/apache2/sites-available/tor-forward.conf << EOF
<VirtualHost 127.0.0.1:80>
    SSLProxyEngine On
    ProxyRequests Off
    ProxyPass "/api" ${WEBSOCKET_URL}
    ProxyPassReverse "/api" ${WEBSOCKET_URL}
    ProxyPass "/" ${STATIC_URL}
    ProxyPassReverse "/" ${STATIC_URL}
</VirtualHost>
EOF


if [[ ! -z "${PRIVATE_KEY}" ]]
then
    echo "[+] Saving PRIVATE_KEY to disk"
    echo "${PRIVATE_KEY}" | base64 -d > /web/hs_ed25519_secret_key
else
    echo "ERROR: must define PRIVATE_KEY in environment"
    exit 1
fi


echo '[+] Starting apache'
sudo /etc/init.d/apache2 start
echo '[+] Initializing local clock from:'$(date)
ntpdate -B -q time.nist.gov
echo '[+] Clock updated to '$(date)
echo '[+] Starting tor'

cat > /etc/tor/torrc << EOF
SocksPort 9052
DataDirectory /tmp/tor
HiddenServiceDir /web/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:80
Log notice stdout
EOF

tor -f /etc/tor/torrc