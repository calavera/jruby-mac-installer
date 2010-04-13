unless ARGV.size == 2
  puts "Usage: ruby setup.rb jruby_source_dir jruby_version"
  exit -1
end

require 'erb'
require 'fileutils'
include FileUtils

#             #
#  VARIABLES  #
#             #

HOME = ARGV[0]
JVERSION = ARGV[1]
JRUBY_DEST = '/Library/Frameworks/JRuby.framework'

DIST = "#{HOME}/dist"
POSTFLIGHT = 'scripts/postflight.patch-profile'
PMDOC = 'JRuby-installer.pmdoc/01jruby.xml'
MACDIST = 'jruby_dist'
GEMSPMDOC = 'JRuby-installer.pmdoc/02gems.xml'
GEMSMAC = 'rubygems/jruby_mac.rb'
GEMSDIST = 'gems_dist'
GEMSDEFAULTS = "#{MACDIST}/lib/ruby/site_ruby/1.8/rubygems/defaults"

UNINSTALLER_INDEX = 'JRuby-uninstaller.pmdoc/index.xml'
UNINSTALLER_PMDOC = 'JRuby-uninstaller.pmdoc/01uninstaller.xml'
UNINSTALLER_SCRIPT = 'scripts/uninstaller.rb'

#           #
#  HELPERS  #
#           #

def replace_variables_in(path)
  File.open(path,"w") do |f|
    f.write ERB.new(File.read("#{path}.erb")).result
  end
end

def prepare_rubygems
  replace_variables_in GEMSMAC
  cp GEMSMAC, GEMSDEFAULTS

  File.open("#{GEMSDEFAULTS}/jruby.rb", "a+") do |file|
    file.write("require 'rubygems/defaults/jruby_mac'")
  end

  mv "#{MACDIST}/lib/ruby/gems", GEMSDIST
end

def cleanup
  
  [MACDIST, GEMSDIST, 'pkg' ].each do |f|
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

#                               #
#  START BUILDING THE PACKAGES  #
#                               #

puts "- Preparing JRuby distribution"

cd HOME do
  if ! File.exist? File.join(DIST, "jruby-bin-#{JVERSION}.zip")
    exec_and_cleanup "ant clean dist"
  end
end

exec_and_cleanup "unzip #{DIST}/jruby-bin-#{JVERSION}.zip -d ."

mv "jruby-#{JVERSION}", MACDIST

prepare_rubygems

puts "- Setting package version"

replace_variables_in POSTFLIGHT
replace_variables_in PMDOC
replace_variables_in GEMSPMDOC

replace_variables_in UNINSTALLER_INDEX
replace_variables_in UNINSTALLER_PMDOC
replace_variables_in UNINSTALLER_SCRIPT

puts "- Building package, it takes a while, be patient my friend"

mkdir_p "pkg"

exec_and_cleanup "time /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -v --doc JRuby-installer.pmdoc --out pkg/JRuby-#{JVERSION}.pkg --version #{JVERSION}"
exec_and_cleanup "time /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker -v --doc JRuby-uninstaller.pmdoc --out pkg/JRuby-uninstaller-#{JVERSION}.pkg --version #{JVERSION}"

if File.exist? DMG = File.join(DIST, "JRuby-#{JVERSION}.dmg")
  rm DMG
end
exec_and_cleanup "time hdiutil create #{DMG} -volname JRuby-#{JVERSION} -fs HFS+ -srcfolder pkg"

puts "- Cleaning directories"

cleanup

puts "- Done"
