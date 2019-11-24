
# example script 
# turn off ! to run each script


set hello !hello
 if {$hello=="hello"} {   
puts "***********************************************************"
   puts "Hello, World - In quotes"    ;# This is a comment after the command.
   # This is a comment at beginning of a line
   puts {Hello, World - In Braces}
   puts {Bad comment syntax example}   # *Error* - there is no semicolon!
   
   puts "This is line 1"; puts "this is line 2"
   
   puts "Hello, World; - With  a semicolon inside the quotes"
   
   # Words don't need to be quoted unless they contain white space:
   puts HelloWorld
   
 }

set curly_bracket !curly_bracket
 if {$curly_bracket=="curly_bracket"} {   
   puts "***********************************************************"
   set Z Albany
   set Z_LABEL "The Capitol of New York is: "
   
   puts "$Z_LABEL $Z"   ;# Prints the value of Z
   puts "$Z_LABEL \$Z"  ;# Prints a literal $Z instead of the value of Z
   
   puts "\nBen Franklin is on the \$100.00 bill"
   
   set a 100.00
   puts "Washington is not on the $a bill"    ;# This is not what you want
   puts "Lincoln is not on the $$a bill"      ;# This is OK
   puts "Hamilton is not on the \$a bill"     ;# This is not what you want
   puts "Ben Franklin is on the \$$a bill"    ;# But, this is OK
   
   puts "\n................. examples of escape strings"
   puts "Tab\tTab\tTab"
   puts "This string prints out \non two lines"
   puts "This string comes out\
   on a single line"
 }

set sq_bracket !sq_bracket
 if {$sq_bracket=="sq_bracket"} {   
   puts "***********************************************************"
   set x abc
   puts "A simple substitution: $x\n"
   
   set y [set x "def"]
   puts "Remember that set returns the new value of the variable: X: $x Y: $y\n"
   
   set z {[set x "This is a string within quotes within braces"]}
   puts "Note the curly braces: $z\n"
   
   set a "[set x {This is a string within braces within quotes}]"
   puts "See how the set is executed: $a"
   puts "\$x is: $x\n"
   
   set b "\[set y {This is a string within braces within quotes}]"
   # Note the \ escapes the bracket, and must be doubled to be a
   # literal character in double quotes
   puts "Note the \\ escapes the bracket:\n \$b is: $b"
   puts "\$y is: $y"   zset number [expr {int(1.2/0.1)}] 
   zfor { set i 0 } { $i <= $number } { incr i } {
   z   set x [expr {$i*0.1}]
   z   puts "create label $x"
   z}
   zputs "***********************************************************"
   zset x     0.0
   zset delta 0.1
   zwhile { $x < 1.2+0.5*$delta } {
   z   puts "create label $x"
   z   set x [expr {$x + $delta}]
   z}
 }


set proc_Ex !proc_Ex
 if {$proc_Ex=="proc_Ex"} {   
   puts "***********************************************************"
        proc example {first {second ""} args} {
            if {$second eq ""} {
                puts "There is only one argument and it is: $first"
                return 1
            } else {
                if {$args eq ""} {
                    puts "There are two arguments - $first and $second"
                    return 2
                } else {
                    puts "There are many arguments - $first and $second and $args"
                    return "many"
                }
            }
        }
        
        set count1 [example ONE]
        set count2 [example ONE TWO]
        set count3 [example ONE TWO THREE ]
        set count4 [example ONE TWO THREE FOUR]
        
        puts "The example was called with $count1, $count2, $count3, and $count4 Arguments"
 }

set list_Ex !list_Ex
 if {$list_Ex=="list_Ex"} {   
   puts "***********************************************************"
       set x "a b c"
       puts "Item at index 2 of the list {$x} is: [lindex $x 2]\n"
       
       set y [split 7/4/1776 "/"]
       puts "We celebrate on the [lindex $y 1]'th day of the [lindex $y 0]'th month\n"
       
       set z [list puts "arg 2 is $y" ]
       puts "A command resembles: $z\n"
       
       set i 0
       foreach j $x {
           puts "$j is item number $i in list x"
           incr i
       }

 }


set get_files !get_files
 if {$get_files=="get_files"} {   
   puts "***********************************************************"
   # This procedure shows how to search for C files in a given directory
   
   proc findMatchingCFiles {dir {extension *.c}} {
      puts "Searching Extension : $extension in path : $dir"
      set files {}
      switch $::tcl_platform(platform) {
         windows {
             puts "Window Platform"
            set ext .obj
         }
         unix {
             puts "Unix Platform"
            set ext .o
         }
      }
      foreach file [glob -nocomplain -directory $dir $extension] {
         puts $file
         set objectFile [file tail [file rootname $file]]$ext
         puts $objectFile
         if {[file exists $objectFile]} {
            lappend files $file
         }
      }
      return $files
   }

   set src_Dir /home/ssingh/Documents/Project/INIPARSER
   set file_var [ findMatchingCFiles $src_Dir ]
   foreach j $file_var {
       puts $j
   }
}



