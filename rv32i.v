`include "def.h"
module rv32i (
    input clk,
    rst_n,
    input [`DATA_W-1:0] instr,
    input [`DATA_W-1:0] readdata,
    output reg [`DATA_W-1:0] pc,
    output [`DATA_W-1:0] adrdata,
    output [`DATA_W-1:0] writedata,
    output we,
    output ecall
);

  /*  Instruction Fetch Stage */
  reg [`DATA_W-1:0] pcplus4D;
  wire [`DATA_W-1:0] pcplus4;
  reg [`DATA_W-1:0] pcBranchMissed;
  reg [`DATA_W-1:0] instrD;
  wire stall;
  wire btakenD;
  wire bra_op;
  assign pcplus4 = pc + 4;

  // static branch prediction
  wire pre_bra_op;
  wire [`DATA_W-1:0] pcbranch;
  wire branchMiss;

  reg [1:0] bra_history[0:31];
  wire [4:0] bra_history_address;
  reg [4:0] bra_history_addressD;

  wire [12:0] imm_bF;
  wire [2:0] funct3F;
  wire [6:0] funct7F;
  wire [`OPCODE_W-1:0] opcodeF;
  wire [`REG_W-1:0] rs1F, rs2F, rdF;
  wire [19:0] sextF;
  assign {funct7F, rs2F, rs1F, funct3F, rdF, opcodeF} = instr;
  assign sextF = {20{instr[31]}};
  assign imm_bF = {funct7F[6], rdF[0], funct7F[5:0], rdF[4:1], 1'b0};

  assign pre_bra_op = (opcodeF == `OP_BRA);
  assign pcbranch = pcplus4 + {sextF[18:0], imm_bF};
  assign bra_history_address = pc[6:2];
  wire bra_history_now;
  assign bra_history_now = bra_history[bra_history_address][1];


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) instrD <= 0;
    else if (!stall & branchMiss & bra_op) instrD <= `NOP;
    else if (!stall) instrD <= instr;
  end

  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 0;
      pcBranchMissed <= 0;
      bra_history_addressD <= 0;
    end else if (!stall & branchMiss & bra_op) pc <= pcBranchMissed;
    else if (!stall & pre_bra_op & bra_history_now) begin
      pc <= pcbranch;
      pcBranchMissed <= pcplus4;
      bra_history_addressD <= bra_history_address;
    end else if (!stall & pre_bra_op & !bra_history_now) begin
      pc <= pcplus4;
      pcBranchMissed <= pcbranch;
      bra_history_addressD <= bra_history_address;
    end else if (!stall & branchMiss & bra_op) pc <= pcBranchMissed;
    else if (!stall) pc <= pcplus4;

  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i = i + 1) begin
        bra_history[i] <= 2'b10;
      end
    end else if (!stall & bra_op & btakenD & bra_history[bra_history_addressD] != 2'b11)
      bra_history[bra_history_addressD] <= bra_history[bra_history_addressD] + 1;
    else if (!stall & bra_op & !btakenD & bra_history[bra_history_addressD] != 2'b00)
      bra_history[bra_history_addressD] <= bra_history[bra_history_addressD] - 1;
  end

  /*  Instruction Decorder Stage */

  wire addcom;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire [`REG_W-1:0] rs1, rs2, rd;
  wire [`DATA_W-1:0] reg1, reg2, reg1f, reg2f;
  wire [`OPCODE_W-1:0] opcode;
  wire [ `SHAMT_W-1:0] shamt;
  wire [`OPCODE_W-1:0] func;
  wire [11:0] imm_i, imm_s;
  wire [12:0] imm_b;
  wire [20:0] imm_j, imm_u;
  wire rwe;
  wire alu_op, imm_op;
  wire sw_op, beq_op, bne_op, blt_op, bge_op, bltu_op, bgeu_op, lw_op;
  wire slt_op, ecall_op;
  wire lui_op;
  wire ext;
  wire signed [31:0] sreg1, sreg2;
  wire [19:0] sext;
  wire [`DATA_W-1:0] imm;

  // pipeline registers
  reg [`DATA_W-1:0] immE, reg1E, reg2E;
  wire [`DATA_W-1:0] resultdata;
  reg [`REG_W-1:0] rdE, rdW;
  reg [2:0] funct3E;
  reg extE, sw_opE, lw_opE, lw_opM, lui_opE, ecall_opE, rweE, rweM, addcomE;
  reg [`REG_W-1:0] rdM;
  reg rweW, alu_opE;
  reg [`REG_W-1:0] rs1E, rs2E;
  wire lwstall, branchstall;
  reg [`DATA_W-1:0] resultM;

  assign sreg1 = $signed(reg1f);
  assign sreg2 = $signed(reg2f);
  assign {funct7, rs2, rs1, funct3, rd, opcode} = instrD;
  assign sext = {20{instrD[31]}};
  assign imm_i = {funct7, rs2};
  assign imm_s = {funct7, rd};
  assign imm_b = {funct7[6], rd[0], funct7[5:0], rd[4:1], 1'b0};
  assign imm_j = {instrD[31], instrD[19:12], instrD[20], instrD[30:21], 1'b0};
  assign imm_u = instrD[31:12];
  // Decorder
  assign sw_op = (opcode == `OP_STORE) & (funct3 == 3'b010);
  assign lw_op = (opcode == `OP_LOAD) & (funct3 == 3'b010);
  assign alu_op = (opcode == `OP_REG);
  assign imm_op = (opcode == `OP_IMM);
  assign bra_op = (opcode == `OP_BRA);
  assign lui_op = (opcode == `OP_LUI);
  assign beq_op = bra_op & (funct3 == 3'b000);
  assign bne_op = bra_op & (funct3 == 3'b001);
  assign blt_op = bra_op & (funct3 == 3'b100);
  assign bge_op = bra_op & (funct3 == 3'b101);
  assign bltu_op = bra_op & (funct3 == 3'b110);
  assign bgeu_op = bra_op & (funct3 == 3'b111);
  assign ecall_op = (opcode == `OP_SPE) & (funct3 == 3'b000);
  assign ext = alu_op & funct7[5];

  assign imm = imm_op | lw_op ? {sext, imm_i}:
				sw_op ? {sext, imm_s}:
	      lui_op ? {imm_u,12'b0}: {sext[10:0], imm_j};

  assign rwe = lw_op | alu_op | imm_op | lui_op;
  assign addcom = (lw_op | sw_op);

  rfile rfile_1 (
      .clk(clk),
      .rd1(reg1),
      .a1 (rs1),
      .rd2(reg2),
      .a2 (rs2),
      .wd3(resultdata),
      .a3 (rdW),
      .we3(rweW)
  );
  // Stall
  assign lwstall = ((rs1 == rdE) | ((rs2 == rdE) & !imm_op)) & lw_opE;
  assign branchstall =  (bra_op & rweE & (rs1 == rdE | rs2 == rdE)) |
      (bra_op & lw_opM & (rs1 == rdM | rs2 == rdM));
  assign stall = lwstall | branchstall;
  assign branchMiss = btakenD != bra_history[bra_history_addressD][1];

  // Forwarding;
  assign reg1f = (rs1 != 0) & (rs1 == rdM) & rweM ? resultM : reg1;
  assign reg2f = (rs2 != 0) & (rs2 == rdM) & rweM ? resultM : reg2;

  // Branch
  assign btakenD = beq_op & (reg1f == reg2f) | bne_op & (reg1f != reg2f) |
		blt_op & (sreg1<sreg2)  | bge_op & (sreg1>=sreg2)  |
		bltu_op & (reg1f<reg2f)  | bgeu_op & (reg1f>=reg2f);
  // assign pcbranchD = pcplus4D + {sext[18:0],imm_b};

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg1E <= 0;
      reg2E <= 0;
      rdE <= 0;
      rs1E <= 0;
      rs2E <= 0;
      funct3E <= 0;
      sw_opE <= 0;
      lw_opE <= 0;
      ecall_opE <= 0;
      lui_opE <= 0;
      alu_opE <= 0;
      rweE <= 0;
      addcomE <= 0;
      extE <= 0;
      immE <= 0;
    end else if (stall) begin
      //		rs1E<=0; rs2E<=0; rdE<=0; 
      sw_opE <= 0;
      rweE   <= 0;
      lw_opE <= 0;
    end else begin
      reg1E <= reg1f;
      reg2E <= reg2f;
      rdE <= rd;
      rs1E <= rs1;
      rs2E <= rs2;
      funct3E <= funct3;
      sw_opE <= sw_op;
      lw_opE <= lw_op;
      ecall_opE <= ecall_op;
      lui_opE <= lui_op;
      alu_opE <= alu_op;
      rweE <= rwe;
      addcomE <= addcom;
      extE <= ext;
      immE <= imm;
    end
  end

  /*  Execution Stage */
  wire [`DATA_W-1:0] srca, srcb, alub, result, aluresult;
  reg [`DATA_W-1:0] alubM;
  reg sw_opM, ecall_opM;
  wire [`DATA_W-1:0] fdata;
  reg  [`DATA_W-1:0] fdataW;
  // assign srca = reg1E;
  // assign srcb = alu_opE? reg2E: immE;
  assign result = lui_opE ? immE : aluresult;
  // Forwarding
  assign srca = rweM & rs1E!=0 & rdM == rs1E ? resultM:
				rweW & rs1E!=0 & rdW == rs1E ? fdataW: reg1E;
  assign srcb = alu_opE ? alub : immE;
  assign alub = rweM & rs2E!=0 & rdM == rs2E ? resultM:
				rweW & rs2E!=0 & rdW == rs2E ? fdataW: reg2E;

  alu alu_1 (
      .a(srca),
      .b(srcb),
      .s(funct3E),
      .ext(extE),
      .addcom(addcomE),
      .y(aluresult)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      resultM <= 0;
      alubM <= 0;
      rdM <= 0;
      rweM <= 0;
      sw_opM <= 0;
      lw_opM <= 0;
      ecall_opM <= 0;
    end else begin
      resultM <= result;
      alubM <= alub;
      rdM <= rdE;
      rweM <= rweE;
      sw_opM <= sw_opE;
      lw_opM <= lw_opE;
      ecall_opM <= ecall_opE;
    end
  end

  /*  Memory Access Stage */
  reg lw_opW, ecall_opW;
  reg [`DATA_W-1:0] resultW;
  reg [`DATA_W-1:0] readdataW;
  assign we = sw_opM;
  assign adrdata = resultM;
  assign writedata = alubM;
  assign fdata = lw_opM ? readdata : resultM;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lw_opW <= 0;
      ecall_opW <= 0;
      rdW <= 0;
      rweW <= 0;
      fdataW <= 0;
      resultW <= 0;
      readdataW <= 0;
    end else begin
      lw_opW <= lw_opM;
      ecall_opW <= ecall_opM;
      rdW <= rdM;
      rweW <= rweM;
      readdataW <= readdata;
      fdataW <= fdata;
      resultW <= resultM;
    end
  end
  /*  Write back Stage */
  assign ecall = ecall_opW;
  assign resultdata = lw_opW ? readdataW : resultW;
endmodule
