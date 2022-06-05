KEYCHAIN_NAME=homelab
KEYCHAIN=$KEYCHAIN_NAME.keychain
# create keychain
security create-keychain $KEYCHAIN
security list-keychains -d user -s $(security list-keychains -d user | sed -e s/\"//g) $KEYCHAIN
# nomad
security import files/tls/nomad/ca/nomad-agent-ca.pem -k $KEYCHAIN 
security import files/tls/nomad/cli/global-cli-nomad-0.pem -k $KEYCHAIN
security import files/tls/nomad/cli/global-cli-nomad-0-key.pem -k $KEYCHAIN
# consul
security import files/tls/consul/ca/consul-agent-ca.pem -k $KEYCHAIN
security import files/tls/consul/cli/dc1-cli-consul-0.pem -k $KEYCHAIN
security import files/tls/consul/cli/dc1-cli-consul-0-key.pem -k $KEYCHAIN
