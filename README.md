# selfhost

## Initial Setup

Make sure rpi0 and nas0 are available at 192.168.0.100 and 192.168.0.101 respectively (Configure either in router or static ip in the node)

For password-less ansible setup do the following on the nodes.

```shell
# Setup your server
## SSH into the machine and perform initial setup
ssh user@host
## Change password of the user. Skip if already done in previous step
passwd
## Make sure sudo runs without password.
sudo su
## If sudo asks for password, run the below command.
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nopass-$USER

# Setup the local dev machine
## Generate ssh key pair. Skip if already present.
ssh-keygen -b 2048 -t rsa
## Copy it to the host. Generally the location is .ssh/id_rsa.pub
ssh-copy-id -i ~/.ssh/mykey user@host
## Alternatively, you can use the following command
cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```

```shell
# Make sure gnu tar, consul, python-nomad are available on local machine (especially on MacOS)
brew install gnu-tar consul # Optionally nomad and vault
pip3 install python-nomad
```

You can optionally change the shell to zsh for productivity during debugging sessions
(Am lazy to automate this. Can be done though.)
```
# Install zsh
sudo apt install zsh
# Changelogin shell to zsh
chsh -s $(which zsh)
# Copy .zshrc
scp misc/zshrc user@ip:~/.zshrc
# Configure prompt
p10k configure
```

## Transfer Install (Optional | Helios64)

For transfer install on helios64

```shell
# Run parted playbook
ansible-playbook --ask-vault-pass parted.yml
```

And follow the steps at https://wiki.kobol.io/helios64/install/transfer/

## Cluster setup

```shell
# Install the required roles
ansible-galaxy install -r requirements.yml
# Get an ephemeral or reusable tailscale auth key at https://login.tailscale.com/admin/settings/authkeys
# Put the key in group_vars/all/vars.vault.yml
ansible-vault edit group_vars/all/vars.vault.yml
# Run the playbook with below command. Enter vault password when prompted.
ansible-playbook --ask-vault-pass playbook.yml
```

To import the security keys to local machine (macos only) keychain, do
```
./scripts/import_keys.sh
```

The test playbook is WIP (Work In Progress) and can be unstable.

## Maintenance

To rekey or rotate ansible vault passwords:
```shell
ansible-vault rekey **/*.vault.yml
```

Nextcloud upgrades must be done in steps. For example, you cannot upgrade from 22.1 to 23.
You should instead do 22.1 -> 22.2 -> 23
