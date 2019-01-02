require 'httpclient'
require 'json'
require 'slack-notifier'

def post_slack(content)
  message = ''
  notifier = Slack::Notifier.new(ENV['WEB_HOOK_URL'])
  content.each do |c|
    message << "\rタイトルは#{c[0]}\rURLは#{c[1]}です。\r"
  end
  notifier.ping("未読記事を報告します！\r#{message}")
end

def fetch_unread_articles
  article_title_and_url = []
  client = HTTPClient.new
  query = { unreadOnly: true }
  response = client.get("https://cloud.feedly.com/v3/streams/contents?streamId=user/#{ENV['STREAM_ID']}/category/global.all", query: query, header: [["Authorization", ENV['ACCESS_TOKEN']])

  body = JSON.parse response.body

  body['items'].each do |item|
    article = []
    article.push(item['title'])
    article.push(item['originId'])
    article_title_and_url.push(article)
  end
  post_slack(article_title_and_url)
end

# 記事の既読api
# def articles_as_read
#   client = HTTPClient.new
#   body = { action: 'markAsRead', type: 'entries', entryId: '' }
#   header = {Authorization: ACCESS_TOKEN}
#   response = client.post('https://cloud.feedly.com/v3/markers', body: body, header: [[header]] )
# end

def lambda_handler(event:, context:)
  fetch_unread_articles
end
