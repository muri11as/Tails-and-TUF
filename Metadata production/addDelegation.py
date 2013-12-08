'''
AUTHOR: CESAR MURILLAS
CS9163
DESCRIPTION: SCRIPT TO ADD A DELEGATED ROLE TO TUF METADATA
USAGE: RUN addDelegation.py path/to/delconfig.txt
'''
from tuf.libtuf import *

##GENERATE KEYS (TEMPORARILY DOING HERE, WOULD NORMALLY BE DONE IN keyconfig.txt/generateKeyStore.py)

##PARSE CONFIG FILE FOR ROOTPATH, PATH AND PASSWORD
repoName,role,path,delpwd = '','','',''


try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file!"
	sys.exit(1)
	
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "REPO":
		repoName = liss[1].strip()
	elif liss[0] == "ROLENAME":
		role = liss[1].strip()
	elif liss[0] == "PATHTODELKEY":
		path = liss[1].strip()
	elif liss[0] == "DELPASSWORD":
		delpwd = liss[1].strip()
filey.close()
r = path+role
#LOAD REPOSITORY
repository = load_repository(repoName)

#GENERATE KEYS
generate_and_write_rsa_keypair(r, bits=3072,password=delpwd)

#IMPORT
public_del_key = import_rsa_publickey_from_file(r+".pub")
private_del_key = import_rsa_privatekey_from_file(r,password=delpwd)
private_targets_key = import_rsa_privatekey_from_file(path+"targets",password="target!gogreen")
private_release_key = import_rsa_privatekey_from_file(path+"release",password="release#gogreen")
private_timestamp_key = import_rsa_privatekey_from_file(path+"timestamp",password="time$gogreen")
private_root_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/rootkeys/root_key/root_key",password="root@gogreen")
#ADD
repository.targets.delegate(role,[public_del_key], [])
repository.targets.stable.add_target("/Users/Ceeze/Desktop/tuf/targets/Tails_i386_0.21_to_0.22.iuk")

#LOAD
repository.root.load_signing_key(private_root_key)
repository.targets.load_signing_key(private_targets_key)
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.stable.load_signing_key(private_del_key)

#WRITE OUT
repository.write()
