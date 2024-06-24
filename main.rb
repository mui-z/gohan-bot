require 'discordrb'
require 'dotenv/load'
require 'net/http'
require 'uri'
require 'dotenv/load'
require 'rexml/document'

include REXML

bot = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_API_KEY'], prefix: '/'

def request_eatery(query)
  recruit_api_key = ENV['RECRUIT_API_KEY']

  uri = URI.parse("https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{recruit_api_key}&#{query}&count=5")
  response = Net::HTTP.get_response(uri)

  doc = Document.new(response.body)

  doc.get_elements("//shop")
end

bot.message(content: 'ping') do |event|
  m = event.respond('pong!')
  m.edit "Pong! Time taken: #{Time.now - event.timestamp} seconds."
end

bot.command(:izakaya, description: "居酒屋を検索します") do |_event, *keyword_string|

  keyword = URI.encode_www_form_component(keyword_string.join().gsub('　', ' '))
  query_hash = {
    "keyword" => keyword,
    "course" => 1,
    "non_smoking" => 1,
  }

  result = []
  query_hash.each do |key, value|
    result << "#{key}=#{value}"
  end

  eatries = request_eatery(result.join('&'))

  eatries.each do |shop|
    _event << "**#{shop.elements["name"].text}**"
    _event << shop.elements["address"].text
    _event << shop.elements["access"].text
    _event << shop.elements["urls"].elements["pc"].text
    _event << ""
  end

  _event << 'Powered by [ホットペッパーグルメ Webサービス](http://webservice.recruit.co.jp/)'
end

bot.command(:lunch, description: "ランチを検索します") do |_event, *keyword_string|
  keyword = URI.encode_www_form_component(keyword_string.join().gsub('　', ' '))
  query_hash = {
    "keyword" => keyword,
    "lunch" => 1
  }

  result = []
  query_hash.each do |key, value|
    result << "#{key}=#{value}"
  end

  eatries = request_eatery(result.join('&'))

  eatries.each do |shop|
    _event << "**#{shop.elements["name"].text}**"
    _event << shop.elements["address"].text
    _event << shop.elements["access"].text
    _event << shop.elements["urls"].elements["pc"].text
    _event << ""
  end

  _event << 'Powered by [ホットペッパーグルメ Webサービス](http://webservice.recruit.co.jp/)'
end

bot.command(:cafe, description: "カフェを3件検索します") do |_event, *keyword_string|
  keyword = URI.encode_www_form_component(keyword_string.join().gsub('　', ' '))
  query_hash = {
    "keyword" => keyword,
    "genre" => "G014",
    "non_smoking" => 1,
    "type" => "lite"
  }

  result = []
  query_hash.each do |key, value|
    result << "#{key}=#{value}"
  end

  eatries = request_eatery(result.join('&'))

  eatries.each do |shop|
    _event << "**#{shop.elements["name"].text}**"
    _event << shop.elements["address"].text
    _event << shop.elements["access"].text
    _event << shop.elements["catch"].text
    _event << shop.elements["urls"].elements["pc"].text
    _event << ""
  end

  _event << 'Powered by [ホットペッパーグルメ Webサービス](http://webservice.recruit.co.jp/)'
end

bot.run
