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
    ary[0].each_with_index do |v,idx|
      if v == "" then
          v = "不明"
      end
      m[ks[idx]] = v
    end
    return m
  end
  def make_ans_hash ary
    ks = [ "num" , "area_num", "pos", "guard", "info"]
    m = Hash.new() 
    ary[0].each_with_index do |v,idx|
      if v == "" then
          v = "不明"
      end
      m[ks[idx]] = v
    end
    return m
  end
end

get '/'do
# エラー時
  if $err_flag then
    $err_flag = false
    begin
      p "get wiki data"
      $map_searcher = TreasureMapList.new({timeout:0.4})
    rescue => er
      p er
      $err_flag = true
    end
    haml :error
# 正常系
  else 
    $num = $anum = nil
    $area_list = $map_searcher.get_area_list
    $res = []
    $ans = []
    if params['type'] == "a"
      begin
        name = $map_searcher.get_area_list[params['area'].to_i]
        num = params['anum'].to_i
        p name,num
        $ans = $map_searcher.search_ans name, num
        $anum = name+sprintf("%02d",num)
        unless $ans.empty? then
          $m =make_ans_hash $ans
        end
      rescue
        ##?area=hoge でありえない値を入れられたときの対処
        #現状はスルー
      end
    else 
      $num = params['num']
      $res = $map_searcher.search_num $num
      unless $res.empty? then
        $m =make_res_hash $res
      end
    end
    p $m
    haml :result
  end
end

post '/'do
  if params['number'] == "" then
    redirect "/"
  else
    n = params['number'].to_i
    redirect "/?num=#{n}"
  end
end

post '/answer' do
  aname = params['answer_area'] 
  anum  = params['answer_number'] 
  redirect "/?type=a&area=#{aname}&anum=#{anum}"
end

