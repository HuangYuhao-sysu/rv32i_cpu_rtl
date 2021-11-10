// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/09
// File Name           : cpu_tb.v
// Module Name         : cpu_tb
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : tb for cpu test
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/09       Huangyh             1.0                         none
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module cpu_tb ();

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                         clk_cpu;
reg                         clk_debug;
reg                         rst_n_cpu_ext;
reg                         rst_n_debug_ext;
reg     [`DEBUG_WIDTH-1:0]  debug;
reg     [`IADDR_WIDTH-1:0]  ext_icache_addr_i;
reg     [`DATA_WIDTH-1:0]   ext_icache_wdata_i;
reg     [`RADDR_WIDTH-1:0]  ext_reg_raddr_i;
reg     [`DADDR_WIDTH-1:0]  ext_dcache_raddr_i;
wire    [`PC_WIDTH-1:0]     ext_pc_o;
wire    [`DATA_WIDTH-1:0]   ext_icache_rdata_o;
wire    [`DATA_WIDTH-1:0]   ext_reg_rdata_o;
wire    [`DATA_WIDTH-1:0]   ext_dcache_rdata_o;

reg     [`DATA_WIDTH-1:0]   cnt;
reg     [`DATA_WIDTH-1:0]   ext_instructions        [0:`IMEM_SIZE];
reg     [`IADDR_WIDTH-1:0]  ext_instructions_addr   [0:`IMEM_SIZE];

localparam MAX = 37;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /
cpu_top u_cpu_top(
    .clk_cpu            ( clk_cpu            ),
    .clk_debug          ( clk_debug          ),
    .rst_n_cpu_ext      ( rst_n_cpu_ext      ),
    .rst_n_debug_ext    ( rst_n_debug_ext    ),
    .debug              ( debug              ),
    .ext_icache_addr_i  ( ext_icache_addr_i  ),
    .ext_icache_wdata_i ( ext_icache_wdata_i ),
    .ext_reg_raddr_i    ( ext_reg_raddr_i    ),
    .ext_dcache_raddr_i ( ext_dcache_raddr_i ),
    .ext_pc_o           ( ext_pc_o           ),
    .ext_icache_rdata_o ( ext_icache_rdata_o ),
    .ext_reg_rdata_o    ( ext_reg_rdata_o    ),
    .ext_dcache_rdata_o ( ext_dcache_rdata_o )
);

always #2.5 clk_cpu     = ~clk_cpu;
always #2.5 clk_debug   = ~clk_debug;

initial begin
    clk_cpu             <=  0;
    rst_n_cpu_ext       <=  1;
    clk_debug           <=  0;
    rst_n_debug_ext     <=  1;
    debug               <=  `DEBUG_DIS;

    ext_reg_raddr_i     <=  `R_ZERO;
    ext_dcache_raddr_i  <=  `DADDR_ZERO;

    #10
    rst_n_cpu_ext       <=  0;
    rst_n_debug_ext     <=  0;
    debug               <=  `DEBUG_ICWR;
    #40
    rst_n_cpu_ext       <=  1;
    rst_n_debug_ext     <=  1;

    #1000
    rst_n_cpu_ext       <=  0;
    rst_n_debug_ext     <=  0;
    debug               <=  `DEBUG_DIS;
    #40
    rst_n_cpu_ext       <=  1;
    rst_n_debug_ext     <=  1;
    #10000
    $finish;
end

//==============================================================================
// i cache write
//==============================================================================
always @(posedge clk_debug or negedge rst_n_debug_ext) begin
    if (rst_n_debug_ext == `RST_ACTIVE) begin
        // reset
        ext_icache_addr_i <= `IADDR_ZERO;
    end

    else begin
        ext_icache_addr_i <= ext_instructions_addr[cnt];
    end
end

always @(posedge clk_debug or negedge rst_n_debug_ext) begin
    if (rst_n_debug_ext == `RST_ACTIVE) begin
        // reset
        cnt <=  0;
    end

    else if (cnt < MAX) begin
        cnt <=  cnt + 1;
    end

    else begin
        cnt <=  0;
    end
