# openvpn-gtk
Simple GTK3 based GUI for openvpn

[![Build Status](https://travis-ci.org/phR0ze/openvpn-gtk.svg)](https://travis-ci.org/phR0ze/openvpn-gtk)
[![Coverage Status](https://coveralls.io/repos/github/phR0ze/openvpn-gtk/badge.svg?branch=master)](https://coveralls.io/github/phR0ze/openvpn-gtk?branch=master)
[![Dependency Status](https://beta.gemnasium.com/badges/github.com/phR0ze/openvpn-gtk.svg)](https://beta.gemnasium.com/projects/github.com/phR0ze/openvpn-gtk)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Deploy App
```bash
bundler install --system
```

# Configuration
1. Create the file ***~/.config/openvpn.yml***
    ```yml
    vpns:
      - name: testvpn
        user: testuser
        route: 10.0.0.0
        conf: /etc/openvpn/client/testvpn.ovpn
    ```
2. Revoke read permissions for groups and others
    ```bash
    chmod og-r ~/.config/openvpn.yml
    ```

# Runtime process
The VPN will be established with a split DNS if the vpn config contains DNS settings. Once this has
occurred the route in the configuration will be added per the new tun0 interface.

Run the CLI

```bash
sudo ./openvpn-cli start --vpn=testvpn
```
