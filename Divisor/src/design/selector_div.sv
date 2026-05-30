module selector_div (

    input  logic        clk,
    input  logic        rst,

    input  logic        valid,
    input  logic [3:0]  key_in,

    input  logic        done,

    input  logic [3:0]  decenas,
    input  logic [3:0]  unidades,

    input  logic [7:0]  divisor_bcd,

    input  logic [7:0]  cociente_bcd,
    input  logic [7:0]  residuo_bcd,

    input  logic [15:0] num_registro,

    output logic [15:0] num_out

);

    typedef enum logic [1:0] {

        VER_COCIENTE,
        VER_RESIDUO,
        VER_DIVIDENDO,
        VER_DIVISOR

    } modo_vista_t;

    modo_vista_t modo_vista;

    logic resultado_activo;

    logic [3:0] key_guardada;

    // Registro de tecla
    always_ff @(posedge clk or posedge rst) begin

        if (rst)
            key_guardada <= 4'h0;
        else if (valid)
            key_guardada <= key_in;

    end

    // FSM principal
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            modo_vista       <= VER_COCIENTE;
            resultado_activo <= 1'b0;

        end else begin

            if (done) begin

                resultado_activo <= 1'b1;
                modo_vista       <= VER_COCIENTE;

            end

            if (resultado_activo) begin

                case (key_guardada)

                    4'hA: modo_vista <= VER_DIVIDENDO;
                    4'hB: modo_vista <= VER_DIVISOR;
                    4'hC: modo_vista <= VER_COCIENTE;
                    4'hD: modo_vista <= VER_RESIDUO;

                    default: modo_vista <= modo_vista;

                endcase

            end
        end
    end

    // Lógica de visualización
    always_comb begin

        if (resultado_activo) begin

            case (modo_vista)

                VER_DIVIDENDO:
                    num_out = {8'b0, decenas, unidades};

                VER_DIVISOR:
                    num_out = {8'b0, divisor_bcd};

                VER_COCIENTE:
                    num_out = {8'b0, cociente_bcd};

                VER_RESIDUO:
                    num_out = {8'b0, residuo_bcd};

                default:
                    num_out = {8'b0, cociente_bcd};

            endcase

        end else begin

            num_out = num_registro;

        end
    end

endmodule