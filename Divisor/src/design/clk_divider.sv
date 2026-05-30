module clk_divider (
    input  logic clk,    // Reloj maestro de entrada (referencia de alta velocidad)
    input  logic rst,    // Reset asíncrono para inicializar el contador
    output logic tick    // Pulso de salida sincronizado que indica el desborde
);
    // Registro de 14 bits para el conteo de ciclos de reloj
    logic [13:0] count;

    // Lógica secuencial para el incremento del contador
    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            count <= 14'd0;         // Reinicio del contador a su valor inicial
        else     
            count <= count + 1'b1;  // Incremento por cada flanco de subida
    end

    // Lógica combinacional para generar el pulso de habilitación.
    // Se activa por un solo ciclo de reloj maestro cada vez que el contador 
    // completa su ciclo de 2^14 estados.
    assign tick = (count == 14'd0);

endmodule