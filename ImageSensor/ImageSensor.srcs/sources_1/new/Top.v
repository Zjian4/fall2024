`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2024 01:40:05 PM
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top(
//    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output CVM300_SPI_CLK,  
    output CVM300_SPI_EN,   
    output CVM300_SPI_IN,   
    input  CVM300_SPI_OUT,  
    
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,   
    inout wire okAA   
      
);

    wire  ILA_Clk,  FSM_Clk, TrigerEvent; 
    wire [23:0] ClkDivThreshold = 1_000;    
    wire IN, ON,OUT,s_clk; 
    wire [9:0] State;
    wire  PC_control;
    wire [6:0]address;
    wire [7:0] writevalue;
    wire [7:0] readvalue;
    wire W_R;
   
 
    assign TrigerEvent = PC_control;   
    assign OUT =CVM300_SPI_OUT;
    //Instantiate the module that we like to test
    SPI SPI_1 (        
//        .led(led),
        .sys_clkn( sys_clkn),           
        .sys_clkp(sys_clkp),            
        .SPI_CLK_0(CVM300_SPI_CLK),           
        .SPI_EN_0(CVM300_SPI_EN),            
        .SPI_IN_0(CVM300_SPI_IN),            
        .SPI_OUT_0(CVM300_SPI_OUT),           
        .address(address),      
        .W_R( W_R),            
        .writevalue(writevalue),     
        .readvalue(readvalue), 
        .State(State),           
        .FSM_Clk_reg(FSM_Clk) ,     
        .ILA_Clk_reg (ILA_Clk),        
        .PC_control (PC_control),          
        .s_clk (s_clk),
        .IN(IN), 
        .OUT(OUT),
        .ON(ON)          
   
            
        );                        
    
         ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State}),                             
        .probe1({FSM_Clk, TrigerEvent}),
        .probe2({s_clk}),
        .probe3 ({IN,OUT,ON})
        );                        


    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication 
    
    //This is the OK host that allows data to be sent or recived    
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );
    
    //  PC_controll is a wire that contains data sent from the PC to FPGA.
    //  The data is communicated via memeory location 0x00
 
 

                        
  localparam  endPt_count = 8;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
    
    
                     
    okWireOut wire20 (  .okHE(okHE),
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20),
                        .ep_datain(readvalue));  
    
                               



       okWireIn wire1 (   .okHE(okHE), 
                        .ep_addr(8'h01), 
                        .ep_dataout(writevalue)); 
       
       okWireIn wire2 (   .okHE(okHE), 
                        .ep_addr(8'h02), 
                        .ep_dataout(address)); 
     
         okWireIn wire3 (   .okHE(okHE), 
                        .ep_addr(8'h03), 
                        .ep_dataout(PC_control)); 
        okWireIn wire4 (   .okHE(okHE), 
                        .ep_addr(8'h04), 
                        .ep_dataout(W_R));                  
        
endmodule
