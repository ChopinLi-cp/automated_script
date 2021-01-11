SCRIPTDIR="$(pwd)"

slug=$1
sha=$2
module=$3
timeout=$4

cd $SCRIPTDIR
sh run_iDFlakies.sh $slug $sha $module $timeout

cd $SCRIPTDIR
sh run_iFixFlakies.sh $slug $sha $module $timeout