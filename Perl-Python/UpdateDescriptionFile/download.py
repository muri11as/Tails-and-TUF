'''
Author: Toan Nguyen
Date: Nov 18, 2013
Description: This file will be called by the UpdateDescriptionFile/Download.pm
to actually download the updates.yml from update server then the return
file will be piped into UpdateDescriptionFile/Download.pm
'''
import tuf.interposition
from tuf.interposition import urllib2_tuf as urllib2
import sys
url = sys.argv[1] #url to download from
tufconfig = tuf.interposition.configure("/usr/share/perl5/Tails/IUK/tuf.interposition_meta.json")
try:
    response = urllib2.urlopen(url)
    print "HTTP/1.1",response.getcode(),"OK" #success
    print response.info() #then print the header
    print '\n'  #separate between header and content
    print response.read() #and the content of updates.yml
#Otherwise, return error code
except urllib2.HTTPError, e:
	print e.code
except urllib2.URLError, e:
	print e.args
finally:
	tuf.interposition.deconfigure(tufconfig)
