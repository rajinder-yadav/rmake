#!/usr/bin/env ruby
#
# Project: Rapid Make
# Author:  Rajinder Yadav <info@devmentor.org>
# Date:    May 21, 2012
# Web :    labs.devmentor.org

# A utility to create CMake based project with
# support for testing using Micro Test.

RMAKE_VERSION = "1.6.5"

require "open-uri"
require "fileutils"
require "shell"
require "erb"

# Create header file if it does not exist
#
# Template variables:
#   filename    - name of file being written
#   headerGuard - name used for header guard
#
def safeCreateHeaderFile( filename )
  return if( File.exist?( filename ) )
  puts "RMake> Creating header file: " + filename
  headerGuard  = filename.upcase.tr( '.', '_' )
  rmake_loc    = File.expand_path( File.dirname( __FILE__ ) )
  template_loc = "#{rmake_loc}/templates"

  header_lines = IO.readlines( "#{template_loc}/title.trb" )
  body_lines   = IO.readlines( "#{template_loc}/header.trb" )

  File.open( filename, "w+" ) do |f|
    expanded_line = ERB.new( header_lines.join , nil, "%<>" )
    f.puts expanded_line.result( binding )
    expanded_line = ERB.new( body_lines.join , nil, "%<>" )
    f.puts expanded_line.result( binding )
  end
end

# Create source file
#
# Template variables:
#
#   filename    - name of file being written
#   headerFile  - header file of source file
#
def safeCreateSourceFile( filename, header_file )
  return if( File.exist?( filename ) )
  puts "RMake> Creating source file " + filename
  rmake_loc = File.expand_path( File.dirname( __FILE__ ) )
  template_loc = "#{rmake_loc}/templates"
  header = "title"
  body = case filename
    when "main.cpp" then "main"
    when "test.main.cpp" then "test.main"
    else "source"
  end

  header_lines = IO.readlines( "#{template_loc}/#{header}.trb" )
  body_lines   = IO.readlines( "#{template_loc}/#{body}.trb" )
  headerFile = filename.sub( /\.(cpp|c)$/, ".h" )

  File.open( filename, "w+" ) do |f|
    expanded_line = ERB.new( header_lines.join , nil, "%<>" )
    f.puts expanded_line.result( binding )
      expanded_line = ERB.new( body_lines.join , nil, "%<>" )
      f.puts expanded_line.result( binding )
  end
end

# Create project folder if it does not exist
def projectSafeCreate( name )
  return if( File.exist?( name ) )
  puts "RMake> Creating project folder #{name}"
  Dir.mkdir( name )
  Dir.chdir( name )
  FileUtils.touch( "CHANGE-LOG.md" )
  FileUtils.touch( "Copyright.txt" )
  FileUtils.touch( "LICENSE.txt" )
  FileUtils.touch( "README.md" )
  folders = ["docs", "include", "lib",]
  folders.each do |folder|
    if( ! Dir.exist?( folder ) )
      puts "RMake> Creating sub-folder #{name}/#{folder}"
      Dir.mkdir( folder )
    end
  end
  Dir.chdir( ".." )
end

# Check if executing rmake from project's root folder
# A proper project folder will have a 'build' and 'src' sub-folder
def checkInProjectFolder
  if( Dir.exist?( "src" ) )
     if( ! Dir.exist?( "build" ) )
        Dir.mkdir( "build" )
     end
  else
    puts "RMake Error!\nMust run this command from the project root folder."
    puts "Project root folder must have a src and build sub-folder."
    puts "See usage: rmake ?"
    exit( false )
  end
end

# Generate an Eclipse project inside the build sub-folder
def genCMakeEclipse( build_type )
  checkInProjectFolder
  Dir.chdir( "build" )
  FileUtils.rm_rf( "./")

  if( $fLinuxOS )
    puts "RMake> Creating #{build_type} Linux Eclipse project makefile "
    system( "cmake -G \"Eclipse CDT4 - Unix Makefiles\" -D CMAKE_BUILD_TYPE=#{build_type} ../src" )
  else
    puts "RMake> Creating #{build_type} Visual C++ NMake makefile "
    system( "cmake -G \"Eclipse CDT4 - NMake Makefiles\" -D CMAKE_BUILD_TYPE=#{build_type} ../src" )
  end
  Dir.chdir( ".." )
end

# Generate a makefile inside the build sub-folder
def genCMakeLinux( build_type )
  puts "RMake> Creating #{build_type} Linux GNU Make makefile "
  checkInProjectFolder
  Dir.chdir( "build" )
  FileUtils.rm_rf( "./")

  system( "cmake -G \"Unix Makefiles\" -D CMAKE_BUILD_TYPE=#{build_type} ../src" )
  Dir.chdir( ".." )
end

# Generate a VC++ NMake makefile inside the build sub-folder
def genCMakeVisualStudio( build_type )
  puts "RMake> Creating #{build_type} VisualStudio project solution "
  checkInProjectFolder
  Dir.chdir( "build" )
  FileUtils.rm_rf( "./")

  system( "cmake -G \"NMake Makefiles\" -D CMAKE_BUILD_TYPE=#{build_type} ../src" )
  Dir.chdir( ".." )
end

