#
## Script de simulacao dos ataques - VALIDACAO
#

load /home/urlan/Projeto/NS2/SOURCE/EXECUTAVEIS/JAMMING/lib/libdei80211mr.so

if {$argc == 7} {
   set valor_simulacao [lindex $argv 0] ;# valor da simulacao atual
   set protocol [lindex $argv 1] ;# tipo de protocolo que serah usado
   set tipo_ataque [lindex $argv 2] ;# tipo do ataque: "deceptive", "reactive" e "random"
   set perc_de_atacantes [lindex $argv 3] ;# porcentagem de atacantes na rede
   set opt(tamanho_cenario) [lindex $argv 4] ;# tamanho do cenario
   set opt(nn) [lindex $argv 5] ;# numero de nos da rede
   set opt(num_traffics) [lindex $argv 6] ;# numero de trafegos na rede
}

set power "on"

if { $protocol == "802.11" } {
   set power "off"
}


# ======================================================================
# Define options
# ======================================================================
set opt(file_)		"ARQUIVOS_PADRAO/NOS/$opt(nn)/posicao_dos_nos.pos"
set opt(trafego_)       "ARQUIVOS_PADRAO/TRAFEGO/trafego-udp.trf"
set opt(nout)		"simulacao.nam"
set opt(tout)		"simulacao.tr"
set opt(chan)		Channel/WirelessChannel/PowerAware
set opt(prop)		Propagation/FreeSpace/PowerAware
set opt(netif)		Phy/WirelessPhy/PowerAware
set opt(mac)		Mac/802_11/Multirate
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)		Antenna/OmniAntenna
set opt(x)		$opt(tamanho_cenario)
set opt(y)		$opt(tamanho_cenario)
set opt(ifqlen)		50	      		;# numero de pacotes maximos na ifq
set opt(PR) 		AODV 			;# protocolo de roteamento
set opt(stop) 		300			;# tempo de parada
set opt(num_atacantes)	[expr  $opt(nn) * $perc_de_atacantes / 100]		;# numero de atacantes
set opt(start_attackers) 		5			;#tempo que os atacantes iniciam o ataque
#set opt(stop_attackers) 		200			;#tempo que os atacantes finalizam o ataque
set opt(stop_attackers) 		100			;#tempo que os atacantes finalizam o ataque

# =====================================================================

Phy/WirelessPhy set  Pt_          0.200; # For 250m transmission range
Phy/WirelessPhy set freq_ 2437e6
Phy/WirelessPhy set L_ 1.0

LL set mindelay_		1us
LL set delay_			1us
LL set bandwidth_		0	;# not used

Mac/802_11 set bSyncInterval_ 20e-6
Mac/802_11 set gSyncInterval_ 10e-6
Mac/802_11 set ShortRetryLimit_ 3
Mac/802_11 set LongRetryLimit_ 5

Mac/802_11/Multirate set PowerControlDecision $power
Mac/802_11/Multirate set Protocol $protocol

Mac/802_11/Multirate set RTSThreshold_ 10
#Mac/802_11/Multirate set RTSThreshold_ 10000
Mac/802_11/Multirate set dump_interf_ 0

PowerProfile set debug_ 0
Phy/WirelessPhy set debug_ 0
Mac/802_11/Multirate set debug_ 0

# ======================================================================
# Procedures
# ======================================================================

# Procedure que retorna ifq

Node/MobileNode instproc getIfq { param0} {
    $self instvar ifq_    
    return $ifq_($param0) 
}

# Procedure que retorna phy

Node/MobileNode instproc getPhy { param0} {
    $self instvar netif_    
    return $netif_($param0) 
}

Node/MobileNode instproc getLL { param0} {
    $self instvar ll_    
    return $ll_($param0)
}

# ============================================ #
# ===== Procedure that creates           ===== #
# ===== deceptive jamming attack          ===== #
# ============================================ #

