// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : hardzard_detection.v
// Module Name         : hardzard_detection
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : this module is comb logic, handle the id forwarding and
//                          ex forwarding when cpu must stall for one or two 
//                          cycles, for example, RAW dependency with LOAD in ex
//                          forwarding, the cpu must stall for one cycles. when
//                          BRANCH after LOAD, it must be stall for 2 cycles, 
//                          BRANCH after ADD..., it mus be stall for 1 cycles.
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

module hardzard_detection (
    // two rs1 from id, assert if forwarding can handle the RAW
    input   [`RADDR_WIDTH-1:0]  id_rs1,
    input                       id_read1,
    input   [`RADDR_WIDTH-1:0]  id_rs2,
    input                       id_read2,

    // handle jump and branch hazard forwarding when BRANCH with a ADD or LOAD
    // after ADD, stall one cycle, after LOAD, stall two cycles.
    // handle normal RAW dependency, rd=rs and mem read enable, stall one cycle.
    input   [`RADDR_WIDTH-1:0]  idex_reg_rd,
    input                       idex_mem_read,
    input                       idex_reg_write,

    input   [`RADDR_WIDTH-1:0]  exmem_reg_rd,
    input                       exmem_mem_read,

    // decide if a jumpbranch or add addi store etc.
    input   [`DATA_WIDTH-1:0]   instruction,

    input   [`DEBUG_WIDTH-1:0]  debug,

    input                       env_exception,
    input                       bp_exception,

    output                      stall
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                     stall_reg;
wire    [`OP_WIDTH-1:0] opcode;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign stall    = stall_reg;
assign opcode   = instruction[6:0];

//==============================================================================
// Stall signals generate -> when enviroment or breakpoint exception or debug 
// mode enable. We need unconditional stall. And then When idex_mem_read enable
// and idex_reg_rd == id_rs1 and read1 enable or idex_reg_rd == id_rs2 and read2
// enable. We need stall for the data hazard. When opcode == JARL or B and 
// idex_reg_write enable, and idex_reg_rd == id_rs1......like above. we also
// need stall for branch and jump data hazard. Finally, if opcode == JARL or B, 
// and exmem_mem_read enable and exmem_reg_rd == id_rs1......like above. We also
// need stall because branch and jump after a LOAD need stall two cycles!! OK! 
// That's all!
//==============================================================================
always @(*) begin
    if (env_exception == `ENV_EXC) begin
        stall_reg   =   `STALL_EN;
    end

    else if (bp_exception == `BP_EXC) begin
        stall_reg   =   `STALL_EN;
    end

    else if (debug != `DEBUG_DIS) begin
        stall_reg   =   `STALL_EN;
    end

    else if (idex_mem_read == `MEM_RD_EN && 
            ((id_rs1 == idex_reg_rd && id_read1 == `REG_S1RD_EN) ||
             (id_rs2 == idex_reg_rd && id_read2 == `REG_S1RD_EN))) begin
        stall_reg   =   `STALL_EN;
    end

    else if (opcode == `OP_JALR || opcode == `OP_B) begin
        if (idex_reg_write == `REG_WR_EN &&
            ((id_rs1 == idex_reg_rd && id_read1 == `REG_S1RD_EN) ||
            (id_rs2 == idex_reg_rd && id_read2 == `REG_S1RD_EN))) begin
            stall_reg   =   `STALL_EN;
        end

        else if (exmem_mem_read == `MEM_RD_EN &&
            ((id_rs1 == exmem_reg_rd && id_read1 == `REG_S1RD_EN) ||
            (id_rs2 == exmem_reg_rd && id_read2 == `REG_S1RD_EN))) begin
            stall_reg   =   `STALL_EN;
        end

        else begin
            stall_reg   =   `STALL_DIS;
        end
    end

    else begin
        stall_reg   =   `STALL_DIS;
    end
end
endmodule