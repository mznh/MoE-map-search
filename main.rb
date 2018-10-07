#!/usr/bin/env ruby

require 'sinatra'
require 'haml'
require './search_map.rb'

configure do
  $map_searcher = TreasureMapList.new()
end


get '/'do
  $res = $map_searcher.search_num params['num']
  haml :result
end

post '/'do
  n = params['number'].to_i
  redirect "/?num=#{n}"
end
