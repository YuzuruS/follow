require 'mechanize'
require 'uri'
require "pry-byebug"

class TwitterAgent < Mechanize

  attr :followed_cnt
  attr :followed_upper_limit

  def initialize
    super
    @followed_cnt = 0 # フォローカウント
    @followed_upper_limit = 50 # 1回のプロセスでフォローする最大値
    @sleep_time = 10 # 1フォローごとにsleepする時間
  end

  def login(user_name, password)
    uri = "https://twitter.com/login"
    page = self.get(uri)
    unless page.meta_refresh.empty?
      page = self.get(page.meta_refresh[0].uri.to_s)
    end
    forms = page.form_with(:action => 'https://twitter.com/sessions')
    forms['session[username_or_email]'] = user_name
    forms['session[password]'] = password
    page = forms.submit
    return page
  end

  def get_search_page(word)
    uri = "https://mobile.twitter.com/search?q=#{URI.escape(word)}"
    page = self.get(uri)
    if page.links[8].text.include?("更新")
      return page.links[8].click
    end
    return page
  end

  def move_next_page(page)
    if page.links[-5].text.include?("さらにツイートを読み込む")
      page = page.links[-5].click
    else
      page = nil
    end
    return page
  end

  def follow_for_search_page(page)
    page.links.each do |l|
      if !l.href.nil? && l.href.include?('/status')
        detail = l.click
        follow(detail)
      end
    end
  end

  def follow(page)
    page.forms.each do |form|
      if form.action.include?("/follow")
        button = form.buttons[0]
        self.submit(form, button)
        p form.action.gsub("/follow", "")
        sleep(@sleep_time)
        @followed_cnt += 1
      end
    end
  end
end