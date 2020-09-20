名前: onsen-dl.sh


概要: インターネットラジオステーション音泉の番組を保存するシェルスクリプト


必要コマンド:

onsen-dl.shの動作には、以下のコマンドが必要です
! 基本コマンドの他、nkfやperl5等、
　最初からインストールされている可能性が高いものは省略

作者が使用しているヴァージョンを併記します

bash4
  GNU bash 4.3.30(1)
  ! ver.4.3以前や、ver.5、zshでの動作は未検証

wget、httpsが有効になっているもの
  1.20
  -cares +digest -gpgme +https +ipv6 -iri +large-file -metalink -nls 
  +ntlm +opie -psl +ssl/openssl 

curl、httpsが有効になっているもの
  7.38.0
  libcurl/7.38.0 OpenSSL/1.0.1t zlib/1.2.8 libidn/1.29 libssh2/1.4.3 librtmp/2.3
  Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s
             rtmp rtsp scp sftp smtp smtps telnet tftp 
  Features: AsynchDNS IDN IPv6 Largefile GSS-API SPNEGO NTLM NTLM_WB SSL libz TLS-SRP 

grep、`-P'オプション(perl正規表現)が有効になっているもの、又はpcregrep
  GNU grep 2.20、pcregrep 8.44
  ! pcregrepを使用する場合は、スクリプト内の`grep -Po'を`pcregrep -o'に置換してください
  * 以下のコマンドでエラーが出なければ`-P'オプションは有効になっています
    grep --help | grep -Po '(?<=(he.|ay |r N)).+?(?=(ON| wo|rsi|sage))'

ffmpeg、opensslが有効になっているもの
  3.4.6
  configuration: --enable-openssl --enable-libxml2 --enable-libmp3lame
  * libmp3lameが無効でもonsen-dl.shは動作します

足りないコマンドは、aptやbrew、又はビルドして、インストールしてください


onsen-dl.sh内の設定:

onsen-dl.shの以下の部分を環境に合わせて設定してください

outdir=       番組のデフォルト保存先
              `$HOME/Downloads'等
              `-o'オプションで都度変更可能

nkf='nkf ..'  nkfのオプション設定
              `nkf -Z1'(2バイトの英数とスペースを1バイトへ変換)以外は任意


インストール:

onsen-dl.shに実行権を与えて
  chmod 755 onsen-dl.sh

`/usr/local/bin'、`$HOME/bin'等、パスが通っているディレクトリへコピー
  cp onsen-dl.sh /パスが/通っている/ディレクトリ/


使用方法:

  ダウンロード:  onsen-dl.sh 番組名 -f m4a|mp3 --with-jpeg|-i -o 保存先

    番組名  下で説明する`-l'オプションで表示される番組名を指定
            日付を省略する等、番組名の一部のみで指定可能ですが
            複数の番組名がヒットするような省略はエラーになります

    -f mp3、又は、-f m4a(省略可能)
            保存する音声タイプを`mp3'又は`m4a'で指定
            このオプションを省略した場合、m4aで保存します
            動画はmp4固定です

    --with-jpg、又は、-i
            番組音声と一緒に、番組ページ内にある画像と説明文も保存

    -o 保存先(省略可能)
            保存先の指定


  番組名を表示:  onsen-dl.sh -l 曜日

    曜日  表示する曜日を`1'(月曜)〜`6'(土日曜)で指定
          `9'ですべての曜日を表示
          曜日を省略した場合、今日の番組名を表示します


  全番組の更新日時を表示:  onsen-dl.sh -n


  今日更新された番組を表示:  onsen-dl.sh -N

    午後1時を基準に、今日又は前日に更新された番組の情報のみ表示
    月曜の午後1時前には金曜〜日曜に更新された番組を表示します


  ヘルプ:  -h
