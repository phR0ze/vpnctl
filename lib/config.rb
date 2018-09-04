#MIT License
#Copyright (c) 2018 phR0ze
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

require 'nub'

# Monkey patch Config with specific functions for vpnctl
module Config
  extend self

  # Read in the ovpn path from the general section of the config
  def ovpn_path
    default = '/etc/openvpn/client'
    yml = Config['general']
    return yml ? yml['ovpn_path'] || default : default
  end

  # Get all vpns as vpn objects
  def vpns
    yml = Config['vpns'] || []
    return yml.map{|x| vpn(x['name'])}
  end

  # Get vpn by name and validate its config
  # @param name [String] name of the vpn to use
  # @returns vpn [Vpn] struct containing the vpn properties
  def vpn(name)
    Config['vpns'] = [] if !Config['vpns']
    vpn = Config['vpns'].find{|x| x['name'] == name }
    raise("couldn't find vpn '#{name}' in config") if !vpn

    # Load name
    name = vpn['name']
    Log.warn("vpn missing name") if !name
    valid = false if !name

    # Load login
    login = vpn['login']
    type = login ? login['type'] : nil
    user = login ? login['user'] : nil
    pass = login ? login['pass'] : nil
    Log.warn("vpn missing login") if !login
    valid = false if !login

    # Load routes
    routes = vpn['routes'] || []

    # Load ovpn config
    ovpn = vpn['ovpn']
    valid = false if !ovpn
    Log.warn("vpn missing ovpn") if !ovpn
    ovpn_auth_path = ovpn ? File.join(File.dirname(ovpn), "#{name}.auth") : nil

    # Load isolate apps
    isolate = vpn['isolate'] || false
    apps = vpn['apps'] || []

    # Load default
    default = vpn['default'] || false

    # Load retry
    _retry = vpn['retry'] || false

    # Load namespace nameservers
    nameservers = vpn['nameservers'] || []

    return Model::Vpn.new(name, Model::Login.new(type, user, pass),
      routes, ovpn, ovpn_auth_path, isolate, apps, default, _retry, nameservers)
  end

  # Create a new vpn
  def add_vpn(name)
    Config['vpns'] = [] if !Config['vpns']
    vpn = Model::Vpn.new(name, Model::Login.new('ask', '', ''),
      [], '', '', false, [], false, false, [])

    Config['vpns'] << {
      'name' => name,
      'login' => {
        'type' => vpn.login.type,
        'user' => vpn.login.user,
        'pass' => vpn.login.pass
      },
      'routes' => vpn.routes,
      'ovpn' => vpn.ovpn,
      'isolate' => vpn.isolate,
      'apps' => vpn.apps,
      'default' => vpn.default,
      'retry' => vpn.retry,
      'nameservers' => vpn.nameservers
    }

    return vpn
  end

  # Delete a vpn by name
  # @param name [String] name of the vpn to delete
  def del_vpn(name)
    Config['vpns'].delete_if{|x| x['name'] == name}
  end

  # Update the given vpn in the config
  # @param vpn [VPN] vpn to update
  def update_vpn(vpn)
    raise "incorrect vpn type" if !vpn.is_a?(Model::Vpn)

    # Ensure only one vpn is set as the default
    Config['vpns'].each{|x| x['default'] = false} if vpn.default
    
    name = vpn.btn ? vpn.btn.label : vpn.name
    raw = Config['vpns'].find{|x| x['name'] == name}
    raw['name'] = vpn.name
    if vpn.login
      raw['login']['type'] = vpn.login.type
      raw['login']['user'] = vpn.login.user
      raw['login']['pass'] = vpn.login.pass
    end
    raw['routes'] = vpn.routes
    raw['ovpn'] = vpn.ovpn
    raw['isolate'] = vpn.isolate
    raw['apps'] = vpn.apps
    raw['default'] = vpn.default
    raw['retry'] = vpn.retry
    raw['nameservers'] = vpn.nameservers
  end
end
