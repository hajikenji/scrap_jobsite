require 'nokogiri'
require 'open-uri'

url = 'https://tenshoku.mynavi.jp/engineer/list/p27/o16210+o16215+o16220/e01/?soff=1&ags=0'
doc = Nokogiri::HTML(URI.open(url))
binding.irb

mynavi = doc.xpath('//*[@id="content"]/div[3]/section[1]/div[1]/div[4]')
# mynavi.each do |element|
#   p element.attributes['href']
# end
details_job_mynavi = mynavi.children[4].children[1].attributes['href'].value
mynavi_root_url = 'https://tenshoku.mynavi.jp'
# doc1.xpath('')

url = mynavi_root_url + details_job_mynavi
if url.include?('msg')
  details_job_mynavi = doc2.xpath('/html/body/div[1]/form/div[1]/nav[1]/ul/li[1]/a')[0].attributes['href'].value
  url = mynavi_root_url + details_job_mynavi
end
details = Nokogiri::HTML(URI.open(url))
company_name = details.xpath('/html/body/div[1]/div[5]/div[2]/div/div[2]/div[2]/div[2]/h1/span[2]').text
