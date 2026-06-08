module display (
    input  logic clk,           // Pin de reloj
    input  logic rst,           // Pin de reset
    input  logic [15:0] num_in, // Número completo a mostrar (ej. 16'hABCD)
    output logic [3:0]  enc_an, // Salida física a los ánodos/cátodos comunes
    output logic [6:0]  enc_seg // Salida física a los 7 segmentos del bus
);

    // Señales internas para interconectar los submódulos
    logic scan_tick;       // Cable que lleva el pulso del divisor
    logic [1:0] sel;       // Cable que indica el dígito activo
    logic [3:0] current_val; // Cable con el nibble que se va a decodificar

    // --- INSTANCIA 1: Generación de tiempo ---
    clk_divider timer (
        .clk(clk),
        .rst(rst),
        .tick(scan_tick)
    );

    // --- INSTANCIA 2: Control de selección de display ---
    anode_control controller (
        .clk(clk),
        .rst(rst),
        .tick(scan_tick),
        .sel(sel),
        .anode(enc_an)
    );

    // --- LÓGICA DE MULTIPLEXACIÓN ---
    // Dependiendo del valor de 'sel', extraemos 4 bits específicos de la entrada.
    // Esto asegura que el decodificador reciba el número correcto para el dígito activo.
    always_comb begin
        case (sel)
            2'd0: current_val = num_in[3:0];   // Dígito 0: bits menos significativos
            2'd1: current_val = num_in[7:4];   // Dígito 1
            2'd2: current_val = num_in[11:8];  // Dígito 2
            2'd3: current_val = num_in[15:12]; // Dígito 3: bits más significativos
            default: current_val = 4'h0;
        endcase
    end

    // --- INSTANCIA 3: Conversión a 7 segmentos ---
    hex_to_7seg decoder (
        .hex(current_val),
        .seg(enc_seg)
    );

endmodule