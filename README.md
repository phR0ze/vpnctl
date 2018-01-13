# openvpn-gtk
Simple GTK3 based GUI for openvpn

# Configuration
1. Create the file ***~/.config/openvpn.yml***
    ```yml
    vpns:
      - name: testvpn
        user: testuser
        route: 10.0.0.0
        conf: /etc/openvpn/client/testvpn.ovpn
    ```
2. Revoke read: ***chmod og-r ~/.config/openvpn.yml***
3. Run CLI: ***sudo ./openvpn-cli start --vpn=testvpn***

# Runtime process
The VPN will be established with split DNS if the vpn config contains DNS settings. Once this has
occurred the route in the configuration will be added per the new tun0 interface.
