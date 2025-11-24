# alt-z

[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](LICENSE)

[rupa/z](https://github.com/rupa/z) のRust再実装版 - **Frecency**（頻度 + 最近性）に基づいてよく使うディレクトリを追跡し、高速なナビゲーションを実現するスマートな `cd` コマンドです。

このプロジェクトは、rupaによるオリジナルの [z](https://github.com/rupa/z) をベースに、パフォーマンス向上と機能拡張のためRustで再実装したものです。

[English README](README.md)

## 特徴

- 🎯 **Frecencyベースのナビゲーション** - 訪問頻度と最近性に基づいてディレクトリにジャンプ
- ⚡ **高速なRust実装** - 超高速なディレクトリ検索
- 🐚 **マルチシェル対応** - Bash、Zsh、Fishで動作
- 🔍 **正規表現パターンマッチング** - 柔軟なパターンでディレクトリを検索
- 🐟 **Fish限定機能** - コマンド未検出時の自動フォールバック（ディレクトリ名をコマンドのように入力！）
- 📊 **スマートランキング** - 自動的にワークフローを学習して優先順位付け

## クイックスタート

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/ymmtmdk/alt-z.git
cd alt-z

# ビルドしてインストール（デフォルトで ~/.local にインストール）
make install

# カスタムディレクトリにインストール
make install PREFIX=/usr/local
```

### シェル統合

シェルの設定ファイルに以下を追加してください：

**Bash** (`~/.bashrc`):
```bash
source ~/.local/share/alt-z/az.sh
```

**Zsh** (`~/.zshrc`):
```bash
source ~/.local/share/alt-z/az.sh
```

**Fish** (`~/.config/fish/config.fish`):
```fish
source ~/.local/share/alt-z/az.fish
```

シェルを再起動するか、設定ファイルを再読み込みしてください。

## 使い方

### 基本的なナビゲーション

```bash
# "project" を含むディレクトリにジャンプ
az project

# "work" と "docs" の両方を含むディレクトリにジャンプ
az work docs

# マッチするすべてのディレクトリをスコア付きでリスト表示
az -l project

# ディレクトリを変更せずに最適なマッチを表示
az -e project
```

### 高度なオプション

```bash
# ランク（頻度）のみでソート
az -r project

# 時間（最近性）のみでソート
az -t project

# 手動でディレクトリを追加
az add /path/to/directory

# 存在しないディレクトリをクリーンアップ
az clean
```

### Fish限定機能

Fishシェルユーザーは、コマンド未検出時の自動フォールバックが利用できます：

```fish
$ myproject  # 'myproject' コマンドが存在しない場合、azが自動的にジャンプを試みます
az: jumping to /home/user/projects/myproject
```

## 仕組み

1. **自動追跡**: `cd` でディレクトリに移動するたびに自動的に記録されます
2. **Frecencyスコアリング**: ディレクトリは以下に基づいてランク付けされます：
   - **頻度**: どれだけ頻繁に訪問するか
   - **最近性**: どれだけ最近訪問したか
3. **スマートマッチング**: 正規表現パターンを使用してディレクトリを検索
4. **クイックジャンプ**: 数文字入力するだけで最適なマッチにジャンプ

## 使用例

```bash
# これらのディレクトリを頻繁に使用した後：
cd ~/projects/work/important-project
cd ~/documents/work/reports
cd ~/downloads

# 素早くジャンプできるようになります：
az imp        # → ~/projects/work/important-project
az rep        # → ~/documents/work/reports
az down       # → ~/downloads
```

## 必要要件

- Rustツールチェーン（ビルド用）
- Bash、Zsh、またはFishシェル

## ソースからビルド

```bash
# リリースバイナリをビルド
make

# テストを実行
make test

# ビルド成果物をクリーンアップ
make clean
```

## アンインストール

```bash
make uninstall
```

シェル設定ファイルから `source` 行を削除することを忘れないでください。

## データ保存

ディレクトリデータはデフォルトで `~/.z` に保存されます。`_Z_DATA` 環境変数を設定することで変更できます：

```bash
export _Z_DATA=~/.config/alt-z/data
```

## コントリビューション

コントリビューションを歓迎します！お気軽にPull Requestを送ってください。

## ライセンス

WTFPL (Do What The Fuck You Want To Public License) - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 謝辞

このプロジェクトは、[rupa](https://github.com/rupa)によるオリジナルの [z](https://github.com/rupa/z) をベースにしたRust再実装版です。

コアアルゴリズムとコンセプトはrupa/zから派生しており、以下の拡張を加えています：
- パフォーマンス向上のためRustで書き直し
- シェルサポートの拡張（Bash、Zsh、Fish）
- Fishシェルのコマンド未検出フォールバック機能
- Makefileによるモダンなビルドシステム

また、[ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) からもインスパイアされています。

## 作者

ymmtmdk
