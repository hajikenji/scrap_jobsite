require 'nokogiri'
require 'open-uri'
require "net/http"
require 'selenium-webdriver'

# url = 'https://www.green-japan.com/search_key/01?case=login&key=brq5yt9kpamb51sb9mru&keyword=%E6%9C%AA%E7%B5%8C%E9%A8%93'

# def scrap_doda(lojic_list)
#   @session = search_logic(lojic_list)
#   list_collect_links = collect_links_to_each_page
#   collect_info_from_each_page(list_collect_links)
# end

# def search_logic(lojic_list)
#   session = Selenium::WebDriver.for :chrome
#   # 10秒待っても読み込まれない場合は、エラーが発生する
#   session.manage.timeouts.implicit_wait = 10
#   # ページ遷移する
#   session.navigate.to lojic_list
#   session
# end

def scrap_green(lojic_list)
  @session = search_logic(lojic_list)
  list_collect_links = collect_links_to_each_page
  collect_info_from_each_page(list_collect_links)
end

def search_logic(lojic_list)
  session = Selenium::WebDriver.for :chrome
  # 10秒待っても読み込まれない場合は、エラーが発生する
  session.manage.timeouts.implicit_wait = 10
  # ページ遷移する
  session.navigate.to lojic_list
  session
end

def collect_links_to_each_page
  list = []

  page_number = @session.find_element(:id, 'client_count').text
  # numの一桁の位が0であればtrue、そうでなければfalse
  page_number = if page_number.to_s.split('').last == '0'
                  page_number.to_i / 10 - 1
                else
                  page_number.to_i / 10
                end
  page_number.times do
    @session.find_elements(:class, 'js-search-result-box').each do |link|
      list << link['href']
    end
    sleep(1.5)
    @session.navigate.to @session.find_element(:class, 'next_page')['href']
  end
  @session.find_elements(:class, 'js-search-result-box').each do |link|
    list << link['href']
  end
  list = list.uniq
end

def collect_info_from_each_page(list_collect_links)
  @session.navigate.to @session.find_element(:xpath, '//*[@id="js-react-header"]/header/div[2]/nav/a[2]')['href']
  form = @session.find_element(:xpath, '//*[@id="user_mail"]')
  form.send_key(ENV['GREEN_EMAIL'])
  form = @session.find_element(:xpath, '//*[@id="user_password"]')
  form.send_key(ENV['GREEN_PASSWORD'])
  @session.find_element(:xpath, '//*[@id="login_btn"]/input').click

  hash_info_about_company = {}
  list_collect_links.each_with_index do |link, index|
    p index
    sleep(2.5)
    @session.navigate.to link
    p link
    @session.find_element(:xpath, '//*[@id="__next"]/div[1]/div/div[1]/div[2]/a').click
    sleep(2.5)

    company_name = @session.find_element(:class, 'detail-content-table').text.slice(/.*株式会社.*/)
    if @session.find_element(:class, 'detail-content-table').text.include?('従業員数')
      employees = @session.find_element(:class, 'detail-content-table').text.slice(/従業員数.*/)
    end
    if @session.find_element(:class, 'detail-content-table').text.include?('売上')
      amount_of_sales = @session.find_element(:class, 'table-comp').text
    end
    hash_info_about_company[company_name] = [link, employees, amount_of_sales]
    p company_name
  end
  hash_info_about_company
end

# @session.navigate.to @session.find_element(:xpath, '//*[@id="js-react-header"]/header/div[2]/nav/a[2]')['href']
# d = @session.find_element(:xpath, '//*[@id="user_mail"]')
# d.send_key('mademoiselle3824@gmail.com')
# d = @session.find_element(:xpath, '//*[@id="user_password"]')
# d.send_key('GCBRcepQPPjy!J4')
# d = @session.find_element(:xpath, '//*[@id="login_btn"]/input')
# d.click

# @session.find_element(:xpath, '//*[@id="__next"]/div[1]/div/div[1]/div[2]/a').click
# @session.find_element(:class, 'table-comp').text
# @session.find_element(:xpath, '//*[@id="content_cont"]/div[4]/div[1]/table/tbody').text.slice(/従業員数.*/)



# @session.find_elements(:class, 'js-search-result-box').each

# @session.navigate.to @session.find_element(:class, 'next_page')['href']

# list = []
# page_number = @session.find_element(:id, 'client_count').text
# # numの一桁の位が0であればtrue、そうでなければfalse
# if page_number.to_s.split('').last == '0'
#   page_number = page_number.to_i / 10 - 1
# else
#   page_number = page_number.to_i / 10
# end
# page_number.times do
#   @session.find_elements(:class, 'js-search-result-box').each do |link|
#     list << link
#   end
#   sleep(1)
#   @session.navigate.to @session.find_element(:class, 'next_page')['href']
# end
# @session.find_elements(:class, 'js-search-result-box').each do |link|
#   list << link
# end

# scrap_green(url)