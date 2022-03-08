# require 'google_drive'

# session = GoogleDrive::Session.from_config('config.json')

# url =  'https://docs.google.com/spreadsheets/d/1pbdFsQR8sfdoPJMTA_RWUuSN_BADZgppb_x4mgRaD7E/edit#gid=0'
# # 事前に書き込みたいスプレッドシートを作成し、上記スプレッドシートのURL(「xxx」の部分)を以下のように指定する
# sheets = session.spreadsheet_by_key(url).worksheets[0]

# # スプレッドシートへの書き込み
# sheets[1, 1] = 'hello world!!'

# # シートの保存
# sheets.save

require "bundler/setup"
require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
CREDENTIALS_PATH = "credentials.json".freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

# デフォルトは0で15分でタイムアウトになるとされる。スクレイピング時間が長いと切れるため設定。
# 詳しくは https://github.com/fog/fog-google/issues/323
Google::Apis::RequestOptions.default.retries = 5
##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts "Open the following URL in the browser and enter the " \
             "resulting code after authorization:\n" + url
    code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI
        )
  end
  credentials
end

# Initialize the API
@service = Google::Apis::SheetsV4::SheetsService.new
@service.client_options.application_name = APPLICATION_NAME
@service.authorization = authorize

# Prints the names and majors of students in a sample spreadsheet:
# https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
spreadsheet_id = "1pbdFsQR8sfdoPJMTA_RWUuSN_BADZgppb_x4mgRaD7E"
range = "A1:A1500"
response = @service.get_spreadsheet_values(spreadsheet_id, range)
# response.values.each do |row|
#     # Print columns A and E, which correspond to indices 0 and 4.
#     puts "#{row[0]}, #{row[4]}"
# end

# url =  'https://docs.google.com/spreadsheets/d/1pbdFsQR8sfdoPJMTA_RWUuSN_BADZgppb_x4mgRaD7E/edit#gid=0'
# sheets = service.spreadsheet_by_key(url).worksheets[0]
# sheets[1, 1] = 'hello world!!'
# sheets.save

# spreadsheet_id = "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
# range = "Class Data!A2:E"
# response = service.get_spreadsheet_values spreadsheet_id, range
# puts "Name, Major:"
# puts "No data found." if response.values.empty?
# response.values.each do |row|
#     # Print columns A and E, which correspond to indices 0 and 4.
#     puts "#{row[0]}, #{row[4]}"
# end

# value_range = Google::Apis::SheetsV4::ValueRange.new
# value_range.values = [
#   # major_dimension = ROWS なので、配列1つが行のデータ
#   # major_dimension = COLUMNS だと、列のデータになる
#   [
#     "A2に入る値"
#   ]
# ]
# response = @service.update_spreadsheet_value(spreadsheet_id, range, value_range, value_input_option: "RAW")

# def stanby_google_sheets
#   service = Google::Apis::SheetsV4::SheetsService.new
#   service.client_options.application_name = APPLICATION_NAME
#   service.authorization = authorize

#   range = "A1:A500"
#   response = service.get_spreadsheet_values(spreadsheet_id, range)
#   exist_raw = response.values.size

#   # Prints the names and majors of students in a sample spreadsheet:
#   # https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
#   spreadsheet_id = "1pbdFsQR8sfdoPJMTA_RWUuSN_BADZgppb_x4mgRaD7E"
#   range = "A#{exist_raw + 1}"
#   response = service.get_spreadsheet_values(spreadsheet_id, range)
#   puts "Name, Major:"
#   puts "No data found." if response.values.empty?
#   value_range = Google::Apis::SheetsV4::ValueRange.new
#   value_range.values = [
#     # major_dimension = ROWS なので、配列1つが行のデータ
#     # major_dimension = COLUMNS だと、列のデータになる
#     [
#       "A2に入る値"
#     ]
#   ]
#   response = service.update_spreadsheet_value(spreadsheet_id, range, value_range, value_input_option: "RAW")
# end

# b = [1,2,3]
# c = [2,3,4,5]
# list = []
# b.each do |_b|
#   c.each do |ary|
#     list << ary unless b.include?(ary)
#   end
# end
# c.each do |ary|
#   list << ary unless b.include?(ary)
# end
# response = @service.get_spreadsheet_values(spreadsheet_id, "A1:" + range)

# list_existing_data = []
# response.values.each do |re|
#   list_existing_data << re[0].to_s
# end

def input_info_into_spreadsheet(scraped_information_list)
  list_spreadsheet_data = get_existing_data_from_spreadsheet
  list_additional_data_without_duplicates = check_for_duplicates(scraped_information_list, list_spreadsheet_data)
  input_data_to_spreadsheet(list_additional_data_without_duplicates)
end


def get_existing_data_from_spreadsheet
  @spreadsheet_id = "1pbdFsQR8sfdoPJMTA_RWUuSN_BADZgppb_x4mgRaD7E"
  @range = "A1:A1500"
  @response = @service.get_spreadsheet_values(@spreadsheet_id, @range)
  list_existing_data = []
  @response.values = [["underfind for nilが起きない用", "a"]] if @response.values.nil?
  @response.values.each do |re|
    list_existing_data << re[0].to_s
  end
  list_existing_data
end

def check_for_duplicates(scraped_information_list, list_existing_data)
  list_additional_data_without_duplicates = []
  scraped_information_list.each do |ary|
    list_additional_data_without_duplicates << ary unless list_existing_data.include?(ary[0])
  end
  list_additional_data_without_duplicates
end

def input_data_to_spreadsheet(list_additional_data_without_duplicates)
  p "追加分" + list_additional_data_without_duplicates.size.to_s + "社"
  # response = service.get_spreadsheet_values(spreadsheet_id, "A1:" + range)
  list_additional_data_without_duplicates.each.with_index(1) do |add_data, index|
    sleep(1)
    value_range = Google::Apis::SheetsV4::ValueRange.new
    value_range.values = [
      # major_dimension = ROWS なので、配列1つが行のデータ
      # major_dimension = COLUMNS だと、列のデータになる
      [
        add_data[0],
        add_data[1][0],
        add_data[1][1],
        add_data[1][2],
        'マイナビ',
        Time.now
      ]
    ]
    raw_to_input = "A#{@response.values.size + index}:F#{@response.values.size + index}"
    @service.update_spreadsheet_value(@spreadsheet_id, raw_to_input, value_range, value_input_option: "RAW")
  end
end