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

```
ansible-playbook --ask-vault-password playbook.yml
```