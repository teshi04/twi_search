# coding: utf-8

require 'rubygems' unless defined? ::Gem
require 'sinatra'
require 'erubis'
require 'yaml'
require 'twitter'

set :server, 'webrick' # unicornで動かすときはいらないっぽい
set :erb, :escape_html => true

path = File.expand_path(File.dirname(__FILE__))

begin
  $settings = YAML::load(open(path+"/twitter.conf"))
rescue
  puts "config file load failed."
end

client = Twitter::REST::Client.new do |config|
 config.consumer_key = $settings["consumer_key"]
 config.consumer_secret = $settings["consumer_secret"]
end

get '/' do

  search_word = "" 
  erb :index, :locals => {:search_word => search_word }
end

post '/' do
  results = []
  search_word = params[:query]
  results = results | client.search(search_word, :result_type => "recent").collect do |tweet|
    "#{tweet.user.screen_name}: #{tweet.text}\n"
  end

  erb :result, :locals => {:results => results, :search_word => search_word }
end
