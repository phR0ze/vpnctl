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
    Config.reset
  end

  def test_main
    out = Sys.capture{assert_raises(SystemExit){vpnCtlCliMain}}.stdout
    assert(out.include?("COMMANDS"))
  end

  def test_main_add
    ARGV << 'add' << 'vpn1' << 'save'
    Config.stub(:init, true) {
      Config.stub(:save, true) {
        out = Sys.capture{vpnCtlCliMain}.stdout
        assert(out.include?("vpn1"))
      }
    }
  end

  def test_main_list
    ARGV << 'list'
    File.stub(:exist?, true) {
      Config.init('foo')
      vpn1 = Config.add_vpn('vpn1')
    }
    Config.stub(:init, true) {
      out = Sys.capture{vpnCtlCliMain}.stdout
      assert(out.include?("vpn1"))
    }
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

  def test_main_start_ask_pass
    ARGV << "start" << "vpn1"
    Config.init('vpnctl.yml')
    vpn1 = Config.add_vpn('vpn1')
    vpn1.login.type = Model::PassTypes.ask
    vpn1.btn = Button.new(vpn1.name)
    Config.update_vpn(vpn1)

    User.stub(:root?, true) {
      Net.stub(:ip_forward?, true) {
        Sys.stub(:getpass, ->(){raise Interrupt}) {
          ThreadComm.stub(:new, []) {
            Sys.capture{vpnCtlCliMain}
          }
        }
      }
    }
  end

  def test_exec_with_status_check
    Config.init('foo')
    Config.add_vpn('vpn1')
    vpn1 = Config.vpn('vpn1')

    User.stub(:root?, true) {
      Net.stub(:ip_forward?, true) {
        vpn = VpnCtlCli.new(vpn1.name)        
        assert_equal(vpn1, vpn.config)
        out = Sys.capture{
          refute(vpn.exec_with_status("echo 'foo'", check:"200"))
        }.stdout
        assert(out.include?("success"))
      }
    }
  end

  def test_exec_with_status_without_check
    Config.init('foo')
    Config.add_vpn('vpn1')
    vpn1 = Config.vpn('vpn1')

    User.stub(:root?, true) {
      Net.stub(:ip_forward?, true) {
        vpn = VpnCtlCli.new(vpn1.name)        
        assert_equal(vpn1, vpn.config)
        out = Sys.capture{vpn.exec_with_status("echo 'foo'")}.stdout
        assert(out.include?("success"))
      }
    }
  end

  def test_exec_with_status_fail
    Config.init('foo')
    Config.add_vpn('vpn1')
    vpn1 = Config.vpn('vpn1')

    User.stub(:root?, true) {
      Net.stub(:ip_forward?, true) {
        vpn = VpnCtlCli.new(vpn1.name)        
        assert_equal(vpn1, vpn.config)
        out = Sys.capture{assert_raises(SystemExit){vpn.exec_with_status("exit 1", die:true)}}.stdout
        assert(out.include?("failed"))
      }
    }
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
