TUF Metadata for Tails has been created with three delegated roles in mind.

	I. STABLE
	II. BETA
	III. NIGHTLY

The stable channel is currently the only one being implemented in Tails, so our focus is on that. We have still implemented the other two delegated roles in anticipation of future efforts.


The three channels represent different methods to download updates, specifically differing in the amount of time in between each update. Stable, beta, and nightly is the order of these channels, with stable having the least frequent updates, and nightly the most.



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
		**After downloading, place all files in the Config Files folder and Target File Modification folder in the same folder as all the other scripts.**
		HAVE ALL SCRIPTS AND CONFIG.TXT FILES IN THE SAME PLACE
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
			STABLEPASSWORD: Password for Tails specific delegated role "stable".
			BETAPASSWORD: Password for Tails specific delegated role "beta".
			NIGHTLYPASSWORD: Password for Tails specific delegated role "nightly".
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
			ROOTKEYSTORE: Path to where your rootkey is stored EX: /users/name/Desktop/rootkeys/rootkey
			KEYSTORE: Path to where your non rootkeys are stored, same as in repoconfig.txt && keyconfig.txt.
			TARGETSTRUCTURE: Path to your update structure, starting with targets/ EX: targets/update/v1/Tails/0.21/i386/
			ROOTPASSWORD: same as in repoconfig.txt && keyconfig.txt.
			TARGETPASSWORD: Same as in repoconfig.txt && keyconfig.txt.
			RELEASEPASSWORD: Same as in repoconfig.txt && keyconfig.txt.
			TIMESTAMPPASSWORD: Same as in repoconfig.txt && keyconfig.txt.
			STABLEPASSWORD: Same as in keyconfig.txt.
			BETAPASSWORD: Same as in keyconfig.txt.
			NIGHTLYPASSWORD: Same as in keyconfig.txt
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
				PATHTO.STAGED: Where your metadata.staged folder is located.
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
				ROOTKEYSTORE: Path to where your rootkey is stored EX: path/to/rootkey
				ROOTPASSWORD: Password for root role.
				TARGETPASSWORD: Password for targets role.
				RELEASEPASSWORD: Password for release role.
				TIMESTAMPPASSWORD: Password for timestamp role.
		Run addDelegation.py
			python addDelegation.py path/to/delconfig.txt
			This is used to create a new delegated role for your TUF Metadata.
========================================================================================================================

In the event that metadata needs to be updated to accomodate a change in the appropriate channel(delegated role), the following instructions should be followed:

	1. All of the files in the Target File Modification Folder should be in the same directory as the configuration files and other scripts.
	2. Set up the configuration file:
		SWAPCONFIG.TXT:
			CHANNEL: The delegated role which you wish to modify targets for: stable, beta, or nightly.
			CHANNELKEYPASSWORD: Password for the delegated role.
			PATHTODIRECTORY: Path to the current working directory which includes all of the scipts & configuration files. EX: /Users/name/Desktop/
			Include the / at the end.
			PATHTOTARGETS: Path to directory where the new files are located. EX: /Users/name/Desktop/newtargs
			REPO: Path to your TUF repository. EX: path/to/repository/ Include the / at the end.
			TARGETSTRUCTURE: Path to the new structure: EX: targets/update/v1/Tails/0.22/i386/ follow this structure. Start with targets/ and end with a / after build.
		SWAPTARGETCONFIG.TXT:
			REPONAME: Same as in targetconfig.txt.
			ROOTKEYSTORE: Same as in targetconfig.txt.
			KEYSTORE: Same as in targetconfig.txt.
			TARGETSTRUCTURE: Must be same as in SWAPCONFIG.TXT  EX: targets/update/v1/Tails/0.22/i386/
			ROOTPASSWORD: Same as in targetconfig.txt.
			TARGETPASSWORD: Same as in targetconfig.txt.
			RELEASEPASSWORD:Same as in targetconfig.txt.
			TIMESTAMPPASSWORD: Same as in targetconfig.txt.
		This will automatically be utilized in the editTargs.py script. Make sure it is configured correctly.
	3. Run editTargs.py
		python editTargs.py path/to/swapconfig.txt
		This will effectively add new target files to the TUF metadata for the specified channel you inputed. This script calls removeTarg.py and the script to add target files to whatever channel (delegated role) you picked. 
========================================================================================================================


Our TUF Metadata is relatively small and efficient. It contains our updates.yml (Update Description File) as a target, as well as the
Target files (either IUK, or full ISO) and the URL's from where they can be downloaded. 
