'''
Author: Cesar Murillas
CS9163
Key Creation
'''

from tuf.libtuf import *

##PARSE CONFIG FILE FOR ROOTPATH, PATH AND PASSWORD
rootpath,path,pword = '','',''

filey = open("/Users/Ceeze/Desktop/keyconfig.txt",'r')
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "ROOTKEYSTORE":
		rootpath = liss[1].strip()
	elif liss[0] == "KEYSTORE":
		path = liss[1].strip()
	elif liss[0] == "PASSWORD":
		pword = liss[1].strip()
filey.close()	 
##CREATE AND STORE ROOT RSA KEY PAIR

generate_and_write_rsa_keypair(rootpath+"root_key",bits=3072,password=pword)

##CREATE AND STORE TIMESTAMP, RELEASE, && TARGETS PUBLIC && PRIVATE KEYS

generate_and_write_rsa_keypair(path+"timestamp",bits=3072,password=pword)
generate_and_write_rsa_keypair(path+"release",bits=3072,password=pword)
generate_and_write_rsa_keypair(path+"targets",bits=3072,password=pword)