end

always @(posedge clk_debug or negedge rst_n_debug_ext) begin
    if (rst_n_debug_ext == `RST_ACTIVE) begin
        // reset
        ext_icache_wdata_i <= `ZERO;
    end

    else begin
        ext_icache_wdata_i <= ext_instructions[cnt];
    end
end

//==============================================================================
// instruction initial
//==============================================================================

//==============================================================================
// 
//==============================================================================
always @(posedge clk_debug or negedge rst_n_debug_ext) begin
    if (rst_n_debug_ext == `RST_ACTIVE) begin
        // reset

//======================================================================
// bubble sort test code
//======================================================================
/*
0:      addi,   r6,     zero,   017;    //  23
4:      addi,   r7,     zero,   014;    //  20
8:      addi,   r8,     zero,   002;    //  2
12:     addi,   r9,     zero,   fff;    //  -1
16:     addi,   r10,    zero,   fe7;    //  -25
20:     addi,   r11,    zero,   010;    //  16
24:     addi,   r12,    zero,   000;    //  0
28:     addi,   r13,    zero,   ff5;    //  -11
32:     addi,   r14,    zero,   ffc;    //  -4
36:     addi,   r15,    zero,   007;    //  7
40:     sh,     zero,   r6,     0;      //  mem[1-0]    23
44:     sh,     zero,   r7,     2;      //  mem[3-2]    20
48:     sh,     zero,   r8,     4;      //  mem[5-4]    2
52:     sh,     zero,   r9,     6;      //  mem[7-6]    -1
56:     sh,     zero,   r10,    8;      //  mem[9-8]    -25
60      sh,     zero,   r11,    10;     //  mem[11-10]  16
64      sh,     zero,   r12,    12;     //  mem[13-12]  0
68      sh,     zero,   r13,    14;     //  mem[15-14]  -11
72      sh,     zero,   r14,    16;     //  mem[17-16]  -4
76      sh,     zero,   r15,    18;     //  mem[19-18]  7
80:     addi,   r2,     zero,   18;     //  for outside loops
84:     addi,   r3,     zero,   0;      //  for inside loops
88:     bge,    r2,     zero,   8;      //  compare, not finished and jump to 96
92:     jalr    r1,     zero,   64;     //  finished and jump to end
96:     slt     r4,     r3,     r2;     //  r3 < r2 then set r4
100:    beq     zero,   r4,     32;     //  finish once inside loop, jump to 132
104:    lh      r5,     r3,     0;      //  r5 <- mem[r3+0]
108:    lh      r6,     r3,     2;      //  r6 <- mem[r3+2]
112:    blt     r5,     r6,     12;     //  r5 < r6, then jump
116:    sh      r3,     r6,     0;      //  mem[r3+0] <- r6
120:    sh      r3,     r5,     2;      //  mem[r3+2] <- r5
124:    addi    r3,     r3,     2;      //  r3 + 2 for next compare
128:    jal     r1,     -32             //  jump to 96
132:    addi    r3,     zero,   0;      //  reset r3 for next out loop
136:    addi    r2,     r2,     -2;     //  outside loop -2
140:    jal     r1,     -52;            //  jump to 88
144:    nop                             //  finished
*/
        ext_instructions[0  ]       <=  32'h00000013;
        ext_instructions[1  ]       <=  32'h01700313;
        ext_instructions[2  ]       <=  32'h01400393;
        ext_instructions[3  ]       <=  32'h00200413;
        ext_instructions[4  ]       <=  32'hfff00493;
        ext_instructions[5  ]       <=  32'hfe700513;
        ext_instructions[6  ]       <=  32'h01000593;
        ext_instructions[7  ]       <=  32'h00000613;
        ext_instructions[8  ]       <=  32'hff500693;
        ext_instructions[9  ]       <=  32'hffc00713;
        ext_instructions[10 ]       <=  32'h00700793;
        ext_instructions[11 ]       <=  32'h00601023;
        ext_instructions[12 ]       <=  32'h00701123;
        ext_instructions[13 ]       <=  32'h00801223;
        ext_instructions[14 ]       <=  32'h00901323;
        ext_instructions[15 ]       <=  32'h00a01423;
        ext_instructions[16 ]       <=  32'h00b01523;
        ext_instructions[17 ]       <=  32'h00c01623;
        ext_instructions[18 ]       <=  32'h00d01723;
        ext_instructions[19 ]       <=  32'h00e01823;
        ext_instructions[20 ]       <=  32'h00f01923;
        ext_instructions[21 ]       <=  32'h01200113;
        ext_instructions[22 ]       <=  32'h00000193;
        ext_instructions[23 ]       <=  32'h00015463;
        ext_instructions[24 ]       <=  32'h040000e7;
        ext_instructions[25 ]       <=  32'h0021a233;
        ext_instructions[26 ]       <=  32'h02020063;
        ext_instructions[27 ]       <=  32'h00019283;
        ext_instructions[28 ]       <=  32'h00219303;
        ext_instructions[29 ]       <=  32'h0062c663;
        ext_instructions[30 ]       <=  32'h00619023;
        ext_instructions[31 ]       <=  32'h00519123;
        ext_instructions[32 ]       <=  32'h00218193;
        ext_instructions[33 ]       <=  32'hfe1ff0ef;
        ext_instructions[34 ]       <=  32'h00000193;
        ext_instructions[35 ]       <=  32'hffe10113;
        ext_instructions[36 ]       <=  32'hfcdff0ef;
        ext_instructions[37 ]       <=  32'h00000013;

        ext_instructions_addr[0  ]  <=  0;
        ext_instructions_addr[1  ]  <=  4;
        ext_instructions_addr[2  ]  <=  8;
        ext_instructions_addr[3  ]  <=  12;
        ext_instructions_addr[4  ]  <=  16;
        ext_instructions_addr[5  ]  <=  20;
        ext_instructions_addr[6  ]  <=  24;
        ext_instructions_addr[7  ]  <=  28;
        ext_instructions_addr[8  ]  <=  32;
        ext_instructions_addr[9  ]  <=  36;
        ext_instructions_addr[10 ]  <=  40;
        ext_instructions_addr[11 ]  <=  44;
        ext_instructions_addr[12 ]  <=  48;
        ext_instructions_addr[13 ]  <=  52;
        ext_instructions_addr[14 ]  <=  56;
        ext_instructions_addr[15 ]  <=  60;
        ext_instructions_addr[16 ]  <=  64;
        ext_instructions_addr[17 ]  <=  68;
        ext_instructions_addr[18 ]  <=  72;
        ext_instructions_addr[19 ]  <=  76;
        ext_instructions_addr[20 ]  <=  80;
        ext_instructions_addr[21 ]  <=  84;
        ext_instructions_addr[22 ]  <=  88;
        ext_instructions_addr[23 ]  <=  92;
        ext_instructions_addr[24 ]  <=  96;
        ext_instructions_addr[25 ]  <=  100;
        ext_instructions_addr[26 ]  <=  104;
        ext_instructions_addr[27 ]  <=  108;
        ext_instructions_addr[28 ]  <=  112;
        ext_instructions_addr[29 ]  <=  116;
        ext_instructions_addr[30 ]  <=  120;
        ext_instructions_addr[31 ]  <=  124;
        ext_instructions_addr[32 ]  <=  128;
        ext_instructions_addr[33 ]  <=  132;
        ext_instructions_addr[34 ]  <=  136;
        ext_instructions_addr[35 ]  <=  140;
        ext_instructions_addr[36 ]  <=  144;
        ext_instructions_addr[37 ]  <=  148;
    end
end

endmodule