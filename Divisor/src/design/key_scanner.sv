module key_scanner #(
    parameter SCAN_DIV = 15000 // Valor para ajustar la velocidad de escaneo
)(
    input  logic       clk,         // Reloj maestro del sistema
    input  logic       rst,         // Reset asíncrono
    input  logic       scan_enable, // Señal de habilitación para permitir el avance de fila
    output logic [1:0] scanned_row, // Índice de la fila actual para uso interno/decodificación
    output logic [3:0] row          // Salida física hacia los pines de las filas del teclado
);

    logic [15:0] scan_cnt; 
    logic scan_tick;

    // Lógica para generar el pulso de temporización de escaneo
    assign scan_tick = (scan_cnt >= SCAN_DIV); 

    always_ff @(posedge clk or posedge rst) begin 
        if (rst)
            scan_cnt <= 0;
        else if (scan_tick)
            scan_cnt <= 0; // Reinicio al alcanzar el límite
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // Contador de filas: Avanza a la siguiente fila solo si hay tick y permiso
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            scanned_row <= 2'd0;
        end else if (scan_tick && scan_enable) begin
            scanned_row <= scanned_row + 1'b1;
        end
    end

    // Decodificador de 2 a 4 bits para la salida física de filas (Lógica One-Hot)
    always_comb begin
        case (scanned_row)
            2'd0: row = 4'b0001; // Activa Fila 0
            2'd1: row = 4'b0010; // Activa Fila 1
            2'd2: row = 4'b0100; // Activa Fila 2
            2'd3: row = 4'b1000; // Activa Fila 3
            default: row = 4'b0000;
        endcase
    end
endmodule