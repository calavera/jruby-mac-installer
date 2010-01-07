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

/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -v --doc JRuby-installer.pmdoc --out $jruby_dist/JRuby.pkg;

rm -rf jruby_dist;

echo 'Done.';
