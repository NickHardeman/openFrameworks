#!/bin/bash
# set -ev
ROOT=${TRAVIS_BUILD_DIR:-"$( cd "$(dirname "$0")/../../.." ; pwd -P )"}

# if [ "$OPT" == "qbs" ]; then
	# exit 0
# else

echo "##[group]**** Running unit tests ****"
cd $ROOT/tests
for group in *; do
	if [ -d $group ]; then
		echo "##[group] $group"
		for test in $group/*; do
			if [ -d $test ]; then
				cd $test
				cp ../../../scripts/templates/linux/Makefile .
				cp ../../../scripts/templates/linux/config.make .
				make -j2 Debug
				cd bin
				binname=$(basename ${test})
				#gdb -batch -ex "run" -ex "bt" -ex "q \$_exitcode" ./${binname}_debug
				./${binname}_debug
				errorcode=$?
				if [[ $errorcode -ne 0 ]]; then
					exit $errorcode
				fi
				cd $ROOT/tests
			fi
		done
		echo "##[endgroup]"
	fi
done
# fi
echo "##[endgroup]"
