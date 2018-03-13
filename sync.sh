#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  sync.sh
#
#         USAGE:  sync.sh [-a, --all] [-f, --files] [--only-env-files]"
#
#   DESCRIPTION:  Uses rsync to push and syncronize local sdpsoft directory
#                 to all remote RGS Statoil servers.
#
#       OPTIONS:  -a --all -f --files --only-env-files
#  REQUIREMENTS:  run as spdadm on vmm03.prod.sdp.ststoil.no in /data/sdpsoft
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Stig O. M. Ofstad, stoo@statoil.com
#       COMPANY:  Statoil
#       VERSION:  1.0
#       CREATED:  ti. 13. mars 12:32:27 +0100 2018
#      REVISION:  ---
#===============================================================================
PROGRAMNAME=$(basename $0)
cd /home/stoo/Gitlab/script/
#cd $(dirname $0)
# SDPSOFT_REMOTE_DIR="/prog/sdpsoft/"
SDPSOFT_REMOTE_DIR="/private/stoo/syncTest/"
SERVERS=(
  root@test01.dev.sdp.statoil.no
  #st-vcris01.st.statoil.no
)

# Print usage info if none or an invalid argument is given.
function usage {
    echo "usage: $PROGRAMNAME [-a, --all] [-i, --include] [--only-env-files]"
    echo -e "      -f, --files           Only sync these files. Example: \"./sync.sh --files python2.7.14 tmux-10.7\""
    echo "      -a, --all             Sync all files"
    echo "      --only-env-files      Only sync 'the env.sh' and 'env.csh' files"
    echo "   requires atleast one argument"
    exit 1
}

if [ "$1" = "--only-env-files" ]; then
    for server in ${SERVERS[@]}; do
        echo " SYNCING to $server"
        rsync -va --include="env.sh" --include="env.csh" --exclude="*" . $server:$SDPSOFT_REMOTE_DIR
    done
elif [ "$1" = "-a" ] || [ "$1" = "--all" ]; then
    for server in ${SERVERS[@]}; do
        echo " SYNCING to $server"
        # Sync the updated environment-files last to avoid putting the updated
        # software in limbo while the new version is syncing
        rsync -va --exclude-from=".gitignore" --exclude="env.sh" --exclude="env.csh" . $server:$SDPSOFT_REMOTE_DIR
        rsync -va --include="env.sh" --include="env.csh" --exclude="*" . $server:$SDPSOFT_REMOTE_DIR
    done
elif [ "$1" = "-f" ] || [ "$1" = "--files" ]; then
    # Shift the $@ parameters. $2 becomes $1. To omit '--files'.
    shift 1
    for server in ${SERVERS[@]}; do
        echo " SYNCING to $server"
        for file in "$@"; do
            rsync -va $file $server:$SDPSOFT_REMOTE_DIR
        done
    done
else
    usage
fi

