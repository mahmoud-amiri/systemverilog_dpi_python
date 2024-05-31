
# Set the project library name
set libname work

# Create the library
vlib $libname
vmap $libname $libname

# Set the source directory
set srcdir ../dpi

# Compile the package first
vlog -sv $srcdir/server_pkg.sv
vlog -sv $srcdir/FileIO_pkg.sv
vlog -sv $srcdir/JSONParser_pkg.sv
vlog -sv $srcdir/server_api_pkg.sv

# Compile the SystemVerilog files
vlog -sv ./server_sv.sv

# Run the simulation
vsim -lib $libname top -sv_lib $srcdir/server
run -all

