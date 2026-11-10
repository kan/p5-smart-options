# AGENTS.md

このリポジトリは CPAN モジュール `Smart::Options` の開発用。コマンドラインの引数を、人が直感で
読むとおりに解釈してハッシュリファレンスにする（node の optimist / minimist にならったもの）。
`Smart::Options::Declare` は、`opts my $var => 'Int'` の形で変数へ直接受け取る DSL。

## ファイル構成

| パス | 内容 |
|---|---|
| `lib/Smart/Options.pm` | 本体。パーサ（`parse`）、設定のメソッド、help の整形。POD（利用者向けドキュメント）も同じファイルにある |
| `lib/Smart/Options/Declare.pm` | DSL。`PadWalker` で `opts` に渡された変数の名前を取り、オプション名にする |
| `t/*.t` | `Smart::Options` のテスト |
| `t/declare/*.t` | `Smart::Options::Declare` のテスト |
| `cpanfile` | 依存モジュールの宣言（runtime / test / develop） |
| `minil.toml` | Minilla の設定 |
| `Changes` | リリース履歴（#9 で `CHANGELOG.md` に移す） |
| `Dockerfile` / `docker-compose.yml` | 開発用の Perl コンテナ（公式の `perl:5.44` に cpm を足したもの）。配布物には入らない |
| `.github/workflows/` | CI（`test.yml`）と `actions.lock` の検証（`verify-lockfile.yml`） |
| `.mailmap` | 配布物の `x_contributors` に出す名前とアドレス（下の「生成物は直接編集しない」） |

## 開発コマンド

ホストの Perl には依存モジュールが入っていないことが多い。`docker-compose.yml` のコンテナを使う。

```sh
docker compose run --rm perl cpm install --with-develop   # cpanfile から依存を local/ に導入
docker compose run --rm perl prove -lr t                  # 全テスト
docker compose run --rm perl prove -lv t/08_config.t      # 単体テスト（verbose）
docker compose run --rm perl minil build                  # 生成物の作り直し（下）
```

- コンテナはホストのユーザー（既定は uid / gid 1000）で動くので、書き出したファイルは root 所有に
  ならない。ホストの uid が 1000 でなければ、repo 直下の `.env`（`.gitignore` 済み、compose が自動で
  読む）に `HOST_UID=<uid>` と `HOST_GID=<gid>` を書き、`docker compose build` からやり直す。
  ボリュームの所有者は作ったときの uid のまま変わらないので、作った後なら `docker compose down -v` で
  消してから入れ直す
- 依存は名前付きボリューム `perl-local-5.44` に入る（別の版でビルドした XS モジュールは読み込めない
  ため、版を名前に含める）。repo 直下の `local/` はコンテナの中ではこのボリュームで隠れる
- 依存の版は固定しない（`cpanfile.snapshot` を置かない）。CI も CPAN の利用者も、その時点の最新を入れる
- コンテナの中の `minil build` は `fatal: Could not read from remote repository.` を出す（コンテナから
  GitHub へ ssh で繋がらないため）。終了コードは 0 で、`README.md` と `META.json` は書き出される

## 生成物は直接編集しない

次のファイルは Minilla（`minil build`）で生成される。

- **`Build.PL` と `META.json` は手で編集しない。** 依存の変更は `cpanfile` に、メタ情報の変更は
  `minil.toml` に書く
- **`README.md` は手で編集しない。** `lib/Smart/Options.pm` の POD から `Pod::Markdown::Github` で
  生成される。利用方法の説明を直すときは POD を直す
- **POD、`cpanfile`、`minil.toml`、`.mailmap` を変えたら、同じ変更で `minil build` を実行し、作り直された
  `README.md` / `META.json` も一緒にコミットする。** ここで作り直さないと、repo の `README.md` と
  `META.json` が古いまま残る
- `META.json` の `x_contributors` は `git log` の作者から作られ、`.mailmap` が名前とアドレスを置き換える。
  **貢献者のアドレスは GitHub の noreply（`<ID>+<login>@users.noreply.github.com`）で載せる。** 新しい
  貢献者のコミットを取り込んだら `.mailmap` に足す。ボット（`github-actions[bot]`、`dependabot[bot]`）は
  作者へ寄せて `x_contributors` から外している
- `Smart-Options-*/`、`.build/`、`local/`、`blib/` はビルドや依存インストールの産物で、`.gitignore` 済み。
  読んだり編集したりしない

## 書き方の制約

