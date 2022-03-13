require './doda_scrap.rb'
require './sheets.rb'

url = 'https://doda.jp/DodaFront/View/JobSearchList.action?ci=012076&oc=03L&ss=1&preBtn=1&pic=1&ds=0&tp=1&bf=1&mpsc_sid=10&oldestDayWdtno=0&leftPanelType=1&usrclk_searchList=PC-logoutJobSearchList_searchConditionArea_searchButtonFloat-ocL-locCity'

hash_info_about_company = scrap_doda(url)
input_info_into_spreadsheet(hash_info_about_company)

# require /Users/hajirokenji/workspace/raiapi/rikunavi/doda_update.rb