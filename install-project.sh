slug=$1
MVNOPTIONS=$2
USER=$3
module=$4
sha=$5
dir=$6
fullTestName=$7
RESULTSDIR=$8

modifiedslug=$(echo ${slug} | sed 's;/;.;' | tr '[:upper:]' '[:lower:]')
short_sha=${sha:0:7}
modifiedslug_with_sha="${modifiedslug}-${short_sha}"

echo "================Installing the project"
mvn clean install -am -pl $module -DskipTests ${MVNOPTIONS} |& tee mvn-install.log

ret=${PIPESTATUS[0]}
exit $ret