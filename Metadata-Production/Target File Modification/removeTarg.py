'''

AUTHOR: CESAR MURILLAS
DESCRIPTION: THIS SCRIPT WILL REMOVE TARGETS ROLE METADATA TO MAKE ROOM FOR NEW
USAGE: run python removeTargs.py path/to/targetconfig.txt

'''

from tuf.libtuf import *
import os 

repoName,rkeystore,keystore = '','',''
rootpwd,targetspwd,releasepwd,timestamppwd = '','','',''

try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file"
	sys.exit(1)
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "REPONAME":
		repoName = liss[1].strip()
		
	elif liss[0] == "ROOTKEYSTORE":
		rkeystore = liss[1].strip()
	
	elif liss[0] == "KEYSTORE":
		keystore = liss[1].strip()
			
	elif liss[0] == "ROOTPASSWORD":
		rootpwd = liss[1].strip()
		
	elif liss[0] == "TARGETPASSWORD":
		targetspwd = liss[1].strip()
		
	elif liss[0] == "RELEASEPASSWORD":
		releasepwd = liss[1].strip()
		
	elif liss[0] == "TIMESTAMPPASSWORD":
		timestamppwd = liss[1].strip()
		
filey.close()
channel = sys.argv[2]
repository = load_repository(repoName)

#REMOVE ALL TARGETS
repository.targets.revoke(channel)


#IMPORT SIGNING KEYS
private_root_key = import_rsa_privatekey_from_file(rkeystore+"root_key",password=rootpwd)
private_timestamp_key = import_rsa_privatekey_from_file(keystore+"timestamp",password=timestamppwd)
private_release_key = import_rsa_privatekey_from_file(keystore+"release",password=releasepwd)
private_targets_key = import_rsa_privatekey_from_file(keystore+"targets",password=targetspwd)

#LOAD SIGNING KEYS
repository.root.load_signing_key(private_root_key)
repository.targets.load_signing_key(private_targets_key)
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)

#NEW VERSIONS OF METADATA
repository.write()