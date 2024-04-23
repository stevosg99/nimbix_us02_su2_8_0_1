#! /bin/bash

sleep 10

# Compile SU2 on the main node in the session
echo "Compiling SU2"
/usr/local/SU2/init/compile_SU2.sh

echo "Changing to /data/SU2 directory to begin data processing."

cd /data/SU2

# Provide permission to run bash file in /data directory
sudo chmod -R 0777 /data/SU2

# Get bash filename from session initialization
while [[ -n "$1" ]]; do
    case "$1" in
	-file)
	    shift
        BASH_FILE="$1"
		;;
	esac
    shift
done

# Call the bash file
source "$BASH_FILE"
