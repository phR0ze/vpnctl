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

require 'ostruct'               # OpenStruct

module Model
  FailMessages = [
    "Received control message: AUTH_FAILED",
  ]

  # VPN management thread command mapping
  CommCmd = OpenStruct.new({
    halt: 'halt',
    fail: 'fail',
    vpn_up: 'vpn_up',
    vpn_down: 'vpn_down',
  })

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
  # @param default [Bool] True if default vpn
  Vpn = Struct.new(:name, :login, :routes, :ovpn, :auth, :default)
end
