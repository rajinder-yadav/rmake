#!/usr/bin/env ruby
#
# Author: Rajinder Yadav <info@devmentor.org>
# Date: May 21, 2012
# Web : labs.devmentor.org

# CMake list file generator and project creator
# specifically designed for making an Eclipse project

RMAKE_VERSION = "1.5.0"

require "fileutils"
require "shell"
require "erb"

# Create header file if it does not exist
#
# Template variables:
#   filename    - name of file being written 
#   headerGuard - name used for header guard
#
def fileSafeCreateHeader( filename )
    
  return if( File.exist?( filename ) )  
  puts "RMake> Creating header file: " + filename  
  headerGuard = filename.upcase.tr( '.', '_' )
  rmake_loc   = File.expand_path( File.dirname( __FILE__ ) )

  title_lines  = IO.readlines( "#{rmake_loc}/templates/title.trb" )
  header_lines = IO.readlines( "#{rmake_loc}/templates/header.trb" )

  File.open( filename, "w+" ) do |f|    
    expanded_line = ERB.new( title_lines.join , nil, "%<>" )
    f.puts expanded_line.result( binding )
    expanded_line = ERB.new( header_lines.join , nil, "%<>" )
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
def fileSafeCreateSource( filename )
  return if( File.exist?( filename ) )
  puts "RMake> Creating source file " + filename
  rmake_loc = File.expand_path( File.dirname( __FILE__ ) )
  
  title_lines = IO.readlines( "#{rmake_loc}/templates/title.trb" )
  source_lines = IO.readlines( "#{rmake_loc}/templates/source.trb" )
  
  headerFile = filename.sub( /\.(cpp|c)$/, ".h" )
  
  File.open( filename, "w+" ) do |f|
    expanded_line = ERB.new( title_lines.join , nil, "%<>" )
    f.puts expanded_line.result( binding )
    if( File.exist?( headerFile ) )
      expanded_line = ERB.new( source_lines.join , nil, "%<>" )
      f.puts expanded_line.result( binding )
    end
  end  
end

# Create project folder if it does not exist
def projectSafeCreate( name )
  return if( File.exist?( name ) )
  Dir.mkdir( name )
end

# Check if executing rmake from project's root folder
# a proper project folder will have a 'build' and 'src' sub-folder
def checkInProjectFolder
  if( !(Dir.exist?( "build" ) && Dir.exist?( "src" ) ) )
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

# create projects folder layout
arg_list = ARGV

# Determine the project build type, Debug (default) or Release
build_type = "Debug"
build_type_index = arg_list.find_index( "g:debug" )

if( build_type_index.nil? )
  build_type_index = arg_list.find_index( "g:release" )
  build_type = "Release" if( !build_type_index.nil? )
end

puts "RMake> Build type #{build_type}"

arg_list.delete_at( build_type_index ) if( !build_type_index.nil? )

# if g:eclipse, g:make, g:nmake is passed
# re-generate project makefile and exit
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
if( project_name =~ /\.(c|cpp|h|hpp)/ )
  puts "RMake> Error!\nProject name must be supplied as the first argument."
  puts "See usage: rmake ?"
  exit( false )
end

puts "RMake> Project name #{project_name}"
projectSafeCreate( project_name )
Dir.chdir( project_name )

header_file = []
source_file = []

# collect project files (header, source)
if( arg_list.size > 1 )
  header_file = arg_list.grep /(\w*\.h|\w*\.hpp)/
  source_file = arg_list.grep /(\w*\.c|\w*\.cpp)/
end

# create project build, src folders
if( !Dir.exist? "build" )
  puts "RMake> Creating build sub-folder"
  Dir.mkdir( "build" )
end

if( !Dir.exist? "src" )
  puts "RMake> Creating project src folder"
  Dir.mkdir( "src" )
  Dir.chdir( "src" )
  Dir.mkdir( "test" )
  puts "RMake> Creating test sub-folder"
  Dir.chdir( ".." )
end

# create blank source, header files
Dir.chdir( "src" )

header_file.each do |filename|
  fileSafeCreateHeader( filename )
end

# if no source file specified, assume a main.cpp blank project
source_file << "main.cpp" if source_file.empty?

source_file.each do |filename|
  fileSafeCreateSource( filename )
end

# create a generic CMakeLists.txt file
puts "RMake> Creating project CMakeLists.txt file"
rmake_loc   = File.expand_path( File.dirname( __FILE__ ) )
cmake_lines  = IO.readlines( "#{rmake_loc}/templates/cmakelists.trb" )

File.open( "CMakeLists.txt", "w" ) do |file|
  expanded_line = ERB.new( cmake_lines.join , nil, "%<>" )
  file.puts expanded_line.result( binding )
end

if( File.exist?( "main.cpp" ) )
  rmake_loc = File.expand_path( File.dirname( __FILE__ ) )

  title_lines = IO.readlines( "#{rmake_loc}/templates/title.trb" )
  main_lines = IO.readlines( "#{rmake_loc}/templates/main.trb" )
  filename = "main.cpp"
  
  File.open( filename, "w+" ) do |f|        
      expanded_line = ERB.new( title_lines.join , nil, "%<>" )
      f.puts expanded_line.result( binding )
      expanded_line = ERB.new( main_lines.join, nil, "%<>" )
      f.puts expanded_line.result( binding )
  end
end

Dir.chdir( ".." )

# generate Eclipse project
genCMakeEclipse( build_type )

Dir.chdir( ".." )

# == MAIN END ===
