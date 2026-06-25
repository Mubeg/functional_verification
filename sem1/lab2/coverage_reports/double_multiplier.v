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
        
 000042   input     clk;
%000001   input     rst;
        
%000001   input     [63:0] input_a;
%000002   input     input_a_stb;
%000002   output    input_a_ack;
        
%000001   input     [63:0] input_b;
%000002   input     input_b_stb;
%000002   output    input_b_ack;
        
%000001   output    [63:0] output_z;
%000002   output    output_z_stb;
%000002   input     output_z_ack;
        
%000002   reg       s_output_z_stb;
%000001   reg       [63:0] s_output_z;
%000002   reg       s_input_a_ack;
%000002   reg       s_input_b_ack;
        
~000012   reg       [3:0] state;
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
        
%000001   reg       [63:0] a, b, z;
%000002   reg       [52:0] a_m, b_m, z_m;
%000002   reg       [12:0] a_e, b_e, z_e;
%000001   reg       a_s, b_s, z_s;
%000001   reg       guard, round_bit, sticky;
%000004   reg       [105:0] product;
        
 000042   always @(posedge clk)
 000042   begin
             //$display("State is %d", state);
        
 000042     case(state)
        
 000013       get_a:
 000013       begin
 000013         s_input_a_ack <= 1;
~000040         if (s_input_a_ack && input_a_stb) begin
%000002           a <= input_a;
%000002           s_input_a_ack <= 0;
%000002           state <= get_b;
                end
              end
        
%000004       get_b:
%000004       begin
%000004         s_input_b_ack <= 1;
~000040         if (s_input_b_ack && input_b_stb) begin
%000002           b <= input_b;
%000002           s_input_b_ack <= 0;
%000002           state <= unpack;
                end
              end
        
%000002       unpack:
%000002       begin
%000002         a_m <= a[51 : 0];
%000002         b_m <= b[51 : 0];
%000002         a_e <= a[62 : 52] - 1023;
%000002         b_e <= b[62 : 52] - 1023;
%000002         a_s <= a[63];
%000002         b_s <= b[63];
%000002         state <= special_cases;
              end
        
%000002       special_cases:
%000002       begin
                //if a is NaN or b is NaN return NaN
~000042         if ((a_e == 1024 && a_m != 0) || (b_e == 1024 && b_m != 0)) begin
%000000           z[63] <= 1;
%000000           z[62:52] <= 2047;
%000000           z[51] <= 1;
%000000           z[50:0] <= 0;
%000000           state <= put_z;
                //if a is inf return inf
%000000         end else if (a_e == 1024) begin
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 2047;
%000000           z[51:0] <= 0;
%000000           state <= put_z;
                  //if b is zero return NaN
%000000           if (($signed(b_e) == -1023) && (b_m == 0)) begin
%000000             z[63] <= 1;
%000000             z[62:52] <= 2047;
%000000             z[51] <= 1;
%000000             z[50:0] <= 0;
%000000             state <= put_z;
                  end
                //if b is inf return inf
%000000         end else if (b_e == 1024) begin
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 2047;
%000000           z[51:0] <= 0;
                  //if b is zero return NaN
%000000           if (($signed(a_e) == -1023) && (a_m == 0)) begin
%000000             z[63] <= 1;
%000000             z[62:52] <= 2047;
%000000             z[51] <= 1;
%000000             z[50:0] <= 0;
%000000             state <= put_z;
                  end
%000000           state <= put_z;
                //if a is zero return zero
%000002         end else if (($signed(a_e) == -1023) && (a_m == 0)) begin
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 0;
%000000           z[51:0] <= 0;
%000000           state <= put_z;
                //if b is zero return zero
%000002         end else if (($signed(b_e) == -1023) && (b_m == 0)) begin
%000000           z[63] <= a_s ^ b_s;
%000000           z[62:52] <= 0;
%000000           z[51:0] <= 0;
%000000           state <= put_z;
%000002         end else begin
                  //Denormalised Number
%000002           if ($signed(a_e) == -1023) begin
%000000             a_e <= -1022;
%000002           end else begin
%000002             a_m[52] <= 1;
                  end
                  //Denormalised Number
%000002           if ($signed(b_e) == -1023) begin
%000000             b_e <= -1022;
%000002           end else begin
%000002             b_m[52] <= 1;
                  end
%000002           state <= normalise_a;
                end
              end
        
%000002       normalise_a:
%000002       begin
%000002         if (a_m[52]) begin
%000002           state <= normalise_b;
%000000         end else begin
%000000           a_m <= a_m << 1;
%000000           a_e <= a_e - 1;
                end
              end
        
%000002       normalise_b:
%000002       begin
%000002         if (b_m[52]) begin
%000002           state <= multiply_0;
%000000         end else begin
%000000           b_m <= b_m << 1;
%000000           b_e <= b_e - 1;
                end
              end
        
%000002       multiply_0:
%000002       begin
~000017         z_s <= a_s ^ b_s;
%000002         z_e <= a_e + b_e + 1;
%000002         product <= a_m * b_m;
%000002         state <= multiply_1;
              end
        
%000002       multiply_1:
%000002       begin
%000002         z_m <= product[105:53];
%000002         guard <= product[52];
%000002         round_bit <= product[51];
%000002         sticky <= (product[50:0] != 0);
%000002         state <= normalise_1;
              end
        
%000003       normalise_1:
%000003       begin
%000002         if (z_m[52] == 0) begin
%000001           z_e <= z_e - 1;
%000001           z_m <= z_m << 1;
%000001           z_m[0] <= guard;
%000001           guard <= round_bit;
%000001           round_bit <= 0;
%000002         end else begin
%000002           state <= normalise_2;
                end
              end
        
%000002       normalise_2:
%000002       begin
%000002         if ($signed(z_e) < -1022) begin
%000000           z_e <= z_e + 1;
%000000           z_m <= z_m >> 1;
%000000           guard <= z_m[0];
%000000           round_bit <= guard;
%000000           sticky <= sticky | round_bit;
%000002         end else begin
%000002           state <= round;
                end
              end
        
%000002       round:
%000002       begin
~000041         if (guard && (round_bit | sticky | z_m[0])) begin
%000000           z_m <= z_m + 1;
%000000           if (z_m == 53'h1fffffffffffff) begin
%000000             z_e <=z_e + 1;
                  end
                end
%000002         state <= pack;
              end
        
%000002       pack:
%000002       begin
%000002         z[51 : 0] <= z_m[51:0];
%000002         z[62 : 52] <= z_e[11:0] + 1023;
%000002         z[63] <= z_s;
~000042         if ($signed(z_e) == -1022 && z_m[52] == 0) begin
%000000           z[62 : 52] <= 0;
                end
                //if overflow occurs, return inf
%000002         if ($signed(z_e) > 1023) begin
%000000           z[51 : 0] <= 0;
%000000           z[62 : 52] <= 2047;
%000000           z[63] <= z_s;
                end
%000002         state <= put_z;
              end
        
%000004       put_z:
%000004       begin
%000004         s_output_z_stb <= 1;
%000004         s_output_z <= z;
~000040         if (s_output_z_stb && output_z_ack) begin
%000002           s_output_z_stb <= 0;
%000002           state <= get_a;
                end
              end
        
            endcase
        
~000037     if (rst == 1) begin
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
        
