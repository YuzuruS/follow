require File.dirname(__FILE__) +  "/twitter_agent"

user = {
    :email     => "your email",
    :password  => "your password"
}


agent = TwitterAgent.new
agent.login(user[:email], user[:password])
page = agent.get_search_page('#hoge')
while !page.nil?
  agent.follow_for_search_page(page)

  if agent.followed_cnt >= agent.followed_upper_limit
    break
  end

  page = agent.move_next_page(page)
end
