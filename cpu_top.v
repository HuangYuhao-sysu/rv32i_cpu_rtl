// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : cpu_top.v
// Module Name         : cpu_top
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : top of cpu
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/02       Huangyh             1.0                 5 stage rv32i
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module cpu_top (
    // Clock for cpu work.
    input                       clk_cpu,
    // Clock for when stall cpu, read data from pc, reg, i cache and d cache.
    input                       clk_debug,

    // Asynchronous reset active low, need to synchronize.
    input                       rst_n_cpu_ext,
    input                       rst_n_debug_ext,

    input   [`DEBUG_WIDTH-1:0]  debug,

    // from external io to write and read i cache.
    input   [`IADDR_WIDTH-1:0]  ext_icache_addr_i,
    input   [`DATA_WIDTH-1:0]   ext_icache_wdata_i,

    // external read reg enable.
    input   [`RADDR_WIDTH-1:0]  ext_reg_raddr_i,

    // external io to read dcache.
    input   [`DADDR_WIDTH-1:0]  ext_dcache_raddr_i,

    // read data to external.
    output  [`PC_WIDTH-1:0]     ext_pc_o,
    output  [`DATA_WIDTH-1:0]   ext_icache_rdata_o,
    output  [`DATA_WIDTH-1:0]   ext_reg_rdata_o,
    output  [`DATA_WIDTH-1:0]   ext_dcache_rdata_o
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /

//==============================================================================
// top level rst signals
//==============================================================================
wire                            rst_n_cpu;
wire                            rst_n_debug;

//==============================================================================
// clk mux
//==============================================================================
wire                            clk_mux;

//==============================================================================
// 5 stage rv32i cpu instance -> pc signals definition
//==============================================================================
wire    [`PC_WIDTH-1:0]         target_pc;
wire                            pc_src;
wire                            stall;
wire    [`PC_WIDTH-1:0]         pc;

//==============================================================================
// 5 stage rv32i cpu instance -> if signals definition
//==============================================================================
wire    [`IADDR_WIDTH-1:0]      pc_aligned;
wire                            if_icache_ceb;
wire                            if_icache_web;

//==============================================================================
// 5 stage rv32i cpu instance -> ifid signals definition
//==============================================================================
wire    [`DATA_WIDTH-1:0]       instruction;
wire                            flush;
wire    [`PC_WIDTH-1:0]         ifid_pc;
wire    [`DATA_WIDTH-1:0]       ifid_instruction;

//==============================================================================
// 5 stage rv32i cpu instance -> id signals definition
//==============================================================================
wire                            id_branch_jump;
wire                            id_alu_src;
wire    [`ALUOP_WIDTH-1:0]      id_alu_op;
wire                            id_mem_write;
wire                            id_mem_read;
wire    [`MEM_MODE_WIDTH-1:0]   id_mem_mode;
wire                            id_mem_to_reg;
wire                            id_reg_write;
wire    [`RADDR_WIDTH-1:0]      id_reg_dest;
wire    [`RADDR_WIDTH-1:0]      id_reg_rs1;
wire                            id_reg_read1;
wire    [`RADDR_WIDTH-1:0]      id_reg_rs2;
wire                            id_reg_read2;
wire    [`DATA_WIDTH-1:0]       id_imm;
wire                            env_exception;
wire                            bp_exception;

//==============================================================================
// 5 stage rv32i cpu instance -> id control signals definition
//==============================================================================
wire                            control_alu_src;
wire    [`ALUOP_WIDTH-1:0]      control_alu_op;
wire                            control_mem_write;
wire                            control_mem_read;
wire    [`MEM_MODE_WIDTH-1:0]   control_mem_mode;
wire                            control_mem_to_reg;
wire                            control_reg_write;

//==============================================================================
// 5 stage rv32i cpu instance -> idex signals definition
//==============================================================================
wire    [`PC_WIDTH-1:0]         idex_pc;
wire                            idex_branch_jump;
wire                            idex_alu_src;
wire    [`ALUOP_WIDTH-1:0]      idex_alu_op;
wire                            idex_mem_write;
wire                            idex_mem_read;
wire    [`MEM_MODE_WIDTH-1:0]   idex_mem_mode;
wire                            idex_mem_to_reg;
wire                            idex_reg_write;
wire    [`DATA_WIDTH-1:0]       idex_reg_rdata1;
wire    [`DATA_WIDTH-1:0]       idex_reg_rdata2;
wire    [`DATA_WIDTH-1:0]       idex_imm;
wire    [`RADDR_WIDTH-1:0]      idex_rs1;
wire    [`RADDR_WIDTH-1:0]      idex_rs2;
wire    [`RADDR_WIDTH-1:0]      idex_reg_rd;

//==============================================================================
// 5 stage rv32i cpu instance -> ex signals definition
//==============================================================================
wire    [`DATA_WIDTH-1:0]       alu_result;
wire    [`DATA_WIDTH-1:0]       mem_wdata;

//==============================================================================
// 5 stage rv32i cpu instance -> exmem signals definition
//==============================================================================
wire                            exmem_mem_write;
wire                            exmem_mem_read;
wire    [`MEM_MODE_WIDTH-1:0]   exmem_mem_mode;
wire                            exmem_mem_to_reg;
wire    [`DATA_WIDTH-1:0]       exmem_alu_result;
wire    [`DATA_WIDTH-1:0]       exmem_mem_wdata;
wire    [`RADDR_WIDTH-1:0]      exmem_reg_dest;
wire                            exmem_reg_write;

//==============================================================================
// 5 stage rv32i cpu instance -> mem access signals definition
//==============================================================================
wire    [`DADDR_WIDTH-1:0]      mem_dcache_addr;
wire                            mem_dcache_ceb;
wire                            mem_dcache_web;
wire    [`DATA_WIDTH-1:0]       mem_dcache_bweb;
wire    [`DATA_WIDTH-1:0]       mem_dcache_wdata;
wire    [`DATA_WIDTH-1:0]       mem_rdata;

//==============================================================================
// 5 stage rv32i cpu instance -> memwb access signals definition
//==============================================================================
wire                            memwb_mem_to_reg;
wire    [`RADDR_WIDTH-1:0]      memwb_reg_dest;
wire    [`DATA_WIDTH-1:0]       memwb_alu_result;
wire                            memwb_reg_write;
wire    [`DATA_WIDTH-1:0]       memwb_mem_rdata;

//==============================================================================
// 5 stage rv32i cpu instance -> wb access signals definition
//==============================================================================
wire                            wb_reg_write;
wire    [`RADDR_WIDTH-1:0]      wb_reg_waddr;
wire    [`DATA_WIDTH-1:0]       wb_reg_wdata;

//==============================================================================
// 5 stage rv32i cpu instance -> regfile access signals definition
//==============================================================================
wire    [`RADDR_WIDTH-1:0]      reg_rs2;
wire                            reg_read2;
wire    [`DATA_WIDTH-1:0]       rs1_data;
wire    [`DATA_WIDTH-1:0]       rs2_data;

//==============================================================================
// 5 stage rv32i cpu instance -> i cache access signals definition
//==============================================================================
wire                            icache_ceb;
wire                            icache_web;
wire    [`IADDR_WIDTH-1:0]      icache_addr;

//==============================================================================
// 5 stage rv32i cpu instance -> d cache access signals definition
//==============================================================================
wire                            dcache_ceb;
wire                            dcache_web;
wire    [`DATA_WIDTH-1:0]       dcache_bweb;
wire    [`DADDR_WIDTH-1:0]      dcache_addr;
wire    [`DATA_WIDTH-1:0]       dcache_dout;


//==============================================================================
// cpu io control signals definition -> io_control
//==============================================================================
wire    [`IADDR_WIDTH-1:0]      ext_icache_addr;
wire                            ext_icache_ceb;
wire                            ext_icache_web;
wire    [`DATA_WIDTH-1:0]       ext_icache_wdata;
wire    [`RADDR_WIDTH-1:0]      ext_reg_rs2;
wire                            ext_reg_read2;
wire    [`DADDR_WIDTH-1:0]      ext_dcache_addr;
wire                            ext_dcache_ceb;
wire                            ext_dcache_web;
wire    [`DATA_WIDTH-1:0]       ext_dcache_bweb;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// async rst and sync release module
//==============================================================================
async_rst u0_async_rst(
    .clk     ( clk_cpu       ),
    .rst_n_i ( rst_n_cpu_ext ),
    .rst_n_o ( rst_n_cpu     )
);

async_rst u1_async_rst(
    .clk     ( clk_debug       ),
    .rst_n_i ( rst_n_debug_ext ),
    .rst_n_o ( rst_n_debug     )
);

//==============================================================================
// clk mux module
//==============================================================================
clk_mux u_clk_mux(
    .clk_cpu     ( clk_cpu     ),
    .clk_debug   ( clk_debug   ),
    .rst_n_cpu   ( rst_n_cpu   ),
    .rst_n_debug ( rst_n_debug ),
    .debug       ( debug       ),
    .clk_mux     ( clk_mux     )
);

//==============================================================================
// for external write i cache, read pc, i cache, regfile and d cache.
//==============================================================================
io_control u_io_control(
    .clk            ( clk_debug          ),
    .rst_n          ( rst_n_debug        ),
    .debug          ( debug              ),
    .pc_i           ( pc                 ),
    .icache_rdata_i ( instruction        ),
    .reg_rdata_i    ( rs2_data           ),
    .dcache_rdata_i ( dcache_dout        ),
    .icache_addr_i  ( ext_icache_addr_i  ),
    .icache_wdata_i ( ext_icache_wdata_i ),
    .reg_raddr_i    ( ext_reg_raddr_i    ),
    .dcache_raddr_i ( ext_dcache_raddr_i ),
    .pc_o           ( ext_pc_o           ),
    .icache_rdata_o ( ext_icache_rdata_o ),
    .reg_rdata_o    ( ext_reg_rdata_o    ),
    .dcache_rdata_o ( ext_dcache_rdata_o ),
    .icache_addr_o  ( ext_icache_addr    ),
    .icache_ceb_o   ( ext_icache_ceb     ),
    .icache_web_o   ( ext_icache_web     ),
    .icache_wdata_o ( ext_icache_wdata   ),
    .reg_raddr_o    ( ext_reg_rs2        ),
    .reg_read_o     ( ext_reg_read2      ),
    .dcache_raddr_o ( ext_dcache_addr    ),
    .dcache_ceb_o   ( ext_dcache_ceb     ),
    .dcache_bweb_o  ( ext_dcache_bweb    )
);

//==============================================================================
// mux i cache, regfile and d cache control signals, if they from cpu or ext.
//==============================================================================
cpu_state_mux u_cpu_state_mux(
    .debug           ( debug           ),
    .int_icache_ceb  ( if_icache_ceb   ),
    .int_icache_web  ( if_icache_web   ),
    .int_icache_addr ( pc_aligned      ),
    .ext_icache_ceb  ( ext_icache_ceb  ),
    .ext_icache_web  ( ext_icache_web  ),
    .ext_icache_addr ( ext_icache_addr ),
    .int_reg_read2   ( id_reg_read2    ),
    .int_reg_rs2     ( id_reg_rs2      ),
    .ext_reg_read2   ( ext_reg_read2   ),
    .ext_reg_rs2     ( ext_reg_rs2     ),
    .int_dcache_ceb  ( mem_dcache_ceb  ),
    .int_dcache_bweb ( mem_dcache_bweb ),
    .int_dcache_addr ( mem_dcache_addr ),
    .ext_dcache_ceb  ( ext_dcache_ceb  ),
    .ext_dcache_bweb ( ext_dcache_bweb ),
    .ext_dcache_addr ( ext_dcache_addr ),
    .icache_ceb      ( icache_ceb      ),
    .icache_web      ( icache_web      ),
    .icache_addr     ( icache_addr     ),
    .reg_read2       ( reg_read2       ),
    .reg_rs2         ( reg_rs2         ),
    .dcache_ceb      ( dcache_ceb      ),
    .dcache_bweb     ( dcache_bweb     ),
    .dcache_addr     ( dcache_addr     )
);

//==============================================================================
// 5 stage rv32i cpu instance -> pc, cpu state
//==============================================================================
program_counter u_program_counter(
    .clk       ( clk_cpu   ),
    .rst_n     ( rst_n_cpu ),
    .target_pc ( target_pc ),
    .pc_src    ( pc_src    ),
    .stall     ( stall     ),
    .pc        ( pc        )
);

//==============================================================================
// 5 stage rv32i cpu instance -> if, combinational logic
//==============================================================================
instruction_fetch u_instruction_fetch(
    .pc         ( pc            ),
    .pc_aligned ( pc_aligned    ),
    .ceb        ( if_icache_ceb ),
    .web        ( if_icache_web )
);

//==============================================================================
// 5 stage rv32i cpu instance -> ifid, sequential logic for pipeline
//==============================================================================
stage_ifid u_stage_ifid(
    .clk           ( clk_cpu          ),
    .rst_n         ( rst_n_cpu        ),
    .current_pc_i  ( pc               ),
    .instruction_i ( instruction      ),
    .stall         ( stall            ),
    .flush         ( flush            ),
    .current_pc_o  ( ifid_pc          ),
    .instruction_o ( ifid_instruction )
);

//==============================================================================
// 5 stage rv32i cpu instance -> id, combinational logic for decode
//==============================================================================
instruction_decode u_instruction_decode(
    .instruction   ( ifid_instruction ),
    .branch_jump   ( id_branch_jump   ),
    .alu_src       ( id_alu_src       ),
    .alu_op        ( id_alu_op        ),
    .mem_write     ( id_mem_write     ),
    .mem_read      ( id_mem_read      ),
    .mem_mode      ( id_mem_mode      ),
    .mem_to_reg    ( id_mem_to_reg    ),
    .reg_write     ( id_reg_write     ),
    .reg_dest      ( id_reg_dest      ),
    .reg_rs1       ( id_reg_rs1       ),
    .reg_read1     ( id_reg_read1     ),
    .reg_rs2       ( id_reg_rs2       ),
    .reg_read2     ( id_reg_read2     ),
    .imm           ( id_imm           ),
    .env_exception ( env_exception    ),
    .bp_exception  ( bp_exception     )
);

//==============================================================================
// 5 stage rv32i cpu instance -> combinational logic for hazard, J and B 
// instructions will be decode and execute in id stage, so we need hazard
// detection logic to detect if it has like ADD after LOAD RAW dependency, or
// B, J after LOAD, ADD RAW dependency, which need stall for 1, 1 or 2 cycles
// respectively.
//==============================================================================
hardzard_detection u_hardzard_detection(
    .id_rs1         ( id_reg_rs1       ),
    .id_read1       ( id_reg_read1     ),
    .id_rs2         ( id_reg_rs2       ),
    .id_read2       ( id_reg_read2     ),
    .idex_reg_rd    ( idex_reg_rd      ),
    .idex_mem_read  ( idex_mem_read    ),
    .idex_reg_write ( idex_reg_write   ),
    .exmem_reg_rd   ( exmem_reg_dest   ),
    .exmem_mem_read ( exmem_mem_read   ),
    .instruction    ( ifid_instruction ),
    .debug          ( debug            ),
    .env_exception  ( env_exception    ),
    .bp_exception   ( bp_exception     ),
    .stall          ( stall            )
);


//==============================================================================
// 5 stage rv32i cpu instance -> for reduce penalty of flush pipeline caused by
// Jump and Branch, these two kinds of instrcutions will be execute in id stage,
// module below is designed specifically for this. Also original data forwarding
// unit in ex move to this module, hazard detection logic will handle J, B
// data forwarding hazard and ADD ect. hazard together.
//==============================================================================
id_branch_jump u_id_branch_jump(
    .alu_src         ( id_alu_src       ),
    .alu_op          ( id_alu_op        ),
    .branch_jump     ( id_branch_jump   ),
    .current_pc      ( ifid_pc          ),
    .id_reg_rs1      ( id_reg_rs1       ),
    .id_reg_rs2      ( id_reg_rs2       ),
    .exmem_reg_dest  ( exmem_reg_dest   ),
    .memwb_reg_dest  ( memwb_reg_dest   ),
    .exmem_reg_write ( exmem_reg_write  ),
    .memwb_reg_write ( memwb_reg_write  ),
    .exmem_reg_wdata ( exmem_alu_result ),
    .wb_reg_wdata    ( wb_reg_wdata     ),
    .reg_rdata1      ( rs1_data         ),
    .reg_rdata2      ( rs2_data         ),
    .imm             ( id_imm           ),
    .target_pc       ( target_pc        ),
    .flush_pipeline  ( flush            ),
    .pc_src          ( pc_src           )
);

//==============================================================================
// 5 stage rv32i cpu instance -> for manage control signals that can change the
// cpu architecture state, including alu src, alu op, reg write, mem read write
// mode, mem to reg. when hazard detected or debug mode enable, these control
// signals should be zero.
//==============================================================================
id_control u_id_control(
    .id_alu_src     ( id_alu_src          ),
    .id_alu_op      ( id_alu_op           ),
    .id_mem_write   ( id_mem_write        ),
    .id_mem_read    ( id_mem_read         ),
    .id_mem_mode    ( id_mem_mode         ),
    .id_mem_to_reg  ( id_mem_to_reg       ),
    .id_reg_write   ( id_reg_write        ),
    .stall          ( stall               ),
    .alu_src        ( control_alu_src     ),
    .alu_op         ( control_alu_op      ),
    .mem_write      ( control_mem_write   ),
    .mem_read       ( control_mem_read    ),
    .mem_mode       ( control_mem_mode    ),
    .mem_to_reg     ( control_mem_to_reg  ),
    .reg_write      ( control_reg_write   )
);

//==============================================================================
// 5 stage rv32i cpu instance -> idex, sequential logic for pipeline
//==============================================================================
stage_idex u_stage_idex(
    .clk           ( clk_cpu            ),
    .rst_n         ( rst_n_cpu          ),
    .pc_i          ( ifid_pc            ),
    .branch_jump_i ( id_branch_jump     ),
    .alu_src_i     ( control_alu_src    ),
    .alu_op_i      ( control_alu_op     ),
    .mem_write_i   ( control_mem_write  ),
    .mem_read_i    ( control_mem_read   ),
    .mem_mode_i    ( control_mem_mode   ),
    .mem_to_reg_i  ( control_mem_to_reg ),
    .reg_write_i   ( control_reg_write  ),
    .reg_rdata1_i  ( rs1_data           ),
    .reg_rdata2_i  ( rs2_data           ),
    .imm_i         ( id_imm             ),
    .rs1_i         ( id_reg_rs1         ),
    .rs2_i         ( id_reg_rs2         ),
    .rd_i          ( id_reg_dest        ),
    .pc_o          ( idex_pc            ),
    .branch_jump_o ( idex_branch_jump   ),
    .alu_src_o     ( idex_alu_src       ),
    .alu_op_o      ( idex_alu_op        ),
    .mem_write_o   ( idex_mem_write     ),
    .mem_read_o    ( idex_mem_read      ),
    .mem_mode_o    ( idex_mem_mode      ),
    .mem_to_reg_o  ( idex_mem_to_reg    ),
    .reg_write_o   ( idex_reg_write     ),
    .reg_rdata1_o  ( idex_reg_rdata1    ),
    .reg_rdata2_o  ( idex_reg_rdata2    ),
    .imm_o         ( idex_imm           ),
    .rs1_o         ( idex_rs1           ),
    .rs2_o         ( idex_rs2           ),
    .rd_o          ( idex_reg_rd        )
);

//==============================================================================
// 5 stage rv32i cpu instance -> ex, combinational logic, contain data
// forwarding unit, just for ADD ect. instrcutions, except J and B.
//==============================================================================
execution u_execution(
    .pc              ( idex_pc          ),
    .branch_jump     ( idex_branch_jump ),
    .alu_src         ( idex_alu_src     ),
    .alu_op          ( idex_alu_op      ),
    .imm             ( idex_imm         ),
    .reg_rdata1      ( idex_reg_rdata1  ),
    .reg_rdata2      ( idex_reg_rdata2  ),
    .rs1             ( idex_rs1         ),
    .rs2             ( idex_rs2         ),
    .exmem_reg_write ( exmem_reg_write  ),
    .memwb_reg_write ( memwb_reg_write  ),
    .exmem_reg_rd    ( exmem_reg_dest   ),
    .memwb_reg_rd    ( memwb_reg_dest   ),
    .exmem_reg_wdata ( exmem_alu_result ),
    .wb_reg_wdata    ( wb_reg_wdata     ),
    .alu_result      ( alu_result       ),
    .mem_wdata       ( mem_wdata        )
);

//==============================================================================
// 5 stage rv32i cpu instance -> exmem, sequential logic for pipeline
//==============================================================================
stage_exmem u_stage_exmem(
    .clk          ( clk_cpu          ),
    .rst_n        ( rst_n_cpu        ),
    .mem_write_i  ( idex_mem_write   ),
    .mem_read_i   ( idex_mem_read    ),
    .mem_mode_i   ( idex_mem_mode    ),
    .mem_to_reg_i ( idex_mem_to_reg  ),
    .alu_result_i ( alu_result       ),
    .mem_wdata_i  ( mem_wdata        ),
    .rd_i         ( idex_reg_rd      ),
    .reg_write_i  ( idex_reg_write   ),
    .mem_write_o  ( exmem_mem_write  ),
    .mem_read_o   ( exmem_mem_read   ),
    .mem_mode_o   ( exmem_mem_mode   ),
    .mem_to_reg_o ( exmem_mem_to_reg ),
    .alu_result_o ( exmem_alu_result ),
    .mem_wdata_o  ( exmem_mem_wdata  ),
    .rd_o         ( exmem_reg_dest   ),
    .reg_write_o  ( exmem_reg_write  )
);

//==============================================================================
// 5 stage rv32i cpu instance -> mem, handle memory read or write. d cache is a 
// sub module of memmory access.
//==============================================================================

memory_access u_memory_access(
    .mem_wdata    ( exmem_mem_wdata  ),
    .mem_addr     ( exmem_alu_result ),
    .mem_mode     ( exmem_mem_mode   ),
    .mem_write    ( exmem_mem_write  ),
    .mem_read     ( exmem_mem_read   ),
    .dcache_rdata ( dcache_dout      ),
    .dcache_addr  ( mem_dcache_addr  ),
    .dcache_ceb   ( mem_dcache_ceb   ),
    .dcache_bweb  ( mem_dcache_bweb  ),
    .dcache_wdata ( mem_dcache_wdata ),
    .mem_rdata    ( mem_rdata        )
);

//==============================================================================
// 5 stage rv32i cpu instance -> memwb, sequential logic for pipeline
//==============================================================================
stage_memwb u_stage_memwb(
    .clk          ( clk_cpu          ),
    .rst_n        ( rst_n_cpu        ),
    .mem_to_reg_i ( exmem_mem_to_reg ),
    .rd_i         ( exmem_reg_dest   ),
    .alu_result_i ( exmem_alu_result ),
    .reg_write_i  ( exmem_reg_write  ),
    .mem_to_reg_o ( memwb_mem_to_reg ),
    .rd_o         ( memwb_reg_dest   ),
    .alu_result_o ( memwb_alu_result ),
    .reg_write_o  ( memwb_reg_write  )
);

//==============================================================================
// 5 stage rv32i cpu instance -> wb, combinational logic for writeback regfile.
//==============================================================================
writeback u_writeback(
    .mem_to_reg ( memwb_mem_to_reg ),
    .rd         ( memwb_reg_dest   ),
    .alu_result ( memwb_alu_result ),
    .reg_web    ( memwb_reg_write  ),
    .mem_rdata  ( mem_rdata        ),
    .reg_write  ( wb_reg_write     ),
    .reg_waddr  ( wb_reg_waddr     ),
    .reg_wdata  ( wb_reg_wdata     )
);

//==============================================================================
// cpu storage, regfile, sequential write, combinational read
//==============================================================================
regfile u_regfile(
    .clk      ( clk_cpu      ),
    .rst_n    ( rst_n_cpu    ),
    .rs1_addr ( id_reg_rs1   ),
    .rs2_addr ( reg_rs2      ),
    .rs1_en   ( id_reg_read1 ),
    .rs2_en   ( reg_read2    ),
    .waddr    ( wb_reg_waddr ),
    .wdata    ( wb_reg_wdata ),
    .wen      ( wb_reg_write ),
    .rs1_data ( rs1_data     ),
    .rs2_data ( rs2_data     )
);


//==============================================================================
// Vivado IP i cache and d cache
//==============================================================================
i_cache u_i_cache(
    .addra ( icache_addr      ),
    .clka  ( clk_mux          ),
    .dina  ( ext_icache_wdata ),
    .douta ( instruction      ),
    .ena   ( icache_ceb       ),
    .wea   ( icache_web       )
);

d_cache u_d_cache(
    .addra ( dcache_addr      ),
    .clka  ( clk_mux          ),
    .dina  ( mem_dcache_wdata ),
    .douta ( dcache_dout      ),
    .ena   ( dcache_ceb       ),
    .wea   ( dcache_bweb      )
);

endmodule