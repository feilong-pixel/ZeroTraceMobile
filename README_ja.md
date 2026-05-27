# すごい転送 - Android 写真をローカル Wi-Fi で PC に転送

[English](README.md) | [中文](README_zh.md)

すごい転送は ExtraSync の日本語名です。ローカル優先の無料 Android 写真転送アプリで、スマホ内の元写真をローカル Wi-Fi 経由で Windows PC に送信します。ZeroTraceBrowser と組み合わせることで、クラウド、サブスクリプション、USB ケーブルなしで Android 写真を PC にバックアップできます。

スマホ側は先に写真メタデータの manifest を送り、デスクトップ側が要求した元ファイルだけをアップロードします。保存先ルート、インポート状態、ハッシュ、重複判定、最終的な整理は ZeroTraceBrowser が担当します。

## このツールの目的

写真を PC に移したいだけなのに、クラウド契約、ケーブル接続、手作業のコピー確認が必要になることがあります。すごい転送は、その小さいけれど大事な作業を安定して行うための無料ツールです。

基本の流れはシンプルです。

- スマホと PC を同じ Wi-Fi 上でペアリングする
- スマホが写真メタデータの manifest を送る
- PC がアップロード対象を判断する
- スマホが要求された元写真を送る
- 取り込み済み、重複、ローカル削除済みの項目は再送しない

Android 写真を PC に転送したい、スマホ写真を Wi-Fi でバックアップしたい、クラウドなしで写真を移動したい、という場面に向けたツールです。

## 関連プロジェクト

すごい転送は、デスクトップ側の写真整理アプリ ZeroTraceBrowser と組み合わせて使います。保存先、重複判定、インポート履歴、最終整理は ZeroTraceBrowser が担当します。

- プロジェクト: [ZeroTraceBrowser](https://github.com/feilong-pixel/ZeroTraceBrowser)
- Clone: `git clone https://github.com/feilong-pixel/ZeroTraceBrowser.git`

## ダウンロード / インストール

すごい転送は現在 Android APK として配布します。

最新リリース: [ExtraSync v0.1.1](https://github.com/feilong-pixel/ZeroTraceMobile/releases/tag/v0.1.1)

1. リリースページから `ExtraSync-v0.1.1-android.apk` をダウンロードします。
2. Android スマホで APK を開きます。
3. Android が「不明なアプリのインストール」を求めた場合、使用中のファイル管理アプリまたはブラウザに許可します。
4. インストール後、同じローカル Wi-Fi 上の ZeroTraceBrowser とペアリングします。

詳しい手順は [Install ExtraSync On Android](docs/InstallAndroid.md) を参照してください。

検索されやすいキーワード:

- Android 写真 PC 転送
- スマホ 写真 Wi-Fi 転送
- Android 写真 バックアップ PC
- 無料 写真転送アプリ
- クラウドなし 写真転送
- ローカル Wi-Fi ファイル転送
- ZeroTraceBrowser モバイル同期

## 現在の範囲

- ZeroTraceBrowser のデスクトップ QR ペイロードをスキャンまたは貼り付け。
- ペアリング済みデスクトップターゲットを保存。
- Android メディアライブラリから写真 manifest バッチを送信。
- デスクトップ側が要求した元写真をアップロード。
- 自動連続同期と停止に対応。
- 類似写真は将来機能のプレースホルダーとして表示のみ。

現在のスマホアプリでは、端末内の重複スキャン、クリーンアップレビュー、写真削除、写真整理は行いません。

## プロジェクト構成

```text
app/                         Flutter Android アプリ
  lib/
    main.dart                 エントリポイント
    src/
      app/                    アプリ構成、ルーティング、テーマ
      features/
        dashboard/            アップロード中心のホーム画面
        sync/                 ペアリング、manifest、アップロード、自動同期 UI
        settings/             設定と言語切り替え
      shared/                 i18n、設定、ストレージ、プラットフォームアダプタ

core/                        将来のポータブルロジック用
docs/                        製品、アーキテクチャ、安全性メモ
```

## Android 優先

現在の実装対象は Android です。Web、Windows、iOS、古い native プレースホルダーはアクティブなアプリツリーから外しています。

## 安全モデル

- 写真はペアリング済みのローカル PC にのみ送信されます。
- スマホ側で写真を削除したり、並べ替えたりしません。
- 同期はスマホ UI から停止できます。
- デスクトップ側が返した取り込み済み、重複、ローカル削除済みの状態は、次回以降のスキップに使われます。
