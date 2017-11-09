`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// LIP_4digit : LOGSYS IP könyvtári elem kijelzõvezérlésre
// Négy számjegyes kijelzõ modul hexadecimális vagy BCD értékek kijelzésére
// Az adatbemenet 16 párhuzamos vonal a 4 számjegy bitjei számára és egy külön 
// 4 bites busz a tizedes (hexadecimális) pontok vezérlésére. A bemeneti 
// érték lehet hexadecimális vagy BCD kódban, minden kód érvényes szegmensképet 
// eredményez. A kijelzés idõmultiplex módon történik, 1kHz körüli kapcsolási 
// frekvenciával (a 16MHz órajelbõl származtatva), ami szép megjelenítést eredményez. 
// Megjegyzés: Az egység mûködési módjából következõen az adatbemeneti vonalak
// értékének változtatása a kijelzési állapothoz képest tetszõleges idõpontban
// megtörténhet, az adatbemenet órajelhez szinkronizációjára nincs szükség.
//////////////////////////////////////////////////////////////////////////////////
module LIP_4digit(
            input  clk16M,                   	// 16MHz frekvenciájú órajel
            input  rst,                         // Szinkron RESET jel
            input  [15:0] number,               // 16 bites szám bemenet
            input  [ 3:0] dp,                   // Tizedes pontok
            output [ 7:0] seg,                  // Szegmens kimenetek
            output reg [ 3:0] dig               // Digit kimenetek
                 );


///////////////////////////////////////////////////////////////////////////////////
// A léptetés frekvenciája megközelítõen 1kHz, amit a 16MHz-es órajelbõl állítunk elõ
// A bináris számlálóval alapú osztó minden 2^14 órajelben elõállít egy léptetõ jelet
///////////////////////////////////////////////////////////////////////////////////

reg [13:0] div;                                 // Órajelosztó számláló
wire rate = &div;	                              // Végérték pulzus kiadása, 
                                                // ha minden bit magas


always @ (posedge clk16M)                       // A számláló a 16MHz-rõl fut	
   if (rst)  div <= 14'b0;                      // Kezdõállapot beállítása
	else      div <= div + 1;                    // Számlálás felfelé
 
//////////////////////////////////////////////////////////////////////////////////
// A 4 számjegyes idõmultiplex vezérlést egy négybites gyûrûs számláló vezérli,
// a számjegyek megjelenítése sorrendje balról jobbra, MSD -> LSD irányba történik
// A számláló engedélyezhetõ, léptetése a RATE jel ütemében történik
// A dig bitekkel közvetlenül választunk a bemeneti 16 bites adat számjegyei közül
// és egyúttal a megfeleleõ tizedes pontot is kiválasztjuk (ha használjuk)
///////////////////////////////////////////////////////////////////////////////////

always	 @ (posedge clk16M)								// 16MHz-rõl, a RATE jel ütemében		
   if (rst)       dig <= 4'b1000;                  // Kezdõállapot, digit[3] aktív
	else if (rate) dig <= {dig[0], dig[3:1]};       // majd a rate jel ütemében lép
                                                            
wire [3:0] value;
wire  decp;

assign value = ({4{dig[3]}} & number[15:12]) | 		// Elosztott multiplexer hálózat, 
					({4{dig[2]}} & number[11: 8]) | 		// a hatékony erõforrás kihasználáshoz
					({4{dig[1]}} & number[ 7: 4]) |     // Egy 4 bites 4:1-be busz MUX-ot valósít 
					({4{dig[0]}} & number[ 3: 0]);      // meg, AND-OR hálózattal

assign decp =  (dig[3] & dp[3]) |						// Ugyanez 1 biten a 4 tizedes pontra
               (dig[2] & dp[2]) |
 					(dig[1] & dp[1]) |
					(dig[0] & dp[0]);
///////////////////////////////////////////////////////////////////////////////////
// A kiválasztott számértéket 7 szegmenses kijelzõ kóddá konvertáljuk
// Az átkódoló logikát pozitív logika szerint írjuk fel, azaz az aktív szegmensek értéke 1
// A szegmenskép kódolása a következõ:
//      0            
//     ---
//  5 |   | 1
//     --- <--6
//  4 |   | 2
//     ---  .
//      3   7 A tizedespont a 7. bit, ezt a dekodolás után illesztjük be
///////////////////////////////////////////////////////////////////////////////////

reg [6:0] segment;											// Változó deklaráció

always @(*)                   		           		// Kódkonverter kombinációs hálózat,  
   begin                                           // Lényegében egy 16*7 bites ROM
      case (value)            //6543210  szegmensek   
         4'b0000 : segment = 7'b0111111;   // 0
         4'b0001 : segment = 7'b0000110;   // 1
         4'b0010 : segment = 7'b1011011;   // 2
         4'b0011 : segment = 7'b1001111;   // 3
         4'b0100 : segment = 7'b1100110;   // 4
         4'b0101 : segment = 7'b1101101;   // 5
         4'b0110 : segment = 7'b1111101;   // 6
         4'b0111 : segment = 7'b0000111;   // 7
         4'b1000 : segment = 7'b1111111;   // 8
         4'b1001 : segment = 7'b1101111;   // 9
         4'b1010 : segment = 7'b1110111;   // A
         4'b1011 : segment = 7'b1111100;   // b
         4'b1100 : segment = 7'b0111001;   // C
         4'b1101 : segment = 7'b1011110;   // d
         4'b1110 : segment = 7'b1111001;   // E
         4'b1111 : segment = 7'b1110001;   // F
         default : segment = 7'b0000000;   // 0
      endcase
   end 
 
assign seg = {decp,segment};       // Tizedes pont és szegmenskód

endmodule 


