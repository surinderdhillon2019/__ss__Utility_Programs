# file provides three sets of functionality: 
#     String manipulation appropriate to parsing file names
#         dirname ........ Returns directory portion of path
#         extension ........ Returns file name extension
#         join ........ Join directories and the file name to one string
#         nativename ....... Returns the native name of the file/directory
#         rootname ....... Returns file name without extension
#         split ........ Split the string into directory and file names
#         tail .................... Returns filename without directory 
#     Information about an entry in a directory:
#         atime ................ Returns time of last access
#         executable ..... Returns 1 if file is executable by user
#         exists ................ Returns 1 if file exists
#         isdirectory ...... Returns 1 if entry is a directory
#         isfile .................. Returns 1 if entry is a regular file
#         lstat ................... Returns array of file status information
#         mtime ............... Returns time of last data modification
#         owned ................ Returns 1 if file is owned by user
#         readable ............ Returns 1 if file is readable by user
#         readlink ............. Returns name of file pointed to by a symbolic link
#         size ..................... Returns file size in bytes
#         stat ..................... Returns array of file status information
#         type .................... Returns type of file
#         writable ............ Returns 1 if file is writeable by user 
#     Manipulating the files and directories themselves:
#         copy ................ Copy a file or a directory
#         delete ................ Delete a file or a directory
#         mkdir ................ Create a new directory
#         rename ................ Rename or move a file or directory 
# 

proc findFiles { basedir pattern } {
    set basedir [ string trimright [ file join [file normalize $basedir] { } ] ]
    set fileList {}
    # return files from current dir
    foreach fileName [ glob -nocomplain -type {f r} -path $basedir $pattern ] {
        lappend fileList $fileName
    }

    foreach dirName [ glob -nocomplain -type {d  r} -path $basedir * ] {

        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList  
}


proc is_member { dirList dirName } {
    foreach item $dirList {
        if { $item==$dirName } {
            return true
        } 
    }
    return false
}

proc findDirs { fileList } {
    set dirList {}  
    puts [llength $fileList]  
    foreach item $fileList {
        set dirName [ file dirname $item]
        if { [ is_member $dirList $dirName ]==true } {
            continue
        } else {
            lappend dirList $dirName
        }
    }
    return  $dirList
}


# put list in a file
proc load_List { ListName {fileName "debug.dat"} } {

    set outfile [open $fileName w]

    foreach item $ListName {
        puts $outfile "$item"
    }

}

proc getProjName { srcDir } {
    # Find project dir Name
    set projectDir [ split $srcDir "/" ]
    return  [lindex $projectDir [ expr { [ llength $projectDir ] - 1 } ] ]       
}

proc getProjName_New { srcDir } {
    # Find project dir Name
    set projDir [getProjName $srcDir] 
    return New_$projDir
}


# create dir structure in Downloads dir
proc copyProjDirStructure { srcDir fileType debugFile } {
    set systemTime [clock seconds]

    set fileList [ findFiles $srcDir $fileType ]
    load_List $fileList  $debugFile

    set dirList  [ findDirs $fileList ] 

    set dirList_new {}

    # Find project dir Name
    set projName     [getProjName $srcDir] 
    set projName_New [getProjName_New $srcDir]

    foreach item $dirList {
        lappend dirList_new [string map [ list $projName $projName_New ]  $item ]
    }    

    foreach item $dirList_new {
        if { [ file isdirectory $item ] } {
            continue
        } else {
            file mkdir $item
        }
    }
    
    return $fileList
}

proc copyProjFiles { srcDir fileList } {
    
    # Find project dir Name
    set projName     [getProjName $srcDir] 
    set projName_New [getProjName_New $srcDir]

    foreach item $fileList {
        set new_File_Path [string map [ list $projName $projName_New ]  $item ]
        if { [ file isdirectory [ file dirname $new_File_Path ]  ] } {
            file copy -force $item $new_File_Path
        } else {
            file mkdir [ file dirname $new_File_Path ]
            file copy $item $new_File_Path
        }
    }  
}

# Set the baseDir to project path
# Set fileType_To_Search to desired file that user want to copy from project directory
# Script will create new poject with same Name with New_ as prefix added to it @ same dir level

set Create_New_Proj_Dir Create_New_Proj_Dir
 if {$Create_New_Proj_Dir=="Create_New_Proj_Dir"} {  

    set baseDir /home/ssingh/Documents/Project/Tcl

    # List of file type to search in base Dir
    set fileType_To_Search {*.tcl *.txt }    

    set systemTime [clock seconds]

    set desired_Format [clock format $systemTime -format {%H_%M_%S} ]



    foreach item $fileType_To_Search {
        set fileToWrite [concat ../debug_Files/Debug_[ string trim $item *. ]_$desired_Format.dat]
        copyProjFiles $baseDir [ copyProjDirStructure $baseDir $item $fileToWrite ]

    }       
 }