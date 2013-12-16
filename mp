#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# Copyright rejuvyesh <mail@rejuvyesh.com>, 2013
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require 'optparse'
require 'shellwords'

# defaults
options = {
        volume: 0,
        speed: 1.0,
}

cmd = ["mpv"]
pwd = Dir.pwd

# check if there is a .mp file in the current directory and add it as options
if File.exists? ".mp"
        File.open(".mp", "r").each do |line|
                ARGV << line.chomp
        end
end

# parse options
begin
        OptionParser.new do |opts|
                opts.banner = "Usage: mp [options]"

                opts.on("-+", "--vol=VOL", Integer, "increase volume by VOL") do |v|
                        options[:volume] = v
                end

                opts.on("-t", "--top-left", "play in top-left corner of the screen") do |tl|
                        options[:position] = :top_left
                end
                opts.on("-b", "--bottom-right", "play in bottom-right corner of the screen") do |br|
                        options[:position] = :bottom_right
                end
                opts.on("-x", "--speed SPEED", Float, "increase speed by SPEED") do |s|
                        options[:speed] = s
                end
                opts.on("-y", "--youtube", "youtube mode") do |y|
                        options[:speed] = 1.5
                end
        end.parse!
rescue OptionParser::InvalidOption => e
        cmd << e.to_s.sub(/^invalid option:\s+/, "")
end

if options[:position] == :top_left
        cmd << "--geometry='0:17' --autofit='150x150'"
elsif options[:position] == :bottom_right
        cmd << "--geometry='100%:97%' --autofit='150x150'"
end

# audio filter
cmd << "--af=scaletempo"
if options[:volume].nonzero?
        cmd << "--af=volume=#{options[:volume]}"
end
# speed increase
if options[:speed] != 1.0
        cmd << "--speed #{options[:speed]}"
end

# begin execution
ENV["DISPLAY"] = display
mpv = cmd.join(" ") + " " + Shellwords.shelljoin(ARGV)
puts "running '#{mpv}'..."
system mpv
