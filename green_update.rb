require './green_scrap'
require './sheets'

url = 'https://www.green-japan.com/search_key/01?case=login&key=brq5yt9kpamb51sb9mru&keyword=%E6%9C%AA%E7%B5%8C%E9%A8%93'

hash_info_about_company = scrap_green(url)
input_info_into_spreadsheet(hash_info_about_company)

# require "/Users/hajirokenji/workspace/raiapi/rikunavi/green_update.rb"