#! /bin/bash

# Symlink python directories
sudo ln -s /usr/bin/python3 /usr/bin/python

# Ensure the current working directory
initdir=/usr/local/SU2
cd $initdir
git clone --branch v8.0.1 https://github.com/su2code/SU2.git
wkdir=/usr/local/SU2/SU2
cd $wkdir

# The next block was added due to compilation issues with CoDi, MeDi, Meson, Ninja, and Mutationpp
#sudo rm -r $wkdir/externals/codi
#sudo rm -r $wkdir/externals/medi
#sudo rm -r $wkdir/externals/meson
#sudo rm -r $wkdir/externals/ninja
#sudo rm -r $wkdir/subprojects/Mutationpp
#sudo mkdir $wkdir/externals/codi
#sudo mkdir $wkdir/externals/medi
#sudo mkdir $wkdir/externals/meson
#sudo mkdir $wkdir/externals/ninja
#sudo mkdir $wkdir/subprojects/Mutationpp

# Set the initial environmental variables
export MPICC=/usr/bin/mpicc
export MPICXX=/usr/bin/mpicxx
export CC=$MPICC
export CXX=$MPICXX
export CXXFLAGS="-O2 -funroll-loops -march=native -mtune=native"

# Set the appropriate flags for the desired install options
flags="-Dwith-mpi=enabled -Denable-autodiff=true -Denable-directdiff=true -Denable-mixedprec=true"

# Compile and verify the above flags compiled correctly
build_counter=0

while [ "$build_counter" -le 3 ]; do

	# Keep track of the build attempts to prevent an infinite loop
	((build_counter++))
			
	# Create a directory for meson
	sudo mkdir -p $wkdir/build
	sudo chown -R root:root $wkdir
	sudo chmod -R 0777 $wkdir
	
	# Compile with meson
	# (note that meson adds 'bin' to the --prefix directory during build)
	sudo ./meson.py build $flags --prefix=$initdir/install | tee -a build_log.txt

	# Set environmental variables from meson build
	export SU2_DATA=/data/SU2
	export SU2_HOME=/usr/local/SU2/SU2
	export SU2_RUN=/usr/local/SU2/install/bin
	export PATH=$PATH:$SU2_RUN
	export PYTHONPATH=$PYTHONPATH:$SU2_RUN
	# Set environmental variable to allow multi-node use
	export SU2_MPI_COMMAND="mpirun --hostfile /etc/JARVICE/nodes -np %i %s"

	# Install with ninja
	sudo ./ninja -C build install
	
	build_counter=10
	
	break
	
done

if [ $build_counter -eq 4 ]; then

	# Exit the script if build unsuccessful
	echo "Unable to correctly compile SU2 after 3 attempts."
	exit 1

elif [ $build_counter -eq 10 ]; then

    echo "SU2 successfully compiled."
	
fi

# Record a ready status
touch /tmp/node_ready_status.txt
