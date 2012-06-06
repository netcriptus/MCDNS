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


proc finish {} {
    global ns_ trace
    
    $ns_ flush-trace
    close $trace

    exit 0

}


$ns_ at 160.0 "finish"
$ns_ run