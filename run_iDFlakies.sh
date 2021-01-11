#!/bin/bash

SCRIPTDIR="$(pwd)"
TOOL_REPO="iDFlakies"

git rev-parse HEAD

date

cd $SCRIPTDIR
RESULTSDIR=$SCRIPTDIR/output/
mkdir -p ${RESULTSDIR}

# This script is run for single experiment (one project)
# Should only be invoked by the run_iDFlakies.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - SHA of the SLUG"
    echo "arg3 - Module of the SLUG"
    echo "arg4 - Timeout in seconds"
    exit
fi

slug=$1
sha=$2
module=$3
timeout=$4

modifiedslug=$(echo ${slug} | sed 's;/;.;' | tr '[:upper:]' '[:lower:]')
short_sha=${sha:0:7}
modifiedslug_with_sha="${modifiedslug}-${short_sha}"

# Set global mvn options for skipping things
MVNOPTIONS="-Ddependency-check.skip=true -Dgpg.skip=true -DfailIfNoTests=false -Dskip.installnodenpm -Dskip.npm -Dskip.yarn -Dlicense.skip -Dcheckstyle.skip -Drat.skip -Denforcer.skip -Danimal.sniffer.skip -Dmaven.javadoc.skip -Dfindbugs.skip -Dwarbucks.skip -Dmodernizer.skip -Dimpsort.skip -Dmdep.analyze.skip -Dpgpverify.skip -Dxml.skip -Dcobertura.skip=true -Dfindbugs.skip=true"

# Clone the testing project
bash $SCRIPTDIR/clone-project.sh "$slug" "$sha"
cd $SCRIPTDIR/$slug

if [[ -z $module ]]; then
    echo "================ Missing module. Exiting now!"
    exit 1
else
    echo "Module passed from the flags."
fi
echo "Location of module: $module"

# echo "================Installing the project"
bash $SCRIPT_USERNAME/install-project.sh "$slug" "$MVNOPTIONS" "$module"
ret=${PIPESTATUS[0]}

mv mvn-install.log ${RESULTSDIR}/${modifiedslug_with_sha}-mvn-install.log

if [[ $ret != 0 ]]; then
    # mvn install does not compile - return 0
    echo "Compilation failed. Actual: $ret"
    exit 1
fi

# Incorporate tooling into the project, using Java XML parsing
cd $SCRIPT_USERNAME/${slug}
sh $SCRIPT_USERNAME/$TOOL_REPO/modify-project.sh .

# Run the plugin, get module test times
echo "*******************iDFLAKIES************************"
echo "Running testplugin for getting module test time"
date

# Optional timeout... In practice our tools really shouldn't need 1hr to parse a project's surefire reports.
timeout ${timeout}s mvn testrunner:testplugin -Ddetector.detector_type=random-class-method -Ddt.randomize.rounds=10 -Ddt.detector.original_order.all_must_pass=false |& tee ${modifiedslug_with_sha}-module_test_time.log

mv *.log ${RESULTSDIR}/

echo "*******************iDFLAKIES************************"
echo "Finished run_iDFlakies.sh"
date