#!/bin/bash

SCRIPT_USERNAME="lichengpeng/test/scripts"
TOOL_REPO="iDFlakies"

git rev-parse HEAD

date

cd /home/$SCRIPT_USERNAME

# This script is run for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ] || [[ $4 == "" ] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - SHA of the SLUG"
    echo "arg3 - Module of the SLUG"
    echo "arg4 - Number of rounds"
    echo "arg5 - Timeout in seconds"
    exit
fi

slug=$1
sha=$2
module=$3
rounds=$4
timeout=$5

RESULTSDIR=/home/$SCRIPT_USERNAME/output/
mkdir -p ${RESULTSDIR}

# Set global mvn options for skipping things
MVNOPTIONS="-Ddependency-check.skip=true -Dgpg.skip=true -DfailIfNoTests=false -Dskip.installnodenpm -Dskip.npm -Dskip.yarn -Dlicense.skip -Dcheckstyle.skip -Drat.skip -Denforcer.skip -Danimal.sniffer.skip -Dmaven.javadoc.skip -Dfindbugs.skip -Dwarbucks.skip -Dmodernizer.skip -Dimpsort.skip -Dmdep.analyze.skip -Dpgpverify.skip -Dxml.skip -Dcobertura.skip=true -Dfindbugs.skip=true"
IDF_OPTIONS="-Ddt.detector.original_order.all_must_pass=false -Ddetector.timeout=${timeout} -Ddt.randomize.rounds=${rounds} -fn -B -e -Ddt.cache.absolute.path=/home/lichengpeng/test/all-output/${modifiedslug}_output"

iDFlakiesVersion=1.2.0-SNAPSHOT

# Setup prolog stuff
./home/$SCRIPT_USERNAME/setup

# Clone the testing project
bash /home/$SCRIPT_USERNAME/clone-project.sh "$slug" "$sha"

# echo "================Installing the project"
bash /home/$SCRIPT_USERNAME/install-project.sh "$slug" "$MVNOPTIONS" "$USER" "$module" "$sha" "$dir" "$fullTestName" "${RESULTSDIR}"
ret=${PIPESTATUS[0]}
mv mvn-install.log ${RESULTSDIR}
if [[ $ret != 0 ]]; then
    # mvn install does not compile - return 0
    echo "Compilation failed. Actual: $ret"
    exit 1
fi

# echo "================Running maven test"
if [[ "$slug" == "dropwizard/dropwizard" ]]; then
    # dropwizard module complains about missing dependency if one uses -pl for some modules. e.g., ./dropwizard-logging
    MVNOPTIONS="${MVNOPTIONS} -am"
elif [[ "$slug" == "fhoeben/hsac-fitnesse-fixtures" ]]; then
    MVNOPTIONS="${MVNOPTIONS} -DskipITs"
fi

# Incorporate tooling into the project, using Java XML parsing
cd "/home/$SCRIPT_USERNAME/${slug}"
/home/$SCRIPT_USERNAME/$TOOL_REPO/pom-modify/modify-project.sh . $iDFlakiesVersion

# Run the plugin, get module test times
echo "*******************iDFLAKIES************************"
echo "Running testplugin for getting module test time"
date

modifiedslug=$(echo ${slug} | sed 's;/;.;' | tr '[:upper:]' '[:lower:]')

# Optional timeout... In practice our tools really shouldn't need 1hr to parse a project's surefire reports.
timeout ${timeout}s mvn testrunner:testplugin ${MVNOPTIONS} ${IDF_OPTIONS} -pl $module -Ddetector.detector_type=original |& tee module_test_time.log

# Gather the results, put them up top
/home/$SCRIPT_USERNAME/gather-results $(pwd) ${RESULTSDIR}
mv *.log ${RESULTSDIR}/

echo "*******************iDFLAKIES************************"
echo "Finished run_project.sh"
date

