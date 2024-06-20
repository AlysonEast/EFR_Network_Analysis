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
    echo "https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h12v05.061.2023242043728/MOD17A2H.A2023233.h12v05.061.2023242043728.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h12v05.061.2023242043728/MOD17A2H.A2023233.h12v05.061.2023242043728.hdf -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h12v05.061.2023242043728/MOD17A2H.A2023233.h12v05.061.2023242043728.hdf | tail -1)
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
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h07v06.061.2023242043408/MOD17A2H.A2023233.h07v06.061.2023242043408.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h12v03.061.2023242044302/MOD17A2H.A2023233.h12v03.061.2023242044302.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h11v03.061.2023242043949/MOD17A2H.A2023233.h11v03.061.2023242043949.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h10v03.061.2023242043745/MOD17A2H.A2023233.h10v03.061.2023242043745.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h08v05.061.2023242043624/MOD17A2H.A2023233.h08v05.061.2023242043624.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h11v06.061.2023242043737/MOD17A2H.A2023233.h11v06.061.2023242043737.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h09v04.061.2023242043943/MOD17A2H.A2023233.h09v04.061.2023242043943.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h08v04.061.2023242044457/MOD17A2H.A2023233.h08v04.061.2023242044457.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h10v06.061.2023242044257/MOD17A2H.A2023233.h10v06.061.2023242044257.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h11v04.061.2023242043949/MOD17A2H.A2023233.h11v04.061.2023242043949.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h07v05.061.2023242044457/MOD17A2H.A2023233.h07v05.061.2023242044457.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h12v04.061.2023242044303/MOD17A2H.A2023233.h12v04.061.2023242044303.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h09v05.061.2023242043753/MOD17A2H.A2023233.h09v05.061.2023242043753.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h13v03.061.2023242044302/MOD17A2H.A2023233.h13v03.061.2023242044302.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h09v03.061.2023242043739/MOD17A2H.A2023233.h09v03.061.2023242043739.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h10v05.061.2023242043739/MOD17A2H.A2023233.h10v05.061.2023242043739.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h20v01.061.2023242051957/MOD17A2H.A2023233.h20v01.061.2023242051957.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h08v06.061.2023242043741/MOD17A2H.A2023233.h08v06.061.2023242043741.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h11v05.061.2023242043743/MOD17A2H.A2023233.h11v05.061.2023242043743.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h13v04.061.2023242044302/MOD17A2H.A2023233.h13v04.061.2023242044302.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h09v06.061.2023242043750/MOD17A2H.A2023233.h09v06.061.2023242043750.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023233.h10v04.061.2023242043741/MOD17A2H.A2023233.h10v04.061.2023242043741.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h12v05.061.2023252010234/MOD17A2H.A2023241.h12v05.061.2023252010234.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h11v06.061.2023252010238/MOD17A2H.A2023241.h11v06.061.2023252010238.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h07v05.061.2023252010246/MOD17A2H.A2023241.h07v05.061.2023252010246.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h10v05.061.2023252010240/MOD17A2H.A2023241.h10v05.061.2023252010240.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h08v04.061.2023252010231/MOD17A2H.A2023241.h08v04.061.2023252010231.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h09v03.061.2023252010238/MOD17A2H.A2023241.h09v03.061.2023252010238.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h20v01.061.2023252010235/MOD17A2H.A2023241.h20v01.061.2023252010235.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h09v06.061.2023252010233/MOD17A2H.A2023241.h09v06.061.2023252010233.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h11v03.061.2023252010243/MOD17A2H.A2023241.h11v03.061.2023252010243.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h11v04.061.2023252010512/MOD17A2H.A2023241.h11v04.061.2023252010512.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h12v03.061.2023252010258/MOD17A2H.A2023241.h12v03.061.2023252010258.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h10v03.061.2023252010249/MOD17A2H.A2023241.h10v03.061.2023252010249.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h10v04.061.2023252010248/MOD17A2H.A2023241.h10v04.061.2023252010248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h11v05.061.2023252011021/MOD17A2H.A2023241.h11v05.061.2023252011021.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h12v04.061.2023252011021/MOD17A2H.A2023241.h12v04.061.2023252011021.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h13v03.061.2023252010736/MOD17A2H.A2023241.h13v03.061.2023252010736.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h09v05.061.2023252010739/MOD17A2H.A2023241.h09v05.061.2023252010739.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h10v06.061.2023252010740/MOD17A2H.A2023241.h10v06.061.2023252010740.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h09v04.061.2023252011248/MOD17A2H.A2023241.h09v04.061.2023252011248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h13v04.061.2023252011253/MOD17A2H.A2023241.h13v04.061.2023252011253.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h07v06.061.2023252011736/MOD17A2H.A2023241.h07v06.061.2023252011736.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h08v05.061.2023252011953/MOD17A2H.A2023241.h08v05.061.2023252011953.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023241.h08v06.061.2023252012009/MOD17A2H.A2023241.h08v06.061.2023252012009.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h08v06.061.2023258045449/MOD17A2H.A2023249.h08v06.061.2023258045449.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h12v03.061.2023258045019/MOD17A2H.A2023249.h12v03.061.2023258045019.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h09v03.061.2023258045250/MOD17A2H.A2023249.h09v03.061.2023258045250.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h10v06.061.2023258045441/MOD17A2H.A2023249.h10v06.061.2023258045441.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h09v06.061.2023258044813/MOD17A2H.A2023249.h09v06.061.2023258044813.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h09v04.061.2023258045016/MOD17A2H.A2023249.h09v04.061.2023258045016.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h09v05.061.2023258044820/MOD17A2H.A2023249.h09v05.061.2023258044820.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h10v03.061.2023258045014/MOD17A2H.A2023249.h10v03.061.2023258045014.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h07v05.061.2023258044828/MOD17A2H.A2023249.h07v05.061.2023258044828.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h07v06.061.2023258045023/MOD17A2H.A2023249.h07v06.061.2023258045023.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h08v05.061.2023258045451/MOD17A2H.A2023249.h08v05.061.2023258045451.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h13v04.061.2023258045017/MOD17A2H.A2023249.h13v04.061.2023258045017.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h11v06.061.2023258045010/MOD17A2H.A2023249.h11v06.061.2023258045010.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h10v04.061.2023258044825/MOD17A2H.A2023249.h10v04.061.2023258044825.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h11v04.061.2023258045446/MOD17A2H.A2023249.h11v04.061.2023258045446.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h13v03.061.2023258050125/MOD17A2H.A2023249.h13v03.061.2023258050125.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h08v04.061.2023258044826/MOD17A2H.A2023249.h08v04.061.2023258044826.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h20v01.061.2023258050722/MOD17A2H.A2023249.h20v01.061.2023258050722.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h11v05.061.2023258045651/MOD17A2H.A2023249.h11v05.061.2023258045651.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h12v05.061.2023258044825/MOD17A2H.A2023249.h12v05.061.2023258044825.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h10v05.061.2023258044835/MOD17A2H.A2023249.h10v05.061.2023258044835.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h11v03.061.2023258045450/MOD17A2H.A2023249.h11v03.061.2023258045450.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023249.h12v04.061.2023258045029/MOD17A2H.A2023249.h12v04.061.2023258045029.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h12v05.061.2023266044807/MOD17A2H.A2023257.h12v05.061.2023266044807.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h08v06.061.2023266044645/MOD17A2H.A2023257.h08v06.061.2023266044645.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h11v06.061.2023266044633/MOD17A2H.A2023257.h11v06.061.2023266044633.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h07v05.061.2023266044808/MOD17A2H.A2023257.h07v05.061.2023266044808.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h07v06.061.2023266045002/MOD17A2H.A2023257.h07v06.061.2023266045002.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h10v03.061.2023266044811/MOD17A2H.A2023257.h10v03.061.2023266044811.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h10v06.061.2023266044810/MOD17A2H.A2023257.h10v06.061.2023266044810.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h09v06.061.2023266044306/MOD17A2H.A2023257.h09v06.061.2023266044306.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h11v05.061.2023266045014/MOD17A2H.A2023257.h11v05.061.2023266045014.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h13v04.061.2023266045259/MOD17A2H.A2023257.h13v04.061.2023266045259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h11v03.061.2023266045012/MOD17A2H.A2023257.h11v03.061.2023266045012.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h10v05.061.2023266045135/MOD17A2H.A2023257.h10v05.061.2023266045135.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h11v04.061.2023266045017/MOD17A2H.A2023257.h11v04.061.2023266045017.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h13v03.061.2023266045013/MOD17A2H.A2023257.h13v03.061.2023266045013.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h08v05.061.2023266045259/MOD17A2H.A2023257.h08v05.061.2023266045259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h09v03.061.2023266045450/MOD17A2H.A2023257.h09v03.061.2023266045450.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h10v04.061.2023266045145/MOD17A2H.A2023257.h10v04.061.2023266045145.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h12v04.061.2023266045137/MOD17A2H.A2023257.h12v04.061.2023266045137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h09v04.061.2023266045257/MOD17A2H.A2023257.h09v04.061.2023266045257.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h12v03.061.2023266045632/MOD17A2H.A2023257.h12v03.061.2023266045632.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h08v04.061.2023266045623/MOD17A2H.A2023257.h08v04.061.2023266045623.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h09v05.061.2023266045022/MOD17A2H.A2023257.h09v05.061.2023266045022.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023257.h20v01.061.2023266050955/MOD17A2H.A2023257.h20v01.061.2023266050955.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h09v03.061.2023274044156/MOD17A2H.A2023265.h09v03.061.2023274044156.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h10v06.061.2023274043744/MOD17A2H.A2023265.h10v06.061.2023274043744.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h11v05.061.2023274044204/MOD17A2H.A2023265.h11v05.061.2023274044204.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h10v05.061.2023274044516/MOD17A2H.A2023265.h10v05.061.2023274044516.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h11v06.061.2023274044203/MOD17A2H.A2023265.h11v06.061.2023274044203.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h12v04.061.2023274043954/MOD17A2H.A2023265.h12v04.061.2023274043954.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h08v06.061.2023274044205/MOD17A2H.A2023265.h08v06.061.2023274044205.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h08v05.061.2023274044211/MOD17A2H.A2023265.h08v05.061.2023274044211.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h08v04.061.2023274044205/MOD17A2H.A2023265.h08v04.061.2023274044205.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h09v06.061.2023274044316/MOD17A2H.A2023265.h09v06.061.2023274044316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h12v05.061.2023274044202/MOD17A2H.A2023265.h12v05.061.2023274044202.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h07v06.061.2023274044710/MOD17A2H.A2023265.h07v06.061.2023274044710.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h09v05.061.2023274044525/MOD17A2H.A2023265.h09v05.061.2023274044525.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h13v04.061.2023274044325/MOD17A2H.A2023265.h13v04.061.2023274044325.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h10v03.061.2023274044323/MOD17A2H.A2023265.h10v03.061.2023274044323.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h09v04.061.2023274044327/MOD17A2H.A2023265.h09v04.061.2023274044327.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h13v03.061.2023274044323/MOD17A2H.A2023265.h13v03.061.2023274044323.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h10v04.061.2023274044522/MOD17A2H.A2023265.h10v04.061.2023274044522.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h11v03.061.2023274044334/MOD17A2H.A2023265.h11v03.061.2023274044334.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h11v04.061.2023274044525/MOD17A2H.A2023265.h11v04.061.2023274044525.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h07v05.061.2023274045235/MOD17A2H.A2023265.h07v05.061.2023274045235.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h20v01.061.2023274044921/MOD17A2H.A2023265.h20v01.061.2023274044921.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023265.h12v03.061.2023274045052/MOD17A2H.A2023265.h12v03.061.2023274045052.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h09v05.061.2023282042305/MOD17A2H.A2023273.h09v05.061.2023282042305.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h08v06.061.2023282042617/MOD17A2H.A2023273.h08v06.061.2023282042617.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h12v05.061.2023282042939/MOD17A2H.A2023273.h12v05.061.2023282042939.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h07v06.061.2023282042605/MOD17A2H.A2023273.h07v06.061.2023282042605.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h13v03.061.2023282042611/MOD17A2H.A2023273.h13v03.061.2023282042611.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h12v04.061.2023282042947/MOD17A2H.A2023273.h12v04.061.2023282042947.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h09v04.061.2023282042617/MOD17A2H.A2023273.h09v04.061.2023282042617.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h11v06.061.2023282042606/MOD17A2H.A2023273.h11v06.061.2023282042606.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h09v06.061.2023282043805/MOD17A2H.A2023273.h09v06.061.2023282043805.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h10v04.061.2023282043213/MOD17A2H.A2023273.h10v04.061.2023282043213.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h11v04.061.2023282043219/MOD17A2H.A2023273.h11v04.061.2023282043219.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h13v04.061.2023282043458/MOD17A2H.A2023273.h13v04.061.2023282043458.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h10v03.061.2023282043210/MOD17A2H.A2023273.h10v03.061.2023282043210.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h09v03.061.2023282043203/MOD17A2H.A2023273.h09v03.061.2023282043203.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h11v03.061.2023282043222/MOD17A2H.A2023273.h11v03.061.2023282043222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h10v05.061.2023282042958/MOD17A2H.A2023273.h10v05.061.2023282042958.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h12v03.061.2023282043212/MOD17A2H.A2023273.h12v03.061.2023282043212.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h07v05.061.2023282043201/MOD17A2H.A2023273.h07v05.061.2023282043201.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h08v04.061.2023282045400/MOD17A2H.A2023273.h08v04.061.2023282045400.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h08v05.061.2023282045404/MOD17A2H.A2023273.h08v05.061.2023282045404.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h20v01.061.2023282044039/MOD17A2H.A2023273.h20v01.061.2023282044039.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h11v05.061.2023282045405/MOD17A2H.A2023273.h11v05.061.2023282045405.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023273.h10v06.061.2023282044027/MOD17A2H.A2023273.h10v06.061.2023282044027.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h11v06.061.2023290184259/MOD17A2H.A2023281.h11v06.061.2023290184259.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h09v06.061.2023290185035/MOD17A2H.A2023281.h09v06.061.2023290185035.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h07v05.061.2023290185042/MOD17A2H.A2023281.h07v05.061.2023290185042.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h07v06.061.2023290184812/MOD17A2H.A2023281.h07v06.061.2023290184812.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h08v04.061.2023290185240/MOD17A2H.A2023281.h08v04.061.2023290185240.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h12v04.061.2023290185051/MOD17A2H.A2023281.h12v04.061.2023290185051.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h09v03.061.2023290185236/MOD17A2H.A2023281.h09v03.061.2023290185236.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h11v04.061.2023290185247/MOD17A2H.A2023281.h11v04.061.2023290185247.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h08v06.061.2023290185243/MOD17A2H.A2023281.h08v06.061.2023290185243.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h10v06.061.2023290185046/MOD17A2H.A2023281.h10v06.061.2023290185046.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h08v05.061.2023290185530/MOD17A2H.A2023281.h08v05.061.2023290185530.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h13v04.061.2023290185519/MOD17A2H.A2023281.h13v04.061.2023290185519.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h10v04.061.2023290185532/MOD17A2H.A2023281.h10v04.061.2023290185532.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h09v04.061.2023290185713/MOD17A2H.A2023281.h09v04.061.2023290185713.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h11v05.061.2023290185527/MOD17A2H.A2023281.h11v05.061.2023290185527.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h12v05.061.2023290185706/MOD17A2H.A2023281.h12v05.061.2023290185706.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h12v03.061.2023290185724/MOD17A2H.A2023281.h12v03.061.2023290185724.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h10v03.061.2023290185525/MOD17A2H.A2023281.h10v03.061.2023290185525.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h10v05.061.2023290185527/MOD17A2H.A2023281.h10v05.061.2023290185527.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h09v05.061.2023290185527/MOD17A2H.A2023281.h09v05.061.2023290185527.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h13v03.061.2023290185918/MOD17A2H.A2023281.h13v03.061.2023290185918.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h11v03.061.2023290185920/MOD17A2H.A2023281.h11v03.061.2023290185920.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023281.h20v01.061.2023290191011/MOD17A2H.A2023281.h20v01.061.2023290191011.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h07v05.061.2023299023436/MOD17A2H.A2023289.h07v05.061.2023299023436.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h10v04.061.2023299023712/MOD17A2H.A2023289.h10v04.061.2023299023712.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h07v06.061.2023299023442/MOD17A2H.A2023289.h07v06.061.2023299023442.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h10v06.061.2023299023444/MOD17A2H.A2023289.h10v06.061.2023299023444.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h08v04.061.2023299023713/MOD17A2H.A2023289.h08v04.061.2023299023713.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h13v03.061.2023299023442/MOD17A2H.A2023289.h13v03.061.2023299023442.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h09v06.061.2023299023439/MOD17A2H.A2023289.h09v06.061.2023299023439.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h08v05.061.2023299024143/MOD17A2H.A2023289.h08v05.061.2023299024143.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h08v06.061.2023299023716/MOD17A2H.A2023289.h08v06.061.2023299023716.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h09v05.061.2023299024143/MOD17A2H.A2023289.h09v05.061.2023299024143.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h11v04.061.2023299023445/MOD17A2H.A2023289.h11v04.061.2023299023445.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h11v05.061.2023299023458/MOD17A2H.A2023289.h11v05.061.2023299023458.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h20v01.061.2023299023716/MOD17A2H.A2023289.h20v01.061.2023299023716.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h12v03.061.2023299023716/MOD17A2H.A2023289.h12v03.061.2023299023716.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h11v06.061.2023299024136/MOD17A2H.A2023289.h11v06.061.2023299024136.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h12v05.061.2023299024136/MOD17A2H.A2023289.h12v05.061.2023299024136.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h09v03.061.2023299023902/MOD17A2H.A2023289.h09v03.061.2023299023902.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h10v03.061.2023299030404/MOD17A2H.A2023289.h10v03.061.2023299030404.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h12v04.061.2023299024337/MOD17A2H.A2023289.h12v04.061.2023299024337.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h13v04.061.2023299024136/MOD17A2H.A2023289.h13v04.061.2023299024136.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h11v03.061.2023299024615/MOD17A2H.A2023289.h11v03.061.2023299024615.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h09v04.061.2023299024611/MOD17A2H.A2023289.h09v04.061.2023299024611.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023289.h10v05.061.2023299025044/MOD17A2H.A2023289.h10v05.061.2023299025044.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h11v06.061.2023306041245/MOD17A2H.A2023297.h11v06.061.2023306041245.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h07v05.061.2023306042501/MOD17A2H.A2023297.h07v05.061.2023306042501.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h07v06.061.2023306041954/MOD17A2H.A2023297.h07v06.061.2023306041954.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h09v06.061.2023306041459/MOD17A2H.A2023297.h09v06.061.2023306041459.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h08v04.061.2023306042631/MOD17A2H.A2023297.h08v04.061.2023306042631.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h10v06.061.2023306041517/MOD17A2H.A2023297.h10v06.061.2023306041517.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h08v06.061.2023306041955/MOD17A2H.A2023297.h08v06.061.2023306041955.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h11v05.061.2023306042837/MOD17A2H.A2023297.h11v05.061.2023306042837.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h13v04.061.2023306043032/MOD17A2H.A2023297.h13v04.061.2023306043032.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h08v05.061.2023306042843/MOD17A2H.A2023297.h08v05.061.2023306042843.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h12v05.061.2023306042833/MOD17A2H.A2023297.h12v05.061.2023306042833.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h10v04.061.2023306042850/MOD17A2H.A2023297.h10v04.061.2023306042850.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h12v04.061.2023306043800/MOD17A2H.A2023297.h12v04.061.2023306043800.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h10v03.061.2023306042838/MOD17A2H.A2023297.h10v03.061.2023306042838.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h09v05.061.2023306042843/MOD17A2H.A2023297.h09v05.061.2023306042843.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h11v04.061.2023306043054/MOD17A2H.A2023297.h11v04.061.2023306043054.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h09v04.061.2023306043037/MOD17A2H.A2023297.h09v04.061.2023306043037.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h10v05.061.2023306042847/MOD17A2H.A2023297.h10v05.061.2023306042847.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h11v03.061.2023306042846/MOD17A2H.A2023297.h11v03.061.2023306042846.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h12v03.061.2023306042846/MOD17A2H.A2023297.h12v03.061.2023306042846.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h13v03.061.2023306042640/MOD17A2H.A2023297.h13v03.061.2023306042640.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h09v03.061.2023306041953/MOD17A2H.A2023297.h09v03.061.2023306041953.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023297.h20v01.061.2023306042627/MOD17A2H.A2023297.h20v01.061.2023306042627.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h12v05.061.2023314061347/MOD17A2H.A2023305.h12v05.061.2023314061347.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h13v03.061.2023314060912/MOD17A2H.A2023305.h13v03.061.2023314060912.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h10v03.061.2023314061115/MOD17A2H.A2023305.h10v03.061.2023314061115.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h09v06.061.2023314060911/MOD17A2H.A2023305.h09v06.061.2023314060911.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h09v03.061.2023314061303/MOD17A2H.A2023305.h09v03.061.2023314061303.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h08v04.061.2023314060926/MOD17A2H.A2023305.h08v04.061.2023314060926.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h09v05.061.2023314061316/MOD17A2H.A2023305.h09v05.061.2023314061316.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h12v03.061.2023314060928/MOD17A2H.A2023305.h12v03.061.2023314060928.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h20v01.061.2023314060907/MOD17A2H.A2023305.h20v01.061.2023314060907.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h08v05.061.2023314061309/MOD17A2H.A2023305.h08v05.061.2023314061309.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h13v04.061.2023314061602/MOD17A2H.A2023305.h13v04.061.2023314061602.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h07v05.061.2023314063504/MOD17A2H.A2023305.h07v05.061.2023314063504.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h10v06.061.2023314062731/MOD17A2H.A2023305.h10v06.061.2023314062731.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h07v06.061.2023314063938/MOD17A2H.A2023305.h07v06.061.2023314063938.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h11v03.061.2023314061758/MOD17A2H.A2023305.h11v03.061.2023314061758.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h11v04.061.2023314062743/MOD17A2H.A2023305.h11v04.061.2023314062743.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h09v04.061.2023314062744/MOD17A2H.A2023305.h09v04.061.2023314062744.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h10v05.061.2023314062357/MOD17A2H.A2023305.h10v05.061.2023314062357.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h11v06.061.2023314062734/MOD17A2H.A2023305.h11v06.061.2023314062734.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h12v04.061.2023314063947/MOD17A2H.A2023305.h12v04.061.2023314063947.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h08v06.061.2023314062154/MOD17A2H.A2023305.h08v06.061.2023314062154.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h11v05.061.2023314063141/MOD17A2H.A2023305.h11v05.061.2023314063141.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023305.h10v04.061.2023314061803/MOD17A2H.A2023305.h10v04.061.2023314061803.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h11v06.061.2023323034752/MOD17A2H.A2023313.h11v06.061.2023323034752.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h08v05.061.2023323034958/MOD17A2H.A2023313.h08v05.061.2023323034958.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h07v06.061.2023323034927/MOD17A2H.A2023313.h07v06.061.2023323034927.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h13v03.061.2023323035232/MOD17A2H.A2023313.h13v03.061.2023323035232.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h09v06.061.2023323035422/MOD17A2H.A2023313.h09v06.061.2023323035422.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h08v04.061.2023323035440/MOD17A2H.A2023313.h08v04.061.2023323035440.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h20v01.061.2023323040214/MOD17A2H.A2023313.h20v01.061.2023323040214.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h12v04.061.2023323040030/MOD17A2H.A2023313.h12v04.061.2023323040030.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h10v03.061.2023323040225/MOD17A2H.A2023313.h10v03.061.2023323040225.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h09v03.061.2023323040221/MOD17A2H.A2023313.h09v03.061.2023323040221.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h09v05.061.2023323040046/MOD17A2H.A2023313.h09v05.061.2023323040046.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h12v05.061.2023323040214/MOD17A2H.A2023313.h12v05.061.2023323040214.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h10v05.061.2023323040058/MOD17A2H.A2023313.h10v05.061.2023323040058.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h12v03.061.2023323040101/MOD17A2H.A2023313.h12v03.061.2023323040101.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h11v03.061.2023323040222/MOD17A2H.A2023313.h11v03.061.2023323040222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h11v04.061.2023323040226/MOD17A2H.A2023313.h11v04.061.2023323040226.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h10v04.061.2023323040233/MOD17A2H.A2023313.h10v04.061.2023323040233.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h13v04.061.2023323040216/MOD17A2H.A2023313.h13v04.061.2023323040216.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h11v05.061.2023323040229/MOD17A2H.A2023313.h11v05.061.2023323040229.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h09v04.061.2023323040454/MOD17A2H.A2023313.h09v04.061.2023323040454.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h07v05.061.2023323040449/MOD17A2H.A2023313.h07v05.061.2023323040449.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h08v06.061.2023323040646/MOD17A2H.A2023313.h08v06.061.2023323040646.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023313.h10v06.061.2023323040911/MOD17A2H.A2023313.h10v06.061.2023323040911.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h10v06.061.2023332044745/MOD17A2H.A2023321.h10v06.061.2023332044745.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h07v05.061.2023332044358/MOD17A2H.A2023321.h07v05.061.2023332044358.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h12v05.061.2023332045633/MOD17A2H.A2023321.h12v05.061.2023332045633.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h09v03.061.2023332045312/MOD17A2H.A2023321.h09v03.061.2023332045312.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h20v01.061.2023332045233/MOD17A2H.A2023321.h20v01.061.2023332045233.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h08v05.061.2023332045249/MOD17A2H.A2023321.h08v05.061.2023332045249.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h08v04.061.2023332050001/MOD17A2H.A2023321.h08v04.061.2023332050001.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h13v04.061.2023332045634/MOD17A2H.A2023321.h13v04.061.2023332045634.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h09v05.061.2023332045312/MOD17A2H.A2023321.h09v05.061.2023332045312.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h10v04.061.2023332045819/MOD17A2H.A2023321.h10v04.061.2023332045819.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h12v04.061.2023332045137/MOD17A2H.A2023321.h12v04.061.2023332045137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h11v04.061.2023332045134/MOD17A2H.A2023321.h11v04.061.2023332045134.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h10v05.061.2023332045510/MOD17A2H.A2023321.h10v05.061.2023332045510.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h07v06.061.2023332044552/MOD17A2H.A2023321.h07v06.061.2023332044552.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h08v06.061.2023332045300/MOD17A2H.A2023321.h08v06.061.2023332045300.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h13v03.061.2023332044733/MOD17A2H.A2023321.h13v03.061.2023332044733.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h09v04.061.2023332045248/MOD17A2H.A2023321.h09v04.061.2023332045248.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h10v03.061.2023332045249/MOD17A2H.A2023321.h10v03.061.2023332045249.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h11v05.061.2023332045338/MOD17A2H.A2023321.h11v05.061.2023332045338.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h12v03.061.2023332045253/MOD17A2H.A2023321.h12v03.061.2023332045253.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h11v03.061.2023332045309/MOD17A2H.A2023321.h11v03.061.2023332045309.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h11v06.061.2023332045239/MOD17A2H.A2023321.h11v06.061.2023332045239.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023321.h09v06.061.2023332044526/MOD17A2H.A2023321.h09v06.061.2023332044526.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h07v05.061.2023340064425/MOD17A2H.A2023329.h07v05.061.2023340064425.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h20v01.061.2023340070125/MOD17A2H.A2023329.h20v01.061.2023340070125.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h11v03.061.2023340064141/MOD17A2H.A2023329.h11v03.061.2023340064141.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h07v06.061.2023340064555/MOD17A2H.A2023329.h07v06.061.2023340064555.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h12v03.061.2023340064616/MOD17A2H.A2023329.h12v03.061.2023340064616.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h09v03.061.2023340064124/MOD17A2H.A2023329.h09v03.061.2023340064124.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h08v05.061.2023340064137/MOD17A2H.A2023329.h08v05.061.2023340064137.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h10v05.061.2023340065107/MOD17A2H.A2023329.h10v05.061.2023340065107.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h12v04.061.2023340064815/MOD17A2H.A2023329.h12v04.061.2023340064815.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h09v06.061.2023340065232/MOD17A2H.A2023329.h09v06.061.2023340065232.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h11v04.061.2023340065836/MOD17A2H.A2023329.h11v04.061.2023340065836.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h10v03.061.2023340070334/MOD17A2H.A2023329.h10v03.061.2023340070334.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h13v03.061.2023340064957/MOD17A2H.A2023329.h13v03.061.2023340064957.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h11v06.061.2023340064536/MOD17A2H.A2023329.h11v06.061.2023340064536.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h13v04.061.2023340065009/MOD17A2H.A2023329.h13v04.061.2023340065009.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h08v06.061.2023340064139/MOD17A2H.A2023329.h08v06.061.2023340064139.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h12v05.061.2023340064008/MOD17A2H.A2023329.h12v05.061.2023340064008.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h09v05.061.2023340065013/MOD17A2H.A2023329.h09v05.061.2023340065013.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h08v04.061.2023340064124/MOD17A2H.A2023329.h08v04.061.2023340064124.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h09v04.061.2023340065142/MOD17A2H.A2023329.h09v04.061.2023340065142.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h11v05.061.2023340065438/MOD17A2H.A2023329.h11v05.061.2023340065438.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h10v06.061.2023340064127/MOD17A2H.A2023329.h10v06.061.2023340064127.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023329.h10v04.061.2023340065329/MOD17A2H.A2023329.h10v04.061.2023340065329.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h20v01.061.2024003132914/MOD17A2H.A2023337.h20v01.061.2024003132914.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h07v06.061.2024003133535/MOD17A2H.A2023337.h07v06.061.2024003133535.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h09v03.061.2024003133601/MOD17A2H.A2023337.h09v03.061.2024003133601.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h09v06.061.2024003133614/MOD17A2H.A2023337.h09v06.061.2024003133614.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h11v06.061.2024003133831/MOD17A2H.A2023337.h11v06.061.2024003133831.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h08v05.061.2024003133925/MOD17A2H.A2023337.h08v05.061.2024003133925.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h10v06.061.2024003134304/MOD17A2H.A2023337.h10v06.061.2024003134304.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h07v05.061.2024003134922/MOD17A2H.A2023337.h07v05.061.2024003134922.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h11v05.061.2024003135213/MOD17A2H.A2023337.h11v05.061.2024003135213.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h11v04.061.2024003135139/MOD17A2H.A2023337.h11v04.061.2024003135139.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h10v05.061.2024003140906/MOD17A2H.A2023337.h10v05.061.2024003140906.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h10v04.061.2024003143052/MOD17A2H.A2023337.h10v04.061.2024003143052.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h10v03.061.2024003143522/MOD17A2H.A2023337.h10v03.061.2024003143522.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h11v03.061.2024003144842/MOD17A2H.A2023337.h11v03.061.2024003144842.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h13v04.061.2024003145231/MOD17A2H.A2023337.h13v04.061.2024003145231.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h12v04.061.2024003145416/MOD17A2H.A2023337.h12v04.061.2024003145416.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h08v04.061.2024003145708/MOD17A2H.A2023337.h08v04.061.2024003145708.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h12v05.061.2024003145759/MOD17A2H.A2023337.h12v05.061.2024003145759.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h08v06.061.2024003150523/MOD17A2H.A2023337.h08v06.061.2024003150523.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h13v03.061.2024003150753/MOD17A2H.A2023337.h13v03.061.2024003150753.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h09v04.061.2024003150958/MOD17A2H.A2023337.h09v04.061.2024003150958.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h09v05.061.2024003151117/MOD17A2H.A2023337.h09v05.061.2024003151117.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023337.h12v03.061.2024003195618/MOD17A2H.A2023337.h12v03.061.2024003195618.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h09v06.061.2024005164834/MOD17A2H.A2023345.h09v06.061.2024005164834.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h11v06.061.2024005170847/MOD17A2H.A2023345.h11v06.061.2024005170847.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h07v05.061.2024005171514/MOD17A2H.A2023345.h07v05.061.2024005171514.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h11v05.061.2024005171823/MOD17A2H.A2023345.h11v05.061.2024005171823.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h09v03.061.2024005172437/MOD17A2H.A2023345.h09v03.061.2024005172437.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h11v04.061.2024005172503/MOD17A2H.A2023345.h11v04.061.2024005172503.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h10v06.061.2024005173942/MOD17A2H.A2023345.h10v06.061.2024005173942.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h10v03.061.2024005175119/MOD17A2H.A2023345.h10v03.061.2024005175119.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h11v03.061.2024005175739/MOD17A2H.A2023345.h11v03.061.2024005175739.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h10v05.061.2024005180016/MOD17A2H.A2023345.h10v05.061.2024005180016.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h08v05.061.2024005175840/MOD17A2H.A2023345.h08v05.061.2024005175840.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h09v05.061.2024005180349/MOD17A2H.A2023345.h09v05.061.2024005180349.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h13v04.061.2024005182222/MOD17A2H.A2023345.h13v04.061.2024005182222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h12v04.061.2024005182510/MOD17A2H.A2023345.h12v04.061.2024005182510.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h13v03.061.2024005182924/MOD17A2H.A2023345.h13v03.061.2024005182924.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h10v04.061.2024005183228/MOD17A2H.A2023345.h10v04.061.2024005183228.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h08v04.061.2024005184208/MOD17A2H.A2023345.h08v04.061.2024005184208.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h07v06.061.2024005185042/MOD17A2H.A2023345.h07v06.061.2024005185042.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h12v05.061.2024005191809/MOD17A2H.A2023345.h12v05.061.2024005191809.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h08v06.061.2024005191558/MOD17A2H.A2023345.h08v06.061.2024005191558.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h09v04.061.2024005193800/MOD17A2H.A2023345.h09v04.061.2024005193800.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023345.h12v03.061.2024005211150/MOD17A2H.A2023345.h12v03.061.2024005211150.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h09v03.061.2024006032228/MOD17A2H.A2023353.h09v03.061.2024006032228.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h10v06.061.2024006032547/MOD17A2H.A2023353.h10v06.061.2024006032547.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h11v04.061.2024006032550/MOD17A2H.A2023353.h11v04.061.2024006032550.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h11v06.061.2024006033219/MOD17A2H.A2023353.h11v06.061.2024006033219.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h07v05.061.2024006033948/MOD17A2H.A2023353.h07v05.061.2024006033948.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h11v03.061.2024006034454/MOD17A2H.A2023353.h11v03.061.2024006034454.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h13v03.061.2024006034823/MOD17A2H.A2023353.h13v03.061.2024006034823.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h10v05.061.2024006034639/MOD17A2H.A2023353.h10v05.061.2024006034639.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h10v03.061.2024006035205/MOD17A2H.A2023353.h10v03.061.2024006035205.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h07v06.061.2024006035042/MOD17A2H.A2023353.h07v06.061.2024006035042.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h10v04.061.2024006035121/MOD17A2H.A2023353.h10v04.061.2024006035121.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h11v05.061.2024006034941/MOD17A2H.A2023353.h11v05.061.2024006034941.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h08v05.061.2024006035006/MOD17A2H.A2023353.h08v05.061.2024006035006.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h12v05.061.2024006035315/MOD17A2H.A2023353.h12v05.061.2024006035315.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h12v04.061.2024006040603/MOD17A2H.A2023353.h12v04.061.2024006040603.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h13v04.061.2024006041314/MOD17A2H.A2023353.h13v04.061.2024006041314.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h09v05.061.2024006043635/MOD17A2H.A2023353.h09v05.061.2024006043635.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h12v03.061.2024006045847/MOD17A2H.A2023353.h12v03.061.2024006045847.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h08v04.061.2024006045717/MOD17A2H.A2023353.h08v04.061.2024006045717.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h09v04.061.2024006050418/MOD17A2H.A2023353.h09v04.061.2024006050418.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h08v06.061.2024006050824/MOD17A2H.A2023353.h08v06.061.2024006050824.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023353.h09v06.061.2024006054228/MOD17A2H.A2023353.h09v06.061.2024006054228.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h07v05.061.2024006052658/MOD17A2H.A2023361.h07v05.061.2024006052658.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h11v06.061.2024006052921/MOD17A2H.A2023361.h11v06.061.2024006052921.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h11v03.061.2024006052944/MOD17A2H.A2023361.h11v03.061.2024006052944.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h09v03.061.2024006052650/MOD17A2H.A2023361.h09v03.061.2024006052650.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h10v05.061.2024006053042/MOD17A2H.A2023361.h10v05.061.2024006053042.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h08v05.061.2024006053426/MOD17A2H.A2023361.h08v05.061.2024006053426.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h09v04.061.2024006053432/MOD17A2H.A2023361.h09v04.061.2024006053432.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h08v04.061.2024006053842/MOD17A2H.A2023361.h08v04.061.2024006053842.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h13v04.061.2024006053539/MOD17A2H.A2023361.h13v04.061.2024006053539.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h10v03.061.2024006053954/MOD17A2H.A2023361.h10v03.061.2024006053954.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h12v05.061.2024006053543/MOD17A2H.A2023361.h12v05.061.2024006053543.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h08v06.061.2024006053915/MOD17A2H.A2023361.h08v06.061.2024006053915.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h09v05.061.2024006053825/MOD17A2H.A2023361.h09v05.061.2024006053825.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h12v03.061.2024006053916/MOD17A2H.A2023361.h12v03.061.2024006053916.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h13v03.061.2024006054226/MOD17A2H.A2023361.h13v03.061.2024006054226.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h07v06.061.2024006054456/MOD17A2H.A2023361.h07v06.061.2024006054456.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h10v06.061.2024006054710/MOD17A2H.A2023361.h10v06.061.2024006054710.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h10v04.061.2024006055304/MOD17A2H.A2023361.h10v04.061.2024006055304.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h09v06.061.2024006055948/MOD17A2H.A2023361.h09v06.061.2024006055948.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h11v05.061.2024006060222/MOD17A2H.A2023361.h11v05.061.2024006060222.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h11v04.061.2024006060950/MOD17A2H.A2023361.h11v04.061.2024006060950.hdf
https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/MOD17A2H.061/MOD17A2H.A2023361.h12v04.061.2024006060255/MOD17A2H.A2023361.h12v04.061.2024006060255.hdf
EDSCEOF
