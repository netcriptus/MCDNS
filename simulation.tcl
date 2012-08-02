set ns_ [new Simulator]
set trace [open trace.tr w]

$ns_ trace-all $trace

# Creating randomness
set RRR [new RNG]
$RRR seed 0

# Creating the pointer to the name server
set NS_pointer 0
# Creating the translation table
set table(-1) 0
# Creating hit counts and misses count on the table
set table_hits 0
set table_misses 0

# Creating sender agent and receiver agent
set sink [new Agent/Null]
set sender [new Agent/UDP]

set cbr_ [new Application/Traffic/CBR]

source options.tcl
source setupFunctions.tcl

# creating nodes
for {set i 0} {$i < $val(mobile_nodes)} {incr i} {
  set node_($i) [$ns_ node]
}

source movements.tcl
source DNScalls.tcl

proc finish {} {
    global ns_ trace
    
    $ns_ flush-trace
    close $trace

    exit 0

}

$ns_ at 1.0 "translate_address $node_(0) $node_(1)"
$ns_ at 30.0 "finish"
$ns_ run