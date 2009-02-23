#!/bin/sh

BINUTILS=1
GCC=0
GCC_BARE=1
NEWLIB=0
GDB=0
INSIGHT=0


CWD=`pwd`
BUILD=$CWD/build
SRC=$CWD/src
PATCHES=$CWD/patches
DL=$CWD/downloads
LOG=$CWD/log
TARGET=arm-elf
PREFIX=/usr/local/armtools/

export CWD BUILD SRC PATCHES DL LOG TARGET PREFIX

PATH=$PREFIX/bin:$PATH
export PATH

JOBS="-j 2"
export JOBS

if [ ! -d $PREFIX ]; then
  mkdir -p $PREFIX || exit 1
fi
touch $PREFIX/test.touch || exit 1
rm -f $PREFIX/test.touch || exit 1

if [ $BINUTILS == 1 ]; then
  logfile=$LOG/binutils.log
  if [ -f $logfile ]; then
    rm -f $logfile
  fi
  scripts/binutils.sh 2>&1 | tee $logfile || exit 1
fi

if [ $GCC_BARE == 1 ]; then
  logfile=$LOG/gcc_bare.log
  if [ -f $logfile ]; then
    rm -f $logfile
  fi
  scripts/gcc_bare.sh 2>&1 | tee $logfile || exit 1
fi

if [ $NEWLIB == 1 ]; then
  logfile=$LOG/newlib.log
  if [ -f $logfile ]; then
    rm -f $logfile
  fi
  scripts/newlib.sh 2>&1 | tee $logfile || exit 1
fi

if [ $GCC == 1 ]; then
  logfile=$LOG/gcc.log
  if [ -f $logfile ]; then
    rm -f $logfile
  fi
  scripts/gcc.sh 2>&1 | tee $logfile || exit 1
fi

if [ $GDB == 1 ]; then
  logfile=$LOG/gdb.log
  if [ -f $logfile ]; then
    rm -f $logfile
  fi
  scripts/gdb.sh 2>&1 | tee $logfile || exit 1
fi

if [ $INSIGHT == 1 ]; then
  logfile=$LOG/insight.log
  if [ -f $logfile ]; then
    rm -f $logfile
  fi
  scripts/insight.sh 2>&1 | tee $logfile || exit 1
fi

exit 0

# End of file
