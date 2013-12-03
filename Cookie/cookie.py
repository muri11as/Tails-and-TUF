# Author: Dominic Spinosa
#
# This script will generate a cookie based on the hash of
# the aggregate TUF metadata. The cookie will be given to
# each connected user and upon any metadata change, a new
# cookie will be sent out. If the user is currently connected
# to the server and/or downloading an update, he/she will be
# prompted after the download is stopped.
