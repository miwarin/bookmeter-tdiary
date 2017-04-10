#!/usr/pkg/bin/ruby -Ku

# -*- encoding: utf-8 -*-

require 'rubygems'
require 'mechanize'
require 'logger'
require 'nkf'
require 'cgi'
require 'pp'

BOOKMETER_USERNAME = 'USERNAME'
BOOKMETER_PASSWORD = 'PASSWORD'
BOOKMETER_USERID = ID
TDIARY_USERNAME = 'USERNAME'
TDIARY_PASSWORD = 'PASSWORD'

class BookMeter

  def initialize
    @mail = BOOKMETER_USERNAME
    @pass = BOOKMETER_PASSWORD
    @matome_uri = %Q(https://bookmeter.com/users/#{BOOKMETER_USERID}/summary/posting/blog?order=desc&insert_break=true&image_size=small#blog_html)
  end

  #
  # 先月分のまとめを取得
  #
  def get
    agent = Mechanize.new
    agent.get('https://bookmeter.com/login')
    agent.page.form_with(:action => '/login'){|f|
      f[ 'session[email_address]' ] = @mail
      f[ 'session[password]' ] = @pass
      f.checkboxes[ 0 ].check
      f.click_button
    }
    
    # まとめへ遷移
    agent.get(@matome_uri)
    
    # 「改行を入れる」をチェック
    agent.page.forms[1].checkboxes[ 0 ].check
    
    text = Nokogiri( agent.page.body ).search( 'textarea' )[ 0 ].to_s
    text.sub!( '<textarea onclick="this.select();" readonly>', '' )
    text.sub!( '</textarea>', '' )
    text = CGI.unescapeHTML( text )
    text = "{{'" + text + "'}}"
    return text
  end
end

class Diary
  def initialize
    @uri = "https://www.area51.gr.jp/~rin/diary/update.rb"
    @referer = "https://www.area51.gr.jp/~rin/diary/update.rb"
    @user = TDIARY_USERNAME
    @pass = TDIARY_PASSWORD
  end
  
  def set(text)
    agent = Mechanize.new
    agent.log = Logger.new($stdout)
    agent.log.level = Logger::INFO
    agent.auth(@user, @pass)
    agent.get(@uri, nil, @referer)
    
    text = "!読書メーター\n\n" + text
    
    agent.page.encoding = 'UTF-8'

    agent.page.form_with(:action => "update.rb") { |form|
      form['body'] = text
      form.submit(
        form.button_with(:name => "append"),
        headers = {
          "referer" => @referer,
        }
      )
    }
  end
end

def main
  bm = BookMeter.new
  text = bm.get
  puts text
  td = Diary.new
  td.set(text)
end

main
