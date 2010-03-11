puts "Usage: ruby setup.rb jruby_source_dir jruby_version" unless ARGV.size == 2

require 'fileutils'
include FileUtils

HOME = ARGV[0]
JVERSION = ARGV[1]
DIST = "#{HOME}/dist"
POSTFLIGHT = "scripts/postflight.patch-profile"
PMDOC = "JRuby-installer.pmdoc/01jruby.xml"

def replace_version_in(path)
  cp path, "#{path}.back"
  content = File.read(path)

  File.open(path, "w+") do |file|
    file.write content.gsub(/@JRUBYVER@/, JVERSION)
  end
end

def restore(path)
  cp "#{path}.back", path
  rm "#{path}.back"
end

puts "- Preparing JRuby distribution"

cd HOME do
  `ant clean dist`
end

`unzip #{DIST}/jruby-bin-#{JVERSION}.zip -d .`

mv "jruby-#{JVERSION}", "jruby_dist"

puts "- Setting package version"

replace_version_in POSTFLIGHT
replace_version_in PMDOC

puts "- Building package"

mkdir "pkg"

`/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker \
-v --doc JRuby-installer.pmdoc --out pkg/JRuby-#{JVERSION}.pkg --version #{JVERSION}`

`hdiutil create #{DIST}/JRuby-#{JVERSION}.dmg -volname \
JRuby-#{JVERSION} -fs HFS+ -srcfolder pkg`

puts "- Cleaning directories"

restore POSTFLIGHT
restore PMDOC

rm_r "jruby_dist"
rm_r "pkg"

puts "- Done"
