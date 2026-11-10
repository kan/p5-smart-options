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
| `CHANGELOG.md` | リリース履歴（Keep a Changelog）。`## [Unreleased]` の下に未リリースの変更を書く |
| `.tagpr` | tagpr の設定 |
| `scripts/tagpr/` | kan/tagpr-scripts を `git subtree` で取り込んだもの。**手で編集しない**（下の「バージョンとリリース」）。配布物には入らない |
| `Dockerfile` / `docker-compose.yml` | 開発用の Perl コンテナ（公式の `perl:5.44` に cpm を足したもの）。配布物には入らない |
| `.github/workflows/` | CI（`test.yml`）、`actions.lock` の検証（`verify-lockfile.yml`）、リリース（`tagpr.yml` / `tagpr-label.yml` / `publish.yml`） |
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
  利用者のコードやテストが頼っている。変えるときは `CHANGELOG.md` に書く
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
| `test.yml` | `master` への push、PR、`workflow_dispatch` | perl 5.44 のテスト（`test`、Docker Hub の `perl:5.44` のコンテナ）、宣言の最低版 5.20 のテスト（`oldest-perl`、actions-setup-perl）、`minil dist` の tarball に `scripts/` が入らないかの確認（`dist`）、`scripts/tagpr/` と呼ぶ SHA の一致の確認（`tagpr-subtree`） |
| `verify-lockfile.yml` | `master` への push、PR | `actions.lock` の検証 |
| `tagpr.yml` / `tagpr-label.yml` / `publish.yml` | リリース | 下の「バージョンとリリース」 |

- action の版は `.github/workflows/actions.lock` で固定している。**`uses:` の行を変えたら、repo の
  ルートで `gh actions-lock` を実行し、書き換わった workflow と lockfile を一緒にコミットする。**
  lockfile を手で編集しない。Dependabot の更新 PR は lockfile も書き換える
- **5.44 のジョブは Docker Hub の `perl:5.44` のコンテナで動かす。** actions-setup-perl は Perl を
  GitHub Releases から認証なしでダウンロードするので、GitHub が匿名のアクセスを絞ると 504 で落ちる。
  `oldest-perl` だけは actions-setup-perl のまま。今の runner で使える `perl` のイメージは 5.26 以降だけのため。
  `publish.yml` が呼ぶ共通の workflow の `publish / Build and check` も actions-setup-perl を使う。
  こちらは tagpr-scripts の中にあり、版はこの repo の `actions.lock` ではなく tagpr-scripts の側で固定される
  （`scripts/tagpr/README.md` の「The CPAN publish workflow」）。
  504 で落ちたら `gh run rerun <run-id> --failed` で再実行する
- Travis CI、CircleCI、Coveralls は廃止済み

## Perl の版を揃える場所

- **開発に使う版（今は 5.44）は、次の 4 か所で揃える。** `Dockerfile` の `FROM`、`test.yml` の
  `perl:<版>` のイメージ（`test` ジョブと `dist` ジョブ）、`publish.yml` の `with:` の `perl-version`
  （共通の workflow へ渡す入力）、`docker-compose.yml` のボリューム名（2 か所）。
  Dependabot（`dependabot.yml` の `docker`）が PR で上げるのは `Dockerfile` だけなので、その PR を
  取り込むときは残りも同じ PR で手で上げる。CI が古い版のまま通っても、新しい版を試したことにはならない。前のボリュームは
  `docker volume rm p5-smart-options_perl-local-<前の版>` で消す
- **最低の版（今は 5.20）は、次の 3 か所で揃える。** `lib/Smart/Options.pm` の `use 5.020`、`cpanfile` の
  `requires 'perl', '5.020000'`、`test.yml` の `oldest-perl` の `perl-version`。変えたら `minil build` で
  `META.json` も作り直す
- Perl の奇数のマイナー版（5.45 など）は開発版。`dependabot.yml` の `ignore` で外している。新しい開発版の
  系列が出たら範囲を足す

## バージョンとリリース

リリースは tagpr で行う。`master` への push ごとに `tagpr.yml` がリリース PR を作り直し、
それをマージするとタグ（`vX.Y.Z`）が打たれ、`publish.yml` が CPAN（PAUSE）へアップロードして
GitHub Release を作る。仕組みと落ちたときの扱いは `scripts/tagpr/README.md` の「The tagpr workflow」。
`publish.yml` は tagpr-scripts の共通の workflow（`publish-cpan.yml`）を呼ぶだけで、ジョブの中身と
落ちたときの再実行の仕方は同じ README の「The CPAN publish workflow」にある。

