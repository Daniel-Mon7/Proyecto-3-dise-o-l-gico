module div_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  key_in,
    input  logic        valid,
    output logic [15:0] num_out
);

    // Declaración de interconexiones 
    logic [5:0] dividendo;
    logic [3:0] divisor;
    logic       start_calc;
    logic [5:0] cociente;
    logic [3:0] residuo;
    logic       done;

    logic [7:0] cociente_bcd;
    logic [7:0] residuo_bcd;
    logic [7:0] divisor_bcd;

    logic [15:0] num_reg_intermitente;
    logic [3:0] wire_decenas;
    logic [3:0] wire_unidades;

    // Instancia del Módulo de Entrada de Teclado
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

    // Instancia del Módulo Procesador de División Matemático
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

    // Conversión BCD directa en línea para las Salidas Finales
    always_comb begin
        // Convertidor BCD para el Cociente
        if (cociente >= 6'd10)
            cociente_bcd = {4'd1, cociente - 6'd10};
        else
            cociente_bcd = {4'd0, cociente[3:0]};

        // Convertidor BCD para el Residuo
        if (residuo >= 4'd10)
            residuo_bcd = {4'd1, residuo - 4'd10};
        else
            residuo_bcd = {4'd0, residuo};

        // Convertidor BCD para el Divisor
        if (divisor >= 4'd10)
            divisor_bcd = {4'd1, divisor - 4'd10};
        else
            divisor_bcd = {4'd0, divisor};
    end

    // Instancia del Selector / Multiplexor de Pantalla
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