Mac package installer for JRuby.

Follow this steps to build the installer:


From PackageMaker, the application:

  1. Open JRuby-installer.pmdoc with PackageMaker that's bundled with The Apple Development Tools. 

  2. Put the JRuby distribution that you want to package under the directory "jruby_dist".

  3. Build the installer.


From the command line:

  run ./build.sh JRUBY_DIST_DIRECTORY JRUBY_VERSION



TODO:

1. Customize the interface:
  * Create a background image for the installer
  * Complete empty step windows
  * Create a rich text version for LICENSE.jruby and README.jruby
