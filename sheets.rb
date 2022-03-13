require 'dotenv'
Dotenv.load

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
@service = Google::Apis::SheetsV4::SheetsService.new
@service.client_options.application_name = APPLICATION_NAME
@service.authorization = authorize

def input_info_into_spreadsheet(scraped_information_list)
  list_spreadsheet_data = get_existing_data_from_spreadsheet
  list_additional_data_without_duplicates = check_for_duplicates(scraped_information_list, list_spreadsheet_data)
  input_data_to_spreadsheet(list_additional_data_without_duplicates)
end


def get_existing_data_from_spreadsheet
  @spreadsheet_id = ENV['SHEET_ID']
  @range = "A1:A2000"
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

    site_name = 'マイナビ' if add_data[1][0].include?('mynavi')
    site_name = 'doda' if add_data[1][0].include?('doda.jp')

    value_range.values = [
      # major_dimension = ROWS なので、配列1つが行のデータ
      # major_dimension = COLUMNS だと、列のデータになる
      [
        add_data[0],
        add_data[1][0],
        add_data[1][1],
        add_data[1][2],
        site_name,
        Time.now
      ]
    ]
    raw_to_input = "A#{@response.values.size + index}:F#{@response.values.size + index}"
    @service.update_spreadsheet_value(@spreadsheet_id, raw_to_input, value_range, value_input_option: "RAW")
  end
end