// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : stage_ifid.v
// Module Name         : stage_ifid
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : sequential logic, if to id, input port with _i postfix,
//                      output port with _o postfix.
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

module stage_ifid (
    input                       clk,
    input                       rst_n,

    input   [`PC_WIDTH-1:0]     current_pc_i,
    input   [`DATA_WIDTH-1:0]   instruction_i,

    // stall for data hazard, like ADD after LOAD, BRANCH after ADD or LOAD.
    input                       stall,

    // flush and next inst is NOP, when B and J.
    input                       flush,

    output  [`PC_WIDTH-1:0]     current_pc_o,
    output  [`DATA_WIDTH-1:0]   instruction_o
);

// =========================================================================== \
// ============================== Define parameter ===========================
// =========================================================================== /
localparam NORMAL   = 2'd0; // normal transmit pc and instruction
localparam STALL    = 2'd1; // stall for one cycle
localparam FLUSH0   = 2'd2; // flush ifid instruction
localparam FLUSH1   = 2'd3; // flush i cache instruction

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`IFIDSM_WIDTH-1:0] current_state;
reg [`IFIDSM_WIDTH-1:0] next_state;

reg [`PC_WIDTH-1:0]     current_pc_o_reg;
reg [`DATA_WIDTH-1:0]   instruction_o_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign current_pc_o = current_pc_o_reg;
assign instruction_o = instruction_o_reg;

//==============================================================================
// state transform
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        current_state <= NORMAL;
    end

    else begin
        current_state <= next_state;
    end
end

//==============================================================================
// next state decode and output decode
//==============================================================================
always @(*) begin
    case (current_state)
        NORMAL: begin
            case ({stall,flush})
                2'b00:  next_state  =   NORMAL;
                2'b01:  next_state  =   FLUSH0;
                2'b10:  next_state  =   STALL;
                2'b11:  next_state  =   STALL;
            endcase
        end

        STALL: begin
            case ({stall,flush})
                2'b00:  next_state  =   NORMAL;
                2'b01:  next_state  =   FLUSH0;
                2'b10:  next_state  =   STALL;
                2'b11:  next_state  =   STALL;
            endcase
        end

        FLUSH0: begin
            next_state  =   FLUSH1;
        end

        FLUSH1: begin
            case ({stall,flush})
                2'b00:  next_state  =   NORMAL;
                2'b01:  next_state  =   FLUSH0;
                2'b10:  next_state  =   STALL;
                2'b11:  next_state  =   STALL;
            endcase
        end
    endcase
end

//==============================================================================
// state output for pc
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        current_pc_o_reg    <=  `ZERO;
    end

    // Regardless of stall and flush， pc always get the input pc， when stall，
    // pc module will handle the real pc value. but for lower power gating
    // design. we should use stall and flush as clock gating enable signals.
    else begin
        case (next_state)
            NORMAL: current_pc_o_reg    <=  current_pc_i;
            STALL:  current_pc_o_reg    <=  current_pc_o_reg;
            FLUSH0: current_pc_o_reg    <=  current_pc_o_reg;
            FLUSH1: current_pc_o_reg    <=  current_pc_o_reg;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        instruction_o_reg   <=  `ZERO;
    end

    // we need to flush two instruction when jump or branch happended
    else begin
        case (next_state)
            NORMAL: instruction_o_reg   <=  instruction_i;
            STALL:  instruction_o_reg   <=  instruction_o_reg;
            FLUSH0: instruction_o_reg   <=  `NOP;
            FLUSH1: instruction_o_reg   <=  `NOP;
        endcase
    end
end

endmodule