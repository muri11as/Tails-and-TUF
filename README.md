# Tails-TUF Integration

This is the Tails Live OS Incremental Upgrade Kit (IUK) with TUF integrated.  To install clone this github to your Tails Live OS system.

###1. Log into Tails with More Options:

   On the Tails startup screen, you must select YES to More options, to be able to enter a root password.  You will need this password later when installing the TUF files.

###2. Clone this repository:

   When Tails has finished loading, open up a terminal window and type the command to clone this git repository.

   ```shell
   git clone https://github.com/muri11as/Tails-and-TUF
   ```

###3. Navigate to the Demo directory inside the Tails-and-TUF folder and run setup in a terminal window:
   ```shell
   cd Tails-and-TUF/Demo
   sudo sh setup.sh
   ```

   This script will unzip the binaries for TUF and the Perl/Python bridge.  You will be asked for the sudo password to unzip the tar files. It will then patch the current IUK files with the modified ones to work with TUF.

###4. Run the update system:
   ```shell
   tails-update-frontend
   ```

   This will execute the Tails IUK Updater.  Periodically TOR will prevent the updater from working, after several attempts it should work.

For more detailed information regarding the following, please refer to the corresponding links provided:
   - Integration of TUF with Tails IUK update system (https://github.com/muri11as/Tails-and-TUF/wiki)
   - Tails OS (https://tails.boum.org)
   - TUF - The Update Framework (https://updateframework.com/projects/project)
