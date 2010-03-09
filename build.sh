#/bin/sh -x
#
# Script to create the JRuby mac installer from the command line. It takes a while, be patient my friend.
#
# It needs two arguments from the command line:
#
#    $1: the jruby's source code directory
#    $2: the jruby's version
#
#
# I.e: sh build.sh ~/dev/jruby 1.5.0.dev
#
# To show the options that PackageMaker accepts run:
#
# /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -help
#

jruby_source=$1
jruby_version=$2

#ant -f $jruby_source/build.xml clean dist

unzip $jruby_source/dist/jruby-bin-$jruby_version.zip -d .;  # unpacking jruby.zip

mv jruby-$jruby_version jruby_dist;

echo 'setting package version' # HACKY!!
postflight="scripts/postflight.patch-profile"
pmdoc="JRuby-installer.pmdoc/01jruby.xml"

replacement="s/@JRUBYVER@/$jruby_version/g"

cp $postflight "$postflight.back"
sed -e $replacement $postflight > "$postflight.tmp"
mv "$postflight.tmp" $postflight

cp $pmdoc "$pmdoc.back"
sed -e $replacement $pmdoc > "$pmdoc.tmp"
mv "$pmdoc.tmp" $pmdoc

echo 'building package'
mkdir pkg;
/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker \
-v --doc JRuby-installer.pmdoc --out pkg/JRuby-$jruby_version.pkg --version $jruby_version;

#hdiutil create $jruby_source/dist/JRuby-$jruby_version.dmg -volname \
#JRuby-$jruby_version -fs HFS+ -srcfolder pkg;

echo 'cleaning directories'
mv "$postflight.back" $postflight
mv "$pmdoc.back" $pmdoc

rm -r jruby_dist;
#rm -r pkg;

echo 'Done.';
