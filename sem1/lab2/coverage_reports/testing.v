//      // verilator_coverage annotation
        `timescale 1ns/1ns
        `include "double_multiplier.v"
        
        import "DPI-C" function longint unsigned c_etalon (longint unsigned a, longint unsigned b);
        
        module top();
        
 000042 reg clock;
%000001 reg reset;
        
%000001 reg[63:0] a = 0, b = 0;
%000001 reg[63:0] res = 0;
%000001 reg[63:0] etalon = 0;
        
        
        /*assign wire a_f = a;
        assign wire b_f = b;
        assign wire res_f = res;
        assign wire etalon_f = etalon;*/
        
        // input clock;
        // input reset;
        
%000001 reg     [63:0] h_input_a;
%000002 reg     h_input_a_stb;
%000002 reg     h_input_a_ack;
        
%000001 reg     [63:0] h_input_b;
%000002 reg     h_input_b_stb;
%000002 reg     h_input_b_ack;
        
%000001 wire    [63:0] h_output_z;
%000002 wire     h_output_z_stb;
%000002 reg     h_output_z_ack;
        
%000001 integer fd = 0, random_n = 0;
%000001 string filename = "";
%000001 integer timeout_counter=0;
%000001 integer timeout_max = 5000;
        
        double_multiplier
        dut(
            .input_a(h_input_a),
            .input_b(h_input_b),
            .input_a_stb(h_input_a_stb),
            .input_b_stb(h_input_b_stb),
            .output_z_ack(h_output_z_ack),
            .clk(clock),
            .rst(reset),
            .output_z(h_output_z),
            .output_z_stb(h_output_z_stb),
            .input_a_ack(h_input_a_ack),
            .input_b_ack(h_input_b_ack)
        
        );
        
%000001 initial begin
%000001     reset = 1;
%000001     clock = 0;
%000001     #10
%000001     reset = 0;
%000001     #10
%000000     if ($value$plusargs("arg0=%x", a) && $value$plusargs("arg1=%x", b)) begin
%000000         perform_calculation_and_check(a, b);
            end
%000000     else if ($value$plusargs("from_file=%s", filename)) begin
%000000         fd = $fopen(filename, "r");
%000000         if(fd == 0) begin
%000000             $display("Unable to open file %s", filename);
                end
%000000         while(!$feof(fd)) begin
%000000             $fscanf(fd, " %x", a);
%000000             $fgetc(fd);
%000000             $fscanf(fd, " %x", b);
%000000             $fgetc(fd);
%000000             perform_calculation_and_check(a, b);
                end
%000000         $fclose(fd);
        
            end
%000001     else if ($value$plusargs("random_mode=%d", random_n)) begin
%000002         while(random_n > 0) begin
%000002             a[31:0] = $random;
%000002             a[63:32] = $random;
%000002             b[31:0] = $random;
%000002             b[63:32] = $random;
%000002             perform_calculation_and_check(a, b);
%000002             random_n -= 1;
                end
            end
%000001     $finish;
        end
        
 000084 always
 000084 begin
 000084     #1
 000084     clock = ~clock;
 000084 	timeout_counter = timeout_counter + 1;
        end
        
%000000 task reset_timeout();
%000000 	$display("Here");
%000000 	reset = 1;
%000000 	#100
%000000 	reset = 0;
        endtask
        
        
%000002 task perform_calculation_and_check(longint unsigned a, longint unsigned b);
%000002 	timeout_counter = 0;
%000002     forever begin
%000004 		if(timeout_counter > timeout_max) begin
%000000 			reset_timeout();
%000000 			return;
        		end
%000002         if(h_input_a_ack == 1'b1) begin
%000000 			break;
        		end
%000002         @(posedge clock);
            end
%000002     h_input_a = a;
%000002     h_input_a_stb = 1;
%000003     forever begin
%000005 		if(timeout_counter > timeout_max) begin
%000000 			reset_timeout();
%000000 			return;
        		end
%000003         if(h_input_a_ack == 1'b0) begin
%000000 			break;
        		end
%000003         @(posedge clock);
            end
        
%000002     h_input_a_stb = 0;
        
%000002     forever begin
%000004 		if(timeout_counter > timeout_max) begin
%000000 			reset_timeout();
%000000 			return;
        		end
%000002         if(h_input_b_ack == 1'b1) begin
%000000 			break;
        		end
%000002         @(posedge clock);
            end
%000002     h_input_b = b;
%000002     h_input_b_stb = 1;
%000002     forever begin
%000004 		if(timeout_counter > timeout_max) begin
%000000 			reset_timeout();
%000000 			return;
        		end
%000002 	    if(h_input_b_ack == 1'b0) begin
%000000 			break;
        		end
%000002         @(posedge clock);
            end
%000002     h_input_b_stb = 0;
        
~000023     forever begin
~000025 		if(timeout_counter > timeout_max) begin
%000000 			reset_timeout();
%000000 			return;
        		end
~000023 		if(h_output_z_stb == 1'b1) begin
%000000 			break;
        		end
 000023         @(posedge clock);
            end
        
%000002     res = h_output_z;
%000002     h_output_z_ack = 1;
%000002 	#1
%000002 	h_output_z_ack = 0;
%000002     etalon = c_etalon(a, b);
        
%000002     $display("%.2e (%x) * %.2e (%x) = %.2e (%x) vs %.2e (%x)\n",
%000002 	$bitstoreal(a), a,
%000002 	$bitstoreal(b), b,
%000002 	$bitstoreal(etalon), etalon,
%000002 	$bitstoreal(res), res);
        
        endtask
        
        endmodule
        
