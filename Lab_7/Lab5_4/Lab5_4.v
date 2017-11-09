`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Digitális technika Laboratórium 5. hét
// 5_4 feladat: BCD számlálók
// 16 bites, 4 dekádos szinkron törölhetõ, tölthetõ, engedélyezhetõ, felfelé/lefelé 
// számláló BCD számláló egység 
// A számláló állapotait a LED-eken és a 7 szegmenses kijelzõn is kijelezzük.
// A kijelzéshez felhasználjuk a LIP_4digit IP modult.
//////////////////////////////////////////////////////////////////////////////////
module Lab5_4(
    input clk,
    input rst,
    input mosi,
    output miso,
    input [3:0] bt,
    input [7:0] sw,
    output [7:0] ld,
    input clk16M,
    output [7:0] seg_n,
    output [3:0] dig_n,
    output [4:0] col_n
    );

//////////////////////////////////////////////////////////////////////////////////
// Belsõ jelek definiálása 
// Eleve 4 db 4 bites BCD számláló kaszkádosítására készülünk
// Ennek megfelelõen definiáljuk a belsõ jeleket.
// A négy egység jele szabványos prefixek alapján: K-kilo, H-hecto, D-deka, U-unit
//////////////////////////////////////////////////////////////////////////////////

wire [3:0] q_k, q_h, q_d, q_u;            // 4 dekádnyi BCD számjegy kód
wire load_k, load_h, load_d, load_u ;     // 4 töltés jel, páronként azonos lesz 
wire dir = bt[3];                         // Közös irányvezérlés a BT[3]-mal 
wire en_k, en_h, en_d, en_u;              // 4 engedélyezõ jel
wire tc_k, tc_h, tc_d, tc_u;              // 4 végérték jelzés

//////////////////////////////////////////////////////////////////////////////////
// 4 db 4 bites BCDCNT beépítése engedélyezési lánccal
//////////////////////////////////////////////////////////////////////////////////

assign en_u = mosi;                       // Globális engedélyezés
assign load_u = bt[0];                    // Alsó bájt töltés engedélyezés sw[3:0]
BCDCNT     BCD_U (.clk(clk), .rst(rst), .load(load_u), .dir(dir), 
                      .en(en_u), .tc(tc_u), .d(sw[3:0]), .q(q_u));

assign en_d = tc_u;                       // Units-Deka engedélyezés
assign load_d = bt[0];                    // Alsó bájt töltés engedélyezés sw [7:4]
BCDCNT     BCD_D (.clk(clk), .rst(rst), .load(load_d), .dir(dir), 
                      .en(en_d), .tc(tc_d), .d(sw[7:4]), .q(q_d));

assign en_h = tc_d;                       // Hecto-Deka engedélyezés
assign load_h = bt[1];                    // Felsõ bájt töltés engedélyezés sw[3:0]
BCDCNT     BCD_H (.clk(clk), .rst(rst), .load(load_h), .dir(dir), 
                      .en(en_h), .tc(tc_h), .d(sw[3:0]), .q(q_h));

assign en_k = tc_h;                       // Kilo-Hecto engedélyezés
assign load_k = bt[1];                    // Felsõ bájt töltés engedélyezés sw[7:4]
BCDCNT     BCD_K (.clk(clk), .rst(rst), .load(load_k), .dir(dir), 
                      .en(en_k), .tc(tc_k), .d(sw[7:4]), .q(q_k));

assign miso = tc_k;                       // Teljes végértékjel MISO-ra
assign ld   = {q_d,q_u};                  // Alsó 2 digit LED-re

//////////////////////////////////////////////////////////////////////////////////
// Numerikus kijelzés a 7 szegmenses kijelzõn, könyvtári kijelzõ modullal
// Mivel az eddigiekben más sok alkatrészt megismertünk, így használhatunk egy 
// összetett rendszerelemet, ami egy általánosan használható funkciót realizál
// Az ilyen HDL kódban meglévõ terveket IP-nek, azaz Intellectual Property-nek 
// nevezi a szakirodalom, hiszen jelentõs tudás lehet benne (amit eddig 5 hét
// alatt a tárgy tanított).
// Ez az egység egy 16 bites, numerikus értéket képes a 4 digites 7 szegmenses 
// kijelzõn megjeleníteni. Mûködtetése a kártya 16MHz-es rendszer órajelérõl 
// történik, figgetlen a LOGSYS GUI-ban használt vezérlõ órajeltõl.
// Rendelkezik egy 4 bites, a tizedes pontok at vezérlõ bemenettel is DP[3:0]. 
// Ha erre nincs szükség, elhagyható, vagy nullára köthetõ. 
// A kijelzõ egység ponált kimenetet ad vissza, tehát invertálni kell.   
//////////////////////////////////////////////////////////////////////////////////
wire [15:0] number;
assign number = {q_k, q_h, q_d, q_u};     // 4 dekádos BCD érték

wire [7:0] seg;                           // Tizedes pont és szegmenskód
wire [3:0] dig;                           // Idõmultiplex vezérlés

LIP_4digit DISP (.clk16M(clk16M), .rst(rst), 
                 .number(number), .dp(4'b0), .seg(seg), .dig(dig));

//////////////////////////////////////////////////////////////////////////////////
// Kijelzõ vonalak negált meghajtása
//////////////////////////////////////////////////////////////////////////////////

assign seg_n = ~seg;
assign dig_n = ~dig;
assign col_n = 5'b11111;

endmodule