set findFiles_Ex !findFiles_Ex
 if {$findFiles_Ex=="findFiles_Ex"} {   
   puts "***********************************************************"

# findFiles
# basedir - the directory to start looking in
# pattern - A pattern, as defined by the glob command, that the files must match
proc findFiles { basedir pattern } {

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}

    # Look in the current directory for matching files, -type {f r}
    # means ony readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }

    # Now look for any sub direcories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Recusively call the routine on the sub directory and append any
        # new files to the results
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList
 }

foreach item [findFiles /home/ssingh/Documents/Project/INIPARSER  *.c] {
   puts "$item \n"
}
eval exec ls [glob *.tcl]

 }
set add_list !add_list
 if {$add_list=="add_list"} {   
   puts "***********************************************************"
   # Adding & Deleting members of a list

   set b [list a b {c d e} {f {g h}}]
   puts "Treated as a list: $b\n"

   set b [split "a b {c d e} {f {g h}}"]
   puts "Transformed by split: $b\n"

   set a [concat a b {c d e} {f {g h}}]
   puts "Concated: $a\n"

   lappend a {ij K lm}                        ;# Note: {ij K lm} is a single element
   puts "After lappending: $a\n"

   set b [linsert $a 3 "1 2 3"]               ;# "1 2 3" is a single element
   puts "After linsert at position 3: $b\n"

   set b [lreplace $b 3 5 "AA" "BB"]
   puts "After lreplacing 3 positions with 2 values at position 3: $b\n"
}


set lsearch_Ex !lsearch_Ex
 if {$lsearch_Ex=="lsearch_Ex"} {   
   puts "***********************************************************"
   set list [list {Washington 1789} {Adams 1797} {Jefferson 1801} \
                  {Madison 1809} {Monroe 1817} {Adams 1825} ]

   set x [lsearch $list Washington*]
   set y [lsearch $list Madison*]
   incr x
   incr y -1                        ;# Set range to be not-inclusive

   set subsetlist [lrange $list $x $y]

   puts "The following presidents served between Washington and Madison"
   foreach item $subsetlist {
      puts "Starting in [lindex $item 1]: President [lindex $item 0] "
   }

   set x [lsearch $list Madison*]

   set srtlist [lsort $list]
   set y [lsearch $srtlist Madison*]

   puts "\n$x Presidents came before Madison chronologically"
   puts "$y Presidents came before Madison alphabetically"
 }



