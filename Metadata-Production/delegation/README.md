### The files in this directory are deprecated.

These Scripts are to be used to produce TUF metadata offline, and then uploaded/copied to the TUF server.

To generate a new Repository:
  
  Run: generateMetadata.py
    **Remember to store your Root Private Key(s) somewhere OFFLINE.**

To add target files to the metadata:

  Run: addtargs.py
    **Remember to have the files you want inside of the "Targets/" folder before running this script**
    
To make a "Live" copy of your metadata after production is finished:

  Run: copyToRepository.py
    **This is used to create a final copy of your metadata and you can then upload to your TUF server**

Our TUF Metadata is relatively small and efficient. It contains our updates.yml (Update Description File) as a target, as well as the
Target files (either IUK, or full ISO) and the URL's from where they can be downloaded. 
