//      // verilator_coverage annotation
        //IEEE Floating Point Multiplier (Double Precision)
        //Copyright (C) Jonathan P Dawson 2014
        //2014-01-10
        module double_multiplier(
                input_a,
                input_b,
                input_a_stb,
                input_b_stb,
                output_z_ack,
                clk,
                rst,
                output_z,
                output_z_stb,
                input_a_ack,
                input_b_ack);
        
 055070   input     clk;
%000001   input     rst;
        
 000265   input     [63:0] input_a;
 001000   input     input_a_stb;
 001000   output    input_a_ack;
        
 000273   input     [63:0] input_b;
 001000   input     input_b_stb;
 001000   output    input_b_ack;
        
 000268   output    [63:0] output_z;
 001000   output    output_z_stb;
 001000   input     output_z_ack;
        
 001000   reg       s_output_z_stb;
 000268   reg       [63:0] s_output_z;
 001000   reg       s_input_a_ack;
 001000   reg       s_input_b_ack;
        
 006000   reg       [3:0] state;
          parameter get_a         = 4'd0,
                    get_b         = 4'd1,
                    unpack        = 4'd2,
                    special_cases = 4'd3,
                    normalise_a   = 4'd4,
                    normalise_b   = 4'd5,
                    multiply_0    = 4'd6,
                    multiply_1    = 4'd7,
                    normalise_1   = 4'd8,
                    normalise_2   = 4'd9,
                    round         = 4'd10,
                    pack          = 4'd11,
                    put_z         = 4'd12;
        
 000273   reg       [63:0] a, b, z;
 002138   reg       [52:0] a_m, b_m, z_m;й
 019772   reg       [12:0] a_e, b_e, z_e;
 000258   reg       a_s, b_s, z_s;
~001996   reg       guard, round_bit, sticky;
 001018   reg       [105:0] product;
        
 055070   always @(posedge clk)
 055070   begin
             //$display("State is %d", state);
        
 055070     case(state)
        
 002009       get_a:
 002009       begin
 002009         s_input_a_ack <= 1;
 054070         if (s_input_a_ack && input_a_stb) begin
 001000           a <= input_a;
 001000           s_input_a_ack <= 0;
 001000           state <= get_b;
                end
              end
        
 002000       get_b:
 002000       begin
 002000         s_input_b_ack <= 1;
 054070         if (s_input_b_ack && input_b_stb) begin
 001000           b <= input_b;
 001000           s_input_b_ack <= 0;
 001000           state <= unpack;
                end
              end
        
 001000       unpack:
 001000       begin
 001000         a_m <= a[51 : 0];
 001000         b_m <= b[51 : 0];
 001000         a_e <= a[62 : 52] - 1023;
 001000         b_e <= b[62 : 52] - 1023;
 001000         a_s <= a[63];
 001000         b_s <= b[63];
 001000         state <= special_cases;
              end
        
 001000       special_cases:
 001000       begin
                //if a is NaN or b is NaN return NaN
~055070         if ((a_e == 1024 && a_m != 0) || (b_e == 1024 && b_m != 0)) begin
                // Шанс этой ветви = 2*(1/2**11*(2**52-1)/2**52) ~ 0.1% 
                // a_e = a[62:52] -> 11 bit, условие сработает, если a_e - конкретное, т.е. 1 из 2**11
                // a_m = a[51:0] -> 52 bit, условие сработает, если a_m - не одно из всех возможных, т.е. 2**52 - 1 из 2**52
%000000           z[63] <= 1;
%000000           z[62:52] <= 2047;
%000000           z[51] <= 1;
%000000           z[50:0] <= 0;
%000000           state <= put_z;
                //if a is inf return inf
%000000         end else if (a_e == 1024) begin
                  // Шанс этой ветви = 1/2**11 * (1/2**52 * (2**11-1)/2**11 + 1/2**52 - (2**11-1)/2**11/2**52) ~ 1.08e-19
				  // Шанс несоблюдения предыдущих ветвей при условии соблюдения условия этой (a_m == 0) && (b_e != 1024 || b_m == 0): (1/2**52 * (2**11-1)/2**11 + 1/2**52 - (2**11-1)/2**11/2**52) ~ 2.22e-16
				  // a_m == 0 -> 1/2**52
				  // (b_e != 1024 || b_m == 0) -> (2**11-1)/2**11 + 1/2**52 - (2**11-1)/2**11/2**52
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 2047;
%000000           z[51:0] <= 0;
%000000           state <= put_z;
                  //if b is zero return NaN
