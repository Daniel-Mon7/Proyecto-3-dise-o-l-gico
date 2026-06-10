module input_div (
    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  key_in,       // Tecla presionada (0-9, A, B, etc.)
    input  logic        valid,        // Señal de dato válido del teclado
    
    output logic [5:0]  dividendo,    // Valor numérico final del dividendo
    output logic [3:0]  divisor,      // Valor numérico final del divisor
    output logic        start_calc,   // Pulso para iniciar la operación en el divisor
    output logic [15:0] num_registro, // Datos para mostrar intermitentemente en pantalla
    output logic [3:0]  decenas,      // Almacena el primer dígito del dividendo
    output logic [3:0]  unidades      // Almacena el segundo dígito del dividendo
);

    // Estados de la FSM de entrada
    typedef enum logic [1:0] {
        ESPERA_DIVIDENDO,
        ESPERA_DIVISOR
    } state_t;
    
    state_t state;
    
    // Flags y registros internos para recordar si ya se ingresó el primer dígito
    logic       tengo_decenas_num;
    logic       tengo_decenas_div; 
    logic [3:0] dec_div;           // Almacena temporalmente la decena del divisor
    
    logic       valid_prev;
    logic       valid_pulse;
    
    // Detector de flanco de subida para 'valid' 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) valid_prev <= 0;
        else valid_prev <= valid;
    end
    assign valid_pulse = valid & ~valid_prev; // Crea un pulso de un ciclo de reloj
    
    // --- Máquina de Estados Principal ---
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
            start_calc <= 0; // Por defecto es 0, solo dura un ciclo activo
            
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
                    
                    if (valid_pulse && key_in == 4'hA) begin 
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
                            if (((dec_div * 10) + key_in) > 15) begin
                                divisor      <= 4'd15;
                                num_registro <= {8'b0, 4'h1, 4'h5};
                            end else begin
                                divisor      <= ((dec_div * 10) + key_in);
                                num_registro <= {8'b0, dec_div, key_in};
                            end
                        end
                    end
                    
                    if (valid_pulse && key_in == 4'hB) begin 
                        // Creamos una variable local para evaluar el valor real del divisor a guardar
                        logic [3:0] divisor_actual;
                        if (tengo_decenas_div) begin
                            divisor_actual = dec_div;
                        end else begin
                            divisor_actual = divisor;
                        end

                        // --- INTERCEPCIÓN DE CERO ---
                        if (divisor_actual == 4'd0) begin
                            // Si es cero, reiniciamos el divisor o puedes optar por no encender 'start_calc'
                            divisor           <= 4'd0;
                            tengo_decenas_div <= 0;
                            start_calc        <= 0; // Bloquea el inicio del cálculo
                            // Opcional: mantén el estado en ESPERA_DIVISOR para obligar a meter un divisor válido
                            state             <= ESPERA_DIVISOR; 
                        end else begin
                            divisor           <= divisor_actual;
                            tengo_decenas_div <= 0;
                            num_registro      <= 16'h0000;
                            start_calc        <= 1;         // Permite calcular
                            state             <= ESPERA_DIVIDENDO; 
                        end
                    end
                end
            endcase
        end
    end
endmodule