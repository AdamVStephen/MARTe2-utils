#!/usr/bin/env bash
#
# Install dependencies not yet fully wrapped in a package manager.
#
# TODO: apply the lookup table method to list options for alternative combinations.
# Guard against unset variable expansion
set -u
SCRIPT="$0"
SCRIPT_DIR=$(dirname $(realpath "$SCRIPT"))
SETENV_SCRIPT_PATH="$SCRIPT_DIR/setenv.sh"

if [ -f "$SETENV_SCRIPT_PATH" ]
then
  source "$SETENV_SCRIPT_PATH"
else
  echo "$SETENV_SCRIPT_PATH not found.  Bailing out"
  exit 54
fi


clone_utils() {
  
  cd ${MARTe2_PROJECT_ROOT} || { echo "${MARTe2_PROJECT_ROOT} does not exist"; exit 42;}
  
  # MARTe2-utils which pulls in MARTe and MARTe2-components
  #git clone --recursive -b develop https://github.com/AdamVStephen/MARTe2-utils
  git submodule init
  git submodule update
  ln -sf ${MARTe2_PROJECT_ROOT}/MARTe2 ${MARTe2_PROJECT_ROOT}/MARTe2-dev
  
  # MARTe2-demos-padova
  # Now a submodule
  # git clone https://vcis-gitlab.f4e.europa.eu/aneto/MARTe2-demos-padova.git
  
  cd ${INSTALLATION_DIR} || { echo "${INSTALLATION_DIR} does not exist"; exit 42;}

  # EPICS R7.0.2
  # Padua 2019 compatibility
  git clone -b R7.0.2 --recursive https://github.com/epics-base/epics-base.git epics-base-7.0.2
  
  # Open Source OPCUA
  # Padua 2019 compatibility
  git clone -b 0.3 https://github.com/open62541/open62541.git open62541-0.3

  # EPICS R7.0.6
  git clone -b R7.0.6 --recursive https://github.com/epics-base/epics-base.git epics-base-7.0.6
  
  # Open Source OPCUA
  git clone -b 1.3 https://github.com/open62541/open62541.git open62541-1.3
  
  # Download SDN:
  wget https://vcis-gitlab.f4e.europa.eu/aneto/MARTe2-demos-padova/raw/develop/Other/SDN_1.0.12_nonCCS.tar.gz
  
  tar zxvf SDN_1.0.12_nonCCS.tar.gz
  
  # Build the open62541 library:
  export OPCUA_BRANCH=1.3
  ln -sf ${INSTALLATION_DIR}/open62541} ${INSTALLATION_DIR}/open62541-${OPCUA_BRANCH}
  
  mkdir -p ${INSTALLATION_DIR}/open62541/build && cd $_ && cmake3 .. && make
  
  # Compile SDN:
  
  cd ${INSTALLATION_DIR}/SDN_1.0.12_nonCCS && make
  
  #Compiling EPICS 7.0.2
  cd ${INSTALLATION_DIR}/epics-base-7.0.2 && echo "OP_SYS_CXXFLAGS += -std=c++11" >> configure/os/CONFIG_SITE.linux-x86_64.Common
  cd ${INSTALLATION_DIR}/epics-base-7.0.2 && make
  
  #Compiling EPICS 7.0.6
  cd ${INSTALLATION_DIR}/epics-base-7.0.6 && echo "OP_SYS_CXXFLAGS += -std=c++11" >> configure/os/CONFIG_SITE.linux-x86_64.Common
  cd ${INSTALLATION_DIR}/epics-base-7.0.6 && make
  touch ${MARTe2_Utils_Repos_Installed_File}
}

if [ -f ${MARTe2_Utils_Repos_Installed_File} ]
then
  echo "marte2-utils already installed"
  exit 0
else
  clone_utils
  exit 0
fi






