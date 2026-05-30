module key_decoder (
    input  logic [1:0] scanned_row, // Índice de la fila activa (0 a 3) enviada por el escáner
    input  logic [3:0] col,         // Estado de las 4 columnas (leído desde los pines físicos)
    output logic [3:0] raw_key,     // Valor hexadecimal resultante de la tecla detectada
    output logic       fila_pres    // Bandera de detección de tecla presionada
);

    always_comb begin
        // CORREGIDO: El valor por defecto en reposo ya no es 0, es F (tecla libre)
        fila_pres = 1'b0;
        raw_key   = 4'hF; 
        
        case (scanned_row)
            // --- FILA 0 ---
            2'd0: if (col != 4'b0000) begin
                fila_pres = 1'b1;
                case (col)
                    4'b0001: raw_key = 4'h1; 
                    4'b0010: raw_key = 4'h2; 
                    4'b0100: raw_key = 4'h3; 
                    4'b1000: raw_key = 4'hA; 
                    default: fila_pres = 1'b0;
                endcase
            end

            // --- FILA 1 ---
            2'd1: if (col != 4'b0000) begin
                fila_pres = 1'b1;
                case (col)
                    4'b0001: raw_key = 4'h4; 
                    4'b0010: raw_key = 4'h5; 
                    4'b0100: raw_key = 4'h6; 
                    4'b1000: raw_key = 4'hB; 
                    default: fila_pres = 1'b0;
                endcase
            end

            // --- FILA 2 ---
            2'd2: if (col != 4'b0000) begin
                fila_pres = 1'b1;
                case (col)
                    4'b0001: raw_key = 4'h7; 
                    4'b0010: raw_key = 4'h8; 
                    4'b0100: raw_key = 4'h9; // Tecla 9
                    4'b1000: raw_key = 4'hC; 
                    default: fila_pres = 1'b0;
                endcase
            end

            // --- FILA 3 ---
            2'd3: if (col != 4'b0000) begin
                fila_pres = 1'b1;
                case (col)
                    4'b0001: raw_key = 4'hE; 
                    4'b0010: raw_key = 4'h0; // Tecla 0 (Ahora sí es única y destaca sobre el reposo)
                    4'b0100: raw_key = 4'hF; 
                    4'b1000: raw_key = 4'hD; 
                    default: fila_pres = 1'b0;
                endcase
            end
            
            default: fila_pres = 1'b0;
        endcase
    end
endmodule