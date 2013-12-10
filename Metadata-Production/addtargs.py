'''

AUTHOR: CESAR MURILLAS
DESCRIPTION: THIS SCRIPT WILL ADD TARGET FILES TO TARGETS ROLE METADATA
USAGE: run python addtargs.py path/to/targetsconfig.txt

'''

from tuf.libtuf import *
import os 

repoName,rkeystore,keystore = '','',''
rootpwd,targetspwd,releasepwd,timestamppwd = '','','',''
del1pwd,del2pwd,del3pwd = '','',''

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

	elif liss[0] == "STABLEPASSWORD":
		del1pwd = liss[1].strip()
		
	elif liss[0] == "BETAPASSWORD":
		del2pwd = liss[1].strip()
		
	elif liss[0] == "NIGHTLYPASSWORD":
		del3pwd = liss[1].strip()
		
filey.close()

##ADD TARGET FILES
'''Make sure the target files are saved in the targets directory of the repository'''
repository = load_repository(repoName)

#Get list of file all file paths
sList = repository.get_filepaths_in_directory(repoName+"targets/stable", recursive_walk=True, followlinks=True)
bList = repository.get_filepaths_in_directory(repoName+"targets/beta", recursive_walk=True, followlinks=True)
nList = repository.get_filepaths_in_directory(repoName+"targets/nightly", recursive_walk=True, followlinks=True)

#IMPORT DELEGATES' PUBLIC KEYS
public_del1_key = import_rsa_publickey_from_file(keystore+"stable.pub")
public_del2_key = import_rsa_publickey_from_file(keystore+"beta.pub")
public_del3_key = import_rsa_publickey_from_file(keystore+"nightly.pub")

#IMPORT SIGNING KEYS
private_del1_key = import_rsa_privatekey_from_file(keystore+"stable",password=del1pwd)
private_del2_key = import_rsa_privatekey_from_file(keystore+"beta",password=del2pwd)
private_del3_key = import_rsa_privatekey_from_file(keystore+"nightly",password=del3pwd)
private_root_key = import_rsa_privatekey_from_file(rkeystore+"root_key",password=rootpwd)
private_timestamp_key = import_rsa_privatekey_from_file(keystore+"timestamp",password=timestamppwd)
private_release_key = import_rsa_privatekey_from_file(keystore+"release",password=releasepwd)
private_targets_key = import_rsa_privatekey_from_file(keystore+"targets",password=targetspwd)

#DELEGATE
repository.targets.delegate("stable",[public_del1_key], sList)
repository.targets.stable.version = repository.targets.version+1
repository.targets.stable.expiration = "2014-06-20 12:00:00"

repository.targets.delegate("beta",[public_del2_key], bList)
repository.targets.beta.version = repository.targets.version+1
repository.targets.beta.expiration = "2014-06-20 12:00:00"

repository.targets.delegate("nightly",[public_del3_key], nList)
repository.targets.nightly.version = repository.targets.version+1
repository.targets.nightly.expiration = "2014-06-20 12:00:00"

#LOAD SIGNING KEYS
repository.targets.stable.load_signing_key(private_del1_key)
repository.targets.beta.load_signing_key(private_del2_key)
repository.targets.nightly.load_signing_key(private_del3_key)
repository.root.load_signing_key(private_root_key)
repository.targets.load_signing_key(private_targets_key)
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)

#NEW VERSIONS OF METADATA
repository.write()