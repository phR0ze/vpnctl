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

require_relative '../lib/model'

class Test_Model < Minitest::Test

  def test_FailMessage
    assert_equal(1, Model::FailMessages.size)
    refute(nil, Model::FailMessages.first)
  end

  def test_CommCmd
    assert_equal('halt', Model::CommCmd.halt)
    assert_equal('fail', Model::CommCmd.fail)
    assert_equal('vpn_up', Model::CommCmd.vpn_up)
    assert_equal('vpn_down', Model::CommCmd.vpn_down)
  end

  def test_PassTypeDisplay
    assert_equal("Ask for password", Model::PassTypeDisplay['ask'])
    assert_equal("Save password", Model::PassTypeDisplay['save'])
  end

  def test_PassTypes
    assert_equal("ask", Model::PassTypes.ask)
    assert_equal("save", Model::PassTypes.save)
  end

  def test_State
    assert_equal("active", Model::State.active)
    assert_equal("connected", Model::State.connected)
  end

  def test_Login_constructor
    login = Model::Login.new('foo', 'bar', 'dandy')
    assert_equal('foo', login.type)
    assert_equal('bar', login.user)
    assert_equal('dandy', login.pass)
  end

  def test_Login_clone_self
    login1 = Model::Login.new('foo', 'bar', 'dandy')
    login2 = login1.clone
    login1.type = "bob"
    refute(login1.type == login2.type)
    assert_equal("bob", login1.type)
    assert_equal("foo", login2.type)
    assert_equal(login1.user, login2.user)
    assert_equal(login1.pass, login2.pass)
  end

  def test_Login_clone_from_other
    login1 = Model::Login.new('foo', 'bar', 'dandy')
    login2 = Model::Login.new.clone(login1)
    login1.type = "bob"
    refute(login1.type == login2.type)
    assert_equal("bob", login1.type)
    assert_equal("foo", login2.type)
    assert_equal(login1.user, login2.user)
    assert_equal(login1.pass, login2.pass)
  end

  def test_Login_clone_nil
    login1 = Model::Login.new('foo', 'bar', 'dandy')
    login2 = Model::Login.new.clone(nil)
    assert_nil(login2.type)
    assert_nil(login2.user)
    assert_nil(login2.pass)
  end

  def test_Vpn_clone_self
    vpn1 = Model::Vpn.new("vpn1", Model::Login.new(Model::PassTypes.ask, "user1", "pass1"),
      ["10.22.13.6"], "/etc/openvpn/client/vpn1.ovpn", "/etc/openvpn/client/vpn1.auth",
      true, ["appfoo"], true, Model::State.active)
    vpn2 = vpn1.clone
    assert_equal(vpn1, vpn2)
    vpn1.name = "foo"
    refute_equal(vpn1, vpn2)
  end

  def test_Vpn_clone_from_other
    vpn1 = Model::Vpn.new("vpn1", Model::Login.new(Model::PassTypes.ask, "user1", "pass1"),
      ["10.22.13.6"], "/etc/openvpn/client/vpn1.ovpn", "/etc/openvpn/client/vpn1.auth",
      true, ["appfoo"], true, Model::State.active)
    vpn2 = Model::Vpn.new.clone(vpn1)
    assert_equal(vpn1, vpn2)
    vpn1.name = "foo"
    refute_equal(vpn1, vpn2)
  end

  def test_Vpn_clone_nil
    vpn1 = Model::Vpn.new("vpn1", Model::Login.new(Model::PassTypes.ask, "user1", "pass1"),
      ["10.22.13.6"], "/etc/openvpn/client/vpn1.ovpn", "/etc/openvpn/client/vpn1.auth",
      true, ["appfoo"], true, Model::State.active)
    vpn2 = Model::Vpn.new.clone(nil)
    refute_equal(vpn1, vpn2)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
