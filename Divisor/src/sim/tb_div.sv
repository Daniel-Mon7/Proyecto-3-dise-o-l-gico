`timescale 1ns / 1ps

module tb_top();

    // --- Señales del Testbench ---
    logic       clk;
    logic       reset;
    logic [3:0] rows;
    logic [3:0] cols;
    logic [3:0] an;
    logic [6:0] seg;

    // --- Instancia del Módulo bajo Prueba (DUT) ---
    top dut (
        .clk(clk),
        .reset(reset),
        .rows(rows),
        .cols(cols),
        .an(an),
        .seg(seg)
    );

    // --- Generación del Reloj (27 MHz) ---
    always begin
        clk = 1'b0; #18.5;
        clk = 1'b1; #18.5;
    end

    // --- Tarea para inyectar directo a div_top omitiendo el debouncer del teclado ---
    task forzar_entrada(input [3:0] key, input integer ciclos);
        begin
            // Forzamos las señales jerárquicas directas a la entrada de div_top
            force dut.division_inst.key_in = key;
            force dut.division_inst.valid  = 1'b1;
            #(37.037 * ciclos); // Mantenemos el pulso por 'N' ciclos de reloj
            
            // Liberamos o ponemos en bajo
            force dut.division_inst.valid  = 1'b0;
            #(37.037 * 2); // Espera de seguridad entre dígitos
            
            // Eliminamos la fuerza para no congelar la señal permanentemente
            release dut.division_inst.key_in;
            release dut.division_inst.valid;
        end
    endtask

    // --- Estímulos ---
    initial begin
        reset = 1'b0; // Activo
        #100;
        reset = 1'b1; // Desactivar reset
        #50;

        // ====================================================
        // CASO 1: Calcular 45 / 6
        // ====================================================
        $display("\n[TB] >>> INICIANDO CASO 1: 45 / 6 <<<");
        forzar_entrada(4'h4, 2); // Decenas (4)
        forzar_entrada(4'h5, 2); // Unidades (5)
        forzar_entrada(4'hA, 2); // Confirmar Dividendo
        
        forzar_entrada(4'h6, 2); // Divisor (6)
        forzar_entrada(4'hB, 2); // Confirmar Divisor e Iniciar Cálculo
        
        #1000; // Tiempo para que el divisor ejecute sus estados

        // ====================================================
        // CASO 2: Calcular 12 / 4
        // ====================================================
        $display("\n[TB] >>> INICIANDO CASO 2: 12 / 4 <<<");
        forzar_entrada(4'h1, 2); // Decenas (1)
        forzar_entrada(4'h2, 2); // Unidades (2)
        forzar_entrada(4'hA, 2); // Confirmar Dividendo
        
        forzar_entrada(4'h4, 2); // Divisor (4)
        forzar_entrada(4'hB, 2); // Confirmar Divisor e Iniciar Cálculo
        
        #1000;

        $display("\n[TB] Todas las pruebas en consola completadas.");
        $finish;
    end

    // --- Monitor de Consola Avanzado ---
    initial begin
        $timeformat(-9, 3, " ns", 12);
        $display("\n=====================================================================");
        $display("          MONITOR DE OPERACIONES DE DIVISIÓN (SIMULACIÓN)            ");
        $display("=====================================================================");
        
        $monitor("Tiempo: %t | Div: %0d | Dvr: %0d | Start: %b | Q: %0d | R: %0d | Done: %b", 
                 $time,
                 dut.division_inst.dividendo,
                 dut.division_inst.divisor,
                 dut.division_inst.start_calc,
                 dut.division_inst.cociente,
                 dut.division_inst.residuo,
                 dut.division_inst.done
        );
    end

endmodule