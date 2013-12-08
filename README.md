# Tails-TUF Integration

This is the Tails Live OS Incremental Upgrade Kit (IUK) with TUF integrated.  To install clone this github to your Tails Live OS system.

###1. Log into Tails with More Options:

   On the Tails startup screen, you must select YES to More options, to be able to enter a root password.  You will need this password later when installing the TUF files.

###2. Navigate to the Demo directory in a terminal window:
   ```shell
   sudo sh setup.sh
   ```

   This script will unzip the binaries for TUF and the Perl/Python bridge.  You will be asked for the sudo password to unzip the tar files. It will then patch the current IUK files with the modified ones to work with TUF.

###3. Run the update system:
   ```shell
   tails-update-frontend
   ```

   This will execute the Tails IUK Updater.  Periodically TOR will prevent the updater from working, after several attempts it should work.

For more detailed information regarding the following, please refer to the corresponding links provided:
   - Integration of TUF with Tails IUK update system (https://github.com/muri11as/Tails-and-TUF/wiki)
   - Tails OS (https://tails.boum.org)
   - TUF - The Update Framework (https://updateframework.com/projects/project)
