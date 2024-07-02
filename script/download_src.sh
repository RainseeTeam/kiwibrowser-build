#!/bin/sh
sudo apt-get update
sudo apt-get install -y python openjdk-8-jdk-headless libncurses5 ccache
sudo update-java-alternatives --set java-1.8.0-openjdk-amd64
git clone --depth 1 "https://github.com/kiwibrowser/src.next" src
cd "$ROOT/src"
echo "MAJOR=112\nMINOR=0\nBUILD=5615\nPATCH=101" > chrome/VERSION
sudo bash install-build-deps.sh --no-chromeos-fonts
build/linux/sysroot_scripts/install-sysroot.py --arch=i386
build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
keytool -genkey -v -keystore keystore.jks -alias dev -keyalg RSA -keysize 2048 -validity 10000 -storepass public_password -keypass public_password -dname "cn=Kiwi Browser, ou=Actions, o=Kiwi Browser, c=GitHub"
export DEPOT_TOOLS_UPDATE=0
gclient runhooks
