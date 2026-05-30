`timescale 1ns / 1ps

module top_tb();
    logic clk;
    logic reset;
    logic [3:0] rows;
    logic [3:0] cols;
    logic [3:0] an;
    logic [6:0] seg;

    top uut (.*);

    always #5 clk = ~clk;

    // Tarea para simular que alguien presiona una tecla física en el teclado
    // Presionar tecla '1' (Fila 0, Columna 0)
    task sim_press_key1();
        begin
            wait(rows == 4'b0001); // Espera a que el scanner active la fila 0
            cols = 4'b0001;        // Cerramos el circuito en la columna 0
            #2000000;              // Mantenemos presionado (tiempo para debouncer)
            cols = 4'b0000;        // Soltamos
            #1000000;
        end
    endtask

    initial begin
        clk = 0;
        reset = 0; // El módulo top invierte reset internamente
        cols = 4'b0000;
        
        #100 reset = 1; // Pulso de reset (en placa es activo bajo)
        #100 reset = 0;

        $display("Iniciando simulación del sistema completo...");
        
        // Simulamos presionar la tecla '1'
        sim_press_key1();

        #5000000;
        $finish;
    end
endmodule