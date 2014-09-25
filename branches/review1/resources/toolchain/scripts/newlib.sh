#!/bin/sh

ACT_UNPACK=1
ACT_CONFIGURE=1
ACT_BUILD=1
ACT_INSTALL=1

APP=newlib
VERSION=1.15.0
TARBALL=$APP-$VERSION.tar.gz

if [ "`basename $CWD`" == "scripts" ]; then
  echo "Start this script from top level tools directory!"
  exit 1
fi

if [ $ACT_UNPACK == 1 ]; then
  echo "---------------------------------------------------------"
  echo "---   Deleting previous source ..."
  cd $SRC
  rm -rf $APP-$VERSION
  echo "---   Unpacking ..."
  tar zxvf $DL/$TARBALL || exit 1
  cd $SRC/$APP-$VERSION
  patch -p1 -i $PATCHES/$APP-info.diff
fi

if [ $ACT_CONFIGURE == 1 ]; then
  echo "---------------------------------------------------------"
  echo "---   Deleting previous build ..."
  cd $BUILD
  rm -rf $APP
  mkdir -p $APP
  echo "---   Configuring ..."
  cd $APP
  $SRC/$APP-$VERSION/configure --target=$TARGET --prefix=$PREFIX \
                                   --disable-newlib-supplied-syscalls --disable-newlib-io-float \
                                   --enable-interwork --enable-multilib \
                                   --with-gnu-ld --with-gnu-as \
                                   --disable-nls --disable-shared \
                                   --enable-languages=c \
                              || exit 1
fi

if [ $ACT_BUILD == 1 ]; then
  echo "---------------------------------------------------------"
  echo "---   Building ..."
  cd $BUILD/$APP
  make $JOBS all || exit 1
fi

if [ $ACT_INSTALL == 1 ]; then
  echo "---------------------------------------------------------"
  echo "---   Installing ..."
  cd $BUILD/$APP
  make $JOBS install || exit 1
fi

exit 0

# End of file
