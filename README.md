# Tails-TUF Integration

This is the Tails Live OS Incremental Upgrade Kit (IUK) with TUF integrated.  To install clone this github to your Tails Live OS system.

###1. Navigate to the Demo directory in a terminal window:
   ```shell
   sudo sh setup.sh
   ```

   This script will unzip the binaries for TUF and the Perl/Python bridge.  You will be asked for the sudo password twice to unzip the tar files.

###2. Navigate to the Perl-Python directory:
   ```shell
   sudo sh setup.sh
   ```

   This will patch the current IUK files with the modified ones to work with TUF.

###3. Run the update system:
   ```shell
   tails-update-frontend
   ```

   This will execute the Tails IUK Updater.