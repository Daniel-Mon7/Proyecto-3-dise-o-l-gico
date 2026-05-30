`timescale 1ns / 1ps

module teclado_completo_tb();
    // Señales de prueba
    logic clk;
    logic rst;
    logic [3:0] row;
    logic [3:0] col;
    logic [3:0] key_out;
    logic valid;

    // Instancia de la Unidad Bajo Prueba (UUT)
    teclado_completo uut (.*);

    // Generación de reloj (100MHz -> Periodo de 10ns)
    always #5 clk = ~clk;

    // Tarea para simular la presión física de una tecla
    // Esta tarea espera a que el scanner active la fila correcta y luego activa la columna
    task simular_tecla(input [1:0] fila_esperada, input [3:0] mascara_columna);
        begin
            $display("Esperando a que el scanner llegue a la fila %0d...", fila_esperada);
            // Esperamos a que el hardware de escaneo active la fila que queremos
            wait(uut.scanned_row == fila_esperada);
            
            // Simulamos que el usuario cierra el circuito físico
            col = mascara_columna;
            $display("Tecla presionada en fila %0d, col %b", fila_esperada, mascara_columna);

            // El debouncer necesita tiempo para estabilizarse (ej. 20ms en la vida real)
            // En simulación usamos un tiempo proporcional al SCAN_DIV
            #1000000; 
            
            // Soltamos la tecla
            col = 4'b0000;
            $display("Tecla soltada.");
            #500000;
        end
    endtask

    initial begin
        // Inicialización de señales
        clk = 0;
        rst = 1;
        col = 4'b0000;

        // Reset del sistema
        #100 rst = 0;
        $display("--- Inicio de simulación de teclado ---");

        // TEST 1: Presionar la Tecla '5'
        // La tecla '5' suele estar en Fila 1, Columna 1
        simular_tecla(2'd1, 4'b0010);

        // TEST 2: Presionar la Tecla 'A'
        // La tecla 'A' suele estar en Fila 0, Columna 3
        simular_tecla(2'd0, 4'b1000);

        // TEST 3: Presionar la Tecla '*' (mapeada como E)
        // Suele estar en Fila 3, Columna 0
        simular_tecla(2'd3, 4'b0001);

        #1000;
        $display("--- Simulación finalizada ---");
        $finish;
    end

    // Monitoreo de resultados en consola
    always @(posedge valid) begin
        $display("[EVENTO] Tecla detectada y validada: %h a las %t unidades de tiempo", key_out, $time);
    end

endmodule