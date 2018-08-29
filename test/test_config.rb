#!/usr/bin/env ruby
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

require 'minitest/autorun'

require_relative '../lib/config'
require_relative '../lib/model'

class Test_Config < Minitest::Test
  Button = Struct.new(:label)

  def setup
    Log.init(path:nil, queue: false, stdout: true)
    Config.reset
  end

  def test_ovpn_path_default
    assert_equal("/etc/openvpn/client", Config.ovpn_path)
  end

  def test_ovpn_path_config
    Config['general'] = {'ovpn_path' => '/foo/bar'}
    assert_equal("/foo/bar", Config.ovpn_path)
  end

  def test_vpns
    vpns = [{'name' => 'vpn1'}]
    Config['vpns'] = vpns

    Config.stub(:vpn, vpns.first) {
      assert_equal(vpns, Config.vpns)
    }
  end

  def test_vpn_not_found
    Sys.capture{assert_raises(RuntimeError){ Config.vpn('vpn1')} }
  end

  def test_vpn_found
    ovpn = "/foo/vpn1.ovpn"
    auth = "/foo/vpn1.auth"

    vpns = [{
      'name' => 'vpn1',
      'login' => {
        'type' => nil,
        'user' => nil,
        'pass' => nil,
      },
      'ovpn' => ovpn
    }]
    Config['vpns'] = vpns

    assert_equal(Model::Vpn.new('vpn1', Model::Login.new, [], ovpn, auth, false, [], false, false, []), Config.vpn('vpn1'))
  end

  def test_add_vpn
    vpn = Model::Vpn.new('vpn1', Model::Login.new('ask', '', ''),
      [], '', '', false, [], false, false, [])
    assert_equal(vpn, Config.add_vpn('vpn1'))
  end

  def test_del_vpn
    Config.add_vpn('vpn1')
    assert_equal(1, Config.vpns.size)
    Config.del_vpn('vpn1')
    assert_equal(0, Config.vpns.size)
  end

  def test_update_vpn_bad_type
    Sys.capture{assert_raises(RuntimeError){ Config.update_vpn("")} }
  end

  def test_update_vpn
    vpn = Config.add_vpn('vpn1')
    vpn.default = true
    vpn.login = Model::Login.new
    vpn.ovpn = "/foo/bar.ovpn"
    vpn.btn = Button.new("vpn1")

    Config.update_vpn(vpn)
    other = Config.vpn('vpn1')
    assert(other.default)
    assert_equal(vpn.ovpn, other.ovpn)
    assert_equal("/foo/vpn1.auth", other.auth)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
