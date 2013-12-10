**Creating TUF Metadata**
========================================================================================================================

TUF Metadata for Tails has been created with three delegated roles in mind.
* Stable
* Beta
* Nightly

The stable channel is currently the only one being implemented in Tails, so we have placed our focus on that channel.
We have, however, implemented the other two delegated roles in anticipation of these future channels.

## First time Metadata Generation
	
###1. Download the TUF Repository Tools

To create a new repository, you will need to generate all the initial metadata files.  Enter the following shell commands to download the TUF Repository Tools.

```shell
virtualenv --no-site-packages (Pick a name)
source (Name you picked)/bin/activate
pip install --upgrade https://github.com/theupdateframework/tuf/archive/repository-tools.zip
```

Source: https://docs.google.com/document/d/1n-4G8cfuGMCBwXDgkj52DuBhRG5Di6YW9p8IaH-fIxc/edit?pli=1#

###2. Clone this repository and navigate to the Metadata-Production folder

You may skip this step if you have already cloned this repo.  Otherwise enter the following command in a shell.

```shell
git clone https://github.com/muri11as/Tails-and-TUF
```

###3. Edit the configuration files

Inside the Config Files directory, open the following configuration files, and make the changes according to your environment.

* setupconfig.txt
* keyconfig.txt
* repoconfig.txt
* targetconfig.txt

You may do step 4 first, then move on to this step if you do not want to keep a fresh copy of the configuration files.  The configuration files should be self explanatory, however, more details on each configuration file and its associated variables is available in the wiki.

###4. Copy the configuration files to the Metadata-Production directory

This will copy all the configuration files in the Config Files directory to the Metadata-Production directory (one level up)

```shell
sh copyfiles.sh
```

###5. Run the setup

In a terminal run the following command to begin generating the initial metadata for your TUF repository.  The metadata will be generated in the location specified in the setupconfig.txt

```shell
python setup.py setupconfig.txt
```


**MANUALLY**

INDIVIDUAL SCRIPT INSTRUCTIONS:

This section is desgined in guiding you when you want to edit a piece of the repository and not generate a whole new one, you would use these scripts.
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

**CHANGING TARGET FILE METADATA**

	In the event that metadata needs to be updated to accomodate a change in the appropriate channel(delegated role), the following instructions should be followed:

	1. All of the files in the Target File Modification Folder should be in the same directory as the configuration files and other scripts.
	2. Set up the two configuration files:
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
