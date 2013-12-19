#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# Copyright rejuvyesh <mail@rejuvyesh.com>, 2013
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require 'optparse'
require 'shellwords'
require 'traktr'
require 'to_name'
require 'yaml'


# defaults
options = {
        volume: 0,
        speed: 1.0,
}

cmd = ["mpv --save-position-on-quit"]
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
      options[:volume]   = v
    end

    opts.on("-l", "--top-left",     "play in top-left corner of the screen") do |tl|
      options[:position] = :top_left
    end
    opts.on("-b", "--bottom-right", "play in bottom-right corner of the screen") do |br|
      options[:position] = :bottom_right
    end
    opts.on("-x", "--speed SPEED",  Float, "increase speed by SPEED") do |x|
      options[:speed]    = x
    end
    opts.on("-s", "--size STR",     "set size of the player") do |sa| 
      options[:size]     = sa
    end
    opts.on("-y", "--youtube",      "youtube mode") do |y|
      options[:speed]    = 1.5
      cmd << "--cache-default=2048"
    end
    opts.on("-a", "--audio",        "audio mode") do |a|
      cmd << "--audio-display=no --gapless-audio"
    end
    opts.on("-t", "--trakt",        "scrobble to trakt") do |t| 
      options[:trakt]    = true;
    end
  end.parse!

rescue OptionParser::InvalidOption => e
  cmd << e.to_s.sub(/^invalid option:\s+/, "")
end

# size
if options[:size]
  cmd << "--autofit='#{options[:size]}'"
end

if options[:position] == :top_left
  cmd << "--geometry='0:17'"
elsif options[:position] == :bottom_right
  cmd << "--geometry='100%:97%'"
end

# audio filter
cmd << "--af=scaletempo"  # Remove chirping at higher speed
if options[:volume].nonzero?
  cmd << "--af=volume=#{options[:volume]}"
end

# speed increase
if options[:speed] != 1.0
  cmd << "--speed=#{options[:speed]}"
end

# begin execution
file      = Shellwords.shelljoin(ARGV)
mpv       = cmd.join(" ") + " " + file
puts "running '#{mpv}'..."
system mpv

# mark as seen on trakt
if options[:trakt]
  traktconfig = YAML.load File.open("#{Dir.home}/.traktrc")
  @trakt      = Traktr::Client.new(traktconfig["api_key"], traktconfig["username"], traktconfig["password"], true)
  show        = ToName.to_name(file)
  tries = 3
  begin 
    info        = @trakt.search.shows(show.name)
    @episodes   = @trakt.show.season(info[0].title,       show.series)
    res         = @trakt.show.episode.seen(info[0],       @episodes[show.episode-1..show.episode-1])
  rescue Exception => e
    tries -= 1
    if tries > 0
      retry
    else
      puts "Couldn't connect to trakt"
    end
  end
end
