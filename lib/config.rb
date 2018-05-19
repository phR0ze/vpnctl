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

  # Get all vpns as vpn objects
  def vpns
    vpns = []
    vpns_yml = Config['vpns']
    raise("couldn't find 'vpns' in config") if vpns_yml.nil?

    # Load each vpn
    vpns_yml.each{|x|
      valid = true

      # Load name
      name = x['name']
      Log.warn("vpn missing name") if !name
      valid = false if !name

      # Load default
      default = x['default']

      # Load login
      login = x['login']
      type = login ? login['type'] : nil
      user = login ? login['user'] : nil
      pass = login ? login['pass'] : nil
      Log.warn("vpn missing login") if !login
      valid = false if !login

      # Load routes
      routes = x['routes'] || []

      # Load ovpn config
      ovpn = x['ovpn']
      valid = false if !ovpn
      Log.warn("vpn missing login") if !ovpn
      ovpn_auth_path = ovpn ? File.join(File.dirname(ovpn), "#{name}.auth") : nil

      # Create vpn model object
      vpns << Model::Vpn.new(name, Model::Login.new(type, user, pass),
        routes, ovpn, ovpn_auth_path, default) if valid
    }

    return vpns
  end

  # Get vpn by name and validate its config
  # @param name [String] name of the vpn to use
  # @returns vpn [Vpn] struct containing the vpn properties
  def vpn(name)
    vpns = Config['vpns']

    raise("couldn't find 'vpns' in config") if vpns.nil?
    vpn = vpns.find{|x| x['name'] == name }

    raise("couldn't find '#{name}' in config") if vpn.nil?
    login = vpn['login']

    raise("couldn't find 'login' in config") if login.nil?
    type = login['type']

    raise("couldn't find 'type' in config") if type.nil?
    user = login['user']

    raise("couldn't find 'user' in config") if user.nil?
    pass = login['pass']

    routes = vpn['routes']
    raise("couldn't find 'routes' in config") if routes.nil?

    ovpn = vpn['ovpn']
    raise("couldn't find 'ovpn' in config") if ovpn.nil?

    default = vpn['default'] || false

    return Model::Vpn.new(name, Model::Login.new(type, user, pass),
      routes || [], ovpn, File.join(File.dirname(ovpn), "#{name}.auth"), default)
  end
end