%000000           if (($signed(b_e) == -1023) && (b_m == 0)) begin
                  // Шанс этой ветви (относительный) = 1/2**63 ~ 1e-19 
				  // Шанс этой ветви (абсолютный) = 1/2**63 * Шанс предыдущей (верхней) = 1/2**63 * 1/2**11 * (1/2**52 * (2**11-1)/2**11 + 1/2**52 - (2**11-1)/2**11/2**52) = 1.17e-38
%000000             z[63] <= 1;
%000000             z[62:52] <= 2047;
%000000             z[51] <= 1;
%000000             z[50:0] <= 0;
%000000             state <= put_z;
                  end
                //if b is inf return inf
%000000         end else if (b_e == 1024) begin
                  // Шанс этой ветви = 1/2**11 * (1/2**52 * (2**11-1)/2**11) ~ 1.08e-19
				  // Шанс несоблюдения предыдущих ветвей при условии соблюдения условия этой (b_m == 0) && (a_e != 1024): (1/2**52 * (2**11-1)/2**11) ~ 2.22e-16
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 2047;
%000000           z[51:0] <= 0;
                  //if b is zero return NaN
%000000           if (($signed(a_e) == -1023) && (a_m == 0)) begin
				  // К моменту этой веткви известно, что a_e != 1024
                  // Шанс этой ветви (относительный) = 1/2**63/(2**11-1) ~ 5.26e-23 
				  // Шанс этой ветви (абсолютный) = 1/2**63/(2**11-1) * Шанс предыдущей (верхней) = 1/2**63/(2**11-1) * 1/2**11 * (1/2**52 * (2**11-1)/2**11) = 5.73e-42
%000000             z[63] <= 1;
%000000             z[62:52] <= 2047;
%000000             z[51] <= 1;
%000000             z[50:0] <= 0;
%000000             state <= put_z;
                  end
%000000           state <= put_z;
                //if a is zero return zero
~001000         end else if (($signed(a_e) == -1023) && (a_m == 0)) begin
				  // К моменту этой веткви известно, что a_e != 1024 && b_e != 1024
                  // Шанс этой ветви = 1/2**63/(2**11-1) ~ 5.29e-23 
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 0;
%000000           z[51:0] <= 0;
%000000           state <= put_z;
                //if b is zero return zero
~001000         end else if (($signed(b_e) == -1023) && (b_m == 0)) begin
				  // К моменту этой веткви известно, что a_e != 1024 && b_e != 1024
                  // Шанс этой ветви = 1/2**63/(2**11-1) ~ 5.29e-23 
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 0;
%000000           z[51:0] <= 0;
%000000           state <= put_z;
 001000         end else begin
                   // Шанс этой ветви = (1-шанс предудущей_1)*(1-шанс предудущей_2)*(1-шанс предудущей_3)*(1-шанс предудущей_4)*(1-шанс предудущей_5) = (1-2*(1/2**11*(2**52-1)/2**52))*(1-1/2**63/(2**11-1))*(1-1/2**63/(2**11-1))*(1-1/2**11 * (1/2**52 * (2**11-1)/2**11))*(1-1/2**11 * (1/2**52 * (2**11-1)/2**11 + 1/2**52 - (2**11-1)/2**11/2**52))
				   // ~ 0.999 
                  //Denormalised Number
~001000           if ($signed(a_e) == -1023) begin
 				    // К моменту этой веткви известно, что a_e != 1024 && b_e != 1024 && (($signed(b_e) != -1023) || (b_m != 0)) && (($signed(a_e) != -1023) || (a_m != 0))
					// Выполнение этой ветви при условии невыполнения предыдущих возможно только если (a_m != 0)
                    // Шанс этой ветви (относительный) = (2**63-1)/2**63/(2**11-1) ~ 0.05% 
					// Шанс этой ветви (абсолютный) = 0.999 * Шанс этой ветви (относительный) ~ 0.05% 

%000000             a_e <= -1022;
 001000           end else begin
 001000             a_m[52] <= 1;
                  end
                  //Denormalised Number
~000999           if ($signed(b_e) == -1023) begin
 				    // К моменту этой веткви известно, что a_e != 1024 && b_e != 1024 && (($signed(b_e) != -1023) || (b_m != 0)) && ($signed(a_e) != -1023) && (a_m != 0)
					// Выполнение этой ветви при условии невыполнения предыдущих возможно только если (b_m != 0)
                    // Шанс этой ветви (относительный) = (2**63-1)/2**63/(2**11-1) ~ 0.05% 
					// Шанс этой ветви (абсолютный) = 0.999 * Шанс этой ветви (относительный) ~ 0.05% 
