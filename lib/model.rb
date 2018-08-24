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

require 'ostruct'

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

  State = OpenStruct.new({
    active: 'active',
    connected: 'connected',
  })

  # Capture structure of login
  # @param type [String] PassTypes string
  # @param user [String] name of the user
  # @param pass [String] password for the user
  Login = Struct.new(:type, :user, :pass) do
    def clone(*args)
      if args.any? && args.first.is_a?(Login)
        self.type = args.first.type
        self.user = args.first.user
        self.pass = args.first.pass
        self
      elsif !args.any?
        Login.new(self.type, self.user, self.pass)
      else
        Login.new
      end
    end
  end

  # VPN model object
  # @param name [String] name of the vpn
  # @param login [Login] credentials for vpn
  # @param routes [Array] list of routes to add for vpn
  # @param ovpn [String] path to ovpn configuration file
  # @param auth [String] path to auth file named <name>.auth
  # @param target [Bool] target specific apps
  # @param apps [Array(String)] apps to target
  # @param default [Bool] True if default vpn
  # @param state [String] state of the vpn
  # @param btn [GtkButton] associated button
  Vpn = Struct.new(:name, :login, :routes, :ovpn, :auth, :target, :apps, :default, :state, :btn) do
    def clone(*args)
      if args.any? && args.first.is_a?(Vpn)
        self.name = args.first.name
        self.login = Login.new.clone(args.first.login)
        self.routes = Marshal.load(Marshal.dump(args.first.routes))
        self.ovpn = args.first.ovpn
        self.auth = args.first.auth
        self.target = args.first.target
        self.apps = Marshal.load(Marshal.dump(args.first.apps))
        self.default = args.first.default
        self.state = args.first.state
        self
      elsif !args.any?
        Vpn.new(self.name, self.login.clone, Marshal.load(Marshal.dump(self.routes)), self.ovpn,
          self.auth, self.target, Marshal.load(Marshal.dump(self.apps)), self.default, self.state)
      else
        Vpn.new
      end
    end
  end
end