proc createDeceptiveJamming {origem tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "Deceptive Jammer: $origem - INICIO: $tempo_inicial - FIM: $tempo_final"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($origem) $jammer_

   # Criando o trafego para a origem
   set cbr_ [new Application/Traffic/CBR]

   $cbr_ set packetSize_ 128
   $cbr_ set interval_ 0.0001
   #$cbr_ set rate_ 50000000
   $cbr_ set random_ 1
   $cbr_ set maxpkts_ 100000000000

   # Conectando a origem ao destino
   $cbr_ attach-agent $jammer_
   #$ns_ connect $jammer_ $null

   set ll_src_ [$node_($origem) getLL 0]
   $cbr_ target $ll_src_

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ deceptive-jamming
   $mac($origem) jamming deceptive

   $mac($origem) jamming start-attack $tempo_inicial
   $mac($origem) jamming stop-attack $tempo_final

   $ns_ at $tempo_inicial "$cbr_ start"
   $ns_ at $tempo_final "$cbr_ stop"
}
# ============================================ #
# ===== Procedure that creates           ===== #
# ===== balanced random jamming attack   ===== #
# ============================================ #

proc createBalancedRandomJamming {origem tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "Balanced Random Jammer: $origem - INICIO: $tempo_inicial - FIM: $tempo_final"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($origem) $jammer_

   # Criando o trafego para a origem
   set cbr_ [new Application/Traffic/CBR]

   $cbr_ set packetSize_ 128
   $cbr_ set interval_ 0.0001
   #$cbr_ set rate_ 50000000
   $cbr_ set random_ 1
   $cbr_ set maxpkts_ 100000000000

   # Conectando a origem ao destino
   $cbr_ attach-agent $jammer_
   #$ns_ connect $jammer_ $null

   set ll_src_ [$node_($origem) getLL 0]
   $cbr_ target $ll_src_

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ random-jamming
 #  $jammer_ type-random-jamming balanced

   $ns_ at $tempo_inicial "$cbr_ start"
   $ns_ at $tempo_final "$cbr_ stop"

   $mac($origem) jamming random
   $mac($origem) jamming random balanced

   $mac($origem) jamming start-attack $tempo_inicial
   $mac($origem) jamming stop-attack $tempo_final
}

# ============================================ #
# ===== Procedure that creates           ===== #
# ===== rare random jamming attack       ===== #
# ============================================ #

proc createRareRandomJamming {origem tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "Rare Random Jammer: $origem - INICIO: $tempo_inicial - FIM: $tempo_final"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($origem) $jammer_

   # Criando o trafego para a origem
   set cbr_ [new Application/Traffic/CBR]

   $cbr_ set packetSize_ 128
   $cbr_ set interval_ 0.0001
   #$cbr_ set rate_ 50000000
   $cbr_ set random_ 1
   $cbr_ set maxpkts_ 100000000000

   # Conectando a origem ao destino
   $cbr_ attach-agent $jammer_
   #$ns_ connect $jammer_ $null

   set ll_src_ [$node_($origem) getLL 0]
   $cbr_ target $ll_src_

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ random-jamming
   #$jammer_ type-random-jamming rare

   $ns_ at $tempo_inicial "$cbr_ start"
   $ns_ at $tempo_final "$cbr_ stop"

   $mac($origem) jamming random
   $mac($origem) jamming random rare

   $mac($origem) jamming start-attack $tempo_inicial
   $mac($origem) jamming stop-attack $tempo_final
}

# ============================================ #
# ===== Procedure that creates           ===== #
# ===== frequent random jamming attack   ===== #
# ============================================ #

proc createFrequentRandomJamming {origem tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "Frequent Random Jammer: $origem - INICIO: $tempo_inicial - FIM: $tempo_final"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($origem) $jammer_

   # Criando o trafego para a origem
   set cbr_ [new Application/Traffic/CBR]

   $cbr_ set packetSize_ 128
   $cbr_ set interval_ 0.0001
   #$cbr_ set rate_ 50000000
   $cbr_ set random_ 1
   $cbr_ set maxpkts_ 100000000000

   # Conectando a origem ao destino
   $cbr_ attach-agent $jammer_
   #$ns_ connect $jammer_ $null

   set ll_src_ [$node_($origem) getLL 0]
   $cbr_ target $ll_src_

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ random-jamming
  # $jammer_ type-random-jamming frequent

   $ns_ at $tempo_inicial "$cbr_ start"
   $ns_ at $tempo_final "$cbr_ stop"

   $mac($origem) jamming random
   $mac($origem) jamming random frequent

   $mac($origem) jamming start-attack $tempo_inicial
   $mac($origem) jamming stop-attack $tempo_final
}