- **最低対応バージョンは Perl 5.20**（`use 5.020`）。kan/coveralls-perl、kan/p5-web-service-mailgun と
  同じにしている。5.22 以降の構文や機能は使わない。`<<>>`、`<<~` のヒアドキュメント、`isa` 演算子などが該当する。
  5.20 で experimental の postfix deref（`$ref->@*`）とサブルーチンのシグネチャも使わない。
  `//`、`say`、`state`、`s///r` は使ってよい。`given/when`（smartmatch）は experimental で廃止が
  決まっているので使わない
- 依存はコアモジュールか `cpanfile` に宣言済みのものに限る。増やすときは `cpanfile` に足す。
  **コアのモジュールでも、5.20 のコアに入っている版より新しい機能を使うなら、`cpanfile` に下限の版を
  書く**（例: `List::Util` の `uniq` は 1.45 からで、その版がコアに入ったのは 5.26。`cpanfile` に
  `requires 'List::Util', '1.45';` と書き、`use List::Util 1.45 qw(uniq);` で読む）
- **公開している振る舞いを変えない。** `parse` が返すハッシュの形、help の文字列、`die` するかどうかは
  利用者のコードやテストが頼っている。変えるときは `Changes` に書く
- インデントは 4 スペース。ファイルを開くときはレキシカルなファイルハンドルと 3 引数の `open` を使う

## テスト

- help の文字列を比べるテスト（`t/02_option.t`、`t/05_subcmd.t`、`t/declare/10_help.t`）は、
  `Text::Table` が作る行末の空白まで期待値に含む。help の整形を変えたら期待値も直す
- `t/05_subcmd.t` と `t/declare/10_help.t` は、help の `Usage:` の行（`$0`）を repo のルートからの
  相対パスとして期待値に書いている。`prove` は repo のルートから実行する
- `t/09_env.t` は `%ENV` を書き換える。環境変数を読むテストを足すときは、ほかのテストの値と
  名前がぶつからないようにする

## CI（GitHub Actions）

| workflow | 起動 | 内容 |
| --- | --- | --- |
| `test.yml` | `master` への push、PR、`workflow_dispatch` | perl 5.44 のテスト（`test`、Docker Hub の `perl:5.44` のコンテナ）、宣言の最低版 5.20 のテスト（`oldest-perl`、actions-setup-perl）、`minil dist` の tarball の確認（`dist`） |
| `verify-lockfile.yml` | `master` への push、PR | `actions.lock` の検証 |

- action の版は `.github/workflows/actions.lock` で固定している。**`uses:` の行を変えたら、repo の
  ルートで `gh actions-lock` を実行し、書き換わった workflow と lockfile を一緒にコミットする。**
  lockfile を手で編集しない。Dependabot の更新 PR は lockfile も書き換える
- **5.44 のジョブは Docker Hub の `perl:5.44` のコンテナで動かす。** actions-setup-perl は Perl を
  GitHub Releases から認証なしでダウンロードするので、GitHub が匿名のアクセスを絞ると 504 で落ちる。
  `oldest-perl` だけは actions-setup-perl のまま（今の runner で使える `perl` のイメージは 5.26 以降だけ）。
  504 で落ちたら `gh run rerun <run-id> --failed` で再実行する
- Travis CI、CircleCI、Coveralls は廃止済み

## Perl の版を揃える場所

- **開発に使う版（今は 5.44）は、次の 3 か所で揃える。** `Dockerfile` の `FROM`、`test.yml` の
  `perl:<版>` のイメージ（`test` ジョブと `dist` ジョブ）、`docker-compose.yml` のボリューム名（2 か所）。
  Dependabot（`dependabot.yml` の
  `docker`）が PR で上げるのは `Dockerfile` だけなので、その PR を取り込むときは残りも同じ PR で手で
  上げる。CI が古い版のまま通っても、新しい版を試したことにはならない。前のボリュームは
  `docker volume rm p5-smart-options_perl-local-<前の版>` で消す
- **最低の版（今は 5.20）は、次の 3 か所で揃える。** `lib/Smart/Options.pm` の `use 5.020`、`cpanfile` の
  `requires 'perl', '5.020000'`、`test.yml` の `oldest-perl` の `perl-version`。変えたら `minil build` で
  `META.json` も作り直す
- Perl の奇数のマイナー版（5.45 など）は開発版。`dependabot.yml` の `ignore` で外している。新しい開発版の
  系列が出たら範囲を足す

## バージョンとリリース

#9 で tagpr へ移す。それまでは版を手で変えない（リリースの作業はメンテナが行う）。

- develop の依存から `Version::Next` と `CPAN::Uploader` を外してあるので、#9 より前に `minil release` を
  使うなら、その 2 つを別に入れる
