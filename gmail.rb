require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'dotenv'

Dotenv.load

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

def oauth_credentials(scope, client_id, client_secret)
  token_store = Google::Auth::Stores::FileTokenStore.new(:file => './tokens.yaml')
  client_id = Google::Auth::ClientId.new(client_id, client_secret)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

  user_id = 'gmail'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    # 初回起動時は OAuth の許可のため URL が出るのでブラウザでアクセスし、code を取得しコンソールにコピペする
    url = authorizer.get_authorization_url(base_url: OOB_URI )
    puts "Open #{url} in your browser and enter the resulting code:"
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

Gmail = Google::Apis::GmailV1
gmail = Gmail::GmailService.new
gmail.authorization = oauth_credentials(Gmail::AUTH_SCOPE, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
p gmail.list_user_messages(ENV["EMAIL"])
