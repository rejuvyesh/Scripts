#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# File: grabjeb.rb
#
# Copyright rejuvyesh <mail@rejuvyesh.com>, 2014
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

# Backup pocket articles

require 'cri'
require 'mechanize'

command = Cri::Command.define do
  name      'grabjeb'
  usage     'grabjeb [options] output.html'
  summary   'backup pocket export'

  flag :h, :help, 'show help' do |value, cmd|
    puts cmd.help
    exit 0
  end

  required :u, :user, 'user'
  required :p, :password, 'password'

  run do |opts, args, cmd|

    output = args.first

    if output.nil?
      puts 'output file required'
      exit 1
    end

    if opts[:user].nil? or opts[:password].nil?
      puts 'need login data'
      exit 1
    end

    puts 'getting pocket export file...'

    # log into pocket
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'

    page = agent.get "https://getpocket.com/login"
    login_form = page.forms.first
    login_form['feed_id'] = opts[:user]
    login_form['password'] = opts[:password]

    agent.submit login_form

    puts "signed in to pocket"

    # Grabbing
    export_page = agent.get 'https://getpocket.com/export/'
    export = export_page.link_with(text: 'Export HTML file').click

    puts 'done'
    puts 'writing to file...'
    File.open(output, 'w') { |file| file.write(export.body) }
  end
end

command.run(ARGV)
