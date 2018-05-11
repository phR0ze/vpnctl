require 'ostruct'               # OpenStruct

module Model

  # Type to user consumable value map
  PassTypeDisplay = {
    'ask' => 'Ask for password',
    'save' => 'Save password',
  }

  # Type list for conditionals
  PassTypes = OpenStruct.new({
    ask: 'ask',
    save: 'save',
  })

  # Capture structure of login
  # @param type [String] PassTypes string
  # @param user [String] name of the user
  # @param pass [String] password for the user
  Login = Struct.new(:type, :user, :pass)

  # VPN model object
  # @param name [String] name of the vpn
  # @param login [Login] credentials for vpn
  # @param routes [Array] list of routes to add for vpn
  # @param ovpn [String] path to ovpn configuration file
  # @param auth [String] path to auth file named <name>.auth
  Vpn = Struct.new(:name, :login, :routes, :ovpn, :auth)

  # VPN management thread command mapping
  CommCmd = OpenStruct.new({
    halt: 'halt',
    vpn_up: 'vpn_up',
    vpn_down: 'vpn_down',
  })
end
