`timescale 1ns / 1ps

module JTEG_Test_File(   
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output ADT7420_A0,
    output ADT7420_A1,
//    output LPS35_SDO,
//    output LPS35_CS,
//    output HTS221_SPIenable,
    output I2C_SCL_1,
    inout I2C_SDA_1,
    output PMOD_A1,
    output PMOD_A2,
    input  [4:0] okUH,
    output [2:0] okHU,
    inout  [31:0] okUHU,
    inout  okAA      
);

    wire  ILA_Clk,  FSM_Clk, TrigerEvent, Clk_stop;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire SCL, SDA; 
    wire [9:0] State;
    wire  PC_control;
    wire data_ready;
    wire [1:0] byte;
    wire [15:0] SingleByteData1;
    wire [15:0] SingleByteData2;
    wire [15:0] SingleByteData3;
    wire [15:0] SingleByteData4;
    wire [15:0] SingleByteData5;
    wire [15:0] SingleByteData6;
    wire      go;
    wire [9:0] ACK_bit;
    wire [5:0] stop;
 
 
    
    assign TrigerEvent = PC_control;   
     motor motor_1(
        .PMOD_A1(PMOD_A1),
        .PMOD_A2(PMOD_A2),
        .CLK(Clk_stop),
//        .sys_clkp(sys_clkp),
//        .okHU(okHU),
//        .okUHU(okUHU),
//        .okAA(okAA),
//        .okUH(okUH),
        .stop(stop),
//        .pause(ACK_bit[0]),
        .pause(data_ready),
        .go(byte),
        .led(led)
    );

    //Instantiate the module that we like to test
    I2C_Transmit I2C_Test1 (        
//        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .ADT7420_A0(ADT7420_A0),
        .ADT7420_A1(ADT7420_A1),
        
        .I2C_SCL_1(I2C_SCL_1),
        .I2C_SDA_1(I2C_SDA_1),             
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .Clk_stop(Clk_stop),
        .ACK_bit(ACK_bit),
        .stop(stop),
        .SCL(SCL),
        .SDA(SDA),
        .State(State),
        .PC_control(PC_control),
        .data_ready(data_ready),
        .byte(byte),
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .XSingleByteData1(SingleByteData1),
        .YSingleByteData2(SingleByteData2),
        .ZSingleByteData3(SingleByteData3),
        .XSingleByteData4(SingleByteData4),
        .YSingleByteData5(SingleByteData5),
        .ZSingleByteData6(SingleByteData6),
        .go(go)
        );
    



    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State, SDA, SCL }),                             
        .probe1({FSM_Clk, TrigerEvent}),
        .probe2({SingleByteData1}),
        .probe3 ({ACK_bit,byte})
        );                        
endmodule