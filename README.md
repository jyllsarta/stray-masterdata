スピカとチロルのマスターデータだよ

## おおまか説明

1. マスタデータ管理シートにマスタを入力して
2. このリポジトリのrakeタスクを実行するとマスタデータをCSVとして抽出、これ自身がブランチを切ってリモートにあげる
3. PRをマージして更新
4. 本体のリポジトリ上でseedするときに吐き出したCSVを利用

という仕組み

## マスターデータ管理シート

https://docs.google.com/spreadsheets/d/1KK6fVkaDvS645MFDO50JTTc3Wc5zS3Ci9eFlGP1b5r4/edit#gid=285460195

## install

### clone repo

```shell
git clone これ
bundle install
```

### get token

* google_drive gemの指示に従ってgoogle spreadsheetのアクセストークンを取得
  * https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md

* アクセストークンを `config.json` に記述

```shell
cp config.json.example config.json
nano config.json
# (client_id, client_secretを取得したトークン類で上書き)
```

## execute

* 以下コマンドを実行

```shell
bundle exec rake masterdata:fetch
```

completed! と表示されたらリモートブランチにpushされているので、githubのGUI上で差分をチェックし、問題がなさげならそのままマージしましょう
