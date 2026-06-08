module hex_to_7seg (
    input  logic [3:0] hex, // Valor de 4 bits (0-F) a decodificar
    output logic [6:0] seg  // Bus de salida para los segmentos [g f e d c b a]
);
    // Lógica combinacional pura: traduce la entrada al patrón de ledes.
    always_comb begin
        unique case (hex)
            // Lógica Inversa: '0' enciende el segmento, '1' lo apaga
            // Formato: g f e d c b a
            4'h0: seg = 7'b1000000; // Muestra '0'
            4'h1: seg = 7'b1111001; // Muestra '1'
            4'h2: seg = 7'b0100100; // Muestra '2'
            4'h3: seg = 7'b0110000; // Muestra '3'
            4'h4: seg = 7'b0011001; // Muestra '4'
            4'h5: seg = 7'b0010010; // Muestra '5'
            4'h6: seg = 7'b0000010; // Muestra '6'
            4'h7: seg = 7'b1111000; // Muestra '7'
            4'h8: seg = 7'b0000000; // Muestra '8' (todos encendidos)
            4'h9: seg = 7'b0010000; // Muestra '9'
            4'hA: seg = 7'b0001000; // Muestra 'A'
            4'hB: seg = 7'b0000011; // Muestra 'b'
            4'hC: seg = 7'b1000110; // Muestra 'C'
            4'hD: seg = 7'b0100001; // Muestra 'd'
            4'hE: seg = 7'b0000110; // Muestra 'E'
            4'hF: seg = 7'b0001110; // Muestra 'F'
            default: seg = 7'b1111111; // Apagado total por seguridad
        endcase
    end
endmodule