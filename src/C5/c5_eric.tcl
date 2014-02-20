isim force add clk40 1 -value 0 -time 12.5 ns -repeat 25 ns 
isim force add rst_n 0
isim force add en 0
isim force add B 0
isim force add cd 0
isim force add q0 1
run 25ns
isim force add rst_n 1
run 250ns
isim force add en 1
run 25ns
isim force add en 0
run 500ns
run 50ns
isim force add q0 0
isim force add en 1
run 25ns
isim force add en 0
run 500ns