%000001             b_e <= -1022;
 000999           end else begin
 000999             b_m[52] <= 1;
                  end
 001000           state <= normalise_a;
                end
              end
        
 001000       normalise_a:
 001000       begin
~001000         if (a_m[52]) begin
 001000           state <= normalise_b;
%000000         end else begin
                  // Шанс срабатывания этой ветви хотя бы один раз за цикл = 0.999*(2**63-1)/2**63/(2**11-1)~ 0.05% 
				  // a_m [52] != 0 только при выполнении ветви "if ($signed(a_e) == -1023) begin"
                  // *Но если сработает один раз - сработает ещё несколько, пока сдвигом не заполнит a_m[52] единицой
                  // ** Мат. Ожидание колическва срабатываний ~ 2
                  // ** int res = 0; for(int i = 1; i < 51; i++){ res += i*2**(-i); } 
                  // Запись в a_m[52] происходит только при определении денормализованности числа
%000000           a_m <= a_m << 1;
%000000           a_e <= a_e - 1;
                end
              end
        
 001002       normalise_b:
 001002       begin
~001000         if (b_m[52]) begin
 001000           state <= multiply_0;
%000002         end else begin
                  // Шанс срабатывания этой ветви хотя бы один раз за цикл = 0.999*(2**63-1)/2**63/(2**11-1) ~ 0.05% 
%000002           b_m <= b_m << 1;
%000002           b_e <= b_e - 1;
                end
              end
        
 001000       multiply_0:
 001000       begin
 015995         z_s <= a_s ^ b_s;
 001000         z_e <= a_e + b_e + 1;
 001000         product <= a_m * b_m;
 001000         state <= multiply_1;
              end
        
 001000       multiply_1:
 001000       begin
 001000         z_m <= product[105:53];
 001000         guard <= product[52];
 001000         round_bit <= product[51];
 001000         sticky <= (product[50:0] != 0);
 001000         state <= normalise_1;
              end
        
 001399       normalise_1:
 001399       begin
 001000         if (z_m[52] == 0) begin
 000399           z_e <= z_e - 1;
 000399           z_m <= z_m << 1;
 000399           z_m[0] <= guard;
 000399           guard <= round_bit;
 000399           round_bit <= 0;
 001000         end else begin
 001000           state <= normalise_2;
                end
              end
        
 039660       normalise_2:
 039660       begin
 038660         if ($signed(z_e) < -1022) begin
 038660           z_e <= z_e + 1;
 038660           z_m <= z_m >> 1;
 038660           guard <= z_m[0];
 038660           round_bit <= guard;
~038660           sticky <= sticky | round_bit;
 001000         end else begin
 001000           state <= round;
                end
              end
        
 001000       round:
 001000       begin
 044574         if (guard && (round_bit | sticky | z_m[0])) begin
 000437           z_m <= z_m + 1;
~000437           if (z_m == 53'h1fffffffffffff) begin
%000000             z_e <=z_e + 1;
                  end
                end
 001000         state <= pack;
              end
        
 001000       pack:
 001000       begin
 001000         z[51 : 0] <= z_m[51:0];
 001000         z[62 : 52] <= z_e[11:0] + 1023;
 001000         z[63] <= z_s;
 053362         if ($signed(z_e) == -1022 && z_m[52] == 0) begin
 000122           z[62 : 52] <= 0;
                end
                //if overflow occurs, return inf
 000873         if ($signed(z_e) > 1023) begin
 000127           z[51 : 0] <= 0;
 000127           z[62 : 52] <= 2047;
 000127           z[63] <= z_s;
                end
 001000         state <= put_z;
              end
        
 002000       put_z:
 002000       begin
 002000         s_output_z_stb <= 1;
 002000         s_output_z <= z;
 054070         if (s_output_z_stb && output_z_ack) begin
 001000           s_output_z_stb <= 0;
 001000           state <= get_a;
                end
              end
        
            endcase
        
~055065     if (rst == 1) begin
%000005       state <= get_a;
%000005       s_input_a_ack <= 0;
%000005       s_input_b_ack <= 0;
%000005       s_output_z_stb <= 0;
            end
        
          end
          assign input_a_ack = s_input_a_ack;
          assign input_b_ack = s_input_b_ack;
          assign output_z_stb = s_output_z_stb;
          assign output_z = s_output_z;
        
        endmodule
        
