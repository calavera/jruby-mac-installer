unless ARGV.size == 2
  puts "Usage: ruby setup.rb jruby_source_dir jruby_version"
  exit -1
end

require 'fileutils'
include FileUtils

HOME = ARGV[0]
JVERSION = ARGV[1]
DIST = "#{HOME}/dist"
POSTFLIGHT = "scripts/postflight.patch-profile"
PMDOC = "JRuby-installer.pmdoc/01jruby.xml"
MACDIST = "jruby_dist"
GEMSDIST = "gems_dist"
GEMSDEFAULTS = "#{MACDIST}/lib/ruby/site_ruby/1.8/rubygems/defaults"

def replace_version_in(path)
  cp path, "#{path}.back"
  content = File.read(path)

  File.open(path, "w+") do |file|
    file.write content.gsub(/@JRUBYVER@/, JVERSION)
  end
end

def restore(path)
  mv "#{path}.back", path
end

def prepare_rubygems
  cp "rubygems/jruby_mac.rb", GEMSDEFAULTS

  File.open("#{GEMSDEFAULTS}/jruby.rb", "a+") do |file|
    file.write("require 'rubygems/defaults/jruby_mac'")
  end

  mv "#{MACDIST}/lib/ruby/gems", GEMSDIST
end

puts "- Preparing JRuby distribution"

cd HOME do
  `ant clean dist`
end

`unzip #{DIST}/jruby-bin-#{JVERSION}.zip -d .`

mv "jruby-#{JVERSION}", MACDIST

prepare_rubygems

puts "- Setting package version"

replace_version_in POSTFLIGHT
replace_version_in PMDOC

puts "- Building package, it takes a while, be patient my friend"

mkdir "pkg"

`/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -v --doc JRuby-installer.pmdoc --out pkg/JRuby-#{JVERSION}.pkg --version #{JVERSION}`

`hdiutil create #{DIST}/JRuby-#{JVERSION}.dmg -volname JRuby-#{JVERSION} -fs HFS+ -srcfolder pkg`

puts "- Cleaning directories"

restore POSTFLIGHT
restore PMDOC

rm_r MACDIST
rm_r GEMSDIST
rm_r "pkg"

puts "- Done"
