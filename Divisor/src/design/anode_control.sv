module anode_control (

    input  logic clk,       // Reloj maestro del sistema

    input  logic rst,       // Reset asíncrono (activo en alto)

    input  logic tick,      // Habilitación de cambio de dígito (proveniente del divisor)

    output logic [1:0] sel, // Selector para el multiplexor de datos (0 a 3)

    output logic [3:0] anode // Salida física hacia los ánodos/cátodos del display

);

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            // Estado inicial: contador a cero y todos los ánodos apagados

            sel   <= 2'd0;

            anode <= 4'b0000;

        end else if (tick) begin

            // Se incrementa el selector para pasar al siguiente dígito

            sel <= sel + 1'b1;

           

            // Decodificador de 2 a 4 bits: activa el pin físico correspondiente

            case (sel)

                2'd0: anode <= 4'b0001; // Activa Dígito 0 (Derecha)

                2'd1: anode <= 4'b0010; // Activa Dígito 1

                2'd2: anode <= 4'b0100; // Activa Dígito 2

                2'd3: anode <= 4'b1000; // Activa Dígito 3 (Izquierda)

            endcase

        end

    end

endmodule