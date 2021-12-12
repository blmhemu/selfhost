# nomad
security import files/tls/nomad/ca/nomad-agent-ca.pem -k ~/Library/Keychains/Cluster.keychain-db
security import files/tls/nomad/cli/global-cli-nomad-0.pem -k ~/Library/Keychains/Cluster.keychain-db
security import files/tls/nomad/cli/global-cli-nomad-0-key.pem -k ~/Library/Keychains/Cluster.keychain-db
# consul
security import files/tls/consul/ca/consul-agent-ca.pem -k ~/Library/Keychains/Cluster.keychain-db
security import files/tls/consul/cli/dc1-cli-consul-0.pem -k ~/Library/Keychains/Cluster.keychain-db
security import files/tls/consul/cli/dc1-cli-consul-0-key.pem -k ~/Library/Keychains/Cluster.keychain-db
