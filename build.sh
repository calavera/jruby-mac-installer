#/bin/sh -x
#
# Script to create the JRuby mac installer from the command line. It takes a while, be patient my friend.
#
# It needs two arguments from the command line:
#
#    $1: the jruby's distribution directory
#    $2: the jruby's version
#

jruby_dist=$1
jruby_version=$2

unzip $jruby_dist/jruby-bin-$jruby_version.zip -d .;  # unpacking jruby.zip
mv jruby-$jruby_version jruby_dist;

find . -type f -name .DS_Store -print0 | xargs -0 rm;  # removing .DS_Store files

sudo chown -R root:wheel jruby_dist;  #  we have to already set the privileges that the contents need after the installation

/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -build -v -f . -doc JRuby-installer.pmdoc -p $jruby_dist/JRuby.pkg -i Info.plist;

sudo rm -rf jruby_dist;
