#!/bin/bash

# Please change the paths to your setups before executing.

echo '
******************************************************
*    _____ __                       ______           *
*   / ___// /_____  _________ ___  / ____/_  _____   *
*   \__ \/ __/ __ \/ ___/ __ `__ \/ __/ / / / / _ \  *
*  ___/ / /_/ /_/ / /  / / / / / / /___/ /_/ /  __/  *
* /____/\__/\____/_/  /_/ /_/ /_/_____/\__, /\___/   *
*                                     /____/         *
*                                                    *
******************************************************
'

echo "[*] MayoMail Let's Encrypt Renewal Script"
echo ""

zimbra_path='/opt/zimbra'

# Backup Certs
rm -rf /opt/certs-`date -I`
mv /opt/certs /opt/certs-`date -I`
mkdir /opt/certs
cd /opt/certs/

# Renewal
/opt/letsencrypt/letsencrypt-auto renew

# Moving scripts
cp /etc/letsencrypt/live/<<<DOMAIN NAME>>>/*pem /opt/certs/

# Insert Zimbra CA
echo """
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
""" >> /opt/certs/chain.pem
chown zimbra:zimbra /opt/certs/*.pem

# Verifying
sudo -u zimbra -H bash -c "$zimbra_path/bin/zmcertmgr verifycrt comm privkey.pem cert.pem chain.pem"

read -p "[*] Everything good? [Please Enter To Continue...]" nothing

cp -a $zimbra_path/ssl/zimbra $zimbra_path/ssl/zimbra.$(date "+%Y%m%d")
cp /opt/certs/privkey.pem $zimbra_path/ssl/zimbra/commercial/commercial.key
chown zimbra:zimbra $zimbra_path/ssl/zimbra/commercial/commercial.key

read -p "[*] Start Deployment? [Please Enter To Continue...]" nothing
sudo -u zimbra -H bash -c "$zimbra_path/bin/zmcertmgr deploycrt comm cert.pem chain.pem"
sudo -u zimbra -H bash -c "$zimbra_path/bin/zmcontrol restart"
