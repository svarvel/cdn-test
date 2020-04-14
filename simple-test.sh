#!/bin/bash
## Author: Matteo Varvello (varvello@brave.com)
## Date: 04-14-2020
## NOTE: Tool to test Brave's private-VPN solution and compare with Fastly in the wild

# simple function for logging
DEBUG=1
myprint(){
    timestamp=`date +%s`
    if [ $DEBUG -gt 0 ]
    then
        if [ $# -eq  0 ]
        then
            echo -e "[ERROR][$timestamp]\tMissing string to log!!!"
        else
            if [ $# -eq  1 ]
            then 
                echo -e "[$0][$timestamp]\t" $1
            else 
                echo -e "[$0][$timestamp][$2]\t" $1
            fi 
        fi
    fi
}

# generate data to be POSTed to my server 
generate_post_data(){
  cat <<EOF
	{
	"uid":"$uid",
	"test_label": "$label", 
	"file_size":"$file_size",
	"cache_hit":"$cache_hit",
	"x-served-by":"$x_served",
	"age":"${age}",
	"type":"${type}",
	"code":"${code}",
	"remoteIP":"${remoteIP}",
	"download_speed":"${download_speed}",
	"t_dns":"${t_dns}",
	"t_connect":"${t_connect}",
	"t_appconnect":"${t_appconnect}",
	"t_pretransfer":"${t_pretransfer}",
	"t_redirect":"${t_redirect}",
	"t_starttransfer":"${t_starttransfer}",
	"t_total":"${t_total}",
	"size_download":"${size_downloadl}",
	"size_download":"${size_header}"
	}
EOF
}



# helper function to test a download 
test_download(){
	# params
	MAX_DURATION=120
	UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36"
	out_file="5Mb.gz"	
	dst=$1
	label=$2

	# curl download 
	myprint "[CURL] Destination: $dst Label: $label"
	timeout $MAX_DURATION curl -v -H "Accept-Encoding: gzip" -H 'user-agent: $UA' -w "@curl-format.txt" -s $dst -o $out_file > ".stats"  2>".headers"
	curl_stats=`cat ".stats"`
	type=`cat ".stats" | cut -f 1 | cut -f 2 -d ":"`
	code=`cat ".stats" | cut -f 2 | cut -f 2 -d ":"`
	remoteIP=`cat ".stats" | cut -f 3 | cut -f 2 -d ":"`
	download_speed=`cat ".stats" | cut -f 4 | cut -f 2 -d ":"`
	t_dns=`cat ".stats" | cut -f 5 | cut -f 2 -d ":"`
	t_connect=`cat ".stats" | cut -f 6 | cut -f 2 -d ":"`
	t_appconnect=`cat ".stats" | cut -f 7 | cut -f 2 -d ":"`
	t_pretransfer=`cat ".stats" | cut -f 8 | cut -f 2 -d ":"`
	t_redirect=`cat ".stats" | cut -f 9 | cut -f 2 -d ":"`
	t_starttransfer=`cat ".stats" | cut -f 10 | cut -f 2 -d ":"`
	t_total=`cat ".stats" | cut -f 11 | cut -f 2 -d ":"`
	size_download=`cat ".stats" | cut -f 12 | cut -f 2 -d ":"`
	size_header=`cat ".stats" | cut -f 13 | cut -f 2 -d ":"`
	
	# check return code 
	cache_hit="N/A" 
	x_served="N/A"
	age="N/A"
	if [ -f ".headers" ] 
	then 
		x_served=`cat ".headers" | grep "x-served-by" | awk '{print $NF}' | sed 's/\\r//g'`
		age=`cat ".headers" | grep "age:" | awk '{print $NF}' | sed 's/\\r//g'`
		cat ".headers" | grep "HIT" > /dev/null
		if [ $? -eq 0 ] 
		then 
			cache_hit="True"
		else 
			cache_hit="False"
		fi 
	fi 

	# logging 
	t_end=`date +%s`
	let "t_passed = t_end - t_start"
	file_size=`stat $out_file | grep "Size"  | cut -f 1 | cut -f 2 -d ":"`
	myprint "File size:$file_size\tCache-HIT:$cache_hit\tX-served-by:$x_served\tAge:$age"
	rm $out_file 

	# report to Matteo's server in NJ
	uid=`date +%s`
	curl  -H "Content-Type:application/json" -X POST -d "$(generate_post_data)" https://nj.batterylab.dev:8080/dCURL
}

# test direct download via Fastly (and report results)
test_download "https://fastly-dev.brave.info/5mb" "fastly"

# test private-vpn download (and report results)
test_download "https://cloudflare1-dev.brave.info/5mb" "cloudflare-fastly"

# test direct download via Fastly (and report results)
test_download "https://fastly-dev.brave.info/5mb" "fastly-cached"
