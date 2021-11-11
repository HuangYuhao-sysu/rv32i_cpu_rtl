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
// Abstract            : tb for Vivado cpu test
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

`timescale 1ns / 1ps

module cpu_tb ();

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                     clk;
reg                     rst_n;
wire    [`PC_WIDTH-1:0] ext_pc;

cpu_top u_cpu_top(
    .clk    ( clk    ),
    .rst_n  ( rst_n  ),
    .ext_pc ( ext_pc )
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 1;
    #100
    rst_n = 0;
    #400
    rst_n = 1;
    
    #100000
    $finish;
end

endmodule