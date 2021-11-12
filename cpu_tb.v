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
integer                 i;

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
    
    #5000
    $finish;
end

//initial begin
//    #5000
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[96]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[97]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[98]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[99]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[100]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[101]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[102]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[103]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[104]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[105]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[106]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[107]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[108]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[109]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[110]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[111]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[112]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[113]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[114]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[115]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[116]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[117]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[118]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[119]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[120]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[121]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[122]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[123]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[124]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[125]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[126]);
//    $monitor("%h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[127]);
//    //$monitor("mem[128]  = %h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[128]);
//    //$monitor("mem[129]  = %h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[129]);
//    //$monitor("mem[130]  = %h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[130]);
//    //$monitor("mem[131]  = %h",u_cpu_top.u_d_cache.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[131]);
//end

endmodule