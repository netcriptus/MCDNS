######### Setting Parameters ##########
set val(channel) Channel/WirelessChannel;      # Channel Type
set val(propagation) Propagation/TwoRayGround; # Radio Propagation Model
set val(net_interface) Phy/WirelessPhy;        # Network interface type
set val(mac) Mac/802_11;                       # Mac type
set val(queue) Queue/DropTail/PriQueue;        # Queue Type
set val(link_layer) LL;                        # Link Layer Type
set val(antenna) Antenna/OmniAntenna;          # Antenna type
set val(queue_len) 50;                         # Maximum packets in queue
set val(mobile_nodes) 30;                      # Number of mobile numbers
set val(routing) AODV;                         # Routing protocol
set val(x) 1000;                               # Grid in x axis
set val(y) 1000;                               # Grid in y axis
set val(stop) 150;                             # Time simulation ends

set topo [new Topography]

######## Applying parameters to node ########

# For some reason, this is now required for wireless
set channel_1 [new $val(channel)]

$ns_ node-config -adhocRouting $val(routing) \
                 -llType $val(link_layer) \
                 -ifqType $val(queue) \
                 -ifqLen $val(queue_len) \
                 -antType $val(antenna) \
                 -propType $val(propagation) \
                 -phyType $val(net_interface) \
                 -channel $channel_1 \
                 -macType $val(mac) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF \
                 -movementTrace OFF
                
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(mobile_nodes)]

######### Setting transmission range to 250 m ########
set RXThresh_ 3.65262e-10
