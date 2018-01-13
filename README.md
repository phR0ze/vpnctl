# openvpn-gtk
Simple GTK3 based GUI for openvpn

# Configuration
1. Create the file ***~/.config/openvpn.yml***
    ```yml
    vpns:
      - name: testvpn
        user: testuser
        conf: /etc/openvpn/client/testvpn.ovpn
    ```
2. Revoke read: ***chmod og-r ~/.config/openvpn.yml***
3. Run CLI: ***sudo ./openvpn-cli start --vpn=testvpn***
