#!/usr/local/bin/ruby
#
# Author: Rajinder Yadav <info@devmentor.org>
# Date: May 21, 2012
# Web : www.devmentor.org

# CMake list file generator and project creator
# specifically designed for making an Eclipse project

require "fileutils"
require "shell"

def fileSafeCreateHeader( filename )
	return if( File.exist?( filename ) )
	headerGuard = filename.upcase.tr( '.', '_' )
	File.open( filename, "w+" ) do |f|
		f.puts "#ifndef _#{headerGuard}_"
		f.puts "#define _#{headerGuard}_\n\n"
		f.puts "#endif // _#{headerGuard}_"
	end
end

def fileSafeCreateSource( filename )
	return if( File.exist?( filename ) )
	headerFile = filename.sub( /\.(cpp|c)$/, ".h" )
	File.open( filename, "w+" ) do |f|
		f.puts( "#include \"#{headerFile}\"" ) if( File.exist?( headerFile ) )
	end
end

def projectSafeCreate( name )
	return if( File.exist?( name ) )
	Dir.mkdir( name )
end

def checkInProjectFolder
	if( !(Dir.exist?( "build" ) && Dir.exist?( "src" ) ) )
		puts "RMake Error!\nMust run this command from the project root folder."
		puts "Project root folder must have a src and build sub-folder."
		puts "See usage: rmake ?"
		exit(0)
	end
end

def genCMakeEclipse
	checkInProjectFolder
	Dir.chdir( "build" )
	FileUtils.rm_rf( "./")
	if( $fLinuxOS )
	   system( "cmake -G \"Eclipse CDT4 - Unix Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
   else
	   system( "cmake -G \"Eclipse CDT4 - NMake Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
   end
	Dir.chdir( ".." )
end

def genCMakeLinux
	checkInProjectFolder
	Dir.chdir( "build" )
	FileUtils.rm_rf( "./")
	system( "cmake -G \"Unix Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
	Dir.chdir( ".." )
end

def genCMakeVisualStudio
	checkInProjectFolder
	Dir.chdir( "build" )
	FileUtils.rm_rf( "./")
	system( "cmake -G \"NMake Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
	Dir.chdir( ".." )
end

def showUsage
	puts "RMake v1.0 - CMake project file generator"
	puts "Created by Rajinder Yadav <info@devmentor.org>"
	puts "Copyright (c) DevMentor.org May 21, 2012\n\n"
	puts "Use: rmake <project_name> <source_header_files>\n\n"
	puts "To re-generate a CMake project file, cd into the project folder and type:\n\n"
	puts "rmake g:eclipse - Eclipse CDT project"
	puts "rmake g:name    - Linux GNU makefile"
	puts "rmake g:nmake   - VC++ NMake makefile"
	exit(0)
end


# === MAIN START ===
$fVisualCPP    = true if( ENV["VCINSTALLDIR"] != nil )
$fLinuxOS = true if( RUBY_PLATFORM =~ /linux/i || system("uname") =~ /linux/i || ENV["OSTYPE"] =~ /linux/i )
$fVisualStudio = true if( ENV["VCINSTALLDIR"] =~ /Visual Studio/i )

if( ARGV.size == 0 || ARGV[0] == '?' || ARGV[0] == '-help' )
	showUsage
end

# just regenerate CMake make file and exit
case( ARGV[0] )
when "g:eclipse"
	genCMakeEclipse
	exit(0)
when "g:make"
	genCMakeLinux
	exit(0)
when "g:nmake"
	genCMakeVisualStudio
	exit(0)
end

# create projects folder layout 
arg_list = ARGV

project_name = arg_list[0]

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
	Dir.mkdir( "build" )
end

if( !Dir.exist? "src" )
	Dir.mkdir( "src" )
	Dir.chdir( "src" )
	Dir.mkdir( "test" )
	Dir.chdir( ".." )
end


# create blank source, header files
Dir.chdir( "src" )

header_file.each do |filename|
	fileSafeCreateHeader( filename )
end

source_file.each do |filename|
	fileSafeCreateSource( filename )
end

# create a generic CMakeLists.txt file
File.open( "CMakeLists.txt", "w" ) do |file|
	file.puts( "cmake_minimum_required(VERSION 2.6)" )
	file.puts( "project(#{project_name})" )
	file.puts( "\n" )
	file.puts( "set( BOOST_INCLUDE \"/home/yadav/dev/cpp/boost_1.49.0/include/\" )" )
	file.puts( "set( BOOST_LIB \"/home/yadav/dev/cpp/boost_1.49.0/lib/\" )" )
	file.puts( "\n" )
	file.puts( "include_directories(\"${PROJECT_SOURCE_DIR}\" \"${BOOST_INCLUDE}\")" )
	file.puts( "#link_directories(\"${BOOST_LIB}\")" )
	file.puts( "\n" )
	file.puts( "set(SOURCE_FILES #{source_file.join(' ')})" )
	file.puts( "set(HEADER_FILES #{header_file.join(' ')})" )
	file.puts( "\n" )
	file.puts( "add_executable(#{project_name} ${SOURCE_FILES} ${HEADER_FILES})" )
	file.puts( "\n" )
	file.puts( "#set(LIB_FILES )" )
	file.puts( "#target_link_libraries(#{project_name} ${LIB_FILES})" )
	file.puts( "#add_subdirectory(test)" )
end

if( File.exist?( "main.cpp" ) )
	File.open( "main.cpp", "w+" ) do |f|
		f.puts "#include <iostream>"
		f.puts "\n"
		f.puts "using namespace std;"
		f.puts "\n"
		f.puts "int main( int argc, char* argv[] )\n{\n    return 0;\n}\n"
	end
end

Dir.chdir( ".." )

# generate Eclipse project
genCMakeEclipse

Dir.chdir( ".." )

# == MAIN END ===
