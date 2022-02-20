#!/usr/bin/env bash
#
# Install package dependencies.  Only necessary on a machine not previously configured for MARTe2
#
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

# Import common shell functions
source "${SCRIPT_DIR}/utils.sh"

install_prereq_centos7() {
  yum -y install epel-release && yum -y update
  # Development package as a group
  yum -y groups install "Development Tools"
  # Extras that are generally useful
  yum -y install wget cmake3 octave libxml libxml2-devel bc vim w3m lsof
  
  # Configure cmake3 as cmake
  alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 --family cmake
  
  # Dependencies to build MARTe2 and EPICS
  yum -y install ncurses-devel readline-devel
  # Python and Perl Parse utilities for open62541 (open source impleemntation of OPC UA based on IEC 62541)
  yum -y install python-dateutil python-six perl-ExtUtils-ParseXS
  # MDSplus
  yum -y install http://www.mdsplus.org/dist/el7/stable/RPMS/noarch/mdsplus-repo-7.50-0.el7.noarch.rpm
  yum -y install mdsplus-kernel* mdsplus-java* mdsplus-python* mdsplus-devel*
  # Install Development dependencies for SDN (libz !)
  # Is this needed on centos7 ?
  # apt-get install -y zlib1g-dev
  echo "Prerequisites installed"
  touch ${MARTe2_Utils_Dependencies_Installed_File}
}

install_prereq_debian11() {
	apt-get update && apt-get install -y build-essential
	apt-get -y install wget octave libxml2 libxml2-dev bc vim git
	wget -qO- "https://github.com/Kitware/CMake/releases/download/v3.21.4/cmake-3.21.4-linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local
	update-alternatives --install /usr/bin/cmake3 cmake /usr/local/bin/cmake 20 --slave /usr/bin/ctest3 ctest /usr/local/bin/ctest --slave /usr/bin/cpack3 cpack /usr/local/bin/cpack --slave /usr/local/bin/ccmake3 ccmake /usr/local/bin/ccmake 
	apt-get -y install ncurses-dev libreadline-dev
	apt-get -y install python3-dateutil python3-six 
	# Install Development dependencies for SDN (libz !)
	apt-get install -y zlib1g-dev
	echo "Prerequisites installed"
	touch ${MARTe2_Utils_Dependencies_Installed_File}
}


install_prereq(){
  this_distro=$(get_distro)
  case "$this_distro" in
    centos7)
      echo "Installing dependencies for supported distro : $this_distro"
      install_prereq_centos7
    ;;
    centos)
      echo "Installing dependencies for unsupported distro : $this_distro using centos7"
      install_prereq_centos7
    ;;
    debian11)
      echo "Installing dependencies for supported distro : $this_distro"
      install_prereq_debian11
    ;;
    debian|ubuntu18.04|ubuntu20.04)
      echo "Installing dependencies for unsupported distro : $this_distro using debian11"
      install_prereq_debian11
    ;;
    *)
      echo "Distribution $this_distro is not yet supported."
	exit 54
    ;;
  esac
}

if [ "$(whoami)" == "root" ]
then
  if [ ! -f ${MARTe2_Utils_Dependencies_Installed_File} ]
  then
    install_prereq
  else
    echo "Dependencies already installed."
  fi
  exit 0
else
  echo "Run as root user : install prerequisites if necessary"
  exit 54
fi

