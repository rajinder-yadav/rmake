RMAKE - The Ruby CMake C++ project creator

Author: Rajinder Yadav <info@devmentor.org>
Date: May 21, 2012

Description: The RMake script creates a project folder with declared source and header files as well as a build and test folder with an Eclipse project ready to use.

To use the rmake script from anywhere, on Linux add the following alias to your ~/.bachrc file.

alias rmake='~/rmake/rmake.rb'

NOTE: make sure the path points to where to have saved rmake.rb, above it's assume it in the user home subfolder of ~/rmake

No Windows you will need to edit the PATH environment variable and add the folder path where rmake.rb is located.


Importing the Eclipse project (Linux)
=====================================
Launch Eclipse, then from the file menu select:

File -> New -> "Make project with existing code"

1. Select Linux GCC for the toochain
2. Browse to the existing project root
3. Click finish

After the project is imported, from eclipse, right-click on the project name and pick "Properties" to bring up the project settings, or use the <Alt+Enter> shortcut.

Next click on "C/C++ Builds"

1. Uncheck use default build command and type: "make VERBOSE=1"
2. Click workspace button and select the folder "build" for this project
3. Click OK

Next expand on "C/C++ General" and select "Path & Symbols"

1. Click on the "Source Location" tab
2. Click "Add Folder" button and select folder "src"
3. Click OK

You should now be able to build and debug your C++ project.


Importing the Eclipse project (Windows & VC++)
==============================================

Now we import our project into Eclipse.
Launch Eclipse and from the file menu select:

File -> New -> "Make project with existing code"

1. Select "Microsoft Visual C++" for the toochain
2. browse to the existing project root
3. click finish

We need to determine where the Include and Lib folder can be found. 
To do this from VC++ command prompt type:

echo %VSINSTALLDIR%
echo %WindowsSdkDir%

Once the project is imported, select it and right-click and pick "Properties" to bring up the project settings, or use the <Alt+Enter> shortcut.

1. Select "C/C++ Build" -> "Settings"
2. Click on "Linker" -> "Libraries"
3. Under "Addtional libpath" click on the "+" icon
4. Enter path to Lib folder, if should be something like

"C:\Program Files\Microsoft SDKs\Windows\v7.0A\Lib"
or
"C:\Program Files\Microsoft Visual Studio 10.0\VC\lib"

Next expand on "C/C++ General" and select "Path & Symbols"
1. Click on the "Source Location" tab
2. Click "Add Folder" button and select "src" folder
3. Click OK

We now need to excluse the build folder from the build process.
1. Right click on the build folder
2. Select "Resource Configurations" -> "Exclude from build"
3. Select ALL and click OK

You should be able to build and run your project.

--
Rajinder Yadav <info@devmentor.org>

http://git.devmentor.org/rmake

Thank you for using RMake, your support is very appreciated!
Happy Hacking =)
