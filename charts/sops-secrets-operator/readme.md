# requirements
brew install sops gpg


# keys howto
# gpg --full-generate-key --expert
gpg --list-secret-keys terracnosaur@gmail.com
gpg --export-secret-keys 76CDA084E2E5EE7CF35D531DDFE9E53D2D8617C2 > keys/private.key
gpg --import keys/private.key
gpg --armor --export 76CDA084E2E5EE7CF35D531DDFE9E53D2D8617C2

# location of the pgp keys
https://drive.google.com/drive/folders/1kcaUcDF90E7CfuTUi10L0FoQ_OzCIKgb


# creating the archive
sops keys/homelab-kube-secrets.yaml

# decrypt the archive