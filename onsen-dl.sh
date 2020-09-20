#!/usr/bin/env bash

outdir=$HOME/Downloads
nkf='nkf --fb-skip -m0 -Z1 -Lu'
ver=1.2.1

usage() {
  echo "onsen-dl.sh($ver): Internet Radio Station<onsen> downloader"
  echo
  echo 'downloads: <name> (-f codec) (--with-jpg|-i) (-o outdir)'
  echo '  <name>         program name'
  echo '  -f codec       mp4|m4a(default) mp3'
  echo '  --with-jpg|-i  download images and information'
  echo "  -o outdir      outdir(omitted:$outdir)"
  echo
  echo 'filenames: -l (num)'
  echo "  -l (num)  number omitted:today(`date +%u`)"
  echo '            1:mon 2:tue 3:wed 4:thu 5:fri 6|7|0:satsun 9:all'
  echo 'updates: -n'
  echo 'newer:   -N'
  echo
  echo 'help: -h'
}

if [[ ! $1 || $1 =~ '-h' ]]; then
  usage
  exit 0
fi

eidx=`curl -s https://www.onsen.ag/web_api/programs | perl -pe 's/({"id":)/\n$1/g; s/,/\n/g; s/\\u002F/\//g' 2>/dev/null`

case $1 in
  # list
  -l|-l?)
  if [ ! $2 ]; then
    [ "${#1}" -gt 2 ] && dateu=${1: -1} || dateu=`date +%u`
  else
    dateu=$2
  fi
  [[ $dateu =~ [07] ]] && dateu=6
  [[ $dateu != [1-6] ]] && dateu=9
  dow=(`echo "$eidx" | sed -n '/delivery_day_of_week/='`)
  m3u8_id=(`echo "$eidx" | sed -n '/playlist/='`)
  case $dateu in
    [1-6])
    for dow_heute in `seq 0 $((${#m3u8_id[@]} - 1))`
    do
      [[ `echo "$eidx" | sed -n ${dow[$dow_heute]}p | grep $dateu` ]] && echo "$eidx" | sed -n ${m3u8_id[$dow_heute]}p | grep -Po '(?<=/[0-9]{6}/).+?(?=\.mp)'
    done | tac
    ;;
    *)
    echo "$eidx" | grep -Po '(?<=/[0-9]{6}/).+?(?=\.mp)' | tac
    ;;
  esac
  ;;
  # updates
  -n|-N)
  [[ `echo $* | grep -e '-N'` ]] && option_N=on
  # source from api(https://www.onsen.ag/web_api/programs)
  eidx_up=`echo "$eidx" | tr -d '"' | tr '[{}\]]' '\n' | grep -E '(title|directory|date)' | grep -v -E '(sponsor|null)' | perl -0pe 's/(updated.+)\n(title.+)\n(directory_name)/$1\n\n$2\n$3/g; s/(delivery_date.+)\n(directory_name)/$1\n\n$2/g; s/(directory_name.+)\n(title.+)\n(directory_name)/$1\n\n$2\n$3/g; s/(directory_name.+)\n(title.+)\n(directory_name)/$1\n\n$2\n$3/g; s/delivery_date/updated/g; s/(link_url.+)\n/$1\n\n/g'`
  proghead=(`echo "$eidx_up" | sed -n '/^$/='`)
  show_updates() {
    echo "$eidx_up" | sed -n "$((${proghead[$ph]} + 1)),${proghead[$(($ph + 1))]}p" | perl -pe 's/(directory_name|title|link_url)://g' | $nkf
  }
  if [ ! $option_N ]; then
    # update -n
    echo "$eidx_up" | sed -n "${proghead[$((${#proghead[@]} - 1))]},$ p" | perl -pe 's/(directory_name|title|link_url)://g' | $nkf
    echo
    for ph in `seq $((${#proghead[@]} - 2)) -1 0`
    do
      show_updates
    done 2>/dev/null
  # newer -N
  else
    [[ `date +%-H` -ge 13 ]] && date=`date +%-m/%-d` || date=`date -d -1day +%-m/%-d`
    for ph in `seq $((${#proghead[@]} - 2)) -1 0`
    do
      [[ `show_updates | grep $date` ]] && show_updates
    done 2>/dev/null
  fi
  echo "$eidx_up" | sed -n '1,/^$/p' | perl -pe 's/(directory_name|title|link_url)://g' | $nkf
  ;;
  # download
  *)
  m3u8=`echo "$eidx" | grep -o http.*m3u8 | grep /$1`
  # not found
  if [ ! "$m3u8" ]; then
    echo "missing $1"
  fi
  # download program
  if [ $m3u8 ]; then
    # -f option
    [[ `echo $* | grep -e '-f'` ]] && optarg_f=`echo $* | grep -Po '(?<= -f).+?(?=( -|$))' | tr -d ' '`
    [[ `ffmpeg -i $m3u8 2>&1 | grep 'Video'` ]] && optarg_f=mp4
    fn=`echo $m3u8 | grep -Po '(?<=[0-9]{6}/).+?(?=\.mp)'`
    # -o option
    if [[ `echo $* | grep -e '-o'` ]]; then
      outdir=`echo $* | grep -Po '(?<= -o).+?(?=( -|$))'`
      [ ! -e $outdir ] && mkdir -p $outdir
    fi
    echo "$$ [download] `date +'%m-%d %H:%M:%S'` start"
    case $optarg_f in
      mp3)
      mp3=https://onsen-dl.sslcs.cdngc.net/radio
      mp3_fn=${fn%-*}
      mp3_pre=${mp3_fn:0:-4}
      mp3_id=${mp3_fn: -4}; mp3_id=${mp3_id^^}
      lower=(`echo $mp3_id | grep -o [A-Z]`)
      for low in {0..3}
      do
        if [[ `curl -LI $mp3/$mp3_pre${mp3_id,,[${lower[$low]}]}.mp3 2>&1 | grep OK` ]]; then
          mp3=$mp3/$mp3_pre${mp3_id,,[${lower[$low]}]}.mp3
          break
        fi
      done
      echo -n "$$ "; wget -nv $mp3 -O $outdir/${mp3##*/} 2>&1
      ;;
      *)
      if [ "$optarg_f" = 'mp4' ]; then
        vc='-vcodec copy'
      else
        optarg_f=m4a
        vc=-vn
      fi
      echo "$$ $m3u8 -> $outdir/${fn}.$optarg_f"
      ffmpeg -i $m3u8 -loglevel error -bsf:a aac_adtstoasc -acodec copy $vc $outdir/$fn".$optarg_f"
      ;;
    esac
  fi
  # downloads jpg
  if [ "`echo $* | grep -E '(--with-jpg|-i)'`" ]; then
    imgfn=$fn
    progname=`echo "$eidx" | grep $1 | grep -Po '(?<=directory_name":").+?(?=")'`
    pagesource=`curl -s https://www.onsen.ag/program/$progname | perl -pe 's/(,|\\\n)/\n/g; s/\\\u002F/\//g'`
    # jpg
    jpg=(`echo "$pagesource" | sed -n -E '/role_of_performer/s/(^.+url:"|"}$)//gp'`)
    jpg=(${jpg[@]} `echo "$pagesource" | sed -n -E '/\/(program_info|selling_item_image)/s/(^.*url:"|".*$)//gp'`)
    for infoitem in `seq 0 $((${#jpg[@]} - 1))`
    do
      if [ ! -f $outdir/${imgfn}_${jpg[$infoitem]#*=}.jpg ]; then
        echo -n "$$ "; wget -nv ${jpg[$infoitem]} -O $outdir/${imgfn}_${jpg[$infoitem]#*=}.jpg
      else
        jpgfn=`echo ${jpg[$infoitem]} | grep -Po '(?<=production/).+?(?=/)'`
        echo -n "$$ "; wget -nv ${jpg[$infoitem]} -O $outdir/${imgfn}_${jpg[$infoitem]#*=}_${jpgfn}.jpg
      fi
    done 2>&1
    # png withoutbanner
    png=(`echo "$pagesource" | sed -n -E '/banner/d; /\/((update|topics|corner)_image|gallery)/s/(^.*src="|" (alt|height).*)//gp'`)
    for wobanner in `seq 0 $((${#png[@]} - 1))`
    do
      if [ ! -f $outdir/${imgfn}_${png[$wobanner]#*=}.png ]; then
        echo -n "$$ "; wget -nv ${png[$wobanner]} -O $outdir/${imgfn}_${png[$wobanner]#*=}.png
      else
        pngfn=`echo ${png[$wobanner]} | grep -Po '(?<=production/).+?(?=/)'`
        echo -n "$$ "; wget -nv ${png[$wobanner]} -O $outdir/${imgfn}_${png[$wobanner]#*=}_${pngfn}.png
      fi
    done 2>&1
    # html to text
    echo "$pagesource" | perl -pe 's/\\n/\n/g' | sed -n '/program_info/,$p' | sed -E '/(email|twitter_id):/s/"//g; s/^[^"]*"//; s/(\[|\]|"|\)\).*)//g; s/([/<][^>]*>|^[ ]*)//g' | perl -pe 's/[{}]/\n/g' | grep -v -E '(^[0-9]$|:[a-z]?$|null|true|false)' | perl -00pe '' >$outdir/${fn}.txt
  fi
  echo "$$ [download] `date +'%m-%d %H:%M:%S'` successful"
  ;;
esac

