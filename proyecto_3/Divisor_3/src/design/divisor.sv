module divisor (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,        // Pulso de inicio de operación
    input  logic [5:0]  dividendo,
    input  logic [3:0]  divisor,
    output logic [5:0]  cociente, 
    output logic [3:0]  residuo,
    output logic        done          // Indica que el cálculo ha terminado
);

    // Estados de la FSM del divisor basado en el algoritmo tradicional Shift-and-Subtract
    typedef enum logic [2:0] {IDLE, INICIO, RESTA, DECIDE, SIGUIENTE, FIN} state_t;
    state_t state;

    logic [5:0] R;             // Registro del residuo parcial
    logic [5:0] resta;         // Resultado de la resta interna
    logic [2:0] bit_index;     // Contador para iterar por cada uno de los 6 bits
    logic [5:0] temp_cociente; // Registro temporal para ir armando el cociente

    // Registros intermedios para guardar las salidas
    logic [5:0] cociente_out;
    logic [3:0] residuo_out;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            temp_cociente <= 0;
            R             <= 0;
            bit_index     <= 0;
            cociente_out  <= 0;
            residuo_out   <= 0;
            done          <= 0;
        end else begin
            done <= 0; // Apaga 'done' por defecto en cada ciclo

            case (state)
                IDLE: begin
                    if (start) begin
                        if (divisor == 4'b0000) begin
                            // --- PROTECCIÓN DIVISIÓN ENTRE ZERO ---
                            // Si se intenta dividir entre 0, se aborta y se va a FIN
                            temp_cociente <= 6'b000000;
                            R             <= dividendo; // Matemáticamente el residuo sería el dividendo entero
                            state         <= FIN;
                        end else begin
                            temp_cociente <= 0;
                            R             <= 0;
                            bit_index     <= 3'd5; // Configura el índice en el bit más significativo (MSB)
                            state         <= INICIO;
                        end
                    end
                end

                INICIO: begin
                    // Desplazamiento a la izquierda de R e introduce el bit actual del dividendo
                    R     <= {R[4:0], dividendo[bit_index]};
                    state <= RESTA;
                end

                RESTA: begin
                    // Realiza la resta tentativa: R - divisor
                    resta <= R - {2'b00, divisor};
                    state <= DECIDE;
                end

                DECIDE: begin
                    // Se revisa si el resultado es negativo. En complemento a 2, si el bit MSB (resta[5]) es 1, es negativo
                    if (resta[5]) begin // R < divisor (No cabe)
                        temp_cociente[bit_index] <= 1'b0; // El bit del cociente es 0
                    end else begin      // R >= divisor (Sí cabe)
                        temp_cociente[bit_index] <= 1'b1; // El bit del cociente es 1
                        R <= resta;                       // Se valida la resta actualizar R
                    end
                    state <= SIGUIENTE;
                end

                SIGUIENTE: begin
                    // Verifica si ya se procesaron los 6 bits (del 5 al 0)
                    if (bit_index == 0)
                        state <= FIN;
                    else begin
                        bit_index <= bit_index - 1; // Decrementa para ir al siguiente bit
                        state     <= INICIO;        // Repite el bucle
                    end
                end

                FIN: begin
                    cociente_out <= temp_cociente; // Salva el cociente final calculado
                    residuo_out  <= R[3:0];        // Lo que quedó en R es el residuo
                    done         <= 1;             // Indica fin de cómputo
                    state        <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // Registro de salida final: Solo actualiza las salidas globales cuando 'done' se activa
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cociente <= 0;
            residuo  <= 0;
        end else if (done) begin
            cociente <= cociente_out;
            residuo  <= residuo_out;
        end
    end

endmodule