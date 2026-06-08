module teclado_completo (
    input  logic clk,
    input  logic rst,
    output logic [3:0] row,
    input  logic [3:0] col,
    output logic [3:0] key_out,
    output logic valid
);

    // Señales de comunicación interna entre sub-módulos
    logic [1:0] scanned_row; // Indica qué fila está activa (0-3)
    logic [3:0] raw_key;     // Valor decodificado pero ruidoso
    logic       fila_pres; // Flag de presión ruidoso
    logic       is_idle;     // Feedback del debouncer al escáner

    // Genera el barrido constante de las filas
    // Incrementamos el parámetro para suavizar el barrido físico
    key_scanner #(
        .SCAN_DIV(30000) 
    ) scanner_inst (
        .clk(clk),
        .rst(rst),
        .scan_enable(is_idle), 
        .scanned_row(scanned_row),
        .row(row)
    );

    // Traduce la posición (fila, columna) a un valor Hexadecimal
    key_decoder decoder_inst (
        .scanned_row(scanned_row),
        .col(col),
        .raw_key(raw_key),
        .fila_pres(fila_pres)
    );

    // Elimina el ruido eléctrico y genera el pulso de validación único
    key_debouncer debouncer_inst (
        .clk(clk),
        .rst(rst),
        .fila_pres(fila_pres),
        .raw_key(raw_key),
        .key_out(key_out),
        .valid(valid),
        .is_idle(is_idle)
    );

endmodule