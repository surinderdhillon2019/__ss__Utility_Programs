
# This script takes in atleast one argument along with multiple other arguments 
# < Arg 1 >      : Full Path of project direcotry
# < Arg 2 - N  > : (Optional Arg) File type to extract from project dir Ex : *.c *.h *.tcl *vhd


# This will recursively search all files under baseDir of input pattern
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

# check if directory already exist in dirList
proc is_member { dirList dirName } {
    foreach item $dirList {
        if { $item==$dirName } {
            return true
        } 
    }
    return false
}

# This will return all the required sub directories based of input fileList
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

# This will return project Name from srcDir path
proc getProjName { srcDir } {
    # Find project dir Name
    set projectDir [ split $srcDir "/" ]
    return  [lindex $projectDir [ expr { [ llength $projectDir ] - 1 } ] ]       
}

# This will return new Project Name from srcDir
proc getProjName_New { srcDir } {
    # Find project dir Name
    set projDir [getProjName $srcDir] 
    return New_$projDir
}


# create dir structure in New_$srdDir directory
proc copyProjDirStructure { srcDir fileType debugFile } {

    set fileList [ findFiles $srcDir $fileType ]
    load_List $fileList  $debugFile

    set dirList  [ findDirs $fileList ] 

    set dirList_new {}

    # Find project dir Name
    set projName     [getProjName $srcDir] 
    set projName_New [getProjName_New $srcDir]
    puts " original Proj: $projName , New Proj : $projName_New"
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


# ****************************************** Main Function ******************************************************
# ****************************************** Main Function ******************************************************
# ****************************************** Main Function ******************************************************
# ****************************************** Main Function ******************************************************


    # Set the baseDir to project path
    # Set fileType_To_Search to desired file that user want to copy from project directory
    # Script will create new poject with same Name with New_ as prefix added to it @ same dir level

        set systemTime [clock seconds]
        set desired_Format [clock format $systemTime -format {%H_%M_%S} ]

        if { $argc < 1} {
            puts " \n\n******************** User must define at least project Dir Path ****************************\n\n"
            puts " \n\n********************             Use case Example               ****************************\n\n"
            puts "tclsh file_IO_command.tcl /home/ssingh/Documents/Project/embeddedsw *.c *.h \n\n"            
        } else {
        
            set baseDir [lindex $argv 0] 

            if { $argc > 1 } {
                set fileType_To_Search {}
                set skipFirst true
                foreach item $argv {
                    if {  $skipFirst != "true"  } {
                        puts "$item "
                        lappend fileType_To_Search $item 
                    }
                    set skipFirst false
                }
            } else {
                # List of file type to search in base Dir
                set fileType_To_Search {*.tcl *.txt }   
            }
            foreach item $fileType_To_Search {
                
                set fileToWrite [concat ../debug_Files/Debug_[ string trim $item *. ]_$desired_Format.dat]                        
                copyProjDirStructure $baseDir $item $fileToWrite
            }
        }


# ****************************************** End Function ******************************************************
# ****************************************** End Function ******************************************************
# ****************************************** End Function ******************************************************
# ****************************************** End Function ******************************************************