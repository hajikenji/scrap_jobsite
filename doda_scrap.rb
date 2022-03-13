require 'nokogiri'
require 'open-uri'
require "net/http"
require 'selenium-webdriver'


# url = "https://doda.jp/DodaFront/View/JobSearchList.action?pr=26%2C27%2C28&oc=031301S%2C032102S&so=50&ss=1&op=17%2C3&preBtn=1&pic=1&ds=0&tp=1&bf=1&mpsc_sid=10&oldestDayWdtno=0&leftPanelType=1&usrclk_searchList=PC-logoutJobSearchList_searchConditionArea_searchButton-ocS-locPrefecture-employment-recruitment"


def scrap_doda(lojic_list)
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

  150.times do
    sleep(1)
    begin
      @session.navigate.to @session.find_element(:class, 'pagenationNext')['href']
    rescue => exception
      if @session.find_element(:xpath, '//*[@id="jobAll"]/div/div[2]/ul[1]/li[2]/span/img')
         p '最後のページ'
         @session.find_elements(:class, '_JobListToDetail').each do |link|
          list << link['href']
         end
         break
      else
        p 'エラー'
        p exception
        exit
      end
    end
    @session.find_elements(:class, '_JobListToDetail').each do |link|
      list << link['href']
    end
  end
  list = list.uniq
end

def collect_info_from_each_page(list_collect_links)
  hash_info_about_company = {}
  list_collect_links.each do |link|
    sleep(1)
    @session.navigate.to link
    if @session.find_element(:class, 'switch_display').text.include?('Pick')
      link = @session.find_element(:class, '_canonicalUrl')['href']
      @session.navigate.to link
    end
    company_name = @session.find_element(:class, 'head_title').text.slice(/.*株式会社.*/)
    employees = @session.find_element(:xpath, '//*[@id="shtTabContent2"]').text.slice(/従業員数.*/)
    amount_of_sales = @session.find_element(:xpath, '//*[@id="shtTabContent2"]').text.slice(/売上高.*/)
    hash_info_about_company[company_name] = [link, employees, amount_of_sales]
    p company_name
  end
  hash_info_about_company
end



# begin
#   session.find_element(:xpath, '//*[@id="jobAll"]/div/div[2]/ul[1]/li[2]/a')['href']
# rescue => exception
#   if session.find_element(:xpath, '//*[@id="jobAll"]/div/div[2]/ul[1]/li[2]/span/img')
#      p '続行'
#   else
#     p 'エラー'
#     p exception
#     exit
#   end
# end