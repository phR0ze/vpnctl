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

  def test_Login
    login = Model::Login.new('foo', 'bar', 'dandy')
    assert_equal('foo', login.type)
    assert_equal('bar', login.user)
    assert_equal('dandy', login.pass)
  end

  def test_CommCmd
    assert_equal('halt', Model::CommCmd.halt)
  end

  def test_PassType
    assert_equal('ask', Model::PassTypes.ask)
    vpn = Model::Login.new(Model::PassTypes.ask, 'user', 'pass')
    assert_equal('ask', vpn.type)
  end
end

# vim: ft=ruby:ts=2:sw=2:sts=2
