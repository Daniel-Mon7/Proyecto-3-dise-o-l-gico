module div_top (

    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  key_in,
    input  logic        valid,
    output logic [15:0] num_out

);

    logic [5:0]  dividendo;
    logic [3:0]  divisor;

    logic        start_calc;

    logic [5:0]  cociente;
    logic [3:0]  residuo;

    logic        done;

    logic [7:0]  cociente_bcd;
    logic [7:0]  residuo_bcd;
    logic [7:0]  divisor_bcd;

    logic [15:0] num_reg_intermitente;

    logic [3:0]  wire_decenas;
    logic [3:0]  wire_unidades;

    input_div u_input_div (

        .clk(clk),
        .rst(rst),
        .key_in(key_in),
        .valid(valid),

        .dividendo(dividendo),
        .divisor(divisor),

        .start_calc(start_calc),

        .num_registro(num_reg_intermitente),

        .decenas(wire_decenas),
        .unidades(wire_unidades)

    );

    divisor u_divisor (

        .clk(clk),
        .rst(rst),
        .start(start_calc),

        .dividendo(dividendo),
        .divisor(divisor),

        .cociente(cociente),
        .residuo(residuo),

        .done(done)

    );

    // Conversión del cociente
    bin_a_bcd u_bin_a_bcd_cociente (

        .bin(cociente),
        .bcd(cociente_bcd)

    );

    // Conversión del residuo
    bin_a_bcd u_bin_a_bcd_residuo (

        .bin({2'b00, residuo}),
        .bcd(residuo_bcd)

    );

    // Conversión del divisor
    bin_a_bcd u_bin_a_bcd_divisor (

        .bin({2'b00, divisor}),
        .bcd(divisor_bcd)

    );

    selector_div u_selector_div (

        .clk(clk),
        .rst(rst),

        .valid(valid),
        .key_in(key_in),

        .done(done),

        .decenas(wire_decenas),
        .unidades(wire_unidades),

        .divisor_bcd(divisor_bcd),

        .cociente_bcd(cociente_bcd),
        .residuo_bcd(residuo_bcd),

        .num_registro(num_reg_intermitente),

        .num_out(num_out)

    );

endmodule