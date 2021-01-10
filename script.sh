slug=$1
sha=$2
module=$3
rounds=$4
timeout=$5

sh run_iDFlakies.sh $slug $sha $module $rounds $timeout
sh run_iFixFlakies.sh $slug $sha $module $rounds $timeout