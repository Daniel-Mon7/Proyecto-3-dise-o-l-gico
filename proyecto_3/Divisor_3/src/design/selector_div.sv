module selector_div (
    input  logic        clk,
    input  logic        rst,
    input  logic        valid,         // Pulso de tecla presionada
    input  logic [3:0]  key_in,        // Tecla actual

    input  logic        done,          // Señal de fin del cálculo del divisor
    input  logic [3:0]  divisor,       // REQUERIDO: Entrada directa del divisor binario

    input  logic [3:0]  decenas,       // Datos del dividendo para mostrar
    input  logic [3:0]  unidades,

    input  logic [7:0]  divisor_bcd,   // Resultados en BCD
    input  logic [7:0]  cociente_bcd,
    input  logic [7:0]  residuo_bcd,

    input  logic [15:0] num_registro,  // Datos de entrada temporales de teclado

    output logic [15:0] num_out        // Salida de 16 bits final hacia los displays
);

    // Modos de visualización de resultados
    typedef enum logic [2:0] {
        VER_COCIENTE,
        VER_RESIDUO,
        VER_DIVIDENDO,
        VER_DIVISOR,
        VER_ERROR_CERO          // Nuevo estado de error para la división entre 0
    } modo_vista_t;

    modo_vista_t modo_vista;
    logic resultado_activo;   // Flag de resultados listos
    logic [3:0] key_guardada; 

    localparam [3:0] CODIGO_GUION = 4'hE; 

    // --- Registro de comando de teclado ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            key_guardada <= 4'h0;
        else if (valid)
            key_guardada <= key_in;
    end

    // --- FSM de Control de Vista ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            modo_vista       <= VER_COCIENTE;
            resultado_activo <= 1'b0;
        end else begin
            
            // 1. Monitoreo de Teclado en vivo para capturar el error de división por cero
            if (valid && key_in == 4'hB && divisor == 4'd0) begin
                resultado_activo <= 1'b1;            // Forzamos la visualización activa
                modo_vista       <= VER_ERROR_CERO;  // Saltamos directo al estado de error
            end
            
            // 2. Si el cálculo termina exitosamente (Divisor NO fue cero)
            else if (done) begin
                resultado_activo <= 1'b1;
                modo_vista       <= VER_COCIENTE;
            end 
            
            // 3. Limpieza de pantalla: Si el usuario presiona 'A' para un nuevo intento
            else if (valid && key_in == 4'hA) begin
                resultado_activo <= 1'b0;
            end

            // 4. Navegación clásica de resultados (solo si no estamos atrapados en el error)
            if (resultado_activo && modo_vista != VER_ERROR_CERO) begin
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

    // --- Lógica Combinacional de Multiplexación de Salida ---
    always_comb begin
        if (resultado_activo) begin
            case (modo_vista)
                VER_ERROR_CERO:
                    // Enviamos el código de guion a los 4 displays individuales de la pantalla
                    // num_out = [Display3, Display2, Display1, Display0]
                    num_out = {CODIGO_GUION, CODIGO_GUION, CODIGO_GUION, CODIGO_GUION};
                
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