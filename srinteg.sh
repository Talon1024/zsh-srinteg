#!/usr/bin/zsh
# Script to generate subresource integrity HTML attributes

use_credentials=0
urls=()
algos=()

for ((curargi=1;curargi<=$#;++curargi)); do
  curarg=${@[curargi]}
  if [[ "$curarg" == '--algo' ]]; then
    curargi=$(( $curargi + 1 ))
    curarg="${@[$curargi]}"
    algos[(ie)$curarg]=$curarg
  elif [[ "$curarg" == '--use-credentials' ]]; then
    use_credentials=1
  else
    urls+="$curarg"
  fi
done

# Use sha384 by default
algos=(${algos:-sha384})

xostr="crossorigin=\""
if [[ $use_credentials -eq 0 ]] {
  xostr="${xostr}anonymous\""
} else {
  xostr="${xostr}use-credentials\""
}

if [[ "${#urls}" -gt 0 ]]; then
  for fileurl in $urls; do
    integstr="integrity=\""
    get=cat
    if [[ "${(L)fileurl:0:7}" == "http://" ]]; then
      get=curl
    elif [[ "${(L)fileurl:0:8}" == "https://" ]]; then
      get=curl
    elif [[ "${(L)fileurl:0:7}" == "file://" ]]; then
      fileurl="${fileurl[7,-1]}"
    fi
    for algo in $algos; do
      integstr="${integstr}${algo}-$($get $fileurl | openssl dgst -$algo -binary | base64 -w 0) "
    done
    integstr="${integstr%% }\""
    print $integstr $xostr
  done
else
  print "Nothing to generate subresource integrity for."
fi
