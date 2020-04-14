# cdn-test
Tool to test content retrieval in the wild

# What does it do and collect? 
The script simple-test.sh will simply fetch a file 3 times: 1) directly from source CDN, 2) via a CDN chain, 3) directly from source CDN (last time guarantees it was cached). At the end of each download, the tool reports to https://nj.batterylab.dev stats on the download performance (encrypted) via a POST. A random UID is generated (just an epoch timestamp) and reported. The server logs the IP address used to report for geolocation purposed - matching with cache identifier also reported

# instructions
git clone git@github.com:svarvel/cdn-test.git
cd cdn-test
./simple-test.sh


