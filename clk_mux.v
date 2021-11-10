// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/09
// File Name           : clk_mux.v
// Module Name         : clk_mux
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : no glich clk mux circuit
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/09       Huangyh             1.0                         none
//
// =============================================================================

//==================================================================================================================//
// 1)  CLOCK MUX                                                                                                    //
//==================================================================================================================//
//                                                                                                                  //
// The following (glitch free) clock mux is implemented as following:                                               //
//                                                                                                                  //
//                                                                                                                  //
//                                                                                                                  //
//                                               dff0a        dff0b                                                 //
//                                +-----.     +--------+   +--------+                                               //
// select_in >>----+-------------O|      \    |        |   |        |          +-----.                              //
//                 |              |       |---| D    Q |---| D    Q |--+-------|      \                             //
//                 |     +-------O|      /    |        |   |        |  |       |       |O-+                         //
//                 |     |        +-----'     |        |   |        |  |   +--O|      /   |                         //
//                 |     |                    |   /\   |   |   /\   |  |   |   +-----'    |                         //
//                 |     |                    +--+--+--+   +--+--+--+  |   |              |                         //
//                 |     |                        O            |       |   |              |                         //
//                 |     |                        |            |       |   |              |  +-----.                //
//    clk_in0 >>----------------------------------+------------+-----------+              +--|      \               //
//                 |     |                                             |                     |       |----<< clk_out//
//                 |     |     +---------------------------------------+                  +--|      /               //
//                 |     |     |                                                          |  +-----'                //
//                 |     +---------------------------------------------+                  |                         //
//                 |           |                 dff1a        dff1b    |                  |                         //
//                 |           |  +-----.     +--------+   +--------+  |                  |                         //
//                 |           +-O|      \    |        |   |        |  |       +-----.    |                         //
//                 |              |       |---| D    Q |---| D    Q |--+-------|      \   |                         //
//                 +--------------|      /    |        |   |        |          |       |O-+                         //
//                                +-----'     |        |   |        |      +--O|      /                             //
//                                            |   /\   |   |   /\   |      |   +-----'                              //
//                                            +--+--+--+   +--+--+--+      |                                        //
//                                                O            |           |                                        //
//                                                |            |           |                                        //
//    clk_in1 >>----------------------------------+------------+-----------+                                        //
//                                                                                                                  //
//                                                                                                                  //
//==================================================================================================================//


`timescale 1ns / 1ps
`include "define.vh"

module clk_mux (
    input                       clk_cpu,    // Clock
    input                       clk_debug,
    input                       rst_n_cpu,  // Asynchronous reset active low
    input                       rst_n_debug,
    input   [`DEBUG_WIDTH-1:0]  debug,      // 0 for clk cpu
    output                      clk_mux
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg     select;
reg     clk_cpu_reg0;
reg     clk_cpu_reg1;
reg     clk_debug_reg0;
reg     clk_debug_reg1;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// debug 0 for select clk_cpu
//==============================================================================
always @(*) begin
    if (debug == `DEBUG_DIS) begin
        select  =   `SEL_CPUCLK;
    end

    else begin
        select  =   `SEL_DEBUGCLK;
    end
end

//==============================================================================
// clk debug select mux reg
//==============================================================================
always @(posedge clk_debug or negedge rst_n_debug) begin
    if (rst_n_debug == `RST_ACTIVE) begin
        // reset
        clk_debug_reg0 <= 0;
    end

    else begin
        clk_debug_reg0 <= select & (~clk_cpu_reg1);
    end
end

always @(negedge clk_debug or negedge rst_n_debug) begin
    if (rst_n_debug == `RST_ACTIVE) begin
        // reset
        clk_debug_reg1 <= 0;
    end

    else begin
        clk_debug_reg1 <= clk_debug_reg0;
    end
end

//==============================================================================
// clk cpu select mux reg
//==============================================================================
always @(posedge clk_cpu or negedge rst_n_cpu) begin
    if (rst_n_cpu == `RST_ACTIVE) begin
        // reset
        clk_cpu_reg0 <= 0;
    end

    else begin
        clk_cpu_reg0 <= (~select) & (~clk_debug_reg1);
    end
end

always @(negedge clk_cpu or negedge rst_n_cpu) begin
    if (rst_n_cpu == `RST_ACTIVE) begin
        // reset
        clk_cpu_reg1 <= 0;
    end

    else begin
        clk_cpu_reg1 <= clk_cpu_reg0;
    end
end

//==============================================================================
// clk mux output
//==============================================================================
assign clk_mux = (clk_debug_reg1 && clk_debug) || (clk_cpu_reg1 && clk_cpu);

endmodule