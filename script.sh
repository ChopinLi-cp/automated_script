SCRIPTDIR="$(pwd)"

slug=$1
sha=$2
module=$3
rounds=$4
timeout=$5

cd $SCRIPTDIR
sh run_iDFlakies.sh $slug $sha $module $rounds $timeout

cd $SCRIPTDIR
sh run_iFixFlakies.sh $slug $sha $module $rounds $timeout