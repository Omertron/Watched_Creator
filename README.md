YAMJ Watched Creator
====================

Simple AutoIT script to create watched files for YAMJ v2

The code is provided here as anti-virus programs often mark these sort of programs as a virus. 

You can download AutoIT from here http://www.autoitscript.com/

# Usage
Simply run the EXE file, at the first run the program will create a INI file with the default configuration options.

## Configuration
The `Watched Creator.ini` file is used to control the behaviour of the application.

Make changes to the file and restart the application for them to take effect.

### Starting Directory
Controls the directory which the program will start scanning from. Set this to the lowest level that you will use, e.g. the root of your video drive.

*Default / Example:*

    StartDir=T:\Films\

### File Types
A list of file extensions to create the watched files for.

*Default / Example:*

    FileTypes=AVI,MKV,MPG,ISO

### Scan BluRay folders
Creates watched files for BluRay folders. 

This will create the watched file using the name of the folder that the `BDMV` folder is in.

*Default / Example:*

    IncludeBluRay=True

### Scan DVD folders
Creates watched files for DVD rip folders. 

This will create the watched file using the name of the folder that the `VIDEO_TS` folder is in.

*Default / Example:*

    IncludeVideoTS=True

### Use Custom Output Directory
The default behaviour of the application is to create watched files with the video files themselves.  Changing this to `True` will allow you to change the directory using the `OutputDir` setting to one of your choosing.

*Default / Example:*

    CustomOutputDir=False
    
### Output Directory
The directory to create the watched files in if the setting `CustomOutputDir` is `True` .

*Default / Example:*

    OutputDir=T:\Jukebox\Watched
    
### Exclusion List
A comma separated list of words that will exclude a directory from the automatic creation of watched files.

*Default / Example:*

    SkipList=RECYCLE.BIN
