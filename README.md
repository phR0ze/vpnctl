# vpnctl
<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/vpnctl/master/images/72x72/vpnctl.png">
<b><i>vpnctl</i></b> was designed to provide automation for openvpn advanced features like split DNS,
additional routing and network namespace isolation for targeted applications available as a
CLI or system tray app.<br><br>

[![Build Status](https://travis-ci.org/phR0ze/vpnctl.svg)](https://travis-ci.org/phR0ze/vpnctl?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/phR0ze/vpnctl/badge.svg?branch=master&service=github)](https://coveralls.io/github/phR0ze/vpnctl?branch=master&service=github)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Disclaimer
***vpnctl*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***vpnctl*** are
strictly the responsiblity of the user and not the developer/creator of ***vpnctl***.

### Current State
***vpnctl*** is currently in development and hasn't even reached beta yet. That said I've tested a
few areas fairly well and will list out what is currently working.

* CLI with ***additional routing*** but not including ***targeted*** apps

### Table of Contents
* [Overview](#overview)
    * [Additional Routing](#additional-routing)
    * [Network Namespace Isolation](#network-namespace-isolation)
* [Install](#install)
    * [cyberlinux Install](#cyberlinux-install)
    * [Manual Install](#manual-install)
* [Configure](#configure)
    * [Config file](#config-file)
* [VpnCtl Guides](#vpnctl-guide)
    * [CLI Guide](#cli-guide)
    * [GUI Guide](#gui-guide)
* [Development](#development)
    * [GTK+](#gtk)

## Overview <a name="overview"></a>

### Additional Routing <a name="Additional Routing"></a>
Many corporate environments provide VPNs for their employees to connect into the corporate network
remotely.  This is a convenient service and corporate IT will typically have a VPN app that you can
use for Windows or Mac to connect but not Linux.  Additionally the provided vpn apps are extremely
simplistic with little ability for configuration which isn't a big deal for management, secretarial
or non-dev types. Developers however need Linux support and often sophisticated routing for private
networks.  ***vpnctl*** fills this gap by providing additional routing configuration for your VPN
connection to forward private IPs in 10.x.x.x or 172.x.x.x or anything through the VPN with a simple
list of desired subnets.

### Network Namespace Isolation <a name="Network Namespace Isolation"></a>
Network namespaces have been available in the Linux Kernel for some time and are regularly used in
projects like ***docker*** and ***kubernetes*** etc... for isolating container applications. However
this same technology can be used to create network namespaces on a host system so that any
application launched within the network namespace is in its own isolated network and unable to
connect to other parts of the host network unless specifically allowed.  This allows for things like
isolating a particular application to always run over a VPN with zero possibility of leakage if the
VPN goes down.  This can all be done by hand but is complicated and error prone if you don't know
what your doing.  ***vpnctl*** harnesses the power of network namespaces to isolate apps as desired
in a clean automated fashion.

## Install <a name="install"></a>

### cyberlinux Install <a name="cyberlinux-install"></a>
```bash
sudo pacman -S vpnctl
```

### Manual Install <a name="manual-install"></a>
```bash
git clone https://github.com/phR0ze/vpnctl.git; cd vpnctl
bundle install --system
```

## Configure <a name="configure"></a>
***vpnctl*** uses the configuration file ***~/.config/vpnctl.yml***. You can create this ahead of
time and populate with your favorite vpn settings as explained in the ***Config file*** section or
you can simply start vpnctl and use the GUI to create and save your config.

### Config file <a name="config-file"></a>
1. Create the file ***~/.config/vpnctl.yml***
    ```yaml
    ---
    vpns:
    - name: NordVPN
      login:
        type: ask
        user: nord-user
        pass: ''
      routes:
      - 10.33.0.0/16
      ovpn: "/etc/openvpn/client/nord.ovpn"
      default: true
      retry: false
      target: false
      apps: []
    - name: pia-us-west
      login:
        type: save
        user: pia-user-name
        pass: pia-usre-pass
      routes: []
      ovpn: "/etc/openvpn/client/us-west.ovpn"
      default: false
      retry: true
      target: true
      apps:
      - chromium
    ```
2. Revoke read permissions for groups and others as sensitive information is stored in the config
    ```bash
    chmod og-r ~/.config/vpnctl.yml
    ```

Configuration property definitions:
* ***name*** - name for the VPN configuration and can be anything
* ***login*** - nested grouper for credentials
* ***type*** - controls whether a password is saved or asked for, possible options ***ask | save***
* ***user*** - saved username for the VPN
* ***pass*** - saved password for the VPN or empty string depending on ***type***
* ***routes*** - list of subnets to route via the VPN gateway. not to be used in conjunction with ***target=true***
* ***ovpn*** - absolute path to the OpenVPN configuration file to use
* ***default*** - flag indicating when true that this vpn should be what is used by default
* ***target*** - flag indicating that an isolated network namespace should be created for this VPN
* ***apps*** - list of applications to start in the new isolated network namespace

## VpnCtl Guides <a name="vpnctl-guides"></a>
The VPN will be established with Split DNS resolution if the vpn config contains DNS settings. Once this has
occurred the ***routes*** in the configuration will be added per the new tun0 interface.

### CLI Guide <a name="cli-guide"></a>
Using ***vpnctl*** via the CLI

**Examples:**
```bash
# Print out vpnctl CLI help
sudo ./vpnctl-cli

# vpnctl-cli_v0.0.53
# --------------------------------------------------------------------------------
# Examples:
# Add VPN: sudo ./vpnctl-cli add PIA save
# List VPNs: sudo ./vpnctl-cli list
# Start VPN: sudo ./vpnctl-cli start NordVPN
# 
# Usage: ./vpnctl-cli [commands] [options]
# Global options:
#     -h|--help                               Print command/options help: Flag(false)
# COMMANDS:
#     add                                     Add VPN yaml stub to config
#     list                                    List configured VPNs
#     start                                   Start VPN service
# 
# see './vpnctl-cli COMMAND --help' for specific command help

# List out available configurations
sudo ./vpnctl-cli list

# Name: NordVPN, Login type: ask, Config: /etc/openvpn/client/nord.ovpn
# Name: pia-use-west, Login type: save, Config: /etc/openvpn/client/us-west.ovpn

# Start the 'NordVPN'
sudo ./vpnctl-cli start NordVPN

# 2018-07-20T13:37:27.391Z:I:: MGMT: Waiting for VPN to halt
# 2018-07-20T13:37:27.392Z:W:: Starting the VPN connection
# 2018-07-20T13:37:27.392Z:I:: Using OpenVPN config /etc/openvpn/client/nord.ovpn
# 2018-07-20T13:37:27.413Z:I:: OVPN: OpenVPN 2.4.6 x86_64-pc-linux-gnu built on Apr 24 2018
# 2018-07-20T13:37:27.413Z:I:: OVPN: library versions: OpenSSL 1.1.0h  27 Mar 2018, LZO 2.10
# 2018-07-20T13:37:27.414Z:I:: OVPN: Socket Buffers: R=[212992->212992] S=[212992->212992]
# 2018-07-20T13:37:27.414Z:I:: OVPN: UDP link local: (not bound)
# 2018-07-20T13:37:27.415Z:I:: OVPN: UDP link remote: [AF_INET]
# 2018-07-20T13:37:27.503Z:I:: OVPN: TLS: Initial packet from [AF_INET], sid=ea834392 9e28deaa
# 2018-07-20T13:37:27.645Z:I:: Waiting for vpn NordVPN to be started...
# 2018-07-20T13:37:27.833Z:I:: OVPN: Control Channel: TLSv1.2, cipher TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384
# 2018-07-20T13:37:27.896Z:I:: Waiting for vpn NordVPN to be started...
# 2018-07-20T13:37:29.108Z:I:: OVPN: OPTIONS IMPORT: timers and/or timeouts modified
# 2018-07-20T13:37:29.108Z:I:: OVPN: OPTIONS IMPORT: --ifconfig/up options modified
# 2018-07-20T13:37:29.109Z:I:: OVPN: OPTIONS IMPORT: route options modified
# 2018-07-20T13:37:29.109Z:I:: OVPN: OPTIONS IMPORT: --ip-win32 and/or --dhcp-option options modified
# 2018-07-20T13:37:29.109Z:I:: OVPN: OPTIONS IMPORT: peer-id set
# 2018-07-20T13:37:29.109Z:I:: OVPN: OPTIONS IMPORT: adjusting link_mtu to 1625
# 2018-07-20T13:37:29.110Z:I:: OVPN: OPTIONS IMPORT: data channel crypto options modified
# 2018-07-20T13:37:29.110Z:I:: OVPN: Data Channel: using negotiated cipher 'AES-256-GCM'
# 2018-07-20T13:37:29.110Z:I:: OVPN: Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
# 2018-07-20T13:37:29.111Z:I:: OVPN: ROUTE_GATEWAY 192.168.1.1/255.255.255.0 IFACE=eno1
# 2018-07-20T13:37:29.112Z:I:: OVPN: TUN/TAP device tun0 opened
# 2018-07-20T13:37:29.112Z:I:: OVPN: TUN/TAP TX queue length set to 100
# 2018-07-20T13:37:29.112Z:I:: OVPN: do_ifconfig, tt->did_ifconfig_ipv6_setup=0
# 2018-07-20T13:37:29.113Z:I:: OVPN: /usr/bin/ip link set dev tun0 up mtu 1500
# 2018-07-20T13:37:29.127Z:I:: OVPN: <14>Jul 20 07:37:29 update-systemd-resolved: Link 'tun0' coming up
# 2018-07-20T13:37:29.134Z:I:: OVPN: <14>Jul 20 07:37:29 update-systemd-resolved: SetLinkDNS
# 2018-07-20T13:37:29.145Z:I:: OVPN: /usr/bin/ip route add ... via 192.168.1.1
# 2018-07-20T13:37:29.148Z:I:: Waiting for vpn NordVPN to be started...
# 2018-07-20T13:37:29.152Z:I:: OVPN: Initialization Sequence Completed
# 2018-07-20T13:37:29.399Z:I:: Waiting for vpn NordVPN to be started...
# 2018-07-20T13:37:29.399Z:I:: VPN NordVPN is up and running
# 2018-07-20T13:37:29.400Z:I:: Adding route ... for ... on tun0...success!
# 2018-07-20T13:37:49.259Z:I:: OVPN: event_wait : Interrupted system call (code=4)

# Gracefully shutdown VPN
# Simply hit Ctrl+c
# ^C
# 2018-07-20T13:21:16.906Z:I:: MGMT: Halting VPN
# 2018-07-20T13:21:16.906Z:I:: MGMT: VPN Halted
```

### GUI Guide <a name="gui-guide"></a>
The GUI is a GTK+ app that wraps the CLI and communicates via message queues.

```bash
sudo ./vpnctl
```

## Development <a name="development"></a>

### GTK+ <a name="gtk"></a>
The intent with the GUI wrapper is to provide a system icon with a menu and icon status. The tray
icon will show a white icon when running but not enabled and a green version when enabled in
target-mode, a blue version when running in target mode and a red version when disabled.

**System Tray Icon Menu**
* ***Enable***
* ***Disable***
* --------------
* ***Settings***
* ***Logs***
* ***Quit***

### Git-Hook Version Increment <a name="git-hook-version-increment"/></a>
Enable the githooks to have automatic version increments

```bash
cd ~/Projects/vpnctl
git config core.hooksPath .githooks
```

<!--
vim: ts=2:sw=2:sts=2
-->
