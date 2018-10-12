#!/usr/bin/env ruby

require 'sinatra'
require 'haml'
require './search_map.rb'

configure do
  $err_flag = false
  begin
    $map_searcher = TreasureMapList.new({timeout:3})
  rescue => er
    $err_flag = true
  end
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
  if $err_flag then
    $err_flag = false
    begin
      p "get wiki data"
      $map_searcher = TreasureMapList.new({timeout:0.5})
    rescue => er
    p "erre!!"
    $err_flag = true
  end

    haml :error
  else 
    $num = params['num']
    $res = $map_searcher.search_num $num
    unless $res.empty? then
      $m =make_res_hash $res
    end
    haml :result
  end
end

post '/'do
  n = params['number'].to_i
  redirect "/?num=#{n}"
end