1. 変更は PR で入れる。**利用者に見える変更の PR は、`CHANGELOG.md` の `## [Unreleased]` の下に
   1 行を足す。** その節がそのままリリースノートになる。外部の貢献者の変更には既存の行にならって
   `(thanks <名前>)` を付ける。リンクは行の中に書く（参照リンクの定義は節の外にあり、
   リリースノートではリンクにならない）。見出しや末尾のリンクの形は `scripts/tagpr/README.md` の
   「What the CHANGELOG has to look like」
2. `master` へマージされるたびに、リリース PR（ブランチ `tagpr-from-v<前の版>`）が作り直される。
   リリース PR は `Options.pm` の `$VERSION` と `META.json` の版を上げ、`## [Unreleased]` を
   その版の節に変える
3. 出したくなったら、リリース PR の中身（版と CHANGELOG の節）を確かめてマージする
   - **tagpr の run が赤いリリース PR はマージしない**（落ちた run がリリース PR を draft にする）
   - 版の上がり方はラベルで決まる。`enhancement` の PR が入っていれば minor、それ以外は patch。
     変えたいときはリリース PR に `tagpr:minor` / `tagpr:major` を付ける。`tagpr-label.yml` が
     リリース PR を draft にして作り直し、ready に戻す。ready に戻るのを待ってからマージする
4. マージすると tagpr がタグを打ち、`publish.yml` が動く。テストして tarball を作り
   （`publish / Build and check`）、PAUSE へアップロードする（`publish / Upload to PAUSE`）。
   その後で GitHub Release を作る（`publish / Create the GitHub release`）
5. PAUSE から届く索引のメールを確かめる

**PAUSE へのアップロードは取り消せない。** 同じファイル名は二度と受け付けられないので、壊れた版を
出したら版を上げて出し直す。

- **版を手で変えない。** 版は `Options.pm` の `our $VERSION` と `META.json` にあり、どちらも
  リリース PR で tagpr が上げる（`.tagpr` の `versionFile`）。`minil release` は使わない
- **版は 3 つ組（`1.0.1`、`1.1.0`）にする。** 0.x の 3 つ組は数値にすると前の版より小さくなりやすい
  （0.7.0 は 0.007000 で 0.061 より小さい）。PAUSE はそういう版を索引に載せない。tagpr での最初の
  リリースを 1.0.0 にし（最初のリリース PR に `tagpr:major`）、以後は 3 つ組のまま上げる
- `Options.pm` と `META.json` の版は、起点のタグ `v0.61.0` に合わせて `0.61.0` にしてある。tagpr は
  前のタグの版の文字列を `versionFile` から探して置き換えるため。0.61.0 は CPAN へは出さない
- `0.061` 以前のタグは Minilla が打った `v` 無しのもの。tagpr は `vX.Y.Z` しか見ないので、0.061 の
  コミットに起点として `v0.61.0` を annotated で打ってある
- **`scripts/tagpr/` を手で編集しない。** 変えるときは kan/tagpr-scripts を直し、
  `git subtree pull -S --prefix=scripts/tagpr https://github.com/kan/tagpr-scripts.git main --squash` で
  取り込む。同じ PR で `tagpr.yml`、`tagpr-label.yml`、`publish.yml` の `uses: kan/tagpr-scripts/...@<SHA>` を、
  squash のコミットの `git-subtree-split` の SHA へ上げる。食い違いは `test.yml` の `tagpr-subtree`
  ジョブが落とす。**この PR はマージコミットでマージする**（squash すると次の subtree pull が壊れる）
- PAUSE の認証情報は GitHub の `cpan` environment の secret（`PAUSE_USER` / `PAUSE_PASSWORD`）にある。
  PAUSE ID は `MIKIHOSHI`。repo のルートに `.pause` があってもコミットしない（`.gitignore` 済み）。
  `cpan` environment でデプロイできる ref はタグ `v*` だけに絞ってある（Settings → Environments →
  `cpan` → Deployment branches and tags）

## 運用

- **`master` へ直接 push しない。** ブランチを切って PR で入れる。tagpr はマージされた PR から
  リリース PR を組み立てるため、直接 push した変更はリリースの流れから漏れる
- tagpr のリリース PR では CI が走らない（`GITHUB_TOKEN` で作られた PR は workflow を起動しない）。
  リリース PR の版と CHANGELOG は、tagpr の run の中で `release-prepare.mjs` が確かめる
