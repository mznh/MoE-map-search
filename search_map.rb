#!/usr/bin/env ruby

require "open-uri"
require "rubygems"
require "nokogiri"



class TreasureMapList 
# スクレイピングするURL
  def initialize(op = {:timeout => 2})



  ## wikiからデータ読み込み
    url = "http://moewiki.usamimi.info/index.php?%A5%B9%A5%AD%A5%EB%2F%B4%F0%CB%DC%2F%B2%F2%C6%C9%2F%B8%C5%A4%D3%A4%BF%C3%CF%BF%DE"
    url2 = "http://moewiki.usamimi.info/index.php?%A5%B9%A5%AD%A5%EB%2F%B4%F0%CB%DC%2F%B2%F2%C6%C9%2F%B8%C5%A4%D3%A4%BF%C3%CF%BF%DE%2F%A5%E9%A5%F3%A5%AF%CA%CC"
    charset = nil
    begin
      p "Get wiki data"
      html = open(url,{read_timeout:op[:timeout]}) do |f|
        charset = f.charset
        f.read
      end
      html2 = open(url2,{read_timeout:op[:timeout]}) do |f|
        charset = f.charset
        f.read
      end
      @doc = Nokogiri::HTML.parse(html, nil, charset)
      @answer_doc = Nokogiri::HTML.parse(html2, nil, charset)
    rescue => er
      p "MoE-Wiki is down??"
      raise er
    end
# タイトルを表示
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
    tables = @answer_doc.xpath('//div[@class="ie5"]/table')
    @treasure_answer_list = [] 
    tables[1..12].each do |table|
      table.search('.//tr').each do |tr|
        thdata = tr.search('.//th')
        th_name = ""
        unless thdata.empty? then
          th_name = thdata[0].text
        end
        if th_name.to_i == 0 then
          next
        end
        treasure_data = tr.search('.//td')[0..3].map.with_index{|td,idx|
## wiki上の表記ブレを吸収
          if idx == 0 then 
            fixed_text = td.text.gsub(/レクスールヒルズ/,"レクスール・ヒルズ")
            fixed_text
          else
            td.text
          end
        }
        treasure_data.unshift(th_name)
        @treasure_answer_list << treasure_data
      end
    end
    @area_list = @treasure_answer_list.map{|d| d[1].match(/[^0-9]*/)[0]}.sort.uniq
  end
  def search_num i 
    @treasure_map_list.select{|m| m[0].to_i == i.to_i}
  end
## プルダウンメニューから選ばれたエリア名と名前を組み合わせて検索
  def search_ans area,num
    name = area + sprintf("%02d",num)
    @treasure_answer_list.select{|m| m[1] == name }
  end
  def get_area_list
    return @area_list
  end
  def echo
    return @treasure_map_list, @treasure_answer_list
  end

end


#td = TreasureMapList.new()
##p td.echo[1].select{|d| d[1]}
#p td.echo[1][5]
