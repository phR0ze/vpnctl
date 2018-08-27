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

require 'nub'
require 'yaml'
require 'minitest/autorun'

root_path = File.join(File.dirname(File.expand_path(__FILE__)), '..')
load File.join(root_path, 'vpnctl-cli')

class Test_VpnCtlCli < Minitest::Test
  Button = Struct.new(:label)

  def setup
    ARGV.clear
  end

  def test_main
    out = Sys.capture{assert_raises(SystemExit){vpnCtlCliMain}}.stdout
    assert(out.include?("COMMANDS"))
  end

  def test_main_test
    ARGV << 'list'
    out = Sys.capture{vpnCtlCliMain}.stdout
    assert(out.include?("vpnctl-cli"))
  end

  def test_main_start_saved_pass
    ARGV << "start" << "vpn1"
    Config.init('vpnctl.yml')
    vpn1 = Config.add_vpn('vpn1')
    vpn1.login.type = Model::PassTypes.save
    vpn1.btn = Button.new(vpn1.name)
    Config.update_vpn(vpn1)

    User.stub(:root?, true) {
      Net.stub(:ip_forward?, true) {
        ThreadComm.stub(:new, nil) {
          Sys.capture{assert_raises{vpnCtlCliMain}}
        }
      }
    }
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
