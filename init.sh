
#! /bin/bash

sleep 10

# Check connection to each node
node_count=$(wc -l < "/etc/JARVICE/nodes")
echo "$node_count node(s) in session."
nodes_connected=1
SECONDS=0
while [ "$nodes_connected" -lt "$node_count" ]; do
	if [ "$SECONDS" -gt 60 ]; then
	    echo "At least one node has not connected."
		echo "Exiting..."
		exit 1
	fi
	sleep 5s
    for node in $(cat /etc/JARVICE/nodes); do   
        if [ "$node" != "$HOSTNAME" ]; then
            echo "Checking connection to $node"
            status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$node" echo ok 2>&1)
			if [ "$status" == ok ]; then
			    echo "$node connection established."
				((nodes_connected++))
			else
				echo "$node not connected. Retrying..."
			fi
        fi
    done
done

# Ensure key environmental variables are set
export SU2_DATA=/opt/SU2
export SU2_HOME=/opt/SU2
export SU2_RUN=/opt/SU2/SU2/bin
export PATH=$PATH:$SU2_RUN
export PYTHONPATH=$PYTHONPATH:$SU2_RUN
# Set environmental variable to allow multi-node use
export SU2_MPI_COMMAND="mpirun --hostfile /etc/JARVICE/nodes -np %i %s"

echo "All nodes initialized."
echo "Changing to /data/SU2 directory to begin data processing."

cd /data/SU2

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
cd $(dirname $BASH_FILE)
chmod +x "$BASH_FILE" 