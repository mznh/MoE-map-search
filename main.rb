#!/usr/bin/env ruby

require 'sinatra'
require 'haml'
require './search_map.rb'

configure do
  $map_searcher = TreasureMapList.new()
end


get '/'do
  $res = $map_searcher.search_num params['num']
  if $res.empty? then
    "not found"
  else
    haml :result
  end
end
