set ns_ [new Simulator]
set trace [open trace.tr w]

$ns_ trace-all $trace

source options.tcl
source setupFunctions.tcl

# creating nodes
for {set i 0} {$i < $val(mobile_nodes)} {incr i} {
  set node_($i) [$ns_ node]
}

source movements.tcl
