#!/usr/bin/env ruby

class Poco < Arch
  def initialize
    super('rv32i', 'rv32i.rb')
    @pc_incr = 4
    @vars = {
      'rd'      => {:bitnum => 5,  :sign => 'unsigned', :label => false, :jump => nil,        :asm_radix => 10,  :bin_radix => 10},
      'rs1'      => {:bitnum => 5,  :sign => 'unsigned', :label => false, :jump => nil,        :asm_radix => 10,  :bin_radix => 10},
      'rs2'      => {:bitnum => 5,  :sign => 'unsigned', :label => false, :jump => nil,        :asm_radix => 10,  :bin_radix => 10},
      'j_imm'     => {:bitnum => 21,  :sign => 'signed', :label => true, :jump => 'relative',        :asm_radix => nil,  :bin_radix => 10},
      'b_imm'     => {:bitnum => 13,  :sign => 'signed',   :label => true, :jump => 'relative',        :asm_radix => nil, :bin_radix => 10},
      'i_imm'     => {:bitnum => 13,  :sign => 'signed',   :label => false, :jump => 'relative',        :asm_radix => nil, :bin_radix => 10}
    }
    
    @opcodes = {
      'add'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_000_${rd}_0110011'},
      'sub'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00100000${rs2}_${rs1}_000_${rd}_0110011'},
      'sll'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_001_${rd}_0110011'},
      'slt'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_010_${rd}_0110011'},
      'sltu'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_011_${rd}_0110011'},
      'xor'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_100_${rd}_0110011'},
      'srl'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_101_${rd}_0110011'},
      'sra'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00100000${rs2}_${rs1}_101_${rd}_0110011'},
      'or'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_110_${rd}_0110011'},
      'and'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_111_${rd}_0110011'},
      'ecall'    => {:asm => 'x${rd}, x${rs1}, x${rs2}',     :bin => '100_00000000${rs2}_${rs1}_000_${rd}_1110011'},
      'lui2'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_001_${rd}_1110011'},
      'addi'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_000_${rd}_0010011'},
      'slti'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_010_${rd}_0010011'},
      'sltiu'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_011_${rd}_0010011'},
      'xori'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_100_${rd}_0010011'},
      'ori'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_110_${rd}_0010011'},
      'andi'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_111_${rd}_0010011'},
      'lw'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}',    :bin => '001_${i_imm}_${rs1}_010_${rd}_0000011'},
      'sw'   => {:asm => 'x${rs2}, x${rs1}, ${i_imm}',    :bin => '010_${i_imm}_${rs1}_010_${rs2}_0100011'},
      'beq'   => {:asm => 'x${rs1}, x${rs2}, ${b_imm}',    :bin => '011_${b_imm}_${rs1}_000_${rs2}_1100011'},
      'bne'   => {:asm => 'x${rs1}, x${rs2}, ${b_imm}',    :bin => '011_${b_imm}_${rs1}_001_${rs2}_1100011'},
      'blt'   => {:asm => 'x${rs1}, x${rs2}, ${b_imm}',    :bin => '011_${b_imm}_${rs1}_100_${rs2}_1100011'},
      'bge'   => {:asm => 'x${rs1}, x${rs2}, ${b_imm}',    :bin => '011_${b_imm}_${rs1}_101_${rs2}_1100011'},
      'bltu'   => {:asm => 'x${rs1}, x${rs2}, ${b_imm}',    :bin => '011_${b_imm}_${rs1}_110_${rs2}_1100011'},
      'bgeu'   => {:asm => 'x${rs1}, x${rs2}, ${b_imm}',    :bin => '011_${b_imm}_${rs1}_111_${rs2}_1100011'},
      'jal'   => {:asm => 'x${rd}, ${j_imm}',    :bin => '111_${j_imm}_${rd}_1101111'},
      'lui'   => {:asm => 'x${rd}, ${j_imm}',    :bin => '110_${j_imm}_${rd}_0110111'},
      'jalr'   => {:asm => 'x${rd}, x${rs1}, ${i_imm}', :bin => '001_${i_imm}_${rs1}_000_${rd}_1100111'}
    }
  end
  
  def absolute_branch_address(cur_pc, dst_pc)
    return dst_pc
  end
  
  def relative_branch_address(cur_pc, dst_pc)
    return dst_pc - cur_pc - @pc_incr
  end
end


$arch = Poco.new
