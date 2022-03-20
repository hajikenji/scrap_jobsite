require './doda_scrap.rb'
require './sheets.rb'

# 未経験可
# url = 'https://doda.jp/DodaFront/View/JobSearchList.action?pr=26%2C27%2C28&oc=03L&ss=1&op=17%2C70&preBtn=1&pic=1&ds=0&tp=1&bf=1&mpsc_sid=10&oldestDayWdtno=0&leftPanelType=1&usrclk_searchList=PC-logoutJobSearchList_searchConditionArea_searchButtonFloat-ocL-locPrefecture-employment-kodawari-recruitment'
# 未経験外し
# url = 'https://doda.jp/DodaFront/View/JobSearchList.action?ss=1&op=3%2C17&pr=26%2C27%2C28&pic=1&ds=0&oc=03L&so=50&tp=1'
# # 1000人まで 11~50
url = 'https://doda.jp/DodaFront/View/JobSearchList.action?pr=26%2C27%2C28&oc=03L&so=50&ss=1&op=3%2C17%2C70&pic=1&ds=0&tp=1&bf=1&mpsc_sid=10&leftPanelType=1&usrclk_searchList=PC-loginJobSearchList_searchConditionArea_searchButton-ocL-locPrefecture-employment-kodawari-recruitment'

hash_info_about_company = scrap_doda(url)
input_info_into_spreadsheet(hash_info_about_company)

# require "/Users/hajirokenji/workspace/raiapi/rikunavi/doda_update.rb"