# ============================================ #
# ===== Procedure that creates           ===== #
# ===== cts reactive jamming attack      ===== #
# ============================================ #

proc createCTSReactiveJamming {attacker tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "CTS Reactive Jammer: $attacker"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($attacker) $jammer_

   set ll_src_ [$node_($attacker) getLL 0]

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ reactive-jamming

   $mac($attacker) jamming reactive-cts

   $mac($attacker) jamming start-attack $tempo_inicial
   $mac($attacker) jamming stop-attack $tempo_final
}


# ============================================ #
# ===== Procedure that creates           ===== #
# ===== data reactive jamming attack     ===== #
# ============================================ #

proc createDataReactiveJamming {attacker tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "DATA Reactive Jammer: $attacker"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($attacker) $jammer_

   set ll_src_ [$node_($attacker) getLL 0]

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ reactive-jamming

   $mac($attacker) jamming reactive-data

   $mac($attacker) jamming start-attack $tempo_inicial
   $mac($attacker) jamming stop-attack $tempo_final
}


# ============================================ #
# ===== Procedure that creates           ===== #
# ===== rts reactive jamming attack      ===== #
# ============================================ #

proc createRTSReactiveJamming {attacker tempo_inicial tempo_final}  {
   global ns_ node_ opt tipo_ataque mac

   puts "RTS Reactive Jammer: $attacker"

   # Criando Agente UDP
   set jammer_ [new Agent/Jamming]
   $ns_ attach-agent $node_($attacker) $jammer_

   set ll_src_ [$node_($attacker) getLL 0]

   $ll_src_ up-target $jammer_

   $jammer_ target $ll_src_
   $jammer_ add-ll $ll_src_

   $jammer_ reactive-jamming

   $mac($attacker) jamming reactive-rts

   $mac($attacker) jamming start-attack $tempo_inicial
   $mac($attacker) jamming stop-attack $tempo_final
}

#
# Procedimento que cria o fluxo de ataque
#

proc createAttack { attacker pos } {
   global mac opt atacante dst_atac phy tipo_ataque

   if {$tipo_ataque == "balanced_random_jamming"} {
      createBalancedRandomJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   } elseif {$tipo_ataque == "frequent_random_jamming"} {
      createFrequentRandomJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   } elseif {$tipo_ataque == "rare_random_jamming"} {
      createRareRandomJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   } elseif {$tipo_ataque == "deceptive_jamming"} {
      createDeceptiveJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   } elseif {$tipo_ataque == "data_reactive_jamming"} {
      createDataReactiveJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   } elseif {$tipo_ataque == "rts_reactive_jamming"} {
      createRTSReactiveJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   } elseif {$tipo_ataque == "cts_reactive_jamming"} {
      createCTSReactiveJamming $attacker $opt(start_attackers) $opt(stop_attackers)
   }
}

# ============================================ #
# ===== Procedure that writes in         ===== #
# ===== the final of the file            ===== #
# ============================================ #

proc escreveFinalArquivo {nome_arq aux} {
   set arq [open $nome_arq "a+"]
   puts $arq "$aux"
   close $arq
}

# ============================================ #
# ===== Procedure that writes in         ===== #
# ===== the final of the file            ===== #
# ============================================ #

proc escrevePosicaoFinalArquivo {nome_arq pos aux} {
   set arq [open $nome_arq "a+"]
   puts $arq "$pos $aux"
   close $arq
}

# ==================================================== #
# ===== Procedimento que faz a verificacao dos   ===== #
# ===== atacantes e chama as funcoes dos ataques ===== #
# ==================================================== #

proc selectAttackers {} {
   global ns_ opt tipo_ataque num_attackers mac origem destino valor_simulacao

      set new_atac 2

      createAttack $new_atac $num_attackers
      #$mac($new_atac) dca off
}

proc verificaRSSI {protocol} {
   global opt mac atacante origem destino tipo_ataque dst_atac phy

   set num_amostras 1800

   set nome_arq "$protocol-rssi.txt"
   set arq [open $nome_arq "a+"]

   for {set i 0} {$i < $num_amostras} {incr i} {
      set rssi($i) [$mac($destino(0)) metrics return-rssi $i]
 
      puts $arq "$rssi($i)"
   }
  
   close $arq
}

