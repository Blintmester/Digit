`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Digit�lis technika Laborat�rium 5. h�t
// 5_4 feladat: BCD sz�ml�l�k
// 16 bites, 4 dek�dos szinkron t�r�lhet�, t�lthet�, enged�lyezhet�, felfel�/lefel� 
// sz�ml�l� BCD sz�ml�l� egys�g 
// A sz�ml�l� �llapotait a LED-eken �s a 7 szegmenses kijelz�n is kijelezz�k.
// A kijelz�shez felhaszn�ljuk a LIP_4digit IP modult.
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
// Bels� jelek defini�l�sa 
// Eleve 4 db 4 bites BCD sz�ml�l� kaszk�dos�t�s�ra k�sz�l�nk
// Ennek megfelel�en defini�ljuk a bels� jeleket.
// A n�gy egys�g jele szabv�nyos prefixek alapj�n: K-kilo, H-hecto, D-deka, U-unit
//////////////////////////////////////////////////////////////////////////////////

wire [3:0] q_k, q_h, q_d, q_u;            // 4 dek�dnyi BCD sz�mjegy k�d
wire load_k, load_h, load_d, load_u ;     // 4 t�lt�s jel, p�ronk�nt azonos lesz 
wire dir = bt[3];                         // K�z�s ir�nyvez�rl�s a BT[3]-mal 
wire en_k, en_h, en_d, en_u;              // 4 enged�lyez� jel
wire tc_k, tc_h, tc_d, tc_u;              // 4 v�g�rt�k jelz�s

//////////////////////////////////////////////////////////////////////////////////
// 4 db 4 bites BCDCNT be�p�t�se enged�lyez�si l�nccal
//////////////////////////////////////////////////////////////////////////////////

assign en_u = mosi;                       // Glob�lis enged�lyez�s
assign load_u = bt[0];                    // Als� b�jt t�lt�s enged�lyez�s sw[3:0]
BCDCNT     BCD_U (.clk(clk), .rst(rst), .load(load_u), .dir(dir), 
                      .en(en_u), .tc(tc_u), .d(sw[3:0]), .q(q_u));

assign en_d = tc_u;                       // Units-Deka enged�lyez�s
assign load_d = bt[0];                    // Als� b�jt t�lt�s enged�lyez�s sw [7:4]
BCDCNT     BCD_D (.clk(clk), .rst(rst), .load(load_d), .dir(dir), 
                      .en(en_d), .tc(tc_d), .d(sw[7:4]), .q(q_d));

assign en_h = tc_d;                       // Hecto-Deka enged�lyez�s
assign load_h = bt[1];                    // Fels� b�jt t�lt�s enged�lyez�s sw[3:0]
BCDCNT     BCD_H (.clk(clk), .rst(rst), .load(load_h), .dir(dir), 
                      .en(en_h), .tc(tc_h), .d(sw[3:0]), .q(q_h));

assign en_k = tc_h;                       // Kilo-Hecto enged�lyez�s
assign load_k = bt[1];                    // Fels� b�jt t�lt�s enged�lyez�s sw[7:4]
BCDCNT     BCD_K (.clk(clk), .rst(rst), .load(load_k), .dir(dir), 
                      .en(en_k), .tc(tc_k), .d(sw[7:4]), .q(q_k));

assign miso = tc_k;                       // Teljes v�g�rt�kjel MISO-ra
assign ld   = {q_d,q_u};                  // Als� 2 digit LED-re

//////////////////////////////////////////////////////////////////////////////////
// Numerikus kijelz�s a 7 szegmenses kijelz�n, k�nyvt�ri kijelz� modullal
// Mivel az eddigiekben m�s sok alkatr�szt megismert�nk, �gy haszn�lhatunk egy 
// �sszetett rendszerelemet, ami egy �ltal�nosan haszn�lhat� funkci�t realiz�l
// Az ilyen HDL k�dban megl�v� terveket IP-nek, azaz Intellectual Property-nek 
// nevezi a szakirodalom, hiszen jelent�s tud�s lehet benne (amit eddig 5 h�t
// alatt a t�rgy tan�tott).
// Ez az egys�g egy 16 bites, numerikus �rt�ket k�pes a 4 digites 7 szegmenses 
// kijelz�n megjelen�teni. M�k�dtet�se a k�rtya 16MHz-es rendszer �rajel�r�l 
// t�rt�nik, figgetlen a LOGSYS GUI-ban haszn�lt vez�rl� �rajelt�l.
// Rendelkezik egy 4 bites, a tizedes pontok at vez�rl� bemenettel is DP[3:0]. 
// Ha erre nincs sz�ks�g, elhagyhat�, vagy null�ra k�thet�. 
// A kijelz� egys�g pon�lt kimenetet ad vissza, teh�t invert�lni kell.   
//////////////////////////////////////////////////////////////////////////////////
wire [15:0] number;
assign number = {q_k, q_h, q_d, q_u};     // 4 dek�dos BCD �rt�k

wire [7:0] seg;                           // Tizedes pont �s szegmensk�d
wire [3:0] dig;                           // Id�multiplex vez�rl�s

LIP_4digit DISP (.clk16M(clk16M), .rst(rst), 
                 .number(number), .dp(4'b0), .seg(seg), .dig(dig));

//////////////////////////////////////////////////////////////////////////////////
// Kijelz� vonalak neg�lt meghajt�sa
//////////////////////////////////////////////////////////////////////////////////

assign seg_n = ~seg;
assign dig_n = ~dig;
assign col_n = 5'b11111;

endmodule
