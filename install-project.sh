slug=$1
MVNOPTIONS=$2
module=$3

echo "================Installing the project"
mvn clean install -am -pl $module -DskipTests ${MVNOPTIONS} |& tee mvn-install.log

ret=${PIPESTATUS[0]}
exit $ret