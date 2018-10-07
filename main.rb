#!/usr/bin/env ruby

require 'sinatra'
require 'haml'
require './search_map.rb'

configure do
  $map_searcher = TreasureMapList.new()
end

helpers do
  def make_res_hash ary
    ks = [ "num" , "area", "rank", "skill"]
    m = Hash.new() 
    $res[0].each_with_index do |v,idx|
      if v == "" then
          v = "不明"
      end
      m[ks[idx]] = v
    end
    return m
  end
end

get '/'do
  $num = params['num']
  $res = $map_searcher.search_num $num
  unless $res.empty? then
    $m =make_res_hash $res
  end
  haml :result
end

post '/'do
  n = params['number'].to_i
  redirect "/?num=#{n}"
end
