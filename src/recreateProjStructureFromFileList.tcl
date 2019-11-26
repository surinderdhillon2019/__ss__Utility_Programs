
# This script takes in Three input arguments 
# < Arg 1 > : Full Path of project direcotry
# < Arg 2 > : Relative path of place and route folder from project directory
# < Arg 3 > : Full path and name of Input file that contain all required file to reconstruct this project. This File ...
#           : should be derived from Build.tcl file. 

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
        # check for duplication
        if { [ is_member $dirList $dirName ]==true } {
            continue
        } else {
            lappend dirList $dirName
        }
    }
    return  $dirList
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
proc recreateProjStructureFromFileList { srcDir fileList } {

    set dirList  [ findDirs $fileList ] 
    set dirList_new {}

    # Find project dir Name
    set projName     [getProjName $srcDir] 
    set projName_New [getProjName_New $srcDir]
    puts $projName_New
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


# *************************************** Main Function *********************************************************
# *************************************** Main Function *********************************************************
# *************************************** Main Function *********************************************************
# *************************************** Main Function *********************************************************

    if { $argc != 3 } {
        puts " \n\n********************       This tcl script require 3 input args     ****************************\n\n"
        puts " \n\n********************             Use case Example                   ****************************\n\n"
        puts "tclsh recreateProjStructureFromFileList.tcl /home/ssingh/Documents/Project/embeddedsw /test/Project  Source_Tcl.dat \n\n"
    } else {
        set projDir [lindex $argv 0] 
        set placeNroute [lindex $argv 1] 
        set infile [lindex $argv 2] 

        if { [ file isdirectory $projDir ] } {
            puts "valid Dir : $projDir"
        } else {
            puts stderr " Directory does not exist \n$$projDir"
            exit 1
        }

        if { [ file isdirectory $projDir$placeNroute ] } {
            puts "valid Dir : $projDir$placeNroute"
        } else {
            puts stderr " Directory does not exist \n$$projDir$placeNroute"
            exit 1
        }

        if { [ file isfile $infile ] } {
            puts "valid input file : $infile"
        } else {
            puts stderr " File does not exist \n$$infile"
            exit 1
        }                        

        set infile [open $infile r]
        set number 0
        set fileList {} 
        while { [gets $infile line] >= 0 } {
            lappend fileList $line
            incr number
        }
        puts "Number of Files :  $number" 
        close $infile

        set fileList_New {} 
        foreach item $fileList {
            lappend fileList_New  $projDir$placeNroute$item
        }
        recreateProjStructureFromFileList $projDir $fileList_New
        }


# *************************************** End of Main  Function *********************************************************
# *************************************** End of Main  Function *********************************************************
# *************************************** End of Main  Function *********************************************************
# *************************************** End of Main  Function *********************************************************