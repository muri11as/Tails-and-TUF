'''
Author: Cesar Murillas
CS9163
Modified: Toan Nguyen
Description: Key creation script. Will be used for first-time creation 
of TUF keys or after revocation
Run: python generateKeyStore.py path/to/keyconfig.txt
'''
import sys
from tuf.libtuf import *

##PARSE CONFIG FILE FOR ROOTPATH, PATH AND PASSWORDS
rootpath,path = '',''
rootpwd,targetpwd,releasepwd,timestamppwd ='','','',''
del1pwd,del2pwd,del3pwd = '','',''

try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file!"
	sys.exit(1)
	
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "ROOTKEYSTORE":
		rootpath = liss[1].strip()
		
	elif liss[0] == "KEYSTORE":
		path = liss[1].strip()
		
	elif liss[0] == "ROOTPASSWORD":
		rootpwd = liss[1].strip()
		
	elif liss[0] == "TARGETPASSWORD":
		targetpwd = liss[1].strip()
		
	elif liss[0] == "RELEASEPASSWORD":
		releasepwd = liss[1].strip()
		
	elif liss[0] == "TIMESTAMPPASSWORD":
		timestamppwd = liss[1].strip()
		
	elif liss[0] == "STABLEPASSWORD":
		del1pwd = liss[1].strip()
		
	elif liss[0] == "BETAPASSWORD":
		del2pwd = liss[1].strip()
		
	elif liss[0] == "NIGHTLYPASSWORD":
		del3pwd = liss[1].strip()
		
filey.close()	
 
##CREATE AND STORE ROOT RSA KEY PAIR
generate_and_write_rsa_keypair(rootpath+"root_key",bits=3072,password=rootpwd)

##CREATE AND STORE TIMESTAMP, RELEASE, TARGETS && ITS DELEGATES' PUBLIC && PRIVATE KEY PAIRS
generate_and_write_rsa_keypair(path+"timestamp",bits=3072,password=timestamppwd)
generate_and_write_rsa_keypair(path+"release",bits=3072,password=releasepwd)
generate_and_write_rsa_keypair(path+"targets",bits=3072,password=targetpwd)
generate_and_write_rsa_keypair(path+"stable", bits=3072,password=del1pwd)
generate_and_write_rsa_keypair(path+"beta", bits=3072,password=del2pwd)
generate_and_write_rsa_keypair(path+"nightly", bits=3072,password=del3pwd)

print "Key Generation Completed..."