export NOMAD_ADDR=https://192.168.0.100:4646
export NOMAD_CACERT=files/tls/nomad/ca/nomad-agent-ca.pem
export NOMAD_CLIENT_CERT=files/tls/nomad/cli/global-cli-nomad-0.pem
export NOMAD_CLIENT_KEY=files/tls/nomad/cli/global-cli-nomad-0-key.pem

nomad system gc
