`timescale 1ns / 1ps
module lab3_example(
   input   wire    [4:0] okUH,
        output  wire    [2:0] okHU,
        inout   wire    [31:0] okUHU,
        inout   wire    okAA,
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp  
    );

    reg [1:0] state = 0;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg;    
               
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
   
    reg [31:0] clkdiv1;
    reg [31:0] clkdiv2;
    reg [31:0] clkdiv3;
    //reg [7:0] counter;
    // reg slow_clk;
   
     wire okClk;            //These are FrontPanel wires needed to IO communication    
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication    
           
    //Declare your registers or wires to send or recieve data
    wire [31:0] variable_1, variable_2;      //signals that are outputs from a module must be wires
    wire [31:0] result_wire;                 //signals that go into modules can be wires or registers
    reg  [31:0] result_register;             //signals that go into modules can be wires or registers
   
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
       
    //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 2 output endpoints, hence endPt_count = 2.
    localparam  endPt_count = 2;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
   
   
    assign led = ~led_register; //map led wire to led_register
    localparam STATE_NS_ON       = 2'd0;
    localparam STATE_P_Walk      = 2'd1;
    localparam STATE_EW_ON     = 2'd2;
    //localparam STATE_CHARLIE    = 2'd3;          
   
   
    initial begin
       clkdiv1 = 0;
       clkdiv2 = 0;
       clkdiv3 = 0;
   
    end
   
//always @(posedge clk) begin  
    //   clkdiv1 <= clkdiv1 + 1'b1;
    //   clkdiv2 <= clkdiv2 + 1'b1;
     //  clkdiv3 <= clkdiv3 + 1'b1;
    // end      
         
    reg P;
    reg NS;
     
    always @(posedge clk)
    begin      
       // button_reg  = ~button;
        //if (button_reg == (4'b0000)) state <= STATE_NS_ON;
       // if (button_reg == (4'b0001)) begin
        if (variable_1== 1) begin
            P <= 1'b1;
        end
        //else
        begin
            case (state)
             STATE_NS_ON : begin
                clkdiv1 <= clkdiv1 + 1'b1;
                clkdiv2 <= 0;
                clkdiv3 <= 0;
                if (P == (1'b1)) begin
                   
                    if( clkdiv1 < 200000000) begin
                         led_register <= 8'b10000101;
                    end
                    else if (clkdiv1 < 300000000) begin
                         led_register <= 8'b01000101;
                    end
                    else if(clkdiv1 < 600000000) begin
                         led_register <= 8'b00100101;
                         
                    end  
                    else begin
                         clkdiv1 <= 0;
                         state <= STATE_P_Walk;
                         NS <= 1;
                    end
               end
               else if (P == 0) begin
                       if( clkdiv1 < 200000000) begin
                         led_register <= 8'b10000101;
                       end
                       else if (clkdiv1 < 300000000) begin
                          led_register <= 8'b01000101;
                       end
                       else if(clkdiv1 < 600000000) begin
                          led_register <= 8'b00100101;                        
                       end  
                       else begin
                           clkdiv1 <= 0;
                           state <= STATE_EW_ON;
                           
                       end
                end
             
                                                               
                end
            STATE_P_Walk : begin
                    clkdiv1 <= 0;
                    clkdiv2 <= 0;
                    clkdiv3 <= clkdiv3 + 1'b1;
                    if( clkdiv3 < 200000000) begin
                         led_register <= 8'b00100110;
                    end else begin
                         clkdiv3 <= 0;
                         P <= 0;
                         if (NS == 1) state <= STATE_EW_ON;
                         else if  (NS == 0) state <= STATE_NS_ON;
                    end
 
                   
                end
               
            STATE_EW_ON : begin
           
                clkdiv1 <= 0;
                clkdiv2 <= clkdiv2 + 1'b1;
                clkdiv3 <= 0;
              if (P == 1) begin
                    if( clkdiv2 < 200000000) begin
                         led_register <= 8'b00110001;
                    end
                    else if (clkdiv2 < 300000000) begin
                         led_register <= 8'b00101001;
                    end
                    else if(clkdiv2 < 600000000) begin
                         led_register <= 8'b00100101;
                         
                    end  
                    else begin
                         clkdiv2 <= 0;
                         NS <= 0;
                         state <= STATE_P_Walk;
                    end
                end
                else if (P == 0) begin
                     if( clkdiv2 < 200000000) begin
                         led_register <= 8'b00110001;
                    end
                    else if (clkdiv2 < 300000000) begin
                         led_register <= 8'b00101001;
                    end
                    else if(clkdiv2 < 600000000) begin
                         led_register <= 8'b00100101;
                         
                    end  
                    else  begin
                         clkdiv2 <= 0;
                         state <= STATE_NS_ON;
                    end
                 end
                                                                 
                end    
             
         
                default: state <=  STATE_NS_ON;
            endcase
        end                          
    end    
   
    okWireIn wire10 (   .okHE(okHE),
                        .ep_addr(8'h00),
                        .ep_dataout(variable_1));
                       
    okWireIn wire11 (   .okHE(okHE),
                        .ep_addr(8'h01),
                        .ep_dataout(variable_2));
                       
                       
    assign result_wire = variable_1 + variable_2;    // Left-Side of 'assign' statement must be a 'wire'

    // result_wire is transmited to the PC via address 0x20  
    okWireOut wire20 (  .okHE(okHE),
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20),
                        .ep_datain(result_wire));
                       
    // Variable 1 and 2 are subtracted and the result is stored in a register named: result_register
    // Since we are using a register to store the result, we not need a clock signal and
    // we will use an always statement examening the clock state  
   
    reg slow_clk;
    reg [7:0] counter;
    reg [31:0] clkdiv;
   
    initial begin
        clkdiv = 0;
        slow_clk = 0;
    end
   
    always @(posedge clk) begin
        clkdiv <= clkdiv + 1'b1;
        if (clkdiv == 10_000_000) begin
            slow_clk <= ~slow_clk;
            clkdiv <= 0;
        end
    end
   
    always @ (posedge slow_clk) begin
        result_register = variable_1 - variable_2;
    end
   
    // result_wire is transmited to the PC via address 0x21                        
    okWireOut wire21 (  .okHE(okHE),
                        .okEH(okEHx[ 1*65 +: 65 ]),
                        .ep_addr(8'h21),
                        .ep_datain(result_register));    
   
endmodule
