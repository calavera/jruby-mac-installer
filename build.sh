#/bin/sh -x
#
# Script to create the JRuby mac installer from the command line. It takes a while, be patient my friend.
#
# It needs two arguments from the command line:
#
#    $1: the jruby's distribution directory
#    $2: the jruby's version
#
# To show the options that PackageMaker accepts run:
#
# /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -help
#

jruby_dist=$1
jruby_version=$2

unzip $jruby_dist/jruby-bin-$jruby_version.zip -d .;  # unpacking jruby.zip
mv jruby-$jruby_version jruby_dist;

mkdir pkg;
/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker \
-v --doc JRuby-installer.pmdoc --out pkg/JRuby-$jruby_version.pkg --version $jruby_version;

hdiutil create $jruby_dist/JRuby-$jruby_version.dmg -volname JRuby -fs HFS+ -srcfolder pkg;

rm -r jruby_dist;
rm -r pkg;

echo 'Done.';
