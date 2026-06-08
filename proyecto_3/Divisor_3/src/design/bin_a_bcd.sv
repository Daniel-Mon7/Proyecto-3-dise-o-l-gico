module bin_a_bcd (

    input  logic [5:0] bin,
    output logic [7:0] bcd

);

    logic [3:0] decenas;
    logic [3:0] unidades;

    always_comb begin

        if (bin >= 60) begin
            decenas  = 4'd6;
            unidades = bin - 60;

        end else if (bin >= 50) begin
            decenas  = 4'd5;
            unidades = bin - 50;

        end else if (bin >= 40) begin
            decenas  = 4'd4;
            unidades = bin - 40;

        end else if (bin >= 30) begin
            decenas  = 4'd3;
            unidades = bin - 30;

        end else if (bin >= 20) begin
            decenas  = 4'd2;
            unidades = bin - 20;

        end else if (bin >= 10) begin
            decenas  = 4'd1;
            unidades = bin - 10;

        end else begin
            decenas  = 4'd0;
            unidades = bin;

        end

        bcd = {decenas, unidades};

    end

endmodule