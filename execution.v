// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : execution.v
// Module Name         : execution
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : execution, comb logic, with ALU and ex forwaring units.
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/02       Huangyh             1.0                         none
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module execution (
    input   [`PC_WIDTH-1:0]     pc,
    input                       branch_jump,
    input                       alu_src,    // 1 for imm, 0 for reg
    input   [`ALUOP_WIDTH-1:0]  alu_op,

    input   [`DATA_WIDTH-1:0]   imm,
    input   [`DATA_WIDTH-1:0]   reg_rdata1,
    input   [`DATA_WIDTH-1:0]   reg_rdata2,

    // forwarding logic and data
    input   [`RADDR_WIDTH-1:0]  rs1,
    input   [`RADDR_WIDTH-1:0]  rs2,
    input                       exmem_reg_write,
    input                       memwb_reg_write,
    input   [`RADDR_WIDTH-1:0]  exmem_reg_rd,
    input   [`RADDR_WIDTH-1:0]  memwb_reg_rd,
    input   [`DATA_WIDTH-1:0]   exmem_reg_wdata,
    input   [`DATA_WIDTH-1:0]   wb_reg_wdata,

    output  [`DATA_WIDTH-1:0]   alu_result, // wb for reg or mem waddr
    output  [`DATA_WIDTH-1:0]   mem_wdata   // mem write data
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg     [`DATA_WIDTH-1:0]   alu_result_reg; // wb for reg or mem waddr

wire    [`DATA_WIDTH-1:0]   operand1;
reg     [`DATA_WIDTH-1:0]   operand2;
reg     [`DATA_WIDTH-1:0]   forwarding_rs1;
reg     [`DATA_WIDTH-1:0]   forwarding_rs2;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// outpur reg assign
//==============================================================================
assign  alu_result  = alu_result_reg;

//==============================================================================
// data forwarding for rs1
//==============================================================================
always @(*) begin
    if (exmem_reg_write == `REG_WR_EN && 
        (exmem_reg_rd != `R_ZERO) &&
        (exmem_reg_rd == rs1)) begin
        forwarding_rs1  =   exmem_reg_wdata;
    end

    else if (memwb_reg_write == `REG_WR_EN && 
            (memwb_reg_rd != `R_ZERO) &&
            (memwb_reg_rd == rs1)) begin
        forwarding_rs1  =   wb_reg_wdata;
    end

    else begin
        forwarding_rs1  =   reg_rdata1;
    end
end

//==============================================================================
// data forwarding for rs2
//==============================================================================
always @(*) begin
    if (exmem_reg_write == `REG_WR_EN && 
        (exmem_reg_rd != `R_ZERO) &&
        (exmem_reg_rd == rs2)) begin
        forwarding_rs2  =   exmem_reg_wdata;
    end

    else if (memwb_reg_write == `REG_WR_EN && 
            (memwb_reg_rd != `R_ZERO) &&
            (memwb_reg_rd == rs2)) begin
        forwarding_rs2  =   wb_reg_wdata;
    end

    else begin
        forwarding_rs2  =   reg_rdata2;
    end
end

//==============================================================================
// operand selected
//==============================================================================
assign  operand1    = forwarding_rs1;

always @(*) begin
    if (alu_src == `ALU_SRC_IMM) begin
        operand2    =   imm;
    end

    else begin
        operand2    =   forwarding_rs2;
    end
end

//==============================================================================
// alu result calculate
//==============================================================================
always @(*) begin
    case (alu_op)
        // ignore overflow
        `ALU_ADD:   alu_result_reg  =   operand1 + operand2;
        `ALU_SUB:   alu_result_reg  =   operand1 - operand2;
        `ALU_AND:   alu_result_reg  =   operand1 & operand2;
        `ALU_OR:    alu_result_reg  =   operand1 | operand2;
        `ALU_XOR:   alu_result_reg  =   operand1 ^ operand2;
        `ALU_SLL:   alu_result_reg  =   operand1 << operand2[4:0];
        `ALU_SRL:   alu_result_reg  =   operand1 >> operand2[4:0];

        // can't use $signed(operand1) >>> operand2[4:0];
        `ALU_SRA:   alu_result_reg  =   (operand1 >> operand2[4:0]) | 
                                ({32{operand1[31]}} << (32 - operand2[4:0]));

        // signed less than compare
        `ALU_LT:    begin
                    alu_result_reg  =   ({~operand1[31],operand1[30:0]} <
                                        {~operand2[31],operand2[30:0]});
        end

        `ALU_LTU:   alu_result_reg  =   (operand1 < operand2);

        // for pc + 4, pc + imm
        `ALU_ADDPC: begin
            if (branch_jump) begin
                    alu_result_reg  =   pc + 4;         // JAL and JALR
            end

            else begin
                    alu_result_reg  =   pc + operand2;  // AUIPC
            end
        end

        default :   alu_result_reg  =   `ZERO;
    endcase
end

//==============================================================================
// Mem wdata assign, no matter if it is a STORE instruction, mem wdata is from
// rs2. If it isn't a STORE instruction, decode stage will disable the mem write
// So even we assign mem wdata = rs2 data, it can affect the cpu state.
//==============================================================================
assign  mem_wdata   = forwarding_rs2;

endmodule