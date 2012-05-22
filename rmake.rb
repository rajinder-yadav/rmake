#!/usr/local/bin/ruby
#
# Author: Rajinder Yadav <info@devmentor.org>
# Date: May 21, 2012
# Web : www.devmentor.org

# CMake list file generator and project creator
# specifically designed for making an Eclipse project

require "fileutils"
require "shell"

def fileSafeCreate( name )
	return if( File.exist?( name ) )
	File.open(name, "w+" ) do |file|
	end
end

def projectSafeCreate( name )
	return if( File.exist?( name ) )
	Dir.mkdir( name )
end

def genCMakeEclipse
	Dir.chdir( "build" )
	FileUtils.rm_rf( "./")
	system( "cmake -G \"Eclipse CDT4 - Unix Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
	Dir.chdir( ".." )
end

def genCMakeLinux
	Dir.chdir( "build" )
	FileUtils.rm_rf( "./")
	system( "cmake -G \"Unix Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
	Dir.chdir( ".." )
end

def genCMakeVisualStudio
	Dir.chdir( "build" )
	FileUtils.rm_rf( "./")
	system( "cmake -G \"NMake Makefiles\" -D CMAKE_BUILD_TYPE=Debug ../src" )
	Dir.chdir( ".." )
end

def showUsage
	puts "RMake - CMake project file generator\n"
	puts "Use: rmake <project_name> <source_header_files>*\n\n"
	puts "To regenerate a CMake file, cd into project folder and type:"
	puts "rmake g:eclipse - Eclipse CDT project"
	puts "rmake g:name    - Linux GNU makefile"
	puts "rmake g:nmake   - VC++ NMake makefile"
end


# === MAIN START ===

if( ARGV.size == 0 )
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
	fileSafeCreate( filename )
end

source_file.each do |filename|
	fileSafeCreate( filename )
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

Dir.chdir( ".." )

# generate Eclipse project
genCMakeEclipse

Dir.chdir( ".." )

# == MAIN END ===
