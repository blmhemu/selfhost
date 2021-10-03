NOMAD_ADDR=https://192.168.0.100:4646
NOMAD_CACERT=files/tls/nomad/ca/nomad-agent-ca.pem
NOMAD_CLIENT_CERT=files/tls/nomad/cli/global-cli-nomad-0.pem
NOMAD_CLIENT_KEY=files/tls/nomad/cli/global-cli-nomad-0-key.pem

nomad system gc
