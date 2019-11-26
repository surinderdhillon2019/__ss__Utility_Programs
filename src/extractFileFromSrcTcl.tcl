set srcTcl /home/ssingh/Documents/Project/Vivado/CPU.tcl
set substring "origin_dir"
set infile [open $srcTcl r]
set fileList {}
set number 0
while { [gets $infile line] >= 0 } {
    if {[string first $substring $line] != -1} {
        lappend fileList "$line"
    }    
}
set outfile [open test.dat w]
foreach item $fileList {
    puts $outfile $item
}