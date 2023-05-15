## TODO, make this into a proper shell script

sudo apt update && sudo apt upgrade -y

#<=======================================================================================>

# Dependencies
sudo apt install build-essential libpcap-dev libpcre3-dev libnet1-dev zlib1g-dev luajit hwloc libdnet-dev libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake cpputest libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev libluajit-5.1-dev libunwind-dev libfl-dev autoconf unzip -y

#<=======================================================================================>

mkdir ~/snort_src && cd ~/snort_src

#<=======================================================================================>

git clone https://github.com/snort3/libdaq.git
cd libdaq
./bootstrap
./configure
make
sudo make install

#<=======================================================================================>
#Getting perftools
cd ..

# Grab the latest release of this thing
file="$(
curl -s https://api.github.com/repos/gperftools/gperftools/releases/latest \
| grep browser_download_url \
| sed -re 's/.*: "([^"]+)".*/\1/' \
| grep tar.gz \
)"
wget $file

# Or a manual method after going to repo an checking the latest release...
# wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.10/gperftools-2.10.tar.gz
tar xzf gperftools*.tar.gz
rm gperftools*.tar.gz
cd gperftools*/
./configure
make
sudo make install

#<=======================================================================================>

# Google's thread caching malloc, for additional performance
cd..
wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
unzip master.zip
rm master.zip
cd snort3-master

#<=======================================================================================>

# ./configure_cmake.sh --help , to see available flags
# I enabled dynamic memory, big pcaps, shell, and I can't even read docs so I disabled them
# This build takes forever so go get some coffee I guess ☕
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc --enable-shell --enable-large-pcap --disable-docs

#<=======================================================================================>

cd build
make
sudo make install

#<=======================================================================================>

sudo ldconfig

#<=======================================================================================>

#Test installation
snort -V

# See detailed information about current installation
snort -c /usr/local/etc/snort/snort.lua
