import urllib2
import sys
url = sys.argv[1]
response = urllib2.urlopen(url)
print response.getcode()
print response.info()
print response.read()
