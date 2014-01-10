set -ex
cp ./bashrc ../.bashrc
cp ./colordiffrc ../.colordiffrc
cp ./screenrc ../.screenrc
cp ./vimrc ../.vimrc

mkdir -v -p ../bin
cp ./tab ../bin/tab
