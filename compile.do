# compile.do

# Set the project library name
set libname work

# Create the library
vlib $libname
vmap $libname $libname

# Set the source directory
set srcdir ./dpi

# Compile the package first
vlog -sv $srcdir/FileIO_pkg.sv

# Compile the SystemVerilog files
vlog -sv ./example.sv

# Load the simulation and specify the shared library
#vsim -lib $libname top -sv_lib $srcdir/server

# Run the simulation
vsim -lib $libname top 
run -all

# End of compile.do
