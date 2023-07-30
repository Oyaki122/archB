`include "def.h"
module imem (
 input [15:0] a,
 output [`DATA_W-1:0] rd);

	reg [`DATA_W-1:0] mem[0:`DEPTH-1];

	assign rd = mem[a];

	initial
      begin
           $readmemb("imem.dat", mem);
    end


endmodule
