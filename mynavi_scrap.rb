require 'nokogiri'
require 'open-uri'

def scrap_mynavi(lojic_list)
  url_based_on_logic = search_logic(lojic_list)
  list_collect_links = collect_links_to_each_page(url_based_on_logic)
  collect_info_from_each_page(list_collect_links)
end

def search_logic(lojic_list)
  @logic_url = 'https://tenshoku.mynavi.jp/engineer/list/'
  lojic_list.each_with_index do |list, index|
    p list
    if list.empty?
      list.delete_at(index)
      next
    end
    if index == 0 || index == 1 || index == 3
      @logic_url += list.join('+') + '/'
    elsif index == 2 || index == 4
      @logic_url += list.join('_') + '/'
    else
      @logic_url += list[0] + '/'
    end
  end
  url = @logic_url + '?soff=1&ags=0'
  Nokogiri::HTML(URI.open(url))
end

def collect_links_to_each_page(url_based_on_logic)
  list_collect_links = []
  url_based_on_logic.xpath('//a[@class="link entry_click entry3"]').each do |url|
    url = url.attributes["href"].value
    url.sub!(/msg./, '') if url.include?('msg')
    list_collect_links << 'https://tenshoku.mynavi.jp' + url
    
  end
  300.times do |page_number|
    sleep(2)
    page_number = page_number + 2
    next_page = url_based_on_logic.xpath("//*[@id='content']/div[3]/div[4]/ul/li[#{page_number}]/a")
    break if next_page.empty? || next_page.text == '次へ'
    p next_page.text + "ページ目収集"
    url = 'https://tenshoku.mynavi.jp' + next_page[0].attributes["href"].value
    page = Nokogiri::HTML(URI.open(url))
    page.xpath('//a[@class="link entry_click entry3"]').each do |next_url|
      next_url = next_url.attributes["href"].value
      next_url.sub!(/msg./, '') if next_url.include?('msg')
      list_collect_links << 'https://tenshoku.mynavi.jp' + next_url
    end
  end
  list_collect_links
end

def collect_info_from_each_page(list_collect_links)
  hash_info_about_company = {}
  
  num = 1
  list_collect_links.each do |link|
    sleep(1)
    p num
    num += 1
    url = link
    link = Nokogiri::HTML(URI.open(link))
    if link.xpath('/html/body/div[1]/div[5]/div[4]/div/div[2]/div[1]/table[2]/tbody/tr[3]/th').text == '従業員数'
      p employees = link.xpath('/html/body/div[1]/div[5]/div[4]/div/div[2]/div[1]/table[2]/tbody/tr[3]/td/div').text
    end
    if link.xpath('/html/body/div[1]/div[5]/div[4]/div/div[2]/div[1]/table[2]/tbody/tr[5]/th').text == '売上高'
      p amount_of_sales = link.xpath('/html/body/div[1]/div[5]/div[4]/div/div[2]/div[1]/table[2]/tbody/tr[5]/td/div').text
    end
    p company_name = link.xpath('//span[@class="companyName"]').text
    hash_info_about_company[company_name] = [url, employees, amount_of_sales]
  end
  hash_info_about_company
end

# list_collect_links.sizeは50なのにhash_info_about_company.sizeは46の不思議を検証するメソッド
# 結果、フォー座ウィンなどよくある系のみ（多分）が上手く抽出されてなかったので支障はないが、謎は解けず
# list = []
# hash_info_about_company.each do |ary|
#   list << ary[1][0]
# end
# h = []
# list_collect_links.each do |ary|
#   h << ary unless list.include?(ary)
# end