require 'ostruct'               # OpenStruct

module Model
  PassType = {
    'Ask for password' => :ask,
    'Save password' => :save,
  }

  # Capture structure of login
  # @param type [Symbol] symbol from PassType mapping
  # @param user [String] name of the user
  # @param pass [String] password for the user
  Login = Struct.new(:type, :user, :pass)

  # Simple command mapping
  CommCmd = OpenStruct.new({
    halt: 'halt',
    vpn_up: 'vpn_up',
    vpn_down: 'vpn_down',
  })
end
