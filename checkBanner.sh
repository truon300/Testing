#!/bin/bash

# We'll need to make this a list of all URLs instead of just this one
vUrls=https://services.econ.census.gov/aaswrapper/ssologin.php?surl=https://sso.econ.census.gov/dashboard/&eurl=https://sso.econ.census.gov/dashboard/&title=DASHBOARD

# Each line is a value in the array.  Each will be checked if it's in the response body
declare -a vStrings=(
"You are accessing"
"all devices and storage media"
"understand and consent to the following"
"unauthorized use of the system is prohibited"
"you have no reasonable expectation of privacy"
"regarding any communication or data transiting"
"Government may monitor, intercept, audit, and search and seize"
"may contain Controlled Unclassified Information"
"accordance with law, regulation, or Government-wide policy"
)

# "for" loops to go through each URL specified in "vUrls" (which is not technically a list at the moment)
for url in $vUrls; do
  #Declare "vResult" and assign '0' as value.  Each string not found will add '1' so we know it was missing
  vResult=0
  #Get response and parse to almost just lower-case text (though the '-i' in grep command below makes it a bit redundant)
  vResponse=$(curl $url | sed 's-<\/\?[^>]\+>--g' | awk '{$1=$1};1' | sed '/^[[:space:]]*$/d')

  # "for" loop to check if each string in "vStrings" can be found in the body
  for string in "${vStrings[@]}"; do
    grep -i "$string" <<< $vResponse > /dev/null
    # If string found, "vResult + 0", if not, "vResult + 1"
    vResult=$(($vResult+$?))
  done

  # Echo ratio of missing results vs total num of strings checked (TODO: Probably remove)
  echo "Missing $vResult out of ${#vStrings[@]} lines"
  vTotal=${#vStrings[@]}  # Assign array count to variable for readable caclulations below
  # Send "results/total * 100) to calc (-l to handle decimals) then only keep number left of dec.
  vPercentMissing=$(echo $vResult \/ $vTotal \* 100 | bc -l | cut -d . -f 1)
  echo "${vPercentMissing}% missing"  # echo % missing (TODO: Probably remove)
  vPercentFound=$((100-vPercentMissing))  # Calculate diff to find % found
  echo "${vPercentFound}% found"  # echo % found
done
