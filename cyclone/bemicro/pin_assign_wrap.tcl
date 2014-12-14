# called from quartus or makefile:
# arg0: <modulename> 
# arg1: <top> 
# arg2: -c <rev> 
# <variant>_pin_assignments.tcl expects "<top> " to be open

set module [lindex $quartus(args) 0]
set top    [lindex $quartus(args) 1]
set rev    [lindex $quartus(args) 3]

package require ::quartus::project
set need_to_close_project 0
set make_assignments 1

if {[is_project_open]} {
    if {[string compare $quartus(project) "$top"]} {
	post_message "Project $top is not open"
	set make_assignments 0
    } else {
	post_message "Project $top is open"
    }
} else {
    if {[project_exists $top]} {
	project_open $top
	set need_to_close_project 1
	post_message "Project $top opened"
	set need_to_close_project 1
    } else {
	post_message "Project $top doesnt exist"
    }
}

set script_dir [file dirname [info script]]

if {$make_assignments} {
    if [string match "quartus_map" $module] {
	if { [file exists "$script_dir/pin_assign.tcl" ] } {
	    post_message "Running pin assignement $script_dir/pin_assign.tcl"
	    source "$script_dir/pin_assign.tcl"
	}
    }
    if {$need_to_close_project} {
	project_close
    }
}
