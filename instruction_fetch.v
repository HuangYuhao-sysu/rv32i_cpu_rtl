// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : instruction_fetch.v
// Module Name         : instruction_fetch
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : instruction fetch module, fetch address 4 bytes aligned
//                          address out of range will return data 0. comb logic
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/01       Huangyh             1.0                         none
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module instruction_fetch (
    input   [`PC_WIDTH-1:0]     pc,         // pc from pc module

    output  [`IADDR_WIDTH-1:0]  pc_aligned  // aligned pc to access i_cache
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`IADDR_WIDTH-1:0]  pc_aligned_reg;
reg [`PC_WIDTH-1:0]     pc_mask;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================

// for Vivado IP, we can't aceess by byte. so pc actually + 1 once time.
assign pc_aligned = pc_aligned_reg >> 2;

always @(*) begin
    pc_mask         =   (pc & `PC_ALIGNED_MASK);
    pc_aligned_reg  =   pc_mask[0+:`IADDR_WIDTH];
end

endmodule