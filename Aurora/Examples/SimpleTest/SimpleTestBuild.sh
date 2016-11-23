set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

BuildXcodeProjectForTarget()
{
	printf "${FUNCNAME[0]}\n"
	
	local projectName=$1
	local targetName=$2
	local config=$3
	local configPath=$4

	xcodebuild \
		-project ${projectName} \
		-target ${targetName} \
			-configuration ${config} \
			CONFIGURATION_BUILD_DIR=${configPath} \
			clean build | xcpretty
	# if you want to use egrep instead of xcpretty
	#| egrep -A 5 "(error|warning):"
}

SetupVariables()
{
	CONFIG=$1
	CURRENTPATH=${PWD}
	cd ${ABSOLUTE_PATH}
	BUILDPATH=${PWD}/xcbuild
	cd ../..
	BASEPATH=${PWD}
}


BuildFrameworks()
{
	cd ${BASEPATH}/Renderer
	local frameworkBuildPath=${BUILDPATH}/Products/${CONFIG}/Frameworks
	BuildXcodeProjectForTarget Renderer.xcodeproj Renderer ${CONFIG} ${frameworkBuildPath}
		
	cd ${BASEPATH}/RuntimeCompiler
	BuildXcodeProjectForTarget RuntimeCompiler.xcodeproj RuntimeCompiler ${CONFIG} ${frameworkBuildPath}

	cd ${BASEPATH}/RuntimeObjectSystem
	BuildXcodeProjectForTarget RuntimeObjectSystem.xcodeproj RuntimeObjectSystem ${CONFIG} ${frameworkBuildPath}

	cd ${BASEPATH}/Systems
	BuildXcodeProjectForTarget Systems.xcodeproj Systems ${CONFIG} ${frameworkBuildPath}
	
	cd ${BASEPATH}/External/libRocket/Build
	BuildXcodeProjectForTarget Rocket.xcodeproj RocketControlsOSX ${CONFIG} ${frameworkBuildPath}
	BuildXcodeProjectForTarget Rocket.xcodeproj RocketDebuggerOSX ${CONFIG} ${frameworkBuildPath}
}

CopyFrameworksAndLibs()
{
	cd ${ABSOLUTE_PATH}
	cp -R ${BUILDPATH}/Products/${CONFIG}/Frameworks ${BUILDPATH}/Products/${CONFIG}/SimpleTest.app/Contents/Frameworks
}