# =========================================== #
# ===== Procedure that verifies metrics ===== #
# =========================================== #

proc verifyMetrics {} {
   global opt mac atacante tipo_ataque protocol

   for {set i 0} {$i < [expr $opt(nn)]} {incr i} {

      if {$i != 2} {

         for {set j 0} {$j < [expr $opt(stop) - 1]} {incr j} {

            set nome_arq_collisions_rate "$protocol-$tipo_ataque-collisions_rate-noh_$i-$j.dat"
            set nome_arq_recv_broadcast_rate "$protocol-$tipo_ataque-recv_broadcast_rate-noh_$i-$j.dat"
            set nome_arq_sent_broadcast_rate "$protocol-$tipo_ataque-sent_broadcast_rate-noh_$i-$j.dat"
            set nome_arq_recv_retransmission_rate "$protocol-$tipo_ataque-recv_retransmission_rate-noh_$i-$j.dat"
            set nome_arq_sent_retransmission_rate "$protocol-$tipo_ataque-sent_retransmission_rate-noh_$i-$j.dat"
            set nome_arq_nav_rate "$protocol-$tipo_ataque-nav_rate-noh_$i-$j.dat"
            set nome_arq_recv_frames_rate "$protocol-$tipo_ataque-recv_frames_rate-noh_$i-$j.dat"
            set nome_arq_sent_frames_rate "$protocol-$tipo_ataque-sent_frames_rate-noh_$i-$j.dat"
            set nome_arq_recv_goodput_rate "$protocol-$tipo_ataque-recv_goodput_rate-noh_$i-$j.dat"
            set nome_arq_sent_goodput_rate "$protocol-$tipo_ataque-sent_goodput_rate-noh_$i-$j.dat"


            set size [$mac($i) metrics $j return-size]

            for {set k 0} {$k < [expr $size]} {incr k} {

               set collisions_rate [$mac($i) metrics $j $k return-collisions-rate]
               set recv_broadcast_rate [$mac($i) metrics $j $k return-recv-broadcast-rate]
               set sent_broadcast_rate [$mac($i) metrics $j $k return-sent-broadcast-rate]
               set recv_retransmission_rate [$mac($i) metrics $j $k return-recv-retransmission-rate]
               set sent_retransmission_rate [$mac($i) metrics $j $k return-sent-retransmission-rate]
               set nav_rate [$mac($i) metrics $j $k return-nav-rate]
               set recv_frames_rate [$mac($i) metrics $j $k return-recv-frames-rate]
               set sent_frames_rate [$mac($i) metrics $j $k return-sent-frames-rate]
               set recv_goodput_rate [$mac($i) metrics $j $k return-recv-goodput-rate]
               set sent_goodput_rate [$mac($i) metrics $j $k return-sent-goodput-rate]

               escreveFinalArquivo $nome_arq_collisions_rate $collisions_rate
               escreveFinalArquivo $nome_arq_recv_broadcast_rate $recv_broadcast_rate
               escreveFinalArquivo $nome_arq_sent_broadcast_rate $sent_broadcast_rate
               escreveFinalArquivo $nome_arq_recv_retransmission_rate $recv_retransmission_rate
               escreveFinalArquivo $nome_arq_sent_retransmission_rate $sent_retransmission_rate
               escreveFinalArquivo $nome_arq_nav_rate $nav_rate
               escreveFinalArquivo $nome_arq_recv_frames_rate $recv_frames_rate
               escreveFinalArquivo $nome_arq_sent_frames_rate $sent_frames_rate
               escreveFinalArquivo $nome_arq_recv_goodput_rate $recv_goodput_rate
               escreveFinalArquivo $nome_arq_sent_goodput_rate $sent_goodput_rate
            }
         } 
      }
   }
}

# =========================================== #
# ===== Procedure that verifies metrics ===== #
# =========================================== #

proc verifyAverageMetrics {} {
   global opt mac atacante tipo_ataque protocol

   for {set i 0} {$i < [expr $opt(nn)]} {incr i} {

      if {$i != 2} {

         set nome_arq_collisions_rate "$protocol-$tipo_ataque-avg-collisions_rate-noh_$i.dat"
         set nome_arq_recv_broadcast_rate "$protocol-$tipo_ataque-avg-recv_broadcast_rate-noh_$i.dat"
         set nome_arq_sent_broadcast_rate "$protocol-$tipo_ataque-avg-sent_broadcast_rate-noh_$i.dat"
         set nome_arq_recv_retransmission_rate "$protocol-$tipo_ataque-avg-recv_retransmission_rate-noh_$i.dat"
         set nome_arq_sent_retransmission_rate "$protocol-$tipo_ataque-avg-sent_retransmission_rate-noh_$i.dat"
         set nome_arq_nav_rate "$protocol-$tipo_ataque-avg-nav_rate-noh_$i.dat"
         set nome_arq_recv_frames_rate "$protocol-$tipo_ataque-avg-recv_frames_rate-noh_$i.dat"
         set nome_arq_sent_frames_rate "$protocol-$tipo_ataque-avg-sent_frames_rate-noh_$i.dat"
         set nome_arq_recv_goodput_rate "$protocol-$tipo_ataque-avg-recv_goodput_rate-noh_$i.dat"
         set nome_arq_sent_goodput_rate "$protocol-$tipo_ataque-avg-sent_goodput_rate-noh_$i.dat"

         for {set j 0} {$j < [expr $opt(stop) - 1]} {incr j} {

            set size [$mac($i) metrics $j return-size]

            set sum_collisions_rate 0.0
            set sum_recv_broadcast_rate 0.0
            set sum_sent_broadcast_rate 0.0
            set sum_recv_retransmission_rate 0.0
            set sum_sent_retransmission_rate 0.0
            set sum_nav_rate 0.0
            set sum_recv_frames_rate 0.0
            set sum_sent_frames_rate 0.0
            set sum_recv_goodput_rate 0.0
            set sum_sent_goodput_rate 0.0


            for {set k 0} {$k < [expr $size]} {incr k} {

               set sum_collisions_rate [expr $sum_collisions_rate + [$mac($i) metrics $j $k return-collisions-rate]]
               set sum_recv_broadcast_rate [expr $sum_recv_broadcast_rate + [$mac($i) metrics $j $k return-recv-broadcast-rate]]
               set sum_sent_broadcast_rate [expr $sum_sent_broadcast_rate + [$mac($i) metrics $j $k return-sent-broadcast-rate]]
               set sum_recv_retransmission_rate [expr $sum_recv_retransmission_rate + [$mac($i) metrics $j $k return-recv-retransmission-rate]]
               set sum_sent_retransmission_rate [expr $sum_sent_retransmission_rate + [$mac($i) metrics $j $k return-sent-retransmission-rate]]
               set sum_nav_rate [expr $sum_nav_rate + [$mac($i) metrics $j $k return-nav-rate]]
               set sum_recv_frames_rate [expr $sum_recv_frames_rate + [$mac($i) metrics $j $k return-recv-frames-rate]]
               set sum_sent_frames_rate [expr $sum_sent_frames_rate + [$mac($i) metrics $j $k return-sent-frames-rate]]
               set sum_recv_goodput_rate [expr $sum_recv_goodput_rate + [$mac($i) metrics $j $k return-recv-goodput-rate]]
               set sum_sent_goodput_rate [expr $sum_sent_goodput_rate + [$mac($i) metrics $j $k return-sent-goodput-rate]]

            }

            escrevePosicaoFinalArquivo $nome_arq_collisions_rate $j [expr double($sum_collisions_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_recv_broadcast_rate $j [expr double($sum_recv_broadcast_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_sent_broadcast_rate $j [expr double($sum_sent_broadcast_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_recv_retransmission_rate $j [expr double($sum_recv_retransmission_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_sent_retransmission_rate $j [expr double($sum_sent_retransmission_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_nav_rate $j [expr double($sum_nav_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_recv_frames_rate $j [expr double($sum_recv_frames_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_sent_frames_rate $j [expr double($sum_sent_frames_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_recv_goodput_rate $j [expr double($sum_recv_goodput_rate) / double($size)]
            escrevePosicaoFinalArquivo $nome_arq_sent_goodput_rate $j [expr double($sum_sent_goodput_rate) / double($size)]
         } 
      }
   }
}

# ======================================================================

# ============= #
# Main Program  #
# ============= #

# create simulator instance
set ns_ [new Simulator]

# sensing threshold in dB above noise power
set sensingTreshdB 5

# data rate
set PHYDataRate Mode11Mb

# base rate
set PHYBaseRate Mode1Mb

# escreve na tela o valor da simulacao atual
puts "Iniciando simulacao numero $valor_simulacao"

# Objeto de topografia
set topo [new Topography]

# Criando objetos de saida
set tracefd [open $opt(tout) w]
#set namtrace [open $opt(nout) w]

$ns_ trace-all $tracefd
#$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Definindo a topografia
$topo load_flatgrid $opt(x) $opt(y)

# Create G.O.D.
set god_ [create-god $opt(nn)]

# Canal
set chan_ [new $opt(chan)]

# Configurando os nos
$ns_ color 1 Red

$ns_ node-config -adhocRouting $opt(PR) \
                -llType $opt(ll) \
                -macType $opt(mac) \
                -ifqType $opt(ifq) \
                -ifqLen $opt(ifqlen) \
                -antType $opt(ant) \
                -propType $opt(prop) \
                -phyType $opt(netif) \
                -topoInstance $topo \
		-agentTrace ON \
                -routerTrace OFF \
		-macTrace ON \
                -ifqTrace OFF \
		-channel $chan_



# Creating nodes

#set peerstats [new PeerStatsDB/Static]
#$peerstats numpeers [expr $opt(nn) + 1]

set noisePower 7e-11

for {set i 0} {$i < [expr $opt(nn)]} {incr i} {

    set node_($i)  [$ns_ node]
    
    #   This is replaced below by '$mac_ nodes'
    #	$n($i) initMultirateWifi 0 

    $node_($i) setPowerProfile 0 [new PowerProfile]

    set mac($i) [$node_($i) getMac 0]
    set ifq($i) [$node_($i) getIfq 0]
    set phy($i) [$node_($i) getPhy 0]

    $mac($i) dataMode_ $PHYDataRate
    $mac($i) basicMode_ $PHYBaseRate
    $mac($i) nodes $opt(nn)

   # if { $protocol == "AEWMA" } {
   #    set current_alpha 0.125
       # setando o alpha inicial da tecnica AEWMA com o valor $current_alpha
  #     $mac($i) PowerControlDecision $protocol setCurrentAlpha $current_alpha

 #   }

    set per($i) [new PER]


    # 802.11B
    $per($i) loadPERTable80211bIntersilHFA3861B
   # $per($i) loadPERTable80211gTrivellato
    $per($i) set debug_ 0
    

    $node_($i) setPER 0 $per($i)
    $per($i) set noise_ $noisePower
    
    set opt(CSThresh) [expr $noisePower *  pow ( 10 , $sensingTreshdB / 10.0 ) ]

    $phy($i) set CSThresh_ $opt(CSThresh)

    $node_($i) random-motion 0

#    $mac($i) dca on
}

if { $opt(file_) == "" } {
	puts "*** Arquivo de nos nao especificado. ***"
        set opt(file_) "none"
} else {
	puts "Carregando as posicoes dos nos"
	source $opt(file_)
}

set origem(0) 0
set destino(0) 1

puts "Trafego 0: $origem(0) --> $destino(0)"

set num_attackers 0

if {$opt(num_atacantes) > 0} {
   $ns_ at 0.5 "selectAttackers"
}

#
## Carregando o arquivo de trafego
#

if { $opt(trafego_) == "" } {
	puts "*** Arquivo de trafego nao especificado. ***"
        set opt(trafego_) "none"
} else {
	puts "Carregando o trafego da simulacao"
	source $opt(trafego_)
}


#
## Terminando a simulacao
#

$ns_ at  $opt(stop) "verifyMetrics"
$ns_ at  $opt(stop) "verifyAverageMetrics"
$ns_ at  $opt(stop).000000001 "puts \"Simulacao terminada...\" ; $ns_ halt"

puts "Inicializando simulacao..."
$ns_ run
