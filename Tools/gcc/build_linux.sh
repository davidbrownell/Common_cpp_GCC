#!/bin/bash
# ----------------------------------------------------------------------
# |
# |  build_linux.sh
# |
# |  David Brownell <db@DavidBrownell.com>
# |      2019-05-11 13:25:50
# |
# ----------------------------------------------------------------------
# |
# |  Copyright David Brownell 2019-20
# |  Distributed under the Boost Software License, Version 1.0. See
# |  accompanying file LICENSE_1_0.txt or copy at
# |  http://www.boost.org/LICENSE_1_0.txt.
# |
# ----------------------------------------------------------------------
set -e                                      # Exit on error
set -x                                      # Statements

# Builds gcc code
#
#   Docker command:
#       [Linux Host]    docker run -it --rm -v `pwd`/..:/local centos:6.8 bash /local/gcc/build_linux.sh <9.1.0>
#       [Windows Host]  docker run -it --rm -v %cd%/..:/local centos:6.8 bash  /local/gcc/build_linux.sh <9.1.0>

if [[ "$1" == "9.1.0" ]]
then
    GCC_VERSION=9.1.0
    GMP_VERSION=6.1.2
    MPC_VERSION=1.1.0
    MPFR_VERSION=4.0.2
else
    echo "Invalid gcc version; expected 9.1.0"
    exit
fi

UpdateEnvironment() {
    set +x
    echo "# ----------------------------------------------------------------------"
    echo "# |"
    echo "# |  Updating Development Environment"
    echo "# |"
    echo "# ----------------------------------------------------------------------"
    set -x

    yum update -y
    yum groupinstall -y 'Development Tools'
    yum install -y xz svn wget

    # 7zip
    wget https://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/x86_64/Packages/p/p7zip-16.02-10.el6.x86_64.rpm
    wget https://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/x86_64/Packages/p/p7zip-plugins-16.02-10.el6.x86_64.rpm

    rpm -U --quiet p7zip-16.02-10.el6.x86_64.rpm
    rpm -U --quiet p7zip-plugins-16.02-10.el6.x86_64.rpm
}

BuildGcc() {
    set +x
    echo "# ----------------------------------------------------------------------"
    echo "# |"
    echo "# |  Building GCC"
    echo "# |"
    echo "# ----------------------------------------------------------------------"
    set -x

    # GCC
    if [[ ! -d "gcc" ]]
    then
        [[ -d "gcc_tmp" ]] && rm -rfd "gcc_tmp"
        svn checkout svn://gcc.gnu.org/svn/gcc/tags/gcc_$(echo "${GCC_VERSION}" | tr . _)_release/ gcc_tmp
        mv gcc_tmp gcc
    fi

    # GMP
    if [[ ! -d "gcc/gmp" ]]
    then
        curl https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.xz | tar Jxf -
        mv gmp-${GMP_VERSION} gcc/gmp
    fi

    # MPC
    if [[ ! -d "gcc/mpc" ]]
    then
        curl https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz | gunzip -c | tar xf -
        mv mpc-${MPC_VERSION} gcc/mpc
    fi

    # MPFR
    if [[ ! -d "gcc/mpfr" ]]
    then
        curl https://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.xz | tar Jxf -
        mv mpfr-${MPFR_VERSION} gcc/mpfr
    fi

    [[ -e build ]] || mkdir build
    cd build

    ../gcc/configure                                                        \
        --prefix=/opt/CommonCppGcc/gcc/${GCC_VERSION}                       \
        --disable-multilib                                                  \
        --disable-libmpx                                                    \
        --enable-languages=c,c++,fortran,go,objc,obj-c++

    make
    make install

    pushd /opt/CommonCppGcc/gcc/${GCC_VERSION} > /dev/null
    [[ -d /local/gcc/v${GCC_VERSION}/Linux ]] || mkdir -p /local/gcc/v${GCC_VERSION}/Linux
    7za a /local/gcc/v${GCC_VERSION}/Linux/Install.7z *
    popd > /null/null
}

[[ -d ./src ]] || mkdir "./src"
pushd ./src > /dev/null

UpdateEnvironment
BuildGcc

set +x
echo DONE!
