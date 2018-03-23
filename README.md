# openvpn-gtk
Simple GTK3 based GUI for openvpn

[![Build Status](https://travis-ci.org/phR0ze/openvpn-gtk.svg)](https://travis-ci.org/phR0ze/openvpn-gtk)
[![Coverage Status](https://coveralls.io/repos/github/phR0ze/openvpn-gtk/badge.svg?branch=master)](https://coveralls.io/github/phR0ze/openvpn-gtk?branch=master)
[![Dependency Status](https://beta.gemnasium.com/badges/github.com/phR0ze/openvpn-gtk.svg)](https://beta.gemnasium.com/projects/github.com/phR0ze/openvpn-gtk)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Table of Contents
* [Install](#install)
* [Configure](#configure)
* [Deploy](#deploy)

## Install <a name="install"></a>
```bash
bundle install --system
```

## Configure <a name="configure"></a>
1. Create the file ***~/.config/openvpn.yml***
    ```yaml
    vpns:
      - name: testvpn
        user: testuser
        routes:
          - 10.33.0.0/16
        conf: /etc/openvpn/client/testvpn.ovpn
    ```
2. Revoke read permissions for groups and others
    ```bash
    chmod og-r ~/.config/openvpn.yml
    ```

Configuration explained:
* ***name*** is a a name for the VPN configuration and can be anything
* ***user*** is your saved username for the VPN
* ***routes*** is a list of subnets that will be routed via the VPN gateway
* ***conf*** is an absolute path to the OpenVPN configuration file to use

## Deploy <a name="deploy"></a>
The VPN will be established with Split DNS resolution if the vpn config contains DNS settings. Once this has
occurred the ***routes*** in the configuration will be added per the new tun0 interface.

Run the CLI

```bash
sudo ./openvpn-cli start --vpn=testvpn
```
