# nixos-flaskwebserver
 Nixos `/etc/nixos/configuration.nix` files that I used to try out setting up flask and uwsgi as per https://github.com/knedlsepp/knedlsepp.at example.

## How to use
  - If you're using the nixos ami replace the contents of `/etc/nixos/configuration.nix` with the one found in that repo at `./amazon-image/configuration.nix`
  - If you're using the nixos virtualbox ova replace the contents of `/etc/nixos/configuration.nix` with the one found in that repo at `./virtualbox-demo/configuration.nix`
  - Then run `nixos-rebuild switch` from the console of the VM
