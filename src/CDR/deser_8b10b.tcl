#----------------------------------------
# send a bit string, lsb first
#----------------------------------------
proc send10b { bs } {
    puts "Sending $bs"
    set n [string length $bs]
    for { set i 0 } {$i < $n } {incr i} {
        set bv [string index $bs $i ]
	puts "  bit = $bv"
	if {$bv == "1"} {
	    isim force add d 1
	} else {
	    isim force add d 0
	}
	isim force add dv 1
	run 8ns
	isim force add d 0
	isim force add dv 0
	run 32ns
    }
}
#------------------------------------------------------------
# main simulation
#------------------------------------------------------------
# set up clock
isim force add clk 1 -value 0 -time 4 ns -repeat 8 ns 
isim force add rst_n 0
isim force add d 0
isim force add dv 0
run 32ns
isim force add rst_n 1 
run 32ns
send10b 0011111001 ; # K.28.1 3c 
send10b 1001110100 ; # D.0.0  00
send10b 1000101011 ; # D.1.0  01
send10b 1011010100 ; # D.2.0  02
send10b 1100010100 ; # D.3.0  03
send10b 0010101011 ; # D.4.0  04
send10b 1111       ; # out of sync
send10b 0011111001 ; # K.28.1 3c 
send10b 1001110100 ; # D.0.0  00
send10b 1000101011 ; # D.1.0  01
send10b 1011010100 ; # D.2.0  02
send10b 1100010100 ; # D.3.0  03
send10b 0010101011 ; # D.4.0  04
send10b 1001110100 ; # D.0.0  00
send10b 1001110100 ; # D.0.0  00




