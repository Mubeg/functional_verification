`timescale 1ns/1ns
`include "double_multiplier.v"

import "DPI-C" function longint unsigned c_etalon (longint unsigned a, longint unsigned b);

module top();

reg clock;
reg reset;

longint unsigned a, b = 0;
longint unsigned res = 0;
longint unsigned etalon = 0;

input clock;
input reset;

reg     [63:0] input_a;
reg     input_a_stb;
reg     input_a_ack;

reg     [63:0] input_b;
reg     input_b_stb;
reg     input_b_ack;

wire    [63:0] output_z;
wire     output_z_stb;
reg     output_z_ack;

double_multiplier
dut(
    .input_a(input_a),
    .input_b(input_b),
    .input_a_stb(input_a_stb),
    .input_b_stb(input_b_stb),
    .output_z_ack(output_z_ack),
    .clk(clock),
    .rst(reset),
    .output_z(output_z),
    .output_z_stb(output_z_stb),
    .input_a_ack(input_a_ack),
    .input_b_ack(input_b_ack)

);

initial begin
    reset = 1;
    clock = 0;
    #10
    reset = 0;
    #10
    if ($value$plusargs("arg0=%d", a) && $value$plusargs("arg1=%d", b)) begin
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

    input_a = a;
    input_a_stb = 1;
    forever begin
        wait (input_a_ack == 1'b0);
        @(posedge clock);
    end
    input_a_stb = 0;
    input_b = b;
    input_b_stb = 1;
    forever begin
        wait (input_b_ack == 1'b0);
        @(posedge clock);
    end
    input_b_stb = 0;

    forever begin
        wait (output_z_stb == 1'b1);
        @(posedge clock);
    end
    res = output_z;
    output_z_ack = 1;

    etalon = c_etalon(a, b);

    $display("%.2e (%x) * %.2e (%x) = %.2e (%x) vs %.2e (%x)\n", a, a, b, b, etalon, etalon, res, res);

endtask

endmodule