# Display rmake usage in the console
def showUsage
  puts "RMake v#{RMAKE_VERSION} - CMake project file generator"
  puts "Created by Rajinder Yadav <info@devmentor.org>"
  puts "Copyright (c) DevMentor.org May 21, 2012\n\n"
  puts "Use: rmake <project_name> <source_header_files>\n\n"
  puts "To re-generate a CMake project file, cd into the project folder and type:\n\n"
  puts "rmake g:eclipse - Eclipse CDT project"
  puts "rmake g:make    - Linux GNU makefile"
  puts "rmake g:nmake   - VC++ NMake makefile\n\n"
  puts "Optional build type flags are:"
  puts "\n  g:debug for Debug build (default)"
  puts "  g:release for Release build"
  exit( false )
end

# === MAIN START ===

$fVisualCPP    = true if( ENV["VCINSTALLDIR"] != nil )
$fLinuxOS      = true if( RUBY_PLATFORM =~ /linux/i || system("uname") =~ /linux/i || ENV["OSTYPE"] =~ /linux/i )
$fVisualStudio = true if( ENV["VCINSTALLDIR"] =~ /Visual Studio/i )

if( ARGV.size == 0 || ARGV[0] == '?' || ARGV[0] == '-help' )
  showUsage
end

# Create projects folder layout
arg_list = ARGV

# Determine the project build type, Debug (default) or Release
build_type = "Debug"
build_type_index = arg_list.find_index( "g:debug" )

if( build_type_index.nil? )
  build_type_index = arg_list.find_index( "g:release" )
  build_type = "Release" if( !build_type_index.nil? )
end

puts "RMake> #{build_type} Build"

arg_list.delete_at( build_type_index ) if( !build_type_index.nil? )

# If g:eclipse, g:make, g:nmake is passed
# Re-generate project makefile and exit
case( arg_list[0] )
when "g:eclipse"
  genCMakeEclipse( build_type )
  exit( false )
when "g:make"
  genCMakeLinux( build_type )
  exit( false )
when "g:nmake"
  genCMakeVisualStudio( build_type )
  exit( false )
end

project_name = arg_list[0]
test_project_name = "test.#{project_name}"

if( project_name =~ /\.(c|cpp|h|hpp)/ )
  puts "RMake> Error!\nProject name must be supplied as the first argument."
  puts "See usage: rmake ?"
  exit( false )
end

puts "RMake> Creating Project #{project_name}"
projectSafeCreate( project_name )
Dir.chdir( project_name )

header_file = []
source_file = []

# Collect project files (header, source)
if( arg_list.size > 1 )
  header_file = arg_list.grep /(\w*\.h|\w*\.hpp)/
  source_file = arg_list.grep /(\w*\.c|\w*\.cpp)/
end

# Create project sub-folders: build, include, src, test
if( !Dir.exist? "build" )
  puts "RMake> Creating sub-folder #{project_name}/build"
  Dir.mkdir( "build" )
end

if( !Dir.exist? "src" )
  puts "RMake> Creating sub-folder #{project_name}/src" 
  Dir.mkdir( "src" )
  Dir.chdir( "src" )
  Dir.mkdir( "include" )
  puts "RMake> Creating sub-folder #{project_name}/src/include"
  Dir.mkdir( "test" )
  puts "RMake> Creating sub-folder #{project_name}/src/test"
  Dir.chdir( "include" )
  micro_test = open( "https://bitbucket.org/rajinder_yadav/micro_test/raw/master/src/include/micro-test.hpp" )
  IO.copy_stream( micro_test, "./micro-test.hpp" )
  Dir.chdir( "../.." )
end

# Create blank source, header files
Dir.chdir( "src" )

header_file.each do |filename|
  safeCreateHeaderFile( filename )
end

# If no source file specified, assume a main.cpp blank project
source_file << "main.cpp" if source_file.empty?
source_file.each do |filename|
  safeCreateSourceFile( filename, header_file )
end

# Create project CMakeLists.txt file
puts "RMake> Creating project CMakeLists.txt file"
rmake_loc   = File.expand_path( File.dirname( __FILE__ ) )
cmake_lines = IO.readlines( "#{rmake_loc}/templates/cmakelists.trb" )

File.open( "CMakeLists.txt", "w" ) do |file|
  expanded_line = ERB.new( cmake_lines.join , nil, "%<>" )
  file.puts expanded_line.result( binding )
end

# Create test.main.cpp source file.
Dir.chdir( "test" )
source_file_cache = source_file
source_file = ["test.main.cpp"]
safeCreateSourceFile( "test.main.cpp", header_file )

# Create a Test CMakeLists.txt file
puts "RMake> Creating Test project CMakeLists.txt file"
rmake_loc   = File.expand_path( File.dirname( __FILE__ ) )
cmake_lines = IO.readlines( "#{rmake_loc}/templates/cmakelists.test.trb" )

File.open( "CMakeLists.txt", "w" ) do |file|
  expanded_line = ERB.new( cmake_lines.join , nil, "%<>" )
  file.puts expanded_line.result( binding )
end

source_file = source_file_cache
Dir.chdir( "../.." )

# Generate Makefile project
genCMakeLinux( build_type )

Dir.chdir( ".." )

# == MAIN END ===
