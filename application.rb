require 'sinatra'
require 'json'
require "sinatra/param"
require 'sinatra/cross_origin'
require 'nokogiri'
require 'open-uri'

EXCLUDED_ALBUMS = ['All photos', 'Все фотографии', 'Фотографии со страницы сообщества', 'Logo pictures']

def trycon(item)
  item ? item.content : nil
end

def find_album(item)
  {
    name:    trycon(item.at_css('.album_name')), 
    count:   trycon(item.at_css('.album_cnt')),
    thumb:   item.at_css('.album_thumb_img')['src'],
    descr:   trycon(item.at_css('.album_desc')),
    link:    item['href'],
  }
end

configure do
  enable :cross_origin
end

get '/greet' do
  content_type :json
  { status: 'ok', message: params[:greet] }.to_json
end

get '/vkposts' do
  content_type :json
  doc = Nokogiri::HTML(open('http://vk.com/' + params[:uid]))
  result = {}
  doc.css('.pi_text').each_with_index do |item, i|
    result[i] = item.at_xpath("./text()").content
  end
  result.to_json
end

get '/vkalbum' do
  content_type :json
  doc = Nokogiri::HTML(open('http://vk.com/albums-' + params[:album]))
  result = {}
  result[:uid] = params[:album]
  result[:albums] = {}
  albums_array = []

  puts doc.css('.album_item').count
  threads = []
  ended = []
  doc.css('.album_item').each do |item|
    name = trycon(item.at_css('.album_name'))
    if !EXCLUDED_ALBUMS.include?(name)
      ended << name
      threads << Thread.new do
        albums_array << find_album(item)
      end
    end
  end
  threads.each(&:join)

  albums_array.each_with_index do |alb, index|
    result[:albums][index] = alb
  end
  result.to_json
end

get '/vkphotos' do
  alb_page = Nokogiri::HTML(open('http://vk.com/album-' + params[:album]))
  result = {}
  alb_page.css('.thumb_item').each_with_index do |photo, i|
    img, wdth, hght = photo.at_css('img')['data-src_big'].split('|')
    photo_link = photo['href']
    result[i] = {
      link:   photo_link,
      thumb:  photo.at_css('img')['src'],
      img:    img,
      width:  wdth,
      height: hght
    }
  end
  result.to_json
end