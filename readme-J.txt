名前: onsen-dl.sh


概要: インターネットラジオステーション音泉の番組をダウンロードするシェルスクリプト


必要コマンド:
onsen-dl.shの動作には、以下のコマンドが必要です
! 基本コマンドの他、nkfやperl5等、最初からインストールされている可能性が高いものも省略
作者が使用しているヴァージョンを併記します

 bash4
GNU bash 4.3.30(1)
! ver.4.3以前や、ver.5、zshでの動作は未検証

 wget、httpsが有効になっているもの
1.20
+digest +https +ipv6 +large-file +ntlm +opie +ssl/openssl 

 curl、httpsが有効になっているもの
7.38.0
libcurl/7.38.0 OpenSSL/1.0.1t zlib/1.2.8 libidn/1.29 libssh2/1.4.3 librtmp/2.3
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp scp sftp smtp smtps telnet tftp 
Features: AsynchDNS IDN IPv6 Largefile GSS-API SPNEGO NTLM NTLM_WB SSL libz TLS-SRP 

 grep、Pオプション(PERL正規表現)が有効になっているもの、又はpcregrep
GNU grep 2.20、pcregrep 8.44
! pcregrepを使用する場合は、スクリプト内の`grep -Po'を`pcregrep -o'に置換
以下のコマンドでエラーが出なければ、Pオプションは有効になっています
grep --help | grep -Po '(?<=(he.|ay |r N)).+?(?=(ON| wo|rsi|sage))'

 ffmpeg、opensslが有効になっているもの
3.4.6
configuration: --enable-openssl --enable-libxml2 --enable-libmp3lame
* onsen-dl.shの動作にlibmp3lameは必要ありません

足りないコマンドは、aptやbrew又はビルドして、インストールしてください


onsen-dl.sh内の設定:
以下の部分を環境に合わせて設定してください

 outdir=
番組のデフォルト保存先
`$HOME/Downloads'等
oオプションで都度変更可能

 nkf='nkf -Z1 ..'
nkfの設定
`nkf -Z1(2バイトの英数とスペースを1バイトへ変換)'以外は任意


インストール:
onsen-dl.shに実行権を与えて(chmod 755 onsen-dl.sh)、`/usr/local/bin'、`$HOME/bin'等、パスが通っているディレクトリへコピー(cp onsen-dl.sh /パスが/通っている/ディレクトリ/)


使用方法:

 ダウンロード:  onsen-dl.sh 番組名 -f m4a|mp3 --with-jpg|-i -o 保存先
必須:
 番組名
下で説明する lオプションで表示される番組名を指定
番組名の一部で指定可能ですが、複数の番組がヒットする省略はエラーになります
任意:
 -f m4a|-f mp3
保存する音声タイプをm4a又はmp3で指定
m4aを保存する場合、このオプションは省略可能です
動画はm4a又はmp3を指定してもmp4で保存されます
 --with-jpg|-i
番組音声と一緒に、番組ページ内にある画像と説明文もダウンロード
 -o 保存先
保存先の指定

 番組名を表示:  onsen-dl.sh -l 曜日
 -l 曜日
表示する曜日を1(月曜)〜6(土日曜)、9(全曜日)で指定
曜日を省略した場合、今日の番組名を表示します

 更新日時を表示:  onsen-dl.sh -n|-N
 -n
全番組を表示
 -N
午後1時を基準に、今日又は前日に更新された番組のみ表示
月曜の午後1時以前には金曜〜日曜に更新された番組を表示します

 ヘルプ:  onsen-dl.sh -h
