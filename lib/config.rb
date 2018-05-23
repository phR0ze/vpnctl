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

module Config
  extend self

  # Read in the ovpn path
  def ovpn_path
    default = '/etc/openvpn/client'
    yml = Config['general']
    return yml ? (yml['ovpn_path'] ? yml['ovpn_path'] : default) : default
  end

  # Get all vpns as vpn objects
  def vpns
    yml = Config['vpns']
    raise("couldn't find 'vpns' in config") if yml.nil?
    return yml.map{|x| vpn(x['name'])}
  end

  # Get vpn by name and validate its config
  # @param name [String] name of the vpn to use
  # @returns vpn [Vpn] struct containing the vpn properties
  def vpn(name)
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
    Log.warn("vpn missing login") if !ovpn
    ovpn_auth_path = ovpn ? File.join(File.dirname(ovpn), "#{name}.auth") : nil

    # Load target apps
    target = vpn['target'] || false
    apps = vpn['apps'] || []

    # Load default
    default = vpn['default'] || false

    return Model::Vpn.new(name, Model::Login.new(type, user, pass),
      routes, ovpn, ovpn_auth_path, target, apps, default)
  end

  # Create a new vpn
  def add_vpn(name)
    Config['vpns'] << {
      'name' => name,
      'login' => {
        'type' => 'ask',
        'user' => '',
        'pass' => ''
      },
      'routes' => [],
      'ovpn' => '',
      'target' => false,
      'apps' => [],
      'default' => false
    }
  end

  # Delete a vpn by name
  # @param name [String] name of the vpn to delete
  def del_vpn(name)
    Config['vpns'].delete_if{|x| x['name'] == name}
  end

  # Update the given vpn in the config
  # @param name [String] name of the vpn to use as a key
  # @param vpn [VPN] vpn to update
  def update_vpn(name, vpn)

    # Ensure only one vpn is set as the default
    Config['vpns'].each{|x| x['default'] = false} if vpn.default
    
    raw = Config['vpns'].find{|x| x['name'] == name}
    raw['name'] = vpn.name
    raw['login']['type'] = vpn.login.type
    raw['login']['user'] = vpn.login.user
    raw['login']['pass'] = vpn.login.pass
    raw['routes'] = vpn.routes
    raw['ovpn'] = vpn.ovpn
    raw['target'] = vpn.target
    raw['apps'] = vpn.apps
    raw['default'] = vpn.default
  end
end
