git config --global http.proxy 'socks5://192.168.31.84:1080' 
git config --global https.proxy 'socks5://192.168.31.84:1080'

export proxy="http://192.168.31.84:1081"
export http_proxy=$proxy
export https_proxy=$proxy

echo "CC=ccache clang -Qunused-arguments"  
echo "CXX=ccache clang++ -Qunused-arguments"  
echo "START_TIME=$(date '+%s')"  

sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo swapoff -a
sudo rm -f /mnt/swapfile


export DEPOT_TOOLS_DIR=$PWD/depot_tools
export PATH=$DEPOT_TOOLS_DIR:$DEPOT_TOOLS_DIR/python2_bin:$DEPOT_TOOLS_DIR/python_bin:$PATH


cd src
echo "MAJOR=112\nMINOR=0\nBUILD=5615\nPATCH=101" > chrome/VERSION

gclient runhooks


cat .build/android_arm/args.gn | sed "s#target_cpu = \"arm\"#target_cpu = \"arm64\"#" | sed "s#android_default_version_name = \"Git\"#android_default_version_name = \"Git$(date '+%y%m%d')\"#" > out/arm64/args.gn
sed -i "s#android_default_version_code = \"1\"#android_default_version_code = \"$(date '+%y%m%d')\"#" out/arm64/args.gn
sed -i "s#is_java_debug = false#is_java_debug = true#" out/arm64/args.gn
echo "\nfatal_linker_warnings = false" >> out/arm64/args.gn

cat out/arm64/args.gn
gn gen out/arm64/


sudo fallocate -l 6G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

ninja -C out/arm64/ -j 8 base 
ninja -C out/arm64/ -j 8 chrome_java 
ninja -C out/arm64/ -j 8 components/guest_view/renderer 
ninja -C out/arm64/ -j 8 chrome/gpu 
ninja -C out/arm64/ -j 8 components/version_info 
ninja -C out/arm64/ -j 8 ui/base 
ninja -C out/arm64/ -j 8 chrome/browser:resources 
ninja -C out/arm64/ -j 8 chrome/browser/ui 
ninja -C out/arm64/ -j 8 chrome/browser 
ninja -C out/arm64/ -j 8 chrome/common 
ninja -C out/arm64/ -j 8 chrome/renderer 
ninja -C out/arm64/ -j 8 extensions 
ninja -C out/arm64/ -j 8 services 
ninja -C out/arm64/ -j 8 v8 
ninja -C out/arm64/ -j 4 chrome_public_apk
