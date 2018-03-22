# openvpn-gtk
Simple GTK3 based GUI for openvpn

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
