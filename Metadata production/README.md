There are two ways of creating metadata for TUF included in these instructions.
		
		I. Automatically
		II. Manually.

**AUTOMATICALLY**
	
	TO RUN ALL SCRIPTS TO CREATE NEW METADATA AUTOMATICALLY
	**WARNING** ALL CONFIGURATION FILES ARE DESIGNED WITH VARIABLE=YOURINPUT, DO NOT CHANGE FORMAT!!
		
	As a prerequesite, you need to install the TUF REPOSITORY TOOLS:
		To Install, in a shell run the following:				
			$ virtualenv --no-site-packages (Pick a name)
			$ source (Name you picked)/bin/activate
			$ pip install --upgrade https://github.com/theupdateframework/tuf/archive/repository-tools.zip
	
	Source: https://docs.google.com/document/d/1n-4G8cfuGMCBwXDgkj52DuBhRG5Di6YW9p8IaH-fIxc/edit?pli=1#
========================================================================================================================	
	1. Download all files into a folder of your choosing
		**After downloading, place all files in the Config Files folder, in the same folder as the scripts.
	2. Open all config.txt files
		-setupconfig.txt
		-keyconfig.txt
		-repoconfig.txt
		-targetconfig.txt
	3. Setup all of your config files to your preference
	4. MAKE SURE ALL FILES IN THIS FOLDER REMAIN IN THE SAME FOLDER:
		SETUPCONFIG.TXT:
			PATHTODIRECTORY
			PATHTOTARGETS
			REPO
			OLDREPO
			LIVEREPO	
			-Change PATHTODIRECTORY: To your current directory where this folder is.
						Make sure all of the included files are present.
						**WILL NOT WORK IF THE CONFIG FILES ARE NOT IN THE SAME DIRECTORY AS THE SCRIPTS**
			-Change PATHTOTARGETS: To the targets folder you want to fill your repository targets folder with.
						EX: you have your target files in a "model" targets folder elsewhere on your machine.
						You want this targets folder to contain your target files. 
						This targets folder will replace the one created by the automated script. 
			-Change REPO: To your current path/to/repository folder. Example: users/home/tuf/
				**INCLUDE THE / at the end**

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
			KEYSTORE: Path to where your non rootkeys are stored, same as in keyconfig.txt.
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
========================================================================================================================
**MANUALLY**

INDIVIDUAL SCRIPT INSTRUCTIONS:

These Scripts are to be used to produce TUF metadata offline, and then uploaded/copied to the TUF server.

	To generate new keys:
		Run generateKeyStore.py 
			python generateKeystore.py path/to/keyconfig.txt
		NOTE: Use Above instructions to setup your keyconfig.txt file.
========================================================================================================================
	To generate a new Repository:
		Run generateMetadata.py
			python generateMetadata.py path/to/repoconfig.txt
		Remember to store your Root Private Key(s) somewhere OFFLINE.
		NOTE: Use Above instructions to setup your repoconfig.txt file.
========================================================================================================================  
	To make a "Live" copy of your metadata after production is finished:
		-Change copyconfig.txt 
			COPYCONFIG.TXT:
				PATHTO.STAGED: Where your metadata.staged foler is located.
				PATHTOLIVE: Where you want your live metadata folder to go (server?).
		Run copyToRepository.py
			python copyToRepository.py path/to/copyconfig.txt
    		This is used to create a final copy of your metadata and you can then upload to your TUF server.   		
========================================================================================================================
	To add a Delegation:
		-Change delconfig.txt
			DELCONFIG.TXT:
				REPO: Where your repository is.
				ROLENAME: What you want to name your new delegated role.
				PATHTODELKEY: Path to where you want to save your new key for this role.
				DELPASSWORD: Password for your new role.
		Run addDelegation.py
			python addDelegation.py path/to/delconfig.txt
			This is used to create a new delegated role for your TUF Metadata.
========================================================================================================================

Our TUF Metadata is relatively small and efficient. It contains our updates.yml (Update Description File) as a target, as well as the
Target files (either IUK, or full ISO) and the URL's from where they can be downloaded. 
