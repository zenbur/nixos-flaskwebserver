{ config, pkgs, ... }:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  environment.systemPackages = with pkgs; [ gitMinimal ];
  nixpkgs.overlays = [
    (self: super: with self; {
      python27 = super.python27.override pythonOverrides;
      python27Packages = super.recurseIntoAttrs (python27.pkgs);
      python36 = super.python36.override pythonOverrides;
      python36Packages = super.recurseIntoAttrs (python36.pkgs);
      pythonOverrides = {
        packageOverrides = python-self: python-super: {
          flask-ruben-helloworld = pythonPackages.buildPythonPackage rec {
            name = "flask-ruben-helloworld-${version}";
            version = "0.1.0";

            src = fetchgit {
              url = "https://github.com/zenbur/flask-hello-world";
              rev = "2d0a6d470707558795686ece4da53bc3648ebdf0";
              sha256 = "01vfckg2km3aqfs431963x1v316mw4hv4dnghf1lpwa9blfy5x7z";
            };
            propagatedBuildInputs = with pythonPackages; [
              flask
              ];
            };
          };
        };
      })];
  nixpkgs.config.allowUnfree = true;

  services.nginx = {
    enable = true;
    virtualHosts."www.example.com" = {
      locations."/" = {
        extraConfig = ''
          uwsgi_pass unix://${config.services.uwsgi.instance.vassals.flask-ruben-helloworld.socket};
          include ${pkgs.nginx}/conf/uwsgi_params;
        '';
      };
    };
  };
  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    instance = {
      type = "emperor";
      vassals = {
        flask-ruben-helloworld = {
          type = "normal";
          pythonPackages = self: with self; [ flask-ruben-helloworld ];
          socket = "${config.services.uwsgi.runDir}/flask-ruben-helloworld.sock";
          wsgi-file = "${pkgs.pythonPackages.flask-ruben-helloworld}/${pkgs.python.sitePackages}/ruben_helloworld/share/flask-ruben-helloworld.wsgi";
        };
      };
    };
    plugins = [ "python2" ];
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
