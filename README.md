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
    * [CLI](#cli)
    * [GUI](#gui)
* [Development](#development)
    * [GTK+ Glade](#gtk-glade)

## Install <a name="install"></a>
```bash
bundle install --system
```

## Configure <a name="configure"></a>
1. Create the file ***~/.config/openvpn.yml***
    ```yaml
    vpns:
      - name: testvpn
        login:
          type: Ask for password
          user: testuser
          pass:
        routes:
          - 10.33.0.0/16
        ovpn: /etc/openvpn/client/testvpn.ovpn
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

### CLI <a name="cli"></a>
Execute via CLI
```bash
sudo ./openvpn-cli start testvpn
```

### GUI <a name="gui"></a>
The GUI is a GTK+ app that wraps the CLI and communicates via message queues.

## Development <a name="development"></a>

### GTK+ Glade <a name="gtk-glade"></a>
The intent with the GUI wrapper is to provide a system icon with a menu and icon status. The tray
icon will show my custom white icon when running but not enabled and a green version when enabled
and a red version when disabled.

**Menu**
* ***Enable***
* ***Disable***
* --------------
* ***Settings***
* ***Logs***
* ***Quit***
