unless ARGV.size == 2
  puts "Usage: ruby setup.rb jruby_source_dir jruby_version"
  exit -1
end

require 'erb'
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
  File.open(path,"w") do |f|
    f.write ERB.new(File.read("#{path}.erb")).result
  end
end

def prepare_rubygems
  cp "rubygems/jruby_mac.rb", GEMSDEFAULTS

  File.open("#{GEMSDEFAULTS}/jruby.rb", "a+") do |file|
    file.write("require 'rubygems/defaults/jruby_mac'")
  end

  mv "#{MACDIST}/lib/ruby/gems", GEMSDIST
end

def cleanup
  
  [MACDIST, GEMSDIST, "pkg"].each do |f|
    rm_r f if File.exist? f
  end
  
  exit
end

def exec_and_cleanup(cmd)
  begin
    %x(#{cmd})
  rescue
    puts "#{cmd} failed. Aborting."
    cleanup
  end
end


trap "SIGINT" do
  puts "Received SIGINT. Aborting."
  cleanup
end


puts "- Preparing JRuby distribution"

cd HOME do
  exec_and_cleanup "ant clean dist"
end

exec_and_cleanup "unzip #{DIST}/jruby-bin-#{JVERSION}.zip -d ."

mv "jruby-#{JVERSION}", MACDIST

prepare_rubygems

puts "- Setting package version"

replace_version_in POSTFLIGHT
replace_version_in PMDOC

puts "- Building package, it takes a while, be patient my friend"

mkdir_p "pkg"

exec_and_cleanup "time /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -v --doc JRuby-installer.pmdoc --out pkg/JRuby-#{JVERSION}.pkg --version #{JVERSION}"

exec_and_cleanup "time hdiutil create #{DIST}/JRuby-#{JVERSION}.dmg -volname JRuby-#{JVERSION} -fs HFS+ -srcfolder pkg"

puts "- Cleaning directories"

cleanup

puts "- Done"
