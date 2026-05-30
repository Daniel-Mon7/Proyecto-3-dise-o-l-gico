module top (
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] rows,
    input  logic [3:0] cols,
    output logic [3:0] an,
    output logic [6:0] seg
);

    logic rst;
    logic [3:0] key_value;
    logic key_valid;
    logic [15:0] num_value;
    
    assign rst = ~reset;
    
    teclado_completo teclado_inst (
        .clk(clk),
        .rst(rst),
        .row(rows),
        .col(cols),
        .key_out(key_value),
        .valid(key_valid)
    );
    
    div_top division_inst (
        .clk(clk),
        .rst(rst),
        .key_in(key_value),
        .valid(key_valid),
        .num_out(num_value)
    );
    
    display display_inst (
        .clk(clk),
        .rst(rst),
        .num_in(num_value),
        .enc_an(an),
        .enc_seg(seg)
    );

endmodule