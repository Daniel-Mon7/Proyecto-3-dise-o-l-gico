module divisor (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [5:0]  dividendo, // Limitado a 6 bits
    input  logic [3:0]  divisor,
    output logic [5:0]  cociente,  // Limitado a 6 bits
    output logic [3:0]  residuo,
    output logic        done
);

    typedef enum logic [2:0] {
        IDLE,
        INICIO,
        RESTA,
        DECIDE,
        SIGUIENTE,
        FIN
    } state_t;
    
    state_t state;
    
    // Registros de 6 bits para manejar la resta con espacio para el signo
    logic [5:0] R;
    logic [5:0] resta;
    logic [2:0] bit_index;
    logic [5:0] temp_cociente;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            cociente      <= 0;
            residuo       <= 0;
            done          <= 0;
            R             <= 0;
            bit_index     <= 0;
            temp_cociente <= 0;
        end else begin
            done <= 0;
            
            case (state)
                IDLE: begin
                    if (start) begin
                        R             <= 6'b0;
                        bit_index     <= 3'd5; // Arranca en el bit 5 (N-1) del dividendo de 6 bits
                        temp_cociente <= 6'b0;
                        state         <= INICIO;
                    end
                end
                
                INICIO: begin
                    R     <= {R[4:0], dividendo[bit_index]};
                    state <= RESTA;
                end
                
                RESTA: begin
                    resta <= R - {2'b00, divisor}; // Resta utilizando 6 bits
                    state <= DECIDE;
                end
                
                DECIDE: begin
                    if (resta[5]) begin // Si el MSB (bit 5) es 1, el resultado es negativo (R < divisor)
                        temp_cociente[bit_index] <= 1'b0;
                    end else begin      // Si es 0, el resultado es positivo o cero (R >= divisor)
                        temp_cociente[bit_index] <= 1'b1;
                        R                        <= resta;
                    end
                    state <= SIGUIENTE;
                end
                
                SIGUIENTE: begin
                    if (bit_index == 0) begin
                        state <= FIN;
                    end else begin
                        bit_index <= bit_index - 1;
                        state     <= INICIO;
                    end
                end
                
                FIN: begin
                    cociente <= temp_cociente;
                    residuo  <= R[3:0];
                    done     <= 1;
                    state    <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule