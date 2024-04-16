set val(stop) 10.0 ;# time of simulation end
set ns [new Simulator]
set tracefile [open 21CSB0B36_Q3.tr w]
$ns trace-all $tracefile
set namfile [open 21CSB0B36_Q3.nam w]
$ns namtrace-all $namfile
$ns color 1 Blue
$ns color 2 Red

# Open trace file for congestion window
set tfile1 [open cwnd1.tr w]
set tfile2 [open cwnd2.tr w]


#Create 9 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

$n0 label "Main Router"
$n1 label "Source 1"
$n2 label "Source 2"

# Create LAN
$ns make-lan "$n3 $n4 $n5 $n6 $n7 $n8 $n9 $n10" 512Kb 50ms LL Queue/DropTail

# Links Definition
$ns duplex-link $n1 $n0 1000kb 60ms DropTail
$ns queue-limit $n1 $n0 6
$ns duplex-link $n2 $n0 1000kb 60ms DropTail
$ns queue-limit $n2 $n0 6
$ns duplex-link $n0 $n3 500kb 60ms DropTail
$ns queue-limit $n0 $n3 7
#Give node position (for NAM)
$ns duplex-link-op $n1 $n0 orient right-down
$ns duplex-link-op $n2 $n0 orient right-up
$ns duplex-link-op $n0 $n3 orient right

# Agents Definition
set tcp0 [new Agent/TCP/Reno]
$ns attach-agent $n1 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n7 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500
$tcp0 set class_ 1
set tfile1 [open cwnd1.tr w]
$tcp0 attach $tfile1
$tcp0 trace cwnd_

set tcp5 [new Agent/TCP/Vegas]
$ns attach-agent $n2 $tcp5
set sink6 [new Agent/TCPSink]
$ns attach-agent $n8 $sink6
$ns connect $tcp5 $sink6
$tcp5 set packetSize_ 1500
$tcp5 set class_ 2
set tfile2 [open cwnd2.tr w]
$tcp5 attach $tfile2
$tcp5 trace cwnd_

# Applications Definition
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 0.3 "$ftp0 start"
$ns at 8.0 "$ftp0 stop"

set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp5
$ns at 0.3 "$ftp4 start"
$ns at 8.0 "$ftp4 stop"

# Function to plot congestion window
proc plotWindow {tcpSource outfile} {
    global ns
    set now [$ns now]
    set cwnd [$tcpSource set cwnd_]

    # Record data in the trace file
    puts $outfile "$now $cwnd"

    # Schedule next plotting
    $ns at [expr $now+0.1] "plotWindow $tcpSource $outfile"
}

# Attach tracing for congestion window to agents
$tcp0 trace cwnd_ $tfile1
$tcp5 trace cwnd_ $tfile2

# Start congestion window plotting
$ns at 0.0 "plotWindow $tcp0 $tfile1"
$ns at 0.0 "plotWindow $tcp5 $tfile2"

# Termination function
proc finish {} {
    global ns tfile1 tfile2
    $ns flush-trace
    close $tfile1
    close $tfile2
    exec xgraph cwnd1.tr cwnd2.tr -geometry 800x400 &
    exec nam 21CSB0B36_Q3.nam &
    exit 0
}

# Set up simulation end events
$ns at $val(stop) "finish"
$ns at $val(stop) "$ns halt"

# Run simulation
$ns run
