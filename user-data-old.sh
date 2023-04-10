#!/bin/bash

#Install AWS_CLI
sudo apt-get update
sudo apt-get install -y awscli jq

sudo mkdir /opt/tfe

#copy license file from S3
aws s3 cp s3://${bucket_name}/license.rli /tmp/license.rli
aws s3 cp s3://${bucket_name}/certificate_pem /tmp/certificate_pem
aws s3 cp s3://${bucket_name}/issuer_pem /tmp/issuer_pem
aws s3 cp s3://${bucket_name}/private_key_pem /tmp/server.key

# Create a full chain from the certificates
cat /tmp/certificate_pem >> /tmp/server.crt
cat /tmp/issuer_pem >> /tmp/server.crt

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

cat > /tmp/tfe_settings.json <<EOF
{
    "enc_password": {
        "value": "${tfe-pwd}"
    },
    "hairpin_addressing": {
        "value": "0"
    },
    "hostname": {
        "value": "${dns_hostname}.${dns_zonename}"
    },
    "production_type": {
        "value": "disk"
    },
    "disk_path": {
        "value": "/opt/tfe"
    }
}
EOF

json=/tmp/tfe_settings.json

jq -r . $json
if [ $? -ne 0 ] ; then
    echo ERR: $json is not a valid json
    exit 1
fi

# create replicated unattended installer config
cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "${tfe-pwd}",
  "TlsBootstrapType": "server-path",
  "TlsBootstrapHostname": "${dns_hostname}.${dns_zonename}",
  "TlsBootstrapCert": "/tmp/server.crt",
  "TlsBootstrapKey": "/tmp/server.key",
  "LogLevel": "debug",
  "ImportSettingsFrom": "/tmp/tfe_settings.json",
  "LicenseFileLocation": "/tmp/license.rli",
  "BypassPreflightChecks": true
}
EOF

json=/etc/replicated.conf
jq -r . $json
if [ $? -ne 0 ] ; then
    echo ERR: $json is not a valid json
    exit 1
fi

# install replicated
curl -Ls -o /tmp/install.sh https://install.terraform.io/ptfe/stable
sudo bash /tmp/install.sh \
        release-sequence=${tfe_release_sequence} \
        no-proxy \
        private-address=$PRIVATE_IP \
        public-address=$PUBLIC_IP