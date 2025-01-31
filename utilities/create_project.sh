#!/bin/bash

# This script sets up a new project. To use it, first create a new directory where you want the project to be located. Then, run this script and give it the path to that directory, for example: $ ./create_project.sh projects/myProject.

if [ "$#" == 0 ] || [ "${2}" == "--help" ]; then
    echo "Usage: $0 [path] '[plugins]'";
    echo "";
    echo "[path] = Path to project directory.";
    echo "[plugins] = List of plugins to be included in project (separated by spaces).";
    echo "";
    exit 1;
fi

DIRPATH=${1}
UTILPATH="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ ! -e ${DIRPATH} ]; then
    echo "Directory ""${DIRPATH}"" does not exist.";
    exit 1;
fi

cd ${DIRPATH}

if [ ! -e "build" ]; then
    mkdir build;
fi

PLUGINS=("energybalance" "lidar" "aeriallidar" "photosynthesis" "radiation" "solarposition" "stomatalconductance" "topography" "visualizer" "voxelintersection" "weberpenntree" "canopygenerator" "boundarylayerconductance")
HEADERS=("EnergyBalanceModel.h" "LiDAR.h" "AerialLiDAR.h" "PhotosynthesisModel.h" "RadiationModel.h" "SolarPosition.h" "StomatalConductanceModel.h" "Topography.h" "Visualizer.h" "VoxelIntersection.h" "WeberPennTree.h" "CanopyGenerator.h" "BoundaryLayerConductanceModel.h")

FILEBASE=`basename $DIRPATH`

if [ "${FILEBASE}" == '.' ]; then
    FILEBASE="executable";
fi

#----- build the CMakeLists.txt file ------#

echo -e '# Helios standard CMakeLists.txt file version 1.6\n' > CMakeLists.txt

echo -e '#-------- USER INPUTS ---------#\n' >> CMakeLists.txt

echo -e '#provide the path to Helios base directory, either as an absolute path or a path relative to the location of this file\nset( BASE_DIRECTORY "../.." )\n'  >> CMakeLists.txt

echo -e '#define the name of the executable to be created\nset( EXECUTABLE_NAME "'$FILEBASE'" )\n' >> CMakeLists.txt

echo -e '#provide name of source file(s) (separate multiple file names with semicolon)\nset( SOURCE_FILES "main.cpp" )\n' >> CMakeLists.txt

if [ "$#" == 1 ]; then
    echo -e '#specify which plug-ins to use (separate plug-in names with semicolon)\nset( PLUGINS "" )\n' >> CMakeLists.txt
else
    echo -ne '#specify which plug-ins to use (separate plug-in names with semicolon)\nset( PLUGINS "' >> CMakeLists.txt

    for argin in "${@:2}"; do
	FOUND=0
	for i in "${PLUGINS[@]}";do
	    if [ "${i}" == "${argin}" ]; then
		echo -ne "${argin};" >> CMakeLists.txt
		FOUND=1
		break;
	    fi
	done
	if [ $FOUND == "0" ]; then
	    echo "Unknown plug-in '${argin}'. Skipping..."
	fi
    done
    echo -e '" )\n\n' >> CMakeLists.txt
fi

cat "${UTILPATH}/CMakeLists_main_v1.6" >> CMakeLists.txt

#echo -e '#-------- MAIN CODE (Dont Modify) ---------#\ncmake_minimum_required(VERSION 2.4)\nproject(helios)' >> CMakeLists.txt
#
#echo -e 'SET(CMAKE_CXX_COMPILER_ID "GNU")\nSET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -std=c++11")\nSET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g" )' >> CMakeLists.txt
#
#echo -e 'if(NOT DEFINED CMAKE_SUPPRESS_DEVELOPER_WARNINGS)\nset(CMAKE_SUPPRESS_DEVELOPER_WARNINGS 1 CACHE INTERNAL "No dev warnings")\nendif()' >> CMakeLists.txt
#
#echo -e 'set( LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib )\nadd_executable( ${EXECUTABLE_NAME} ${SOURCE_FILES} )\nadd_subdirectory( ${BASE_DIRECTORY}/core "lib" )\ntarget_link_libraries( ${EXECUTABLE_NAME} helios)' >> CMakeLists.txt
#
#echo -e 'LIST(LENGTH PLUGINS PLUGIN_COUNT)\nmessage("-- Loading ${PLUGIN_COUNT} plug-ins")\nforeach(PLUGIN ${PLUGINS})\n\tmessage("-- loading plug-in ${PLUGIN}")\n\tif( ${PLUGIN} STREQUAL ${EXECUTABLE_NAME} )\n\t\tmessage( FATAL_ERROR "The executable name cannot be the same as a plugin name. Please rename your executable." )\n\tendif()\n\tadd_subdirectory( ${BASE_DIRECTORY}/plugins/${PLUGIN} "plugins/${PLUGIN}" )\n\ttarget_link_libraries( ${EXECUTABLE_NAME} ${PLUGIN} )\nendforeach(PLUGIN)' >> CMakeLists.txt
#
#echo -e 'include_directories( "${PLUGIN_INCLUDE_PATHS};${CMAKE_CURRENT_SOURCE_DIRECTORY}" )\n' >> CMakeLists.txt

#----- build the main.cpp file ------#

if [ "$#" == 1 ]; then
  echo -e '#include "Context.h"' > main.cpp
fi

for argin in "${@:2}"; do
    FOUND=0
    IND=0
    for i in "${PLUGINS[@]}";do
	if [ "${i}" == "${argin}" ]; then
	    echo -e '#include "'${HEADERS[${IND}]}'"' >> main.cpp
	    FOUND=1
	    break;
	fi
	IND=$((IND+1))
    done
    if [ $FOUND == "0" ]; then
	echo "Unknown plug-in '${argin}'. Skipping..."
    fi
done

echo -e '\nusing namespace helios;\n' >> main.cpp

echo -e 'int main(){\n\n\n}' >> main.cpp
