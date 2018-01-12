require 'mechanize'
require 'logger'
require 'cgi'
require 'pp'

module BookMeter
  class BookMeter

    def initialize(username, pass, id)
      @mail = username
      @pass = pass
      @matome_uri = %Q(https://bookmeter.com/users/#{id}/summary/monthly/posting/blog?order=desc&insert_break=true&image_size=small#blog_html)
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
      text = Nokogiri( agent.page.body ).search( "//div[@class='inner__htmlsample']" ).to_s
      text = "{{'" + text + "'}}"
      return text
    end
  end

  class Diary
    def initialize(username, pass, uri)
      @user = username
      @pass = pass
      @uri = uri
      @referer = uri
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
end # module
