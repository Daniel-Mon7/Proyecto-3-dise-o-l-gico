module bin_a_bcd (
    input  logic [5:0] bin,   // Entrada binaria de 6 bits (máximo decimal: 63)
    output logic [7:0] bcd    // Salida BCD de 8 bits {decenas[3:0], unidades[3:0]}
);

    logic [3:0] decenas;
    logic [3:0] unidades;

    // Bloque combinacional que evalúa el rango del valor de entrada
    always_comb begin
        if (bin >= 60) begin
            decenas  = 4'd6;         // Si es mayor o igual a 60, las decenas son 6
            unidades = bin - 60;     // El resto va a las unidades

        end else if (bin >= 50) begin
            decenas  = 4'd5;         // Rango 50-59
            unidades = bin - 50;

        end else if (bin >= 40) begin
            decenas  = 4'd4;         // Rango 40-49
            unidades = bin - 40;

        end else if (bin >= 30) begin
            decenas  = 4'd3;         // Rango 30-39
            unidades = bin - 30;

        end else if (bin >= 20) begin
            decenas  = 4'd2;         // Rango 20-29
            unidades = bin - 20;

        end else if (bin >= 10) begin
            decenas  = 4'd1;         // Rango 10-19
            unidades = bin - 10;

        end else begin
            decenas  = 4'd0;         // Menor a 10, decenas en 0
            unidades = bin;          // Las unidades son el mismo número de entrada
        end

        // Concatena los dos dígitos de 4 bits para formar la salida final de 8 bits
        bcd = {decenas, unidades};
    end

endmodule