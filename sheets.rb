require 'dotenv'
Dotenv.load

require "google_drive"

require "bundler/setup"
require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
CREDENTIALS_PATH = "credentials.json".freeze

TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

# デフォルトは0で15分でタイムアウトになるとされる。スクレイピング時間が長いと切れるため設定。
# 詳しくは https://github.com/fog/fog-google/issues/323
Google::Apis::RequestOptions.default.retries = 5

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
# @service = Google::Apis::SheetsV4::SheetsService.new
# @service.client_options.application_name = APPLICATION_NAME
# @service.authorization = authorize
@service = GoogleDrive::Session.from_service_account_key("./credentials.json")


def input_info_into_spreadsheet(scraped_information_list)
  list_spreadsheet_data = get_existing_data_from_spreadsheet
  list_additional_data_without_duplicates = check_for_duplicates(scraped_information_list, list_spreadsheet_data)
  input_data_to_spreadsheet(list_additional_data_without_duplicates)
end


def get_existing_data_from_spreadsheet
  # @spreadsheet_id = ENV['SHEET_ID_service']
  # @range = "A1:A2000"
  # @response = @service.get_spreadsheet_values(@spreadsheet_id, @range)
  # list_existing_data = []
  # @response.values = [["underfind for nilが起きない用", "a"]] if @response.values.nil?
  # @response.values.each do |re|
  #   list_existing_data << re[0].to_s
  # end
  ws = @service.spreadsheet_by_key(ENV['SHEET_ID_service'])
  ws = ws.worksheets[0]
  list_existing_data = []
  (1..ws.num_rows).each do |row|
    list_existing_data << ws[row, 1]
  end
  @ws = ws
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
    p index

    site_name = 'マイナビ' if add_data[1][0].include?('mynavi')
    site_name = 'doda' if add_data[1][0].include?('doda.jp')
    site_name = 'green' if add_data[1][0].include?('green-japan')

    @ws[@ws.num_rows + 1, 1] = add_data[0]
    add_data[1].push(site_name, Time.now)
    list = []
    list << add_data[1]
    @ws.update_cells(@ws.num_rows, 2, list)
    @ws.save
  end
end