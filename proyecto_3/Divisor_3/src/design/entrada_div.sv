module input_div (
    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  key_in,
    input  logic        valid,
    
    output logic [5:0]  dividendo,
    output logic [3:0]  divisor,
    output logic        start_calc,
    output logic [15:0] num_registro,
    output logic [3:0]  decenas,      
    output logic [3:0]  unidades       
);

    typedef enum logic [1:0] {
        ESPERA_DIVIDENDO,
        ESPERA_DIVISOR
    } state_t;
    
    state_t state;
    
    logic       tengo_decenas_num;
    logic       tengo_decenas_div; 
    logic [3:0] dec_div;           
    
    logic       valid_prev;
    logic       valid_pulse;
    
    
    // Detector de pulso para evitar lecturas múltiples
    always_ff @(posedge clk or posedge rst) begin
        if (rst) valid_prev <= 0;
        else valid_prev <= valid;
    end
    assign valid_pulse = valid & ~valid_prev;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state             <= ESPERA_DIVIDENDO;
            dividendo         <= 0;
            divisor           <= 0;
            decenas           <= 0;
            unidades          <= 0;
            tengo_decenas_num <= 0;
            tengo_decenas_div <= 0;
            dec_div           <= 0;
            start_calc        <= 0;
            num_registro      <= 16'h0000;
        end else begin
            start_calc <= 0;
            
            case (state)
                ESPERA_DIVIDENDO: begin
                    if (valid_pulse && key_in <= 4'h9) begin
                        if (!tengo_decenas_num) begin
                            decenas           <= key_in;
                            unidades          <= 4'h0; 
                            tengo_decenas_num <= 1;
                            dividendo         <= {2'b00, key_in};
                            num_registro      <= {12'b0, key_in}; 
                        end else begin
                            unidades          <= key_in;
                            tengo_decenas_num <= 0;
                            dividendo         <= (decenas * 10) + key_in;
                            num_registro      <= {8'b0, decenas, key_in}; 
                        end
                    end
                    
                    if (valid_pulse && key_in == 4'hA) begin // Tecla A para confirmar dividendo
                        if (tengo_decenas_num) begin
                            dividendo         <= {2'b00, decenas};
                            num_registro      <= {12'b0, decenas};
                            tengo_decenas_num <= 0;
                        end
                        state <= ESPERA_DIVISOR;
                        tengo_decenas_div <= 0;
                    end
                end
                
                ESPERA_DIVISOR: begin
                    if (valid_pulse && key_in <= 4'h9) begin
                        if (!tengo_decenas_div) begin
                            dec_div           <= key_in;
                            tengo_decenas_div <= 1;
                            divisor           <= key_in; 
                            num_registro      <= {12'b0, key_in}; 
                        end else begin
                            tengo_decenas_div <= 0;
                            // Lógica de tope: máximo 15 (0F)
                            if (((dec_div * 10) + key_in) > 15) begin
                                divisor      <= 4'd15;
                                num_registro <= {8'b0, 4'h1, 4'h5}; 
                            end else begin
                                divisor      <= ((dec_div * 10) + key_in);
                                num_registro <= {8'b0, dec_div, key_in};
                            end
                        end
                    end
                    
                    if (valid_pulse && key_in == 4'hB) begin // Tecla B para iniciar división
                        if (tengo_decenas_div) begin
                            divisor           <= dec_div;
                            tengo_decenas_div <= 0;
                        end
                        num_registro <= 16'h0000; // <-- limpiar el registro temporal
                        start_calc  <= 1;
                        state       <= ESPERA_DIVIDENDO;
                    end
                end
            endcase
        end
    end
endmodule