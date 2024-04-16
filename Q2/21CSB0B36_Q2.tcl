set val(stop)   10.0;
set ns [new Simulator]
set tracefile [open 21CSB0B36_Q2.tr w]
$ns trace-all $tracefile
set namfile [open 21CSB0B36_Q2.nam w]
$ns namtrace-all $namfile

#Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
$n0 label "ping1"
$n1 label "ping2"
$n2 label "R1"
$n3 label "R2"
$n4 label "ping3"
$n5 label "ping4"
$ns color 1 red
$ns color 2 blue
$ns color 3 green
$ns color 4 orange

#Createlinks between nodes
$ns duplex-link $n0 $n2 1000kb 60ms DropTail
$ns queue-limit $n0 $n2 2
$ns duplex-link $n1 $n2 1000kb 60ms DropTail
$ns queue-limit $n1 $n2 2
$ns duplex-link $n2 $n3 100Kb 60ms DropTail
$ns queue-limit $n2 $n3 2
$ns duplex-link $n3 $n4 1000kb 60ms DropTail
$ns duplex-link $n3 $n5 500kb 60ms DropTail

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

set ping0 [new Agent/Ping]
$ns attach-agent $n0 $ping0
set ping1 [new Agent/Ping]
$ns attach-agent $n1 $ping1
set ping4 [new Agent/Ping]
$ns attach-agent $n4 $ping4
set ping5 [new Agent/Ping]
$ns attach-agent $n5 $ping5
$ns connect $ping0 $ping4
$ns connect $ping1 $ping5

proc sendPingPacket {} {
        global ns ping0 ping1
        set intervalTime 0.01
        set now [$ns now]
        $ns at [expr $now + $intervalTime] "$ping0 send"
        $ns at [expr $now + $intervalTime] "$ping1 send"
        $ns at [expr $now + $intervalTime] "sendPingPacket"
}

#rtt=round trip time(packet travel from src to dest and back to src)
Agent/Ping instproc recv {from rtt} {
        global seq
        $self instvar node_
        puts "The node [$node_ id] received an ACK from the node $from with RTT $rtt ms"
}

$ping0 set class_ 1
$ping1 set class_ 2
$ping4 set class_ 3
$ping5 set class_ 4

#'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam 21CSB0B36_Q2.nam &
    exit 0
}

$ns at 0.01 "sendPingPacket"
$ns at 10.0 "finish"
$ns run 
#end

