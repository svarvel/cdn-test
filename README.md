# Summary
Tool to test content retrieval over CDNs in the wild

# Requirements
OS: MacOS/Linux  (tested on Mojave and Raspbian/Ubuntu)

software: curl (https://curl.haxx.se/)


# What does it do and collect? 
The script simply fetches a file 3 times: 1) directly from source CDN, 2) via a CDN chain, 3) directly from source CDN (last time guarantees it was cached). At the end of each download, the tool reports to https://nj.batterylab.dev stats on the download performance (encrypted) via a POST. A random UID is generated (just an epoch timestamp) and reported. The server logs the IP address used to report for geolocation purposed - matching with cache identifier also reported. For example: 

```
{'x-served-by': 'cache-ewr18128-EWR', 'uid': '1586881806', 't_connect': '0.017205 sec', 'srcIP': '192.168.1.1', 'age': '2711', 'file_size_on_disk': '5242880', 't_appconnect': '0.057772 sec', 't_dns': '0.004713 sec', 'size_download': '5242880 Bytes', 'code': '200', 't_total': '0.553598 sec', 'remoteIP': '151.101.210.217', 'download_speed': '9470554.000 Bps', 'cache_hit': 'True', 'size_header': '481 Bytes', 'test_label': 'fastly-cached', 't_pretransfer': '0.058361 sec', 'type': 'binary/octet-stream', 't_redirect': '0.000000 sec', 't_starttransfer': '0.067278 sec'}
```

# Instructions
```
git clone git@github.com:svarvel/cdn-test.git
cd cdn-test
./simple-test.sh
```

