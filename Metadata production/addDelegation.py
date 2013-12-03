'''
AUTHOR: CESAR MURILLAS
CS9163
DESCRIPTION: SCRIPT TO ADD A DELEGATED ROLE TO TUF METADATA
USAGE: RUN addDelegation.py path/to/delconfig.txt
'''
from tuf.libtuf import *

##GENERATE KEY (TEMPORARILY DOING HERE, WOULD NORMALLY BE DONE IN keyconfig.txt/generateKeyStore.py)

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
	
#LOAD REPOSITORY
repository = load_repository(repoName)

#GENERATE KEYS
generate_and_write_rsa_keypair(path, bits=3072,password=delpwd)

#IMPORT
public_del_key = import_rsa_publickey_from_file(path+".pub")
private_del_key = import_rsa_privatekey_from_file(path,password=delpwd)

#ADD
repository.targets.delegate(role,[public_del_key], [])

#LOAD
repository.role.load_signing_key(private_del_key)

#WRITE OUT
repository.write()
