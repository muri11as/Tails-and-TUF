import urllib2
import sys
url = sys.argv[1]
try:
    response = urllib2.urlopen(url)
    print "HTTP/1.1",response.getcode(),"OK"
    print response.info()
    print response.read()
except urllib2.HTTPError, e:
	print e.code
except urllib2.URLError, e:
	print e.args
