module divisor (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [5:0]  dividendo,
    input  logic [3:0]  divisor,
    output logic [5:0]  cociente, 
    output logic [3:0]  residuo,
    output logic        done
);

    typedef enum logic [2:0] {IDLE, INICIO, RESTA, DECIDE, SIGUIENTE, FIN} state_t;
    state_t state;

    logic [5:0] R;
    logic [5:0] resta;
    logic [2:0] bit_index;
    logic [5:0] temp_cociente;

    // Registros finales de salida
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
            done <= 0; // limpiar done cada ciclo excepto FIN

            case (state)
                IDLE: begin
                    if (start) begin
                        temp_cociente <= 0;
                        R             <= 0;
                        bit_index     <= 3'd5;
                        state         <= INICIO;
                    end
                end

                INICIO: begin
                    R     <= {R[4:0], dividendo[bit_index]};
                    state <= RESTA;
                end

                RESTA: begin
                    resta <= R - {2'b00, divisor};
                    state <= DECIDE;
                end

                DECIDE: begin
                    if (resta[5]) // R < divisor
                        temp_cociente[bit_index] <= 1'b0;
                    else begin
                        temp_cociente[bit_index] <= 1'b1;
                        R <= resta;
                    end
                    state <= SIGUIENTE;
                end

                SIGUIENTE: begin
                    if (bit_index == 0)
                        state <= FIN;
                    else begin
                        bit_index <= bit_index - 1;
                        state     <= INICIO;
                    end
                end

                FIN: begin
                    cociente_out <= temp_cociente;
                    residuo_out  <= R[3:0];
                    done         <= 1;
                    state        <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // Salidas finales registradas
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