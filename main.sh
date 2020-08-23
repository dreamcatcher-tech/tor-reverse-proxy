#!/bin/bash

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

if [[ ! -z "${PRIVATE_KEY}" ]]
then
    echo "[+] Saving PRIVATE_KEY to disk"
    echo "${PRIVATE_KEY}" | base64 -d > /web/hs_ed25519_secret_key
fi

tor -f /etc/tor/torrc