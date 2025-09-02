#setup.do file
#Christian Carreira		7/27/2025
#NOTE: Check the #(SET MANUALLY)# sections before running
#NOTE: Use puts "" statements to debug if needed
#NOTE: [pwd] returns the current directory
#NOTE: If using MIF or HEX files for memory initialization, remember to put a copy in the project folder

#TODO: Maybe create run.do file in the project folder that just compiles and runs the sim?

#======================================
#Directory / Path Management
#======================================

#Sets the current directory
set current_directory [pwd]

if {![file exists Project_Files]} {
	file mkdir Project_Files
}

#Sets the project directory
set project_directory [pwd]/Project_Files
					
#(SET MANUALLY)#
#Sets VHDL file directory
set VHDL_directory [pwd]../../VHDL_Source/

#======================================
#Project Creation
#======================================

if { [file exists $project_directory/DilithiumSim.mpf] } {
    puts "Project already exists, opening..."
	#Open the project
    project open $project_directory/DilithiumSim
	
	# Get the list of all files in the project
	set file_list [project filenames]

	# Loop through the files and delete VHDL files
	foreach file $file_list {
		if {[string match "*.vhd" $file] || [string match "*.vhdl" $file]} {
			puts "Deleting VHDL file: $file"
			project removefile $file
		}
	}

} else {
    puts "Creating new project"
	#Create a new project
    project new $project_directory DilithiumSim work
}

#======================================
#Project Add VHDL Files
#======================================
#(SET MANUALLY)#
#Add new VHDL files to this list
project addfile $VHDL_directory/GlobalVars.vhd
project addfile $VHDL_directory/ZetaForwardROM.vhd
project addfile $VHDL_directory/ZetaInverseROM.vhd
project addfile $VHDL_directory/MontgomeryReducer.vhd
project addfile $VHDL_directory/butterfly.vhd
project addfile $VHDL_directory/ntt.vhd
project addfile $VHDL_directory/ram.vhd
project addfile $VHDL_directory/ramControl.vhd
project addfile $VHDL_directory/mainControl.vhd
project addfile $VHDL_directory/Testbench.vhd

#Calculates the proper order if above files are in an incorrect order, uncomment for debugging
#project calculateorder

#======================================
#Project Compilation and Simulation
#======================================

#Compiles all files

#VHDL 2008
#set files [project filenames]
#foreach file $files {
#    if {[string match "*.vhd" $file] || [string match "*.vhdl" $file]} {
#        puts "Compiling $file with VHDL-2008"
#        vcom -2008 $file
#    }
#}

#or

#VHDL 2002
project compileall


#(SET MANUALLY)#
#Change this filename to whatever file you wish to sim as a top level
vsim Testbench

if { [file exists $project_directory/wave.do] } {
#Runs the latest state of the wave sim, make sure it saves as wave.do (default)
	do wave.do
}

#Load all signals (remove if sim becomes too slow)
log * -r

#Start the sim
run 50 us
#run -all