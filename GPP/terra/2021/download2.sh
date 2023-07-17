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
    echo "https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2020.12.26/MOD17A2H.A2020361.h12v03.006.2021004040305.hdf"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 5 --netrc-file "$netrc" https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2020.12.26/MOD17A2H.A2020361.h12v03.006.2021004040305.hdf -w '\n%{http_code}' | tail  -1`
    if [ "$approved" -ne "200" ] && [ "$approved" -ne "301" ] && [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w '\n%{http_code}' https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2020.12.26/MOD17A2H.A2020361.h12v03.006.2021004040305.hdf | tail -1)
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
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h09v03.006.2021010043549.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h08v04.006.2021010043549.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h08v05.006.2021010043852.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h12v03.006.2021010043851.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h11v06.006.2021010043839.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h07v05.006.2021010043841.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h07v06.006.2021010043840.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h13v04.006.2021010043553.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h10v04.006.2021010044201.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h13v03.006.2021010043848.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h11v05.006.2021010043848.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h09v06.006.2021010044148.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h09v05.006.2021010044155.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h11v03.006.2021010043847.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h10v05.006.2021010044200.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h12v05.006.2021010044143.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h09v04.006.2021010043849.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h12v04.006.2021010043849.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h10v03.006.2021010043843.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h08v06.006.2021010043849.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h11v04.006.2021010043852.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.01/MOD17A2H.A2021001.h10v06.006.2021010043842.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h11v04.006.2021018043115.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h09v03.006.2021018043107.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h07v05.006.2021018043409.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h07v06.006.2021018043409.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h11v05.006.2021018043413.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h13v03.006.2021018043415.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h12v03.006.2021018043416.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h10v03.006.2021018043413.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h10v04.006.2021018043801.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h08v05.006.2021018043421.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h08v06.006.2021018043753.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h08v04.006.2021018043746.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h11v03.006.2021018043420.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h09v06.006.2021018043414.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h11v06.006.2021018043741.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h10v06.006.2021018043410.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h10v05.006.2021018043802.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h13v04.006.2021018043412.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h09v04.006.2021018043415.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h12v04.006.2021018043414.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h09v05.006.2021018044950.hdf
https://e4ftl01.cr.usgs.gov//DP133/MOLT/MOD17A2H.006/2021.01.09/MOD17A2H.A2021009.h12v05.006.2021018044942.hdf
EDSCEOF
