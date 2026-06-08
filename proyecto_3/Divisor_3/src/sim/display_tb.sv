`timescale 1ns / 1ps

module display_tb();
    logic clk;
    logic rst;
    logic [15:0] num_in;
    logic [3:0] enc_an;
    logic [6:0] enc_seg;

    display uut (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        num_in = 16'h1234; // Queremos ver '1', '2', '3', '4'
        #20 rst = 0;

        // Monitoreo de cambios en los ánodos
        $monitor("Tiempo: %t | Ánodo: %b | Segmentos: %b", $time, enc_an, enc_seg);

        // Dejamos correr suficiente tiempo para que el clk_divider genere ticks
        // Nota: Si el clk_divider tiene un contador muy grande, 
        // considera reducirlo en el código para la simulación.
        #1000000; 
        $finish;
    end
endmodule