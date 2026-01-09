`timescale 1ns/1ns
`include "double_multiplier.v"

import "DPI-C" function longint unsigned c_etalon (longint unsigned a, longint unsigned b);

module top();

reg clock;
reg reset;

reg[63:0] a, b = 0;
reg[63:0] res = 0;
reg[63:0] etalon = 0;


/*assign wire a_f = a;
assign wire b_f = b;
assign wire res_f = res;
assign wire etalon_f = etalon;*/

input clock;
input reset;

reg     [63:0] h_input_a;
reg     h_input_a_stb;
reg     h_input_a_ack;

reg     [63:0] h_input_b;
reg     h_input_b_stb;
reg     h_input_b_ack;

wire    [63:0] h_output_z;
wire     h_output_z_stb;
reg     h_output_z_ack;

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

initial begin
    reset = 1;
    clock = 0;
    #10
    reset = 0;
    #10
    if ($value$plusargs("arg0=%x", a) && $value$plusargs("arg1=%x", b)) begin
        perform_calculation_and_check(a, b);
    end
//    else if ($test$plusargs("from_file")) begin
//        int fd = $fopen(filename, "r");
//        if (fd == 0) begin
//            $fatal(1, "Cannot open file '%s'", filename);
//        end

//        while (!$feof(fd)) begin
//            void'($fgets(line, fd));
//            if (line.len() == 0) continue; // пропускаем пустые строки

//            // Разбиваем строку по пробелам/табуляциям
//            args = line.split({" ", "\t"});

//            // Преобразуем строки в числа
//            for (int i = 0; i < args.size(); i++) begin
//                void'($sscanf(args[i], "%d", arg_values[i]));
//            end

//            $display("File line: %s → values = %p", line, arg_values);

//            // Здесь вызываем функцию/блок для вычисления с arg_values
//            perform_calculation_and_check(a, b);
//        end
//    end
//    else if ($test$plusargs("random_mode")) begin

//    end
    $finish;
end

always
begin
    #1
    clock = ~clock;
end


task perform_calculation_and_check(longint unsigned a, longint unsigned b);

    h_input_a = a;
    h_input_a_stb = 1;
    forever begin
        if(h_input_a_ack == 1'b0) begin
			break;
		end
        @(posedge clock);
    end
    h_input_a_stb = 0;
    h_input_b = b;
    h_input_b_stb = 1;
	#1
    forever begin
	    if(h_input_b_ack == 1'b0) begin
			break;
		end
        @(posedge clock);
    end
    h_input_b_stb = 0;
    forever begin
		if(h_output_z_stb == 1'b1) begin
			break;
		end
        @(posedge clock);
    end

    res = h_output_z;
    h_output_z_ack = 1;
	#1
	h_output_z_ack = 0;
    etalon = c_etalon(a, b);

    $display("%.2e (%x) * %.2e (%x) = %.2e (%x) vs %.2e (%x)\n",
	$bitstoreal(a), a,
	$bitstoreal(b), b,
	$bitstoreal(etalon), etalon,
	$bitstoreal(res), res);

endtask

endmodule