set String_comparisons !String_comparisons
 if {$String_comparisons=="String_comparisons"} {   
   puts "***********************************************************"
   set fullpath "/usr/home/clif/TCL_STUFF/TclTutor/Lsn.17"
   set relativepath "CVS/Entries"
   set directorypath "/usr/bin/"

   set paths [list $fullpath $relativepath $directorypath]

   foreach path $paths  {

       set first [string first "/" $path]
       set last [string last "/" $path]
      puts "first : $first, last : $last"
       # Report whether path is absolute or relative

       if {$first != 0} {
           puts "$path is a relative path"
       } else {
           puts "$path is an absolute path"
       }

       # If "/" is not the last character in $path, report the last word.
       # else, remove the last "/", and find the next to last "/", and
       #   report the last word.

       incr last
       if {$last != [string length $path]} {
           set name [string range $path $last end]
           puts "The file referenced in $path is $name"
       } else {
           incr last -2;
           set tmp [string range $path 0 $last]
           set last [string last "/" $tmp]
           incr last;
           set name [string range $tmp $last end]
           puts "The final directory in $path is $name"
       }

       # CVS is a directory created by the CVS source code control system.
       #

       if {[string match "*CVS*" $path]} {
           puts "$path is part of the source code control tree"
       }

       # Compare to "a" to determine whether the first char is upper or lower case
       set comparison [string  compare $name "a"]
       if {$comparison >= 0} {
           puts "$name starts with a lowercase letter\n"
       } else {
           puts "$name starts with an uppercase letter\n"
       }
   }    

 }


 set format_String !format_String
 if {$format_String=="format_String"} {   
   puts "***********************************************************"
   set upper "THIS IS A STRING IN UPPER CASE LETTERS"
   set lower "this is a string in lower case letters"
   set trailer "This string has trailing dots ...."
   set leader "....This string has leading dots"
   set both  "((this string is nested in parens )))"

   puts "tolower converts this: $upper"
   puts "              to this: [string tolower $upper]\n"
   puts "toupper converts this: $lower"
   puts "              to this: [string toupper $lower]\n"
   puts "trimright converts this: $trailer"
   puts "                to this: [string trimright $trailer .]\n"
   puts "trimleft converts this: $leader"
   puts "               to this: [string trimleft $leader .]\n"
   puts "trim converts this: $both"
   puts "           to this: [string trim $both "()"]\n"

   set labels [format "%-20s %+10s " "Item" "Cost"]
   set price1 [format "%-20s %10d Cents Each" "Tomatoes" "30"]
   set price2 [format "%-20s %10d Cents Each" "Peppers" "20"]
   set price3 [format "%-20s %10d Cents Each" "Onions" "10"]
   set price4 [format "%-20s %10.2f per Lb." "Steak" "3.59997"]

   puts "\n Example of format:\n"
   puts "$labels"
   puts "$price1"
   puts "$price2"
   puts "$price3"
   puts "$price4"

 }




 set Associative_Arrays !Associative_Arrays
   if {$Associative_Arrays=="Associative_Arrays"} {   
      puts "***********************************************************"
      proc addname {first last} {
       global name

       # Create a new ID (stored in the name array too for easy access)

       incr name(ID)
       set id $name(ID)

       set name($id,first) $first   ;# The index is simply a string!
       set name($id,last)  $last    ;# So we can use both fixed and
                                    ;# varying parts
   }

   #
   # Initialise the array and add a few names
   #
   global name
   set name(ID) 0

   addname Mary Poppins
   addname Uriah Heep
   addname Rene Descartes
   addname Leonardo "da Vinci"

   #
   # Check the contents of our database
   # The parray command is a quick way to
   # print it
   #
   parray name

   #
   # Some array commands
   #
   array set array1 [list {123} {Abigail Aardvark} \
                          {234} {Bob Baboon} \
                          {345} {Cathy Coyote} \
                          {456} {Daniel Dog} ]

   puts "Array1 has [array size array1] entries\n"

   puts "Array1 has the following entries: \n [array names array1] \n"

   puts "ID Number 123 belongs to $array1(123)\n"

   if {[array exist array1]} {
       puts "array1 is an array"
   } else {
       puts "array1 is not an array"
   }

   if {[array exist array2]} {
       puts "array2 is an array"
   } else {
       puts "array2 is not an array"
   }

   proc existence {variable} {
       upvar $variable testVar
       if { [info exists testVar] } {
   	puts "$variable Exists"
       } else {
   	puts "$variable Does Not Exist"
       }
   }

   # Create an array
   for {set i 0} {$i < 5} {incr i} { set a($i) test }

   puts "\ntesting unsetting a member of an array"
   existence a(0)
   puts "a0 has been unset"
   unset a(0)
   existence a(0)

   puts "\ntesting unsetting several members of an array, with an error"
   existence a(3)
   existence a(4)
   catch {unset a(3) a(0) a(4)}
   puts "\nAfter attempting to delete a(3), a(0) and a(4)"
   existence a(3)
   existence a(4)

   puts "\nUnset all the array's elements"
   existence a
   array unset a *

   puts "\ntesting unsetting an array"
   existence a
   puts "a has been unset"
   unset a
   existence a
 }


 set dict_Ex !dict_Ex
   if {$dict_Ex=="dict_Ex"} {   
      puts "***********************************************************"
      # Create a dictionary:
      # Two clients, known by their client number,
      # with forenames, surname
      #
      dict set clients 1 forenames Joe
      dict set clients 1 surname   Schmoe
      dict set clients 2 forenames Anne
      dict set clients 2 surname   Other

      #
      # Print a table
      #
      puts "Number of clients: [dict size $clients]"
      dict for {id info} $clients {
         puts "Client $id:"
         dict with info {
            puts "   Name: $forenames $surname"
         }
      }

   }

   
 set numOfLines_Count numOfLines_Count
   if {$numOfLines_Count=="numOfLines_Count"} {   
      puts "***********************************************************"   
      # Count the number of lines in a text file
      #
      set infile [open "common_tcl.tcl" r]
      set number 0

      #
      # gets with two arguments returns the length of the line,
      # -1 if the end of the file is found
      #
      while { [gets $infile line] >= 0 } {
          incr number
      }
      close $infile

      puts "Number of lines: $number"

      #
      # Also report it in an external file
      #
      set outfile [open "report.out" w]
      puts $outfile "Number of lines: $number"
      close $outfile
}


# Retrieving all the files with extension ".tcl" in the current directory: 
set report_tcl !report_tcl
 if {$report_tcl=="report_tcl"} {   
   puts "***********************************************************"
    set tclfiles [glob *.tcl]
    puts "Name - date of last modification"
    foreach f $tclfiles {
        #puts "$f - [clock format [file mtime $f] -format %x]"
        puts   " [format "%20s" $f] - [clock format [file mtime $f] ]"
    }
 }

#
# Report all the files and subdirectories in the current directory
# For files: show the size
# For directories: show that they _are_ directories
#
set report_all !report_all
 if {$report_all=="report_all"} {   
   puts "***********************************************************"
    set dirs [glob -nocomplain -type d *]
    if { [llength $dirs] > 0 } {
        puts "Directories:"
        foreach d [lsort $dirs] {
            puts "    $d"
        }
    } else {
        puts "(no subdirectories)"
    }

    set files [glob -nocomplain -type f *]
    if { [llength $files] > 0 } {
        puts "Files:"
        foreach f [lsort $files] {
            puts "    [file size $f] - $f"
        }
    } else {
        puts "(no files)"
    }
 }    


# put list in a file
proc load_List { ListName {fileName "debug.dat"} } {
        set outfile [open $fileName w]
        foreach item $ListName {
            puts $outfile "$item"
        }
}
