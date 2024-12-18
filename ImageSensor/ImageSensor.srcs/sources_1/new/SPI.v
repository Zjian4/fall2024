`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2024 01:51:36 PM
// Design Name: 
// Module Name: SPI
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


module SPI(
//    input  sys_clkn,
    input SPI_FSM,
//    input  sys_clkp,
    output SPI_CLK_0,
    output SPI_EN_0,
    output SPI_IN_0,
    input  SPI_OUT_0,
    input [6:0]address,
    input  W_R,
    input [7:0] writevalue,
    output reg [7:0] readvalue,
    
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg [9:0] State,
    input PC_control,
    output reg ON,
    output reg IN,
    output reg OUT,
    output reg s_clk

    
    
    
    );
    
//    reg [9:0] State;
//    wire [23:0] ClkDivThreshold =10 0;   
//    wire FSM_Clk, ILA_Clk; 
//    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
//                                      .sys_clkp(sys_clkp),                                      
//                                      .ClkDivThreshold(ClkDivThreshold),
//                                      .FSM_Clk(FSM_Clk),                          
//                                      .ILA_Clk(ILA_Clk) );
                                      
                                      
                                      
    localparam STATE_INIT       = 10'd0;    
 
    assign SPI_EN_0  = ON;
    assign SPI_IN_0  = IN;                                   
    assign SPI_OUT_0 = OUT; 
    assign SPI_CLK_0 =s_clk;                                  
   
    initial  begin
        s_clk=0;
        
        ON=0;
        IN=0;
        State =  STATE_INIT; 
    end
    
//    always @(*) begin          
//        FSM_Clk_reg = FSM_Clk;
//        ILA_Clk_reg = ILA_Clk;   
//    end   
                               
    always @(posedge SPI_FSM) begin                       
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                
                 if (PC_control == 1'b1) State <= 10'd1;                    
                 else begin                 
                     
                    s_clk=0;
                   
                    ON=0;
                    IN=0;
                  end
            end            
            
            // This is the Start sequence            
            10'd1  :   begin 
                  
                   ON <= 1'b1; s_clk <= 1'b0;                                          State <= State + 1'b1;  end         
            10'd2  :   begin  s_clk <= 1'b0;    IN <= W_R;                            State <= State + 1'b1;  end
            10'd3  :   begin  s_clk <= 1'b1;                                          State <= State + 1'b1;  end
            10'd4  :   begin  s_clk <= 1'b1;                                          State <= State + 1'b1;  end   
            
            10'd5  :   begin  s_clk <= 1'b0;         IN <=    address[6];                 State <= State + 1'b1;  end   
            10'd6  :   begin  s_clk <= 1'b0;                                              State <= State + 1'b1;  end   
            10'd7  :   begin  s_clk <= 1'b1;                                            State <= State + 1'b1;  end   
            10'd8  :   begin  s_clk <= 1'b1;                                                          State <= State + 1'b1;  end   
            
            10'd9  :   begin  s_clk <= 1'b0;          IN <=    address[5];                     State <= State + 1'b1;  end   
            10'd10 :   begin  s_clk <= 1'b0;                                                         State <= State + 1'b1;  end   
            10'd11 :   begin  s_clk <= 1'b1;                                                         State <= State + 1'b1;  end 
            10'd12 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end  
            
             
            10'd13 :   begin  s_clk <= 1'b0;         IN <=    address[4];                        State <= State + 1'b1;  end   
            10'd14 :   begin  s_clk <= 1'b0;                                                           State <= State + 1'b1;  end   
            10'd15 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd16 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            
            10'd17 :   begin  s_clk <= 1'b0;         IN <=    address[3];                         State <= State + 1'b1;  end   
            10'd18 :   begin  s_clk <= 1'b0;                                                           State <= State + 1'b1;  end   
            10'd19 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd20 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            10'd21 :   begin  s_clk <= 1'b0;          IN <=    address[2];                        State <= State + 1'b1;  end   
            10'd22 :   begin  s_clk <= 1'b0;                                                           State <= State + 1'b1;  end   
            10'd23 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd24 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            10'd25 :   begin  s_clk <= 1'b0;              IN <=    address[1];                        State <= State + 1'b1;  end   
            10'd26 :   begin  s_clk <= 1'b0;                                                           State <= State + 1'b1;  end   
            10'd27 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd28 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            10'd29 :   begin  s_clk <= 1'b0;              IN <=    address[0];                State <= State + 1'b1;  end   
            10'd30 :   begin  s_clk <= 1'b0;                                                           State <= State + 1'b1;  end   
            10'd31 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd32 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            
            
            10'd33 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[7]; end       State <= State + 1'b1;  end   
            10'd34 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[7]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd35 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd36 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            10'd37 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[6]; end       State <= State + 1'b1;  end   
            10'd38 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[6]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd39 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd40 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end    
            
            
             10'd41 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[5]; end       State <= State + 1'b1;  end   
            10'd42 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[5]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd43 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd44 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            
             10'd45 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[4]; end       State <= State + 1'b1;  end   
            10'd46 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[4]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd47 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd48 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
             10'd49 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[3]; end       State <= State + 1'b1;  end   
            10'd50 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[3]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd51 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd52 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
             10'd53 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[2]; end       State <= State + 1'b1;  end   
            10'd54 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[2]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd55 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd56 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
             10'd57 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[1]; end       State <= State + 1'b1;  end   
            10'd58 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[1]  <= OUT;   end      State <= State + 1'b1;  end   
            10'd59 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd60 :   begin  s_clk <= 1'b1;                                                              State <= State + 1'b1;  end   
            
            
            
             10'd61 :   begin  s_clk <= 1'b0;         if (W_R==1'b1)begin IN<= writevalue[0]; end       State <= State + 1'b1;  end   
            10'd62 :   begin  s_clk <= 1'b0;     if (W_R==1'b0) begin   readvalue[0] <= OUT;   end      State <= State + 1'b1;  end   
            10'd63 :   begin  s_clk <= 1'b1;                                                           State <= State + 1'b1;  end   
            10'd64 :   begin  s_clk <= 1'b1;                                                              State <= STATE_INIT;  end   
            
             
  
  
  
  
  
         
         
         
         
         
         
         
         
         
         
         
         
         
                                      
        endcase;                              
       end;                               
endmodule
