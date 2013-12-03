There are two ways of creating metadata for TUF included in these instructions.
The first way is automatically, the second is manually.

TO RUN ALL SCRIPTS TO CREATE NEW METADATA AUTOMATICALLY

**WARNING** ALL CONFIGURATION FILES ARE DESIGNED WITH VARIABLE=YOURINPUT, DO NOT CHANGE FORMAT!!

	1. Download all files into a folder of your choosing
	2. Open all config.txt files
		setupconfig.txt
		keyconfig.txt
		repoconfig.txt
		targetconfig.txt
	3. Setup all of your config files to your preference
	4. MAKE SURE ALL FILES IN THIS FOLDER REMAIN IN THE SAME FOLDER:
		SETUPCONFIG.TXT:
			
			PATHTODIRECTORY
			PATHTOTARGETS
			OLDTARGETSPATH
			OLDREPO
			LIVEREPO	
		
			-Change PATHTODIRECTORY: To your current directory where this folder is. Make sure all of the included files are present. *WILL NOT WORK IF THE CONFIG FILES ARE NOT IN THE SAME DIRECTORY AS THE SCRIPTS**
			-Change PATHTOTARGETS: To the targets folder you want to fill your repository targets folder with. EX: you have your target files in a "model" targets folder elsewhere on your machine. You want this targets folder to contain your target files. This targets folder will replace the one created by the automated script. 
			-Change OLDTARGETSPATH: To your current repository/targets folder. Example: users/home/tuf/targets
			-Change OLDREPO: To path/to/repo/metadata.staged
			-Change LIVEREPO: To path/to/repo/metadata (This will be your "live" and finalized metadata for your server)
	5. Change the remaining fields in the other config.txt files to suit your needs.
		KEYCONFIG.TXT:
			ROOTKEYSTORE: Should be the path to where you want to store your RSA rootkey pair.
			KEYSTORE: Should be the path to where you want to store the other non rootkey pairs.
			ROOTPASSWORD: Password for your root role.
			TARGETPASSWORD: Password for your targets role.
			RELEASEPASSWORD: Password for your release role.
			TIMESTAMPPASSWORD: Password for your timestamp role.
		REPOCONFIG.TXT:
			ROOTKEY: Path to your rootkey.
			REPONAME: Path to your repository.
			KEYSTORE: Path to where your non rootkeys are stored, same ad in keyconfig.txt.
			ROOTPASSWORD: Same as in keyconfig.txt. 
			TARGETPASSWORD: Same as in keyconfig.txt. 
			RELEASEPASSWORD: Same as in keyconfig.txt. 
			TIMESTAMPPASSWORD: Same as in keyconfig.txt. 
			ROOTTHRESH: Threshold for root role.
			TIMESTAMPTHRESH: Threshold for timestap role.
			RELEASETHRESH: Threshold for release role.
			TARGETSTHRESH: Threshold for targets role.
			TIMESTAMPEXP: Expiration date and time for Timestamp Role in: YYYY-MM-DD HH:MM:SS format.
		TARGETCONFIG.TXT:
			REPONAME: Path to your repository, same as in repoconfig.txt.
			KEYSTORE: Path to where your non rootkeys are stored, same as in repoconfig.txt && keyconfig.txt.
			TARGETPASSWORD: Same as in repoconfig.txt && keyconfig.txt.
			RELEASEPASSWORD: Same as in repoconfig.txt && keyconfig.txt.
			TIMESTAMPPASSWORD: Same as in repoconfig.txt && keyconfig.txt.
	6. Run setup.py
		"python setup.py /path/to/setupconfig.txt"


INDIVIDUAL SCRIPT INSTRUCTIONS:

These Scripts are to be used to produce TUF metadata offline, and then uploaded/copied to the TUF server.

	To generate new keys:
		Run generateKeyStore.py 
			python generateKeystore.py path/to/keyconfig.txt
		NOTE: Use Above instructions to setup your keyconfig.txt file.


	To generate a new Repository:
  
		Run generateMetadata.py
			python generateMetadata.py path/to/repoconfig.txt
		Remember to store your Root Private Key(s) somewhere OFFLINE.
		NOTE: Use Above instructions to setup your repoconfig.txt file.

    
	To make a "Live" copy of your metadata after production is finished:

		Run copyToRepository.py
			python copyToRepository.py path/to/copyconfig.txt
    This is used to create a final copy of your metadata and you can then upload to your TUF server
    	-Change copyconfig.txt 
			COPYCONFIG.TXT:
				PATHTO.STAGED: Where your metadata.staged foler is located.
				PATHTOLIVE: Where you want your live metadata folder to go (server?).

Our TUF Metadata is relatively small and efficient. It contains our updates.yml (Update Description File) as a target, as well as the
Target files (either IUK, or full ISO) and the URL's from where they can be downloaded. 
