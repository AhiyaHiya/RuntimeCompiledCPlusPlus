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
	printf "${FUNCNAME[0]}\n"
	
	CONFIG=$1
	CURRENTPATH=${PWD}
	cd ${ABSOLUTE_PATH}
	BUILDPATH=${PWD}/xcbuild
	cd ../..
	BASEPATH=${PWD}
}


BuildFrameworks()
{
	printf "${FUNCNAME[0]}\n"
	
	local projectsPath=$1
	cd ${projectsPath}/Renderer
	local frameworkBuildPath=${BUILDPATH}/Products/${CONFIG}/Frameworks
	BuildXcodeProjectForTarget Renderer.xcodeproj Renderer ${CONFIG} ${frameworkBuildPath}
		
	cd ${projectsPath}/RuntimeCompiler
	BuildXcodeProjectForTarget RuntimeCompiler.xcodeproj RuntimeCompiler ${CONFIG} ${frameworkBuildPath}

	cd ${projectsPath}/RuntimeObjectSystem
	BuildXcodeProjectForTarget RuntimeObjectSystem.xcodeproj RuntimeObjectSystem ${CONFIG} ${frameworkBuildPath}

	cd ${projectsPath}/Systems
	BuildXcodeProjectForTarget Systems.xcodeproj Systems ${CONFIG} ${frameworkBuildPath}
	
	cd ${projectsPath}/External/libRocket/Build
	BuildXcodeProjectForTarget Rocket.xcodeproj RocketControlsOSX ${CONFIG} ${frameworkBuildPath}
	BuildXcodeProjectForTarget Rocket.xcodeproj RocketDebuggerOSX ${CONFIG} ${frameworkBuildPath}
}

CopyFrameworksAndLibs()
{
	printf "${FUNCNAME[0]}\n"
	
	cd ${ABSOLUTE_PATH}
	cp -R ${BUILDPATH}/Products/${CONFIG}/Frameworks ${BUILDPATH}/Products/${CONFIG}/SimpleTest.app/Contents/Frameworks
}
