module Adder_16bit(A, B, cin, Sat_Sum, Ovfl);
input [15:0] A, B;
input cin;
output [15:0]Sat_Sum;
output Ovfl;
wire  [2:0]C;
wire [15:0]Sum;
wire [15:0]Binv;
wire [3:0]G, P;

assign Binv = cin ? ~B : B;

adder_4bit s0to3(.a(A[3:0]), .b(Binv[3:0]), .cin(cin), .sum(Sum[3:0]), .cout(), .ovfl(), .G(G[0]), .P(P[0]));
adder_4bit s4to7(.a(A[7:4]), .b(Binv[7:4]), .cin(C[0]), .sum(Sum[7:4]), .cout(), .ovfl(), .G(G[1]), .P(P[1]));
adder_4bit s8to11(.a(A[11:8]), .b(Binv[11:8]), .cin(C[1]), .sum(Sum[11:8]), .cout(), .ovfl(), .G(G[2]), .P(P[2]));
adder_4bit s11to15(.a(A[15:12]), .b(Binv[15:12]), .cin(C[2]), .sum(Sum[15:12]), .cout(), .ovfl(), .G(G[3]), .P(P[3]));


assign C[0] = G[0] | (P[0] & cin);
assign C[1] = G[1] | (P[1] & (G[0] | (P[0] & cin)));
assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & cin);
assign cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & cin);

assign  Ovfl = ~A[15] & ~Binv[15] & Sum[15] | A[15] & Binv[15] & ~Sum[15];

assign Sat_Sum[15:0] = (Ovfl) ? (Sum[15] ? 16'h7FFF : 16'h8000) : Sum[15:0]; 

endmodule



//////////////// 4 bit adder slice //////////////////////////////////////////////////////////////////////////////////////////////


module adder_4bit(a, b, cin, sum, ovfl, cout, G, P);
input [3:0]a,b;
output [3:0]sum;
input cin;
output ovfl,cout;
wire [3:0]g, p;
wire [2:0]c;
output G,P;


gen_prop gen0(.a(a[0]), .b(b[0]), .g(g[0]), .p(p[0]));
gen_prop gen1(.a(a[1]), .b(b[1]), .g(g[1]), .p(p[1]));
gen_prop gen2(.a(a[2]), .b(b[2]), .g(g[2]), .p(p[2]));
gen_prop gen3(.a(a[3]), .b(b[3]), .g(g[3]), .p(p[3]));


assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
assign P = p[3] & p[2] & p[1] & p[0];



assign c[0] = g[0] | (p[0] & cin);
assign c[1] = g[1] | (p[1] & (g[0] | (p[0] & cin)));
assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin);
assign cout = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & cin);

assign sum[0] = a[0] ^ b[0] ^ cin;
assign sum[1] = a[1] ^ b[1] ^ c[0];
assign sum[2] = a[2] ^ b[2] ^ c[1];
assign sum[3] = a[3] ^ b[3] ^ c[2]; 

assign ovfl = a[3] & b[3] & ~sum[3] | ~a[3] & ~b[3] & sum[3];
endmodule

///////////////////  Generate and Propagate slice /////////////////////////////////////////////////////////////////////////////

module gen_prop(a, b, g, p);
input a, b;
output p, g;
assign g = a & b;
assign p = a | b;
endmodule

