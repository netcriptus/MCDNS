proc send_packet {src targ} {
  global ns_
  global sink sender

  $ns_ attach-agent $src $sender
  $ns_ attach-agent $targ $sink
  
  $sender start

}

proc start_name_server {} {
  global NS_pointer
  global val
  global node_
  global table
  
  for {set i 0} {$i < $val(mobile_nodes)} {incr i} {
    send_packet $NS_pointer $node_($i)
    set table($i) 1
  }
}

proc translate_address {source_node target_node} {
  global NS_pointer
  global table_hits
  global table_misses
  
  # Is there a name server? If not, become it.
  if {!$NS_pointer} {
    set NS_pointer $source_node
    start_name_server
  }
  
  # Do we have this guy's address?
  if {[info exists table($target_node)]} {
    incr table_hits
  } else {
    incr table_misses
  }
  
  # Am I the name server?
  if {$NS_pointer != $source_node} {
    send_packet $NS_pointer $source_node
  }
}