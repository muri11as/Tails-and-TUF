'''

AUTHOR: CESAR MURILLAS
DESCRIPTION: THIS SCRIPT WILL ADD TARGET FILES TO TARGETS ROLE METADATA
USAGE: run python addtargs.py path/to/targetsconfig.txt

'''

from tuf.libtuf import *
import os 

repo,keystore = '',''
targetspwd,releasepwd,timestamppwd = '','',''

try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file"
	sys.exit(1)
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "REPONAME":
		repoName = liss[1].strip()
		
	elif liss[0] == "KEYSTORE":
		keystore = liss[1].strip()
		
	elif liss[0] == "TARGETPASSWORD":
		targetspwd = liss[1].strip()
		
	elif liss[0] == "RELEASEPASSWORD":
		releasepwd = liss[1].strip()
		
	elif liss[0] == "TIMESTAMPPASSWORD":
		timestamppwd = liss[1].strip()

##ADD TARGET FILES
'''Make sure the target files are saved in the targets directory of the repository'''
repository = load_repository(repo)
#Get list of file all file paths

list_of_targets = repository.get_filepaths_in_directory(repo+"targets", recursive_walk=True, followlinks=True)

#Add List of target files to the targets metadata

for targ in tList:
	repository.targets.add_target(targ)

#IMPORT SIGNING KEYS
private_timestamp_key = import_rsa_privatekey_from_file(keystore+"timestamp",password=timestamppwd)
private_release_key = import_rsa_privatekey_from_file(keystore+"release",password=releasepwd)
private_targets_key = import_rsa_privatekey_from_file(keystore+"targets",password=targetspwd)

#LOAD SIGNING KEYS

repository.targets.load_signing_key(private_targets_key)
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)

#NEW VERSIONS OF METADATA

repository.write()