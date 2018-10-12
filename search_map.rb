#!/usr/bin/env ruby

require "open-uri"
require "rubygems"
require "nokogiri"



class TreasureMapList 
# スクレイピングするURL
  def initialize   
    url = "http://moewiki.usamimi.info/index.php?%A5%B9%A5%AD%A5%EB%2F%B4%F0%CB%DC%2F%B2%F2%C6%C9%2F%B8%C5%A4%D3%A4%BF%C3%CF%BF%DE"
    charset = nil
    begin
      html = open(url) do |f|
        charset = f.charset
        f.read
      end
      @doc = Nokogiri::HTML.parse(html, nil, charset)
    rescue => er
      raise "MoE-Wiki is down??"
    end
# タイトルを表示
    p @doc.title
    tables = @doc.xpath('//div[@class="ie5"]/table')
    @treasure_map_list = [] 
    tables[1..12].each do |table|
      table.search('.//tr').each do |tr|
        thdata = tr.search('.//th')
        th_name =""
        unless thdata.empty? then
          th_name = thdata[0].text
        end
        if th_name.to_i == 0 then
          next
        end
        treasure_data = tr.search('.//td')[0..2].map{|td| td.text}
        treasure_data.unshift(th_name)
        @treasure_map_list << treasure_data
      end
    end
    @treasure_map_list
  end
  def search_num i 
    p @treasure_map_list.select{|m| m[0].to_i == i.to_i}
  end
end

