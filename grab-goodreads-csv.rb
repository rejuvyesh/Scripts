#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# File: grab-goodreads-csv.rb
#
# Copyright rejuvyesh <mail@rejuvyesh.com>, 2013
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>


require "cri"
require "mechanize"

command = Cri::Command.define do
  name        'grab-goodreads-csv'
  usage       'grab-goodreads-csv [options] output.csv'
  summary     'downloads goodreads csv'

  flag :h, :help,  'show help' do |value, cmd|
    puts cmd.help
    exit 0
  end

  required :u, :user,     'user'
  required :p, :password, 'password'

  run do |opts, args, cmd|
    output = args.shift

    if output.nil?
      puts "output file required"
      exit 1
    end

    if opts[:user].nil? or opts[:password].nil?
      puts "need login data"
      exit 1
    end

    puts "grabbing csv..."

    # log into goodreads
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'

    page = agent.get "https://www.goodreads.com/user/sign_in"

    login_form = page.forms.first
    login_form['user[email]'] = opts[:user]
    login_form['user[password]'] = opts[:password]

    page = agent.submit login_form

    puts "signed in to goodreads"
    puts "Getting CSV"

    # Grab CSV
    csv_url = "http://www.goodreads.com/review_porter/goodreads_export.csv"

    csv_content = agent.get_file(csv_url)

    puts "done"

    puts "writing to file..."

    File.open(output, 'w') { |file| file.write(csv_content) }
      
  end
end

command.run(ARGV)
