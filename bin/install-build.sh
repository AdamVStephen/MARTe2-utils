#!/usr/bin/env bash
#
# Original repository : https://github.com/AdamVStephen/MARTe2-utils
#
# Check out and build specific versions of MARTe2 and MARTe2-components

#set -x
# Guard against unset variable expansion
set -u
SCRIPT="$0"
SCRIPT_DIR="$(dirname "$(realpath "$SCRIPT")")"
SETENV_SCRIPT_PATH="$SCRIPT_DIR/setenv.sh"

if [ -f "$SETENV_SCRIPT_PATH" ]
then
  # shellcheck disable=SC1090 # path is being constructed known correct
  source "$SETENV_SCRIPT_PATH"
else
  echo "$SETENV_SCRIPT_PATH not found.  Bailing out"
  exit 54
fi

# For post-installation environment setup, define INSTALLATION_DIR 
# exceptionally we need to refer to an unbound variable
set +u
echo "export INSTALLATION_DIR="${INSTALLATION_DIR}" >> "${HOME}/.MARTe2-utils.rc
set -u

# Placate shell-check and ensure env is as expected.
export MARTe2_PROJECT_ROOT=${MARTe2_PROJECT_ROOT:-/fatalerror}
if [ ! -d "${MARTe2_PROJECT_ROOT}" ]
then
	echo "Non existent MARTe2_PROJECT_ROOT : bail"
	exit 54
fi

# Import common shell functions
# shellcheck disable=SC1090 # path is being constructed known correct
source "${SCRIPT_DIR}/utils.sh"

# Look up tables of known good combinations of branches and OS versions
#

export DEFAULT_CORE_SHA="v1.5.4"

declare -A core_branch=( 
	["centos7_was"]="99c7d76af4" 
	["centos7"]="" 
	["debian11"]="" 
	["ubuntu18.04"]="" 
	["ubuntu20.04"]="" 
)

export DEFAULT_COMPONENTS_SHA="v1.4.1"

declare -A components_branch=( 
	["centos7_was"]="00a08ac"  
	["centos7"]=""  
	["ubuntu18.04"]="" 
	["ubuntu20.04"]="" 
	["debian11"]="" 
)

build_marte() {
  core_sha=$1
  components_sha=$2
  #echo "build marte for $core_sha and $components_sha"
  cd "${MARTe2_PROJECT_ROOT}"/MARTe2-dev && git checkout "$core_sha" && make -f Makefile.linux 2>&1 | tee "build.$core_sha.$(date +%s).log"
  cd "${MARTe2_PROJECT_ROOT}"/MARTe2-components && git checkout "$components_sha" && make -f Makefile.linux 2>&1 | tee "build.$components_sha.$(date +%s).log"
}

usage() {
  echo "$SCRIPT [core sha] [components sha]"
  exit 54 
}

this_distro=$(get_distro)

case $# in
  0) echo "Defaults null"
	export CORE_SHA=${core_branch[$this_distro]:=$DEFAULT_CORE_SHA}
	export COMPONENTS_SHA=${components_branch[$this_distro]:=$DEFAULT_COMPONENTS_SHA}
  ;;
  1) echo "Defaults core sha"
	export CORE_SHA=$1
	export COMPONENTS_SHA=${components_branch[$this_distro]:=$DEFAULT_COMPONENTS_SHA}
  ;;
  2) echo "core and components sha"
	export CORE_SHA=$1
	export COMPONENTS_SHA=$2
  ;;
  **) echo "Defaults non-null"
	usage
  ;;
esac

build_marte "$CORE_SHA" "$COMPONENTS_SHA" 

exit 0
