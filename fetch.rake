# 所定のgoogle spreadsheetをダウンロードしてきて、seedsディレクトリにcsvをエクスポート
require "google_drive"
require 'byebug'
require 'git'

SPREADSHEET_KEY = "1KK6fVkaDvS645MFDO50JTTc3Wc5zS3Ci9eFlGP1b5r4"

namespace :masterdata do
  task :fetch do |_, args|

    reset_repository
    session = GoogleDrive::Session.from_config("config.json")
    sess = session.spreadsheet_by_key(SPREADSHEET_KEY)
    retry_count = 0
    tables = selected_tables || load_config
    tables.each do |table_name|
      begin
        ws = sess.worksheet_by_title(table_name)
        ws.export_as_file("seeds/#{table_name}.csv")
        puts "saved #{table_name}.csv"
        sleep(1)
      rescue Google::Apis::RateLimitError
        puts "rate limit exceeded, sleeping 60 seconds..."
        retry_count += 1
        sleep(60)
        retry if retry_count < 5
      end
    end
    push_to_repository
  end

  def selected_tables
    return nil if ENV["TARGET_TABLES"].nil?
    ENV["TARGET_TABLES"].split(",")
  end

  def load_config
    YAML.load(File.read("tables.yml"))['tables']
  end

  def work_branch_name
    "masterdata_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  def reset_repository
    git_client = Git.open("./")

    git_client.reset_hard
    git_client.checkout("develop")
    git_client.pull
  end

  def push_to_repository
    git_client = Git.open("./")
    git_client.branch(work_branch_name).create
    git_client.checkout(work_branch_name)
    # ファイルを追加してコミット
    git_client.add("seeds/*")
    begin
      git_client.commit("update by Masterdata Task #{Time.now.to_s}")
      git_client.push("origin", work_branch_name)
      puts "completed!"
    rescue Git::GitExecuteError => e
      puts e.class
      puts e.message
      puts e.backtrace
    end
    git_client.checkout("develop")
  end
end
