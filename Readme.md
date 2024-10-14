# docker-mirakc-epgstation

[mirakc](https://github.com/mirakc/mirakc) + [EPGStation](https://github.com/l3tnun/EPGStation) の Docker コンテナ

## 前提条件

- Dockerの導入が必須
- ホスト上の pcscd は停止する
- チューナーのドライバが適切にインストールされていること
- PT3用に設定してありますそのままの設定で使用されたい場合はPT3を利用してください

## インストール手順

```sh
curl -sf https://raw.githubusercontent.com/5ym/docker-mirakc-epgstation/main/setup.sh | sh -s
cd docker-mirakc-epgstation
# チャンネル、チューナー設定
# https://github.com/mirakc/mirakc?tab=readme-ov-file#launch-a-mirakc-docker-container
vim mirakc/config.yml
# コメントアウトされている restart や user の設定を適宜変更する
vim compose.yml
```

## 起動

```sh
docker compose up -d
```

mirakc の EPG 更新を待ってからブラウザで <http://DockerHostIP:8888> へアクセスし動作を確認する

## 停止

```sh
docker compose down
```

## 更新

```sh
# mirakcとdbを更新
docker compose pull
# epgstationを更新
docker compose build --pull
# 最新のイメージを元に起動
docker compose up -d
```

## 設定

### Mirakc

- ポート番号: 40772

### EPGStation

- ポート番号: 8888
- ポート番号: 8889

### 各種ファイル保存先

- 録画データ
```./recorded```
- サムネイル
```./epgstation/thumbnail```
- 予約情報と HLS 配信時の一時ファイル
```./epgstation/data```
- EPGStation 設定ファイル
```./epgstation/config```
- EPGStation のログ
```./epgstation/logs```

## v1からの移行について

[docs/migration.md](docs/migration.md)を参照
