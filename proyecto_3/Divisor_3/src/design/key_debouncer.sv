module key_debouncer #(
    parameter DEBOUNCE_TIME = 270000 // Tiempo de espera (ej. 10ms si clk=27MHz)
)(
    input  logic       clk,       // Reloj maestro del sistema
    input  logic       rst,       // Reset asíncrono
    input  logic       fila_pres, // Flag: indica que se detectó una tecla presionada
    input  logic [3:0] raw_key,   // Valor de la tecla detectada actualmente (sin filtrar)
    
    output logic [3:0] key_out,   // Valor de la tecla ya estabilizada
    output logic       valid,     // Pulso de un solo ciclo indicando dato válido
    output logic       is_idle    // Indica que el sistema está listo para buscar otra tecla
);

    // Definición de estados de la FSM utilizando un tipo enumerado
    typedef enum logic [1:0] {
        IDLE     = 2'd0, // Reposo: Esperando a que se presione una tecla
        DEBOUNCE = 2'd1, // Validación: Confirmando que la señal sea estable y no ruido
        PRESSED  = 2'd2  // Retención: Tecla validada, esperando a que se suelte
    } state_t;

    state_t state;
    logic [31:0] debounce_cnt; // Contador para alcanzar el tiempo de estabilización
    logic [3:0]  stable_key;   // Registro para memorizar el valor de la tecla durante la validación

    // Lógica combinacional: is_idle es verdadero solo cuando no se está procesando nada
    assign is_idle = (state == IDLE);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Inicialización de señales por Reset
            state        <= IDLE;
            debounce_cnt <= 0;
            valid        <= 0;
            key_out      <= 0;
            stable_key   <= 0;
        end else begin
            valid <= 1'b0; // Comportamiento por defecto: el pulso dura un solo ciclo
            
            case (state)
                // --- ESTADO: IDLE (ESPERA) ---
                IDLE: begin
                    if (fila_pres) begin
                        stable_key   <= raw_key; // Se captura el valor inicial para comparar después
                        debounce_cnt <= 0;
                        state        <= DEBOUNCE;
                    end
                end

                // --- ESTADO: DEBOUNCE (VALIDACIÓN) ---
                DEBOUNCE: begin
                    // Verifica si la tecla sigue presionada y mantiene el mismo valor
                    if (fila_pres && raw_key == stable_key) begin
                        if (debounce_cnt >= DEBOUNCE_TIME) begin
                            key_out <= stable_key; // Se actualiza la salida con el dato estable
                            valid   <= 1'b1;       // Se genera el pulso de confirmación
                            state   <= PRESSED;
                        end else begin
                            debounce_cnt <= debounce_cnt + 1'b1;
                        end
                    end else begin
                        // Si la señal cambia o desaparece, se considera ruido mecánico
                        state <= IDLE;
                    end
                end

                // --- ESTADO: PRESSED (RETENCIÓN) ---
                PRESSED: begin
                    // El sistema se queda en este estado hasta que se deje de presionar la tecla
                    // Esto evita la repetición automática no deseada de caracteres
                    if (!fila_pres) begin
                        debounce_cnt <= 0;
                        state        <= IDLE; // Regresa a esperar cuando el usuario suelta la tecla
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule