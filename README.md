# selfhost

## Initial Setup

For password-less ansible setup do the following

```
# Generate ssh key pair. Skip if already present.
ssh-keygen -b 2048 -t rsa
# Copy it to the host. Generally the location is .ssh/id_rsa.pub
ssh-copy-id -i ~/.ssh/mykey user@host
# Alternatively, you can use the following command
cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```