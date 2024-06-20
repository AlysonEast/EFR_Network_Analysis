#!/bin/bash

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (aly3213): " username
    username=${username:-aly3213}
    read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login $username password $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v06.061.2024007005005/MYD17A2H.A2023361.h10v06.061.2024007005005.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v06.061.2024007005005/MYD17A2H.A2023361.h10v06.061.2024007005005.hdf -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v06.061.2024007005005/MYD17A2H.A2023361.h10v06.061.2024007005005.hdf | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

fetch_urls() {
  if command -v curl >/dev/null 2>&1; then
      setup_auth_curl
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  elif command -v wget >/dev/null 2>&1; then
      # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
      echo
      echo "WARNING: Can't find curl, use wget instead."
      echo "WARNING: Script may not correctly identify Earthdata Login integrations."
      echo
      setup_auth_wget
      while read -r line; do
        # Get everything after the last '/'
        filename="${line##*/}"

        # Strip everything after '?'
        stripped_query_params="${filename%%\?*}"

        wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --output-document $stripped_query_params --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
      done;
  else
      exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
  fi
}

fetch_urls <<'EDSCEOF'
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v06.061.2024007005005/MYD17A2H.A2023361.h10v06.061.2024007005005.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v05.061.2024007005934/MYD17A2H.A2023361.h10v05.061.2024007005934.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h11v06.061.2024007010114/MYD17A2H.A2023361.h11v06.061.2024007010114.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h12v04.061.2024007005650/MYD17A2H.A2023361.h12v04.061.2024007005650.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h12v03.061.2024007010058/MYD17A2H.A2023361.h12v03.061.2024007010058.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h08v06.061.2024007005911/MYD17A2H.A2023361.h08v06.061.2024007005911.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h07v06.061.2024007010828/MYD17A2H.A2023361.h07v06.061.2024007010828.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h08v04.061.2024007010954/MYD17A2H.A2023361.h08v04.061.2024007010954.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v04.061.2024007011133/MYD17A2H.A2023361.h10v04.061.2024007011133.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h11v04.061.2024007011735/MYD17A2H.A2023361.h11v04.061.2024007011735.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h12v05.061.2024007011439/MYD17A2H.A2023361.h12v05.061.2024007011439.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h11v05.061.2024007012752/MYD17A2H.A2023361.h11v05.061.2024007012752.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h10v03.061.2024007012642/MYD17A2H.A2023361.h10v03.061.2024007012642.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h09v03.061.2024007013149/MYD17A2H.A2023361.h09v03.061.2024007013149.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h11v03.061.2024007013146/MYD17A2H.A2023361.h11v03.061.2024007013146.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h09v05.061.2024007013428/MYD17A2H.A2023361.h09v05.061.2024007013428.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h09v04.061.2024007014011/MYD17A2H.A2023361.h09v04.061.2024007014011.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h13v03.061.2024007013929/MYD17A2H.A2023361.h13v03.061.2024007013929.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h08v05.061.2024007014709/MYD17A2H.A2023361.h08v05.061.2024007014709.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h13v04.061.2024007020000/MYD17A2H.A2023361.h13v04.061.2024007020000.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h09v06.061.2024007015731/MYD17A2H.A2023361.h09v06.061.2024007015731.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023361.h07v05.061.2024007021346/MYD17A2H.A2023361.h07v05.061.2024007021346.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h07v06.061.2024006033742/MYD17A2H.A2023353.h07v06.061.2024006033742.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h10v06.061.2024006033659/MYD17A2H.A2023353.h10v06.061.2024006033659.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h09v06.061.2024006034000/MYD17A2H.A2023353.h09v06.061.2024006034000.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h09v03.061.2024006033801/MYD17A2H.A2023353.h09v03.061.2024006033801.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h12v05.061.2024006034313/MYD17A2H.A2023353.h12v05.061.2024006034313.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h10v05.061.2024006034752/MYD17A2H.A2023353.h10v05.061.2024006034752.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h08v06.061.2024006034544/MYD17A2H.A2023353.h08v06.061.2024006034544.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h10v03.061.2024006035101/MYD17A2H.A2023353.h10v03.061.2024006035101.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h12v03.061.2024006035103/MYD17A2H.A2023353.h12v03.061.2024006035103.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h13v03.061.2024006035936/MYD17A2H.A2023353.h13v03.061.2024006035936.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h09v05.061.2024006035801/MYD17A2H.A2023353.h09v05.061.2024006035801.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h11v04.061.2024006040504/MYD17A2H.A2023353.h11v04.061.2024006040504.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h11v03.061.2024006040701/MYD17A2H.A2023353.h11v03.061.2024006040701.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h13v04.061.2024006040844/MYD17A2H.A2023353.h13v04.061.2024006040844.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h09v04.061.2024006041018/MYD17A2H.A2023353.h09v04.061.2024006041018.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h07v05.061.2024006042102/MYD17A2H.A2023353.h07v05.061.2024006042102.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h10v04.061.2024006043222/MYD17A2H.A2023353.h10v04.061.2024006043222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h11v06.061.2024006044352/MYD17A2H.A2023353.h11v06.061.2024006044352.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h11v05.061.2024006050710/MYD17A2H.A2023353.h11v05.061.2024006050710.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h08v05.061.2024006051715/MYD17A2H.A2023353.h08v05.061.2024006051715.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h12v04.061.2024006054508/MYD17A2H.A2023353.h12v04.061.2024006054508.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023353.h08v04.061.2024006054907/MYD17A2H.A2023353.h08v04.061.2024006054907.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h07v06.061.2024005163205/MYD17A2H.A2023345.h07v06.061.2024005163205.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h09v03.061.2024005170516/MYD17A2H.A2023345.h09v03.061.2024005170516.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h10v06.061.2024005170100/MYD17A2H.A2023345.h10v06.061.2024005170100.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h10v03.061.2024005170305/MYD17A2H.A2023345.h10v03.061.2024005170305.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h11v04.061.2024005172049/MYD17A2H.A2023345.h11v04.061.2024005172049.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h12v05.061.2024005174218/MYD17A2H.A2023345.h12v05.061.2024005174218.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h13v04.061.2024005175646/MYD17A2H.A2023345.h13v04.061.2024005175646.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h08v06.061.2024005180110/MYD17A2H.A2023345.h08v06.061.2024005180110.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h11v06.061.2024005180737/MYD17A2H.A2023345.h11v06.061.2024005180737.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h09v05.061.2024005180914/MYD17A2H.A2023345.h09v05.061.2024005180914.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h11v03.061.2024005181041/MYD17A2H.A2023345.h11v03.061.2024005181041.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h09v06.061.2024005181335/MYD17A2H.A2023345.h09v06.061.2024005181335.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h13v03.061.2024005182829/MYD17A2H.A2023345.h13v03.061.2024005182829.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h10v05.061.2024005182854/MYD17A2H.A2023345.h10v05.061.2024005182854.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h12v04.061.2024005182827/MYD17A2H.A2023345.h12v04.061.2024005182827.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h12v03.061.2024005182926/MYD17A2H.A2023345.h12v03.061.2024005182926.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h07v05.061.2024005183101/MYD17A2H.A2023345.h07v05.061.2024005183101.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h08v05.061.2024005185558/MYD17A2H.A2023345.h08v05.061.2024005185558.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h10v04.061.2024005185717/MYD17A2H.A2023345.h10v04.061.2024005185717.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h08v04.061.2024005191012/MYD17A2H.A2023345.h08v04.061.2024005191012.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h09v04.061.2024005193815/MYD17A2H.A2023345.h09v04.061.2024005193815.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023345.h11v05.061.2024005195855/MYD17A2H.A2023345.h11v05.061.2024005195855.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h12v03.061.2024003132153/MYD17A2H.A2023337.h12v03.061.2024003132153.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h12v04.061.2024003133049/MYD17A2H.A2023337.h12v04.061.2024003133049.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h07v06.061.2024003134022/MYD17A2H.A2023337.h07v06.061.2024003134022.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h09v05.061.2024003134659/MYD17A2H.A2023337.h09v05.061.2024003134659.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h10v06.061.2024003135012/MYD17A2H.A2023337.h10v06.061.2024003135012.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h11v04.061.2024003135305/MYD17A2H.A2023337.h11v04.061.2024003135305.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h08v04.061.2024003135941/MYD17A2H.A2023337.h08v04.061.2024003135941.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h09v03.061.2024003140644/MYD17A2H.A2023337.h09v03.061.2024003140644.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h10v05.061.2024003140428/MYD17A2H.A2023337.h10v05.061.2024003140428.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h13v04.061.2024003140758/MYD17A2H.A2023337.h13v04.061.2024003140758.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h12v05.061.2024003141806/MYD17A2H.A2023337.h12v05.061.2024003141806.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h10v03.061.2024003142637/MYD17A2H.A2023337.h10v03.061.2024003142637.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h11v03.061.2024003143614/MYD17A2H.A2023337.h11v03.061.2024003143614.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h10v04.061.2024003143537/MYD17A2H.A2023337.h10v04.061.2024003143537.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h13v03.061.2024003143952/MYD17A2H.A2023337.h13v03.061.2024003143952.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h08v06.061.2024003145039/MYD17A2H.A2023337.h08v06.061.2024003145039.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h07v05.061.2024003145140/MYD17A2H.A2023337.h07v05.061.2024003145140.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h09v04.061.2024003145404/MYD17A2H.A2023337.h09v04.061.2024003145404.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h11v05.061.2024003145732/MYD17A2H.A2023337.h11v05.061.2024003145732.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h11v06.061.2024003150839/MYD17A2H.A2023337.h11v06.061.2024003150839.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h09v06.061.2024003155538/MYD17A2H.A2023337.h09v06.061.2024003155538.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h08v05.061.2024003161539/MYD17A2H.A2023337.h08v05.061.2024003161539.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023337.h20v01.061.2024003205107/MYD17A2H.A2023337.h20v01.061.2024003205107.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h12v03.061.2023340065610/MYD17A2H.A2023329.h12v03.061.2023340065610.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h10v04.061.2023340065014/MYD17A2H.A2023329.h10v04.061.2023340065014.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h07v05.061.2023340065832/MYD17A2H.A2023329.h07v05.061.2023340065832.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h11v05.061.2023340064606/MYD17A2H.A2023329.h11v05.061.2023340064606.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h13v04.061.2023340065623/MYD17A2H.A2023329.h13v04.061.2023340065623.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h11v06.061.2023340064402/MYD17A2H.A2023329.h11v06.061.2023340064402.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h07v06.061.2023340064558/MYD17A2H.A2023329.h07v06.061.2023340064558.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h10v06.061.2023340063944/MYD17A2H.A2023329.h10v06.061.2023340063944.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h13v03.061.2023340064430/MYD17A2H.A2023329.h13v03.061.2023340064430.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h10v05.061.2023340064138/MYD17A2H.A2023329.h10v05.061.2023340064138.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h09v06.061.2023340064129/MYD17A2H.A2023329.h09v06.061.2023340064129.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h11v03.061.2023340065858/MYD17A2H.A2023329.h11v03.061.2023340065858.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h11v04.061.2023340064427/MYD17A2H.A2023329.h11v04.061.2023340064427.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h12v05.061.2023340064128/MYD17A2H.A2023329.h12v05.061.2023340064128.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h08v04.061.2023340064754/MYD17A2H.A2023329.h08v04.061.2023340064754.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h08v06.061.2023340064138/MYD17A2H.A2023329.h08v06.061.2023340064138.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h09v05.061.2023340064142/MYD17A2H.A2023329.h09v05.061.2023340064142.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h08v05.061.2023340071358/MYD17A2H.A2023329.h08v05.061.2023340071358.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h20v01.061.2023340065623/MYD17A2H.A2023329.h20v01.061.2023340065623.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h09v03.061.2023340064556/MYD17A2H.A2023329.h09v03.061.2023340064556.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h09v04.061.2023340064441/MYD17A2H.A2023329.h09v04.061.2023340064441.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h12v04.061.2023340064144/MYD17A2H.A2023329.h12v04.061.2023340064144.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023329.h10v03.061.2023340070453/MYD17A2H.A2023329.h10v03.061.2023340070453.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h12v04.061.2023332050014/MYD17A2H.A2023321.h12v04.061.2023332050014.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h12v03.061.2023332045656/MYD17A2H.A2023321.h12v03.061.2023332045656.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h09v03.061.2023332045237/MYD17A2H.A2023321.h09v03.061.2023332045237.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h11v03.061.2023332045654/MYD17A2H.A2023321.h11v03.061.2023332045654.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h10v04.061.2023332044915/MYD17A2H.A2023321.h10v04.061.2023332044915.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h10v06.061.2023332045216/MYD17A2H.A2023321.h10v06.061.2023332045216.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h12v05.061.2023332044853/MYD17A2H.A2023321.h12v05.061.2023332044853.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h20v01.061.2023332044801/MYD17A2H.A2023321.h20v01.061.2023332044801.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h07v06.061.2023332045559/MYD17A2H.A2023321.h07v06.061.2023332045559.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h13v03.061.2023332050331/MYD17A2H.A2023321.h13v03.061.2023332050331.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h11v06.061.2023332044515/MYD17A2H.A2023321.h11v06.061.2023332044515.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h13v04.061.2023332045645/MYD17A2H.A2023321.h13v04.061.2023332045645.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h09v04.061.2023332045147/MYD17A2H.A2023321.h09v04.061.2023332045147.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h08v06.061.2023332045644/MYD17A2H.A2023321.h08v06.061.2023332045644.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h10v05.061.2023332045151/MYD17A2H.A2023321.h10v05.061.2023332045151.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h11v05.061.2023332050006/MYD17A2H.A2023321.h11v05.061.2023332050006.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h07v05.061.2023332045804/MYD17A2H.A2023321.h07v05.061.2023332045804.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h09v05.061.2023332045259/MYD17A2H.A2023321.h09v05.061.2023332045259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h08v04.061.2023332044934/MYD17A2H.A2023321.h08v04.061.2023332044934.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h08v05.061.2023332050333/MYD17A2H.A2023321.h08v05.061.2023332050333.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h11v04.061.2023332045645/MYD17A2H.A2023321.h11v04.061.2023332045645.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h10v03.061.2023332044902/MYD17A2H.A2023321.h10v03.061.2023332044902.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023321.h09v06.061.2023332045316/MYD17A2H.A2023321.h09v06.061.2023332045316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h11v06.061.2023323035345/MYD17A2H.A2023313.h11v06.061.2023323035345.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h13v04.061.2023323035829/MYD17A2H.A2023313.h13v04.061.2023323035829.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h12v05.061.2023323035833/MYD17A2H.A2023313.h12v05.061.2023323035833.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h09v06.061.2023323035819/MYD17A2H.A2023313.h09v06.061.2023323035819.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h08v05.061.2023323035354/MYD17A2H.A2023313.h08v05.061.2023323035354.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h10v05.061.2023323035620/MYD17A2H.A2023313.h10v05.061.2023323035620.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h11v05.061.2023323035824/MYD17A2H.A2023313.h11v05.061.2023323035824.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h09v04.061.2023323040220/MYD17A2H.A2023313.h09v04.061.2023323040220.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h09v03.061.2023323040213/MYD17A2H.A2023313.h09v03.061.2023323040213.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h13v03.061.2023323040047/MYD17A2H.A2023313.h13v03.061.2023323040047.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h11v04.061.2023323040054/MYD17A2H.A2023313.h11v04.061.2023323040054.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h10v06.061.2023323040212/MYD17A2H.A2023313.h10v06.061.2023323040212.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h10v04.061.2023323040226/MYD17A2H.A2023313.h10v04.061.2023323040226.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h12v04.061.2023323040222/MYD17A2H.A2023313.h12v04.061.2023323040222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h08v06.061.2023323040221/MYD17A2H.A2023313.h08v06.061.2023323040221.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h08v04.061.2023323040640/MYD17A2H.A2023313.h08v04.061.2023323040640.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h07v06.061.2023323040454/MYD17A2H.A2023313.h07v06.061.2023323040454.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h20v01.061.2023323040450/MYD17A2H.A2023313.h20v01.061.2023323040450.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h07v05.061.2023323040438/MYD17A2H.A2023313.h07v05.061.2023323040438.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h12v03.061.2023323040926/MYD17A2H.A2023313.h12v03.061.2023323040926.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h10v03.061.2023323041316/MYD17A2H.A2023313.h10v03.061.2023323041316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h09v05.061.2023323041321/MYD17A2H.A2023313.h09v05.061.2023323041321.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023313.h11v03.061.2023323041121/MYD17A2H.A2023313.h11v03.061.2023323041121.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h13v03.061.2023314061204/MYD17A2H.A2023305.h13v03.061.2023314061204.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h08v06.061.2023314061014/MYD17A2H.A2023305.h08v06.061.2023314061014.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h08v05.061.2023314061718/MYD17A2H.A2023305.h08v05.061.2023314061718.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h12v05.061.2023314061201/MYD17A2H.A2023305.h12v05.061.2023314061201.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h07v06.061.2023314061151/MYD17A2H.A2023305.h07v06.061.2023314061151.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h10v06.061.2023314061158/MYD17A2H.A2023305.h10v06.061.2023314061158.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h11v05.061.2023314061202/MYD17A2H.A2023305.h11v05.061.2023314061202.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h08v04.061.2023314061408/MYD17A2H.A2023305.h08v04.061.2023314061408.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h10v05.061.2023314061801/MYD17A2H.A2023305.h10v05.061.2023314061801.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h09v06.061.2023314061204/MYD17A2H.A2023305.h09v06.061.2023314061204.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h11v04.061.2023314061406/MYD17A2H.A2023305.h11v04.061.2023314061406.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h20v01.061.2023314061559/MYD17A2H.A2023305.h20v01.061.2023314061559.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h11v03.061.2023314061412/MYD17A2H.A2023305.h11v03.061.2023314061412.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h12v04.061.2023314061156/MYD17A2H.A2023305.h12v04.061.2023314061156.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h09v04.061.2023314061221/MYD17A2H.A2023305.h09v04.061.2023314061221.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h09v03.061.2023314061017/MYD17A2H.A2023305.h09v03.061.2023314061017.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h09v05.061.2023314061220/MYD17A2H.A2023305.h09v05.061.2023314061220.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h11v06.061.2023314063134/MYD17A2H.A2023305.h11v06.061.2023314063134.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h07v05.061.2023314062141/MYD17A2H.A2023305.h07v05.061.2023314062141.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h13v04.061.2023314062939/MYD17A2H.A2023305.h13v04.061.2023314062939.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h12v03.061.2023314063418/MYD17A2H.A2023305.h12v03.061.2023314063418.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h10v03.061.2023314062946/MYD17A2H.A2023305.h10v03.061.2023314062946.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023305.h10v04.061.2023314062358/MYD17A2H.A2023305.h10v04.061.2023314062358.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h10v06.061.2023306041954/MYD17A2H.A2023297.h10v06.061.2023306041954.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h09v04.061.2023306042508/MYD17A2H.A2023297.h09v04.061.2023306042508.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h08v04.061.2023306042624/MYD17A2H.A2023297.h08v04.061.2023306042624.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h11v06.061.2023306042829/MYD17A2H.A2023297.h11v06.061.2023306042829.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h07v06.061.2023306042459/MYD17A2H.A2023297.h07v06.061.2023306042459.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h07v05.061.2023306041256/MYD17A2H.A2023297.h07v05.061.2023306041256.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h09v03.061.2023306043222/MYD17A2H.A2023297.h09v03.061.2023306043222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h11v05.061.2023306042840/MYD17A2H.A2023297.h11v05.061.2023306042840.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h13v03.061.2023306043046/MYD17A2H.A2023297.h13v03.061.2023306043046.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h11v03.061.2023306042844/MYD17A2H.A2023297.h11v03.061.2023306042844.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h12v04.061.2023306043037/MYD17A2H.A2023297.h12v04.061.2023306043037.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h20v01.061.2023306043027/MYD17A2H.A2023297.h20v01.061.2023306043027.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h12v03.061.2023306043236/MYD17A2H.A2023297.h12v03.061.2023306043236.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h13v04.061.2023306042833/MYD17A2H.A2023297.h13v04.061.2023306042833.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h08v05.061.2023306043044/MYD17A2H.A2023297.h08v05.061.2023306043044.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h10v03.061.2023306043039/MYD17A2H.A2023297.h10v03.061.2023306043039.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h11v04.061.2023306043615/MYD17A2H.A2023297.h11v04.061.2023306043615.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h09v05.061.2023306042835/MYD17A2H.A2023297.h09v05.061.2023306042835.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h10v05.061.2023306043041/MYD17A2H.A2023297.h10v05.061.2023306043041.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h12v05.061.2023306042834/MYD17A2H.A2023297.h12v05.061.2023306042834.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h10v04.061.2023306043049/MYD17A2H.A2023297.h10v04.061.2023306043049.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h08v06.061.2023306042837/MYD17A2H.A2023297.h08v06.061.2023306042837.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023297.h09v06.061.2023306043037/MYD17A2H.A2023297.h09v06.061.2023306043037.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h11v06.061.2023299023708/MYD17A2H.A2023289.h11v06.061.2023299023708.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h09v03.061.2023299023907/MYD17A2H.A2023289.h09v03.061.2023299023907.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h08v04.061.2023299023900/MYD17A2H.A2023289.h08v04.061.2023299023900.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h10v03.061.2023299023909/MYD17A2H.A2023289.h10v03.061.2023299023909.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h11v04.061.2023299023715/MYD17A2H.A2023289.h11v04.061.2023299023715.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h13v03.061.2023299024146/MYD17A2H.A2023289.h13v03.061.2023299024146.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h09v06.061.2023299023916/MYD17A2H.A2023289.h09v06.061.2023299023916.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h07v06.061.2023299024328/MYD17A2H.A2023289.h07v06.061.2023299024328.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h20v01.061.2023299023917/MYD17A2H.A2023289.h20v01.061.2023299023917.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h09v05.061.2023299024335/MYD17A2H.A2023289.h09v05.061.2023299024335.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h07v05.061.2023299024130/MYD17A2H.A2023289.h07v05.061.2023299024130.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h10v05.061.2023299024143/MYD17A2H.A2023289.h10v05.061.2023299024143.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h09v04.061.2023299024608/MYD17A2H.A2023289.h09v04.061.2023299024608.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h12v05.061.2023299024138/MYD17A2H.A2023289.h12v05.061.2023299024138.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h10v04.061.2023299024142/MYD17A2H.A2023289.h10v04.061.2023299024142.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h12v04.061.2023299024140/MYD17A2H.A2023289.h12v04.061.2023299024140.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h11v03.061.2023299024146/MYD17A2H.A2023289.h11v03.061.2023299024146.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h11v05.061.2023299024137/MYD17A2H.A2023289.h11v05.061.2023299024137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h10v06.061.2023299024331/MYD17A2H.A2023289.h10v06.061.2023299024331.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h08v05.061.2023299024138/MYD17A2H.A2023289.h08v05.061.2023299024138.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h13v04.061.2023299024135/MYD17A2H.A2023289.h13v04.061.2023299024135.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h08v06.061.2023299024337/MYD17A2H.A2023289.h08v06.061.2023299024337.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023289.h12v03.061.2023299025948/MYD17A2H.A2023289.h12v03.061.2023299025948.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h11v06.061.2023290184628/MYD17A2H.A2023281.h11v06.061.2023290184628.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h07v05.061.2023290185234/MYD17A2H.A2023281.h07v05.061.2023290185234.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h09v03.061.2023290185246/MYD17A2H.A2023281.h09v03.061.2023290185246.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h08v06.061.2023290185720/MYD17A2H.A2023281.h08v06.061.2023290185720.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h10v04.061.2023290185716/MYD17A2H.A2023281.h10v04.061.2023290185716.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h08v04.061.2023290185532/MYD17A2H.A2023281.h08v04.061.2023290185532.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h09v05.061.2023290185527/MYD17A2H.A2023281.h09v05.061.2023290185527.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h09v04.061.2023290185717/MYD17A2H.A2023281.h09v04.061.2023290185717.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h07v06.061.2023290185525/MYD17A2H.A2023281.h07v06.061.2023290185525.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h10v06.061.2023290185527/MYD17A2H.A2023281.h10v06.061.2023290185527.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h12v04.061.2023290185526/MYD17A2H.A2023281.h12v04.061.2023290185526.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h10v05.061.2023290185725/MYD17A2H.A2023281.h10v05.061.2023290185725.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h13v03.061.2023290185722/MYD17A2H.A2023281.h13v03.061.2023290185722.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h12v05.061.2023290185909/MYD17A2H.A2023281.h12v05.061.2023290185909.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h11v03.061.2023290190149/MYD17A2H.A2023281.h11v03.061.2023290190149.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h10v03.061.2023290190141/MYD17A2H.A2023281.h10v03.061.2023290190141.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h09v06.061.2023290190137/MYD17A2H.A2023281.h09v06.061.2023290190137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h12v03.061.2023290190149/MYD17A2H.A2023281.h12v03.061.2023290190149.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h13v04.061.2023290185913/MYD17A2H.A2023281.h13v04.061.2023290185913.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h08v05.061.2023290185911/MYD17A2H.A2023281.h08v05.061.2023290185911.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h11v05.061.2023290185915/MYD17A2H.A2023281.h11v05.061.2023290185915.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h11v04.061.2023290190144/MYD17A2H.A2023281.h11v04.061.2023290190144.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023281.h20v01.061.2023290190546/MYD17A2H.A2023281.h20v01.061.2023290190546.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h09v03.061.2023283223159/MYD17A2H.A2023273.h09v03.061.2023283223159.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h10v06.061.2023283223408/MYD17A2H.A2023273.h10v06.061.2023283223408.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h13v04.061.2023283223404/MYD17A2H.A2023273.h13v04.061.2023283223404.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h11v06.061.2023283223203/MYD17A2H.A2023273.h11v06.061.2023283223203.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h10v04.061.2023283223610/MYD17A2H.A2023273.h10v04.061.2023283223610.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h11v05.061.2023283223207/MYD17A2H.A2023273.h11v05.061.2023283223207.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h08v05.061.2023283223409/MYD17A2H.A2023273.h08v05.061.2023283223409.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h20v01.061.2023283223403/MYD17A2H.A2023273.h20v01.061.2023283223403.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h08v04.061.2023283223203/MYD17A2H.A2023273.h08v04.061.2023283223203.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h10v03.061.2023283223408/MYD17A2H.A2023273.h10v03.061.2023283223408.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h07v05.061.2023283223402/MYD17A2H.A2023273.h07v05.061.2023283223402.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h09v06.061.2023283223406/MYD17A2H.A2023273.h09v06.061.2023283223406.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h07v06.061.2023283223753/MYD17A2H.A2023273.h07v06.061.2023283223753.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h08v06.061.2023283223559/MYD17A2H.A2023273.h08v06.061.2023283223559.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h11v04.061.2023283223805/MYD17A2H.A2023273.h11v04.061.2023283223805.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h11v03.061.2023283224409/MYD17A2H.A2023273.h11v03.061.2023283224409.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h10v05.061.2023283223801/MYD17A2H.A2023273.h10v05.061.2023283223801.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h12v04.061.2023283223802/MYD17A2H.A2023273.h12v04.061.2023283223802.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h09v04.061.2023283223806/MYD17A2H.A2023273.h09v04.061.2023283223806.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h12v03.061.2023283223812/MYD17A2H.A2023273.h12v03.061.2023283223812.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h12v05.061.2023283223756/MYD17A2H.A2023273.h12v05.061.2023283223756.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h13v03.061.2023283223802/MYD17A2H.A2023273.h13v03.061.2023283223802.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023273.h09v05.061.2023283223805/MYD17A2H.A2023273.h09v05.061.2023283223805.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h12v05.061.2023274044324/MYD17A2H.A2023265.h12v05.061.2023274044324.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h10v06.061.2023274044323/MYD17A2H.A2023265.h10v06.061.2023274044323.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h11v03.061.2023274044520/MYD17A2H.A2023265.h11v03.061.2023274044520.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h12v03.061.2023274044536/MYD17A2H.A2023265.h12v03.061.2023274044536.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h08v04.061.2023274044200/MYD17A2H.A2023265.h08v04.061.2023274044200.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h10v03.061.2023274044320/MYD17A2H.A2023265.h10v03.061.2023274044320.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h09v05.061.2023274044526/MYD17A2H.A2023265.h09v05.061.2023274044526.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h07v06.061.2023274044154/MYD17A2H.A2023265.h07v06.061.2023274044154.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h11v06.061.2023274044151/MYD17A2H.A2023265.h11v06.061.2023274044151.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h09v04.061.2023274044516/MYD17A2H.A2023265.h09v04.061.2023274044516.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h09v03.061.2023274044151/MYD17A2H.A2023265.h09v03.061.2023274044151.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h08v06.061.2023274044324/MYD17A2H.A2023265.h08v06.061.2023274044324.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h12v04.061.2023274044520/MYD17A2H.A2023265.h12v04.061.2023274044520.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h13v04.061.2023274044157/MYD17A2H.A2023265.h13v04.061.2023274044157.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h11v05.061.2023274044155/MYD17A2H.A2023265.h11v05.061.2023274044155.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h11v04.061.2023274044721/MYD17A2H.A2023265.h11v04.061.2023274044721.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h09v06.061.2023274044913/MYD17A2H.A2023265.h09v06.061.2023274044913.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h08v05.061.2023274044518/MYD17A2H.A2023265.h08v05.061.2023274044518.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h10v04.061.2023274044917/MYD17A2H.A2023265.h10v04.061.2023274044917.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h13v03.061.2023274045240/MYD17A2H.A2023265.h13v03.061.2023274045240.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h10v05.061.2023274045114/MYD17A2H.A2023265.h10v05.061.2023274045114.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h20v01.061.2023274050141/MYD17A2H.A2023265.h20v01.061.2023274050141.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023265.h07v05.061.2023274044911/MYD17A2H.A2023265.h07v05.061.2023274044911.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h10v06.061.2023266044311/MYD17A2H.A2023257.h10v06.061.2023266044311.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h08v04.061.2023266044805/MYD17A2H.A2023257.h08v04.061.2023266044805.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h13v04.061.2023266044809/MYD17A2H.A2023257.h13v04.061.2023266044809.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h12v03.061.2023266044815/MYD17A2H.A2023257.h12v03.061.2023266044815.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h08v05.061.2023266044808/MYD17A2H.A2023257.h08v05.061.2023266044808.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h12v05.061.2023266044804/MYD17A2H.A2023257.h12v05.061.2023266044804.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h10v04.061.2023266045143/MYD17A2H.A2023257.h10v04.061.2023266045143.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h09v05.061.2023266044814/MYD17A2H.A2023257.h09v05.061.2023266044814.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h09v03.061.2023266044816/MYD17A2H.A2023257.h09v03.061.2023266044816.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h09v06.061.2023266044811/MYD17A2H.A2023257.h09v06.061.2023266044811.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h07v06.061.2023266045006/MYD17A2H.A2023257.h07v06.061.2023266045006.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h11v05.061.2023266044814/MYD17A2H.A2023257.h11v05.061.2023266044814.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h10v03.061.2023266045332/MYD17A2H.A2023257.h10v03.061.2023266045332.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h11v06.061.2023266045334/MYD17A2H.A2023257.h11v06.061.2023266045334.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h12v04.061.2023266045141/MYD17A2H.A2023257.h12v04.061.2023266045141.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h11v03.061.2023266045142/MYD17A2H.A2023257.h11v03.061.2023266045142.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h08v06.061.2023266045018/MYD17A2H.A2023257.h08v06.061.2023266045018.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h13v03.061.2023266044812/MYD17A2H.A2023257.h13v03.061.2023266044812.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h10v05.061.2023266045023/MYD17A2H.A2023257.h10v05.061.2023266045023.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h11v04.061.2023266045338/MYD17A2H.A2023257.h11v04.061.2023266045338.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h07v05.061.2023266045007/MYD17A2H.A2023257.h07v05.061.2023266045007.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h20v01.061.2023266050500/MYD17A2H.A2023257.h20v01.061.2023266050500.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023257.h09v04.061.2023266050002/MYD17A2H.A2023257.h09v04.061.2023266050002.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h11v06.061.2023258045020/MYD17A2H.A2023249.h11v06.061.2023258045020.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h12v03.061.2023258045301/MYD17A2H.A2023249.h12v03.061.2023258045301.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h13v04.061.2023258045253/MYD17A2H.A2023249.h13v04.061.2023258045253.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h09v04.061.2023258044820/MYD17A2H.A2023249.h09v04.061.2023258044820.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h12v05.061.2023258045441/MYD17A2H.A2023249.h12v05.061.2023258045441.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h08v06.061.2023258045023/MYD17A2H.A2023249.h08v06.061.2023258045023.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h08v04.061.2023258044818/MYD17A2H.A2023249.h08v04.061.2023258044818.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h07v06.061.2023258044815/MYD17A2H.A2023249.h07v06.061.2023258044815.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h11v03.061.2023258050126/MYD17A2H.A2023249.h11v03.061.2023258050126.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h09v03.061.2023258045009/MYD17A2H.A2023249.h09v03.061.2023258045009.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h11v04.061.2023258045259/MYD17A2H.A2023249.h11v04.061.2023258045259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h10v04.061.2023258045022/MYD17A2H.A2023249.h10v04.061.2023258045022.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h09v06.061.2023258044825/MYD17A2H.A2023249.h09v06.061.2023258044825.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h09v05.061.2023258045308/MYD17A2H.A2023249.h09v05.061.2023258045308.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h10v03.061.2023258045259/MYD17A2H.A2023249.h10v03.061.2023258045259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h10v06.061.2023258044348/MYD17A2H.A2023249.h10v06.061.2023258044348.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h07v05.061.2023258044341/MYD17A2H.A2023249.h07v05.061.2023258044341.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h20v01.061.2023258051817/MYD17A2H.A2023249.h20v01.061.2023258051817.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h08v05.061.2023258044551/MYD17A2H.A2023249.h08v05.061.2023258044551.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h13v03.061.2023258044826/MYD17A2H.A2023249.h13v03.061.2023258044826.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h10v05.061.2023258045017/MYD17A2H.A2023249.h10v05.061.2023258045017.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h11v05.061.2023258044442/MYD17A2H.A2023249.h11v05.061.2023258044442.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023249.h12v04.061.2023258045020/MYD17A2H.A2023249.h12v04.061.2023258045020.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h07v06.061.2023252010017/MYD17A2H.A2023241.h07v06.061.2023252010017.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h08v04.061.2023252010011/MYD17A2H.A2023241.h08v04.061.2023252010011.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h07v05.061.2023252010239/MYD17A2H.A2023241.h07v05.061.2023252010239.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h09v05.061.2023252010015/MYD17A2H.A2023241.h09v05.061.2023252010015.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h10v04.061.2023252010516/MYD17A2H.A2023241.h10v04.061.2023252010516.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h08v05.061.2023252010248/MYD17A2H.A2023241.h08v05.061.2023252010248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h09v03.061.2023252010257/MYD17A2H.A2023241.h09v03.061.2023252010257.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h20v01.061.2023252010511/MYD17A2H.A2023241.h20v01.061.2023252010511.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h08v06.061.2023252010248/MYD17A2H.A2023241.h08v06.061.2023252010248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h13v03.061.2023252010255/MYD17A2H.A2023241.h13v03.061.2023252010255.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h13v04.061.2023252010305/MYD17A2H.A2023241.h13v04.061.2023252010305.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h12v03.061.2023252010249/MYD17A2H.A2023241.h12v03.061.2023252010249.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h11v03.061.2023252010251/MYD17A2H.A2023241.h11v03.061.2023252010251.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h09v06.061.2023252011016/MYD17A2H.A2023241.h09v06.061.2023252011016.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h11v04.061.2023252011024/MYD17A2H.A2023241.h11v04.061.2023252011024.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h11v06.061.2023252011247/MYD17A2H.A2023241.h11v06.061.2023252011247.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h10v06.061.2023252011239/MYD17A2H.A2023241.h10v06.061.2023252011239.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h09v04.061.2023252011245/MYD17A2H.A2023241.h09v04.061.2023252011245.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h10v05.061.2023252011247/MYD17A2H.A2023241.h10v05.061.2023252011247.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h11v05.061.2023252012017/MYD17A2H.A2023241.h11v05.061.2023252012017.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h12v04.061.2023252011949/MYD17A2H.A2023241.h12v04.061.2023252011949.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h12v05.061.2023252012013/MYD17A2H.A2023241.h12v05.061.2023252012013.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023241.h10v03.061.2023252012035/MYD17A2H.A2023241.h10v03.061.2023252012035.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h12v05.061.2023242043612/MYD17A2H.A2023233.h12v05.061.2023242043612.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h07v05.061.2023242043726/MYD17A2H.A2023233.h07v05.061.2023242043726.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h11v06.061.2023242043928/MYD17A2H.A2023233.h11v06.061.2023242043928.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h08v05.061.2023242043748/MYD17A2H.A2023233.h08v05.061.2023242043748.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h09v05.061.2023242043746/MYD17A2H.A2023233.h09v05.061.2023242043746.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h20v01.061.2023242052031/MYD17A2H.A2023233.h20v01.061.2023242052031.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h09v04.061.2023242043743/MYD17A2H.A2023233.h09v04.061.2023242043743.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h08v04.061.2023242044458/MYD17A2H.A2023233.h08v04.061.2023242044458.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h11v04.061.2023242043749/MYD17A2H.A2023233.h11v04.061.2023242043749.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h12v04.061.2023242043943/MYD17A2H.A2023233.h12v04.061.2023242043943.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h09v06.061.2023242043737/MYD17A2H.A2023233.h09v06.061.2023242043737.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h12v03.061.2023242043945/MYD17A2H.A2023233.h12v03.061.2023242043945.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h09v03.061.2023242043936/MYD17A2H.A2023233.h09v03.061.2023242043936.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h11v05.061.2023242043620/MYD17A2H.A2023233.h11v05.061.2023242043620.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h10v05.061.2023242043951/MYD17A2H.A2023233.h10v05.061.2023242043951.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h10v03.061.2023242043940/MYD17A2H.A2023233.h10v03.061.2023242043940.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h13v04.061.2023242043739/MYD17A2H.A2023233.h13v04.061.2023242043739.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h11v03.061.2023242043939/MYD17A2H.A2023233.h11v03.061.2023242043939.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h08v06.061.2023242043942/MYD17A2H.A2023233.h08v06.061.2023242043942.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h13v03.061.2023242043740/MYD17A2H.A2023233.h13v03.061.2023242043740.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h10v04.061.2023242043947/MYD17A2H.A2023233.h10v04.061.2023242043947.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h07v06.061.2023242043359/MYD17A2H.A2023233.h07v06.061.2023242043359.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MYD17A2H.061/MYD17A2H.A2023233.h10v06.061.2023242043733/MYD17A2H.A2023233.h10v06.061.2023242043733.hdf
EDSCEOF
