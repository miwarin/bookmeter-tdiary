#!/usr/pkg/bin/ruby -Ku

# -*- encoding: utf-8 -*-


require 'rubygems'
require 'mechanize'
require 'logger'
require 'nkf'
require 'pp'

class BookMeter

  def initialize
    @mail = 'miwarin@gmail.com'
    @pass = 'PASSWORD'
#    @matome_uri = 'http://book.akahoshitakuya.com/matome' # 先月
    @matome_uri = 'http://book.akahoshitakuya.com/matome?sort=0&size=3&tab_id=5#sort_form_blog'
#    @matome_uri = 'http://book.akahoshitakuya.com/matome_lw' # 先週
#    @matome_uri = 'http://book.akahoshitakuya.com/matome_ly' # 去年
  end

  #
  # 先月分のまとめを取得
  #
  def get
    agent = Mechanize.new
    agent.get('http://book.akahoshitakuya.com/login')
    agent.page.form_with(:action => '/login'){|f|
      f.field_with( :name => 'mail' ).value = @mail
      f.field_with( :name => 'password' ).value = @pass
      f.checkboxes[ 0 ].check
      f.click_button
    }
    
    
    agent.get(@matome_uri)

    body = Nokogiri( agent.page.body )
    text = body.search( 'textarea' )[ 2 ].to_s
    text.sub!( %q[<textarea onclick="this.select();_gaq.push(['_trackEvent', 'matome', 'textarea_blog_tag']);">], '')
    # " 秀丸の強調表示がホゲるのでわざとダブルクオーテーションを追加しとく
    
    text.sub!( '</textarea>', '')
    text.gsub!( "'", "\\\\'" )
    text = "{{'" + text + "'}}"
    return text
  end

end

class Diary
  def initialize
    @uri = "http://www.area51.gr.jp/~rin/diary/update.rb"
#    @uri = "http://localhost/~rin/diary/update.rb"
    @user = "TDIARY USER"
    @pass = "TDIARY PASSWORD"
    @referer = "http://www.area51.gr.jp/~rin/diary/update.rb"
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
  td = Diary.new
  td.set(text)
end

main
