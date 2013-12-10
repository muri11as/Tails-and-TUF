'''
Author: Toan Nguyen
Date: Nov 18, 2013
Description: This file will be called by the TargetFile/Download.pm
to actually download the *.iuk or *.iso from update server then downloaded
file will be piped into TargetFile/Download.pm
'''

import tuf.interposition
from tuf.interposition import urllib2_tuf as urllib2
import sys
url = sys.argv[1]
#tuf.log.add_console_handler()
config = tuf.interposition.configure("/usr/share/perl5/Tails/IUK/tuf.interposition_target.json")
try:
    response = urllib2.urlopen(url)
    print "HTTP/1.1",response.getcode(),"OK" #success
    print response.info() #then print the header
    print '\n' #separate between header and content
    tmpFilename = "/tmp/" + url.rsplit('/',1)[1] + ".tmp" 
    f = open(tmpFilename,'wb')
    f.write(response.read())
    f.close()
    print  tmpFilename #return filename of the target file downloaded by TUF
#Otherwise, return error code
except urllib2.HTTPError, e:
	print e.code
except urllib2.URLError, e:
	print e.args
finally:
    tuf.interposition.deconfigure(config)
