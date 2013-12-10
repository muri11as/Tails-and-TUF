'''

AUTHOR: CESAR MURILLAS
DESCRIPTION: THIS SCRIPT WILL ADD TARGET FILES TO TARGETS ROLE METADATA
USAGE: run python addToStable.py path/to/swaptargetconfig.txt channel channelpassword

'''

from tuf.libtuf import *
import os 

repoName,rkeystore,keystore, updatePath = '','','',''
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
	
	elif liss[0] == "TARGETSTRUCTURE":
		updatePath = liss[1].strip()
		
	elif liss[0] == "TARGETPASSWORD":
		targetspwd = liss[1].strip()
		
	elif liss[0] == "RELEASEPASSWORD":
		releasepwd = liss[1].strip()
		
	elif liss[0] == "TIMESTAMPPASSWORD":
		timestamppwd = liss[1].strip()
		
filey.close()

#ADD TARGET FILES
channel = sys.argv[2]
del1pwd = sys.argv[3]
repository = load_repository(repoName)

#GET LIST OF ALL TARGET FILES
sList = repository.get_filepaths_in_directory(repoName+updatePath+channel, recursive_walk=True, followlinks=True)

#IMPORT DELEGATE PUBLIC KEY
public_del1_key = import_rsa_publickey_from_file(keystore+channel+".pub")

#IMPORT SIGNING KEYS
private_del1_key = import_rsa_privatekey_from_file(keystore+channel,password=del1pwd)
private_root_key = import_rsa_privatekey_from_file(rkeystore+"root_key",password=rootpwd)
private_timestamp_key = import_rsa_privatekey_from_file(keystore+"timestamp",password=timestamppwd)
private_release_key = import_rsa_privatekey_from_file(keystore+"release",password=releasepwd)
private_targets_key = import_rsa_privatekey_from_file(keystore+"targets",password=targetspwd)

#ADD DELEGATE
repository.targets.delegate(channel,[public_del1_key], sList)
repository.targets.stable.version = repository.targets.version+1

#LOAD SIGNING KEYS
repository.targets.stable.load_signing_key(private_del1_key)
repository.root.load_signing_key(private_root_key)
repository.targets.load_signing_key(private_targets_key)
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)

#NEW VERSIONS OF METADATA
repository.write()