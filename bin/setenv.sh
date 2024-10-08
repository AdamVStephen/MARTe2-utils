#!/usr/bin/env bash
# vim: set ft=bash:
# Set environment variables for the project.  Referenced from other install and run scripts.
#
# 2022-01-22 passes shellcheck linting OK.
# 2022-01-22 : bashtip : surround shell expansion strings in double quotes : shellcheck
# 2022-01-22 : bashtip : use || exit after a cd attempt in case the directory is not found : shellcheck
# 2024-08-24 : add guards to preserve provided MARTe2_DIR and MARTe2_Components_DIR if defined.
# TODO: use the following to avoid any absolute path reference assumptions : install wherever cloned to.
#set -x

export SCRIPT="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
export SCRIPT_REALPATH=$(realpath "$SCRIPT")
export SCRIPT_NAME=$(basename "$SCRIPT_REALPATH")
export SCRIPT_DIR=$(dirname "$SCRIPT_REALPATH")

export PATH=$PATH:${SCRIPT_DIR}
export INSTALLATION_DIR=$(realpath "$SCRIPT_DIR/../../")

export MARTe2_PROJECT_ROOT=${INSTALLATION_DIR}/MARTe2-utils
export MARTe2_Utils_Dependencies_Installed_File=${MARTe2_PROJECT_ROOT}/marte2-utils.deps.installed
export MARTe2_Utils_Repos_Installed_File=${MARTe2_PROJECT_ROOT}/marte2-utils.repos.installed

if [ -z ${MARTe2_DIR+x} ]
then 
	echo "MARTe2_DIR environment variable is not set"
	echo "Set relative to $MARTe2_PROJECT_ROOT"
	export MARTe2_DIR=${MARTe2_PROJECT_ROOT}/MARTe2-dev
	echo "MARTe2_DIR is ${MARTe2_DIR}"
else
	echo "Preserving MARTe2_DIR environment variable "
	echo "MARTe2_DIR is ${MARTe2_DIR}"
fi
if [ -z ${MARTe2_Components_DIR+x} ]
then 
	echo "MARTe2_Components_DIR environment variable is not set"
	echo "Set relative to $MARTe2_PROJECT_ROOT"
	export MARTe2_Components_DIR=${MARTe2_PROJECT_ROOT}/MARTe2-components
	echo "MARTe2_Components_DIR is ${MARTe2_Components_DIR}"
else
	echo "Preserving MARTe2_Components_DIR environment variable "
	echo "MARTe2_Components_DIR is ${MARTe2_Components_DIR}"
fi
# Avoid building the OPCUADataSource by suppressing the next two lines
# https://github.com/AdamVStephen/MARTe2-utils/blob/issues/issues/%230001_MARTe2-components_build/OPCUAClient.md
#export OPEN62541_LIB=${MARTe2_PROJECT_ROOT}/Projects/open62541/build/bin
#export OPEN62541_INCLUDE=${MARTe2_PROJECT_ROOT}/Projects/open62541/build

export EPICS_BASE=${INSTALLATION_DIR}/epics-base-7.0.6
export EPICSPVA=${INSTALLATION_DIR}/epics-base-7.0.6
export EPICS_HOST_ARCH=linux-x86_64

export SDN_CORE_INCLUDE_DIR=${INSTALLATION_DIR}/SDN_1.0.12_nonCCS/src/main/c++/include/
export SDN_CORE_LIBRARY_DIR=${INSTALLATION_DIR}/SDN_1.0.12_nonCCS/target/lib/

# TODO: Make this idempotent to avoid excessive path growth
export PATH=$PATH:${INSTALLATION_DIR}/epics-base-7.0.6/bin/linux-x86_64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MARTe2_DIR/Build/x86-linux/Core/:$EPICS_BASE/lib/$EPICS_HOST_ARCH:$SDN_CORE_LIBRARY_DIR

# EPICS Environment : tune per machine
# Broadcast address of the specifc network
export EPICS_CA_ADDR_LIST=127.0.0.255
export EPICS_CA_AUTO_ADDR_LIST=NO

#export MDSPLUS_DIR=/usr/local/mdsplus
