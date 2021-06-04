# selfhost

## Initial Setup

For password-less ansible setup do the following

```
## Setup your server
# SSH into the machine and perform initial setup
ssh user@host
# Change password of the user. Skip if already done in previous step
passwd
# Make sure sudo runs without password.
sudo su
# If sudo asks for password, run the below command.
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nopass-$USER

## Setup the local dev machine
# Generate ssh key pair. Skip if already present.
ssh-keygen -b 2048 -t rsa
# Copy it to the host. Generally the location is .ssh/id_rsa.pub
ssh-copy-id -i ~/.ssh/mykey user@host
# Alternatively, you can use the following command
cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```

## How to run this playbook

```
# Get a reusable tailscale auth key at https://login.tailscale.com/admin/settings/authkeys
# Encrypt the key using ansible vault. I prefer password based auth. You can use a password file with proper permissions and add it to .gitignore. Many shells log the history. Remove the command from shell history (.zsh_history | .bash_history)
ansible-vault encrypt_string --ask-vault-pass 'tskey-xxxxxxxxxxxxxxxx' --name 'tailscale_auth_key'
# Copy the output of the above command to the vars section of Install Tailscale part of playbook.yml
# tailscale_auth_key: !vault |
#          $ANSIBLE_VAULT;1.1;AES256
#          xxxxxxxxxxxxxxxxxxxxxxxxxxx
#          xxxxxxxxxxxxxxxxxxxxxxxxxxx
# Run the playbook with below command. Enter vault password when prompted.
ansible-playbook --ask-vault-pass playbook.yml
```