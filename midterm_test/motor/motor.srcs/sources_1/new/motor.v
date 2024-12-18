`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2024 02:22:13 PM
// Design Name: 
// Module Name: motor
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


module motor(


    output PMOD_A1,
    output PMOD_A2,
//    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp 
    
   
    );

     reg [23:0] clkdiv;
     reg [2:0] state;
     reg slow_clk;
     reg DIR1;
     reg EN1;
     reg [7:0] counter;
    // This section defines the main system clock from two
    //differential clock signals: sys_clkn and sys_clkp
    // Clk is a high speed clock signal running at ~200MHz
    wire clk;
    reg [2:0] pause;
    
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    initial begin
        clkdiv = 0;
        counter = 8'h00;
          state = 3'd0;
          pause = 3'b0;  
    end
    
    assign led = ~counter;
    assign PMOD_A1=EN1;
    assign PMOD_A2 =DIR1;
           
    // This code creates a slow clock from the high speed Clk signal
    // You will use the slow clock to run your finite state machine
    // The slow clock is derived from the fast 20 MHz clock by dividing it 10,000,000 time
    // Hence, the slow clock will run at 2 Hz
    always @(posedge clk) begin
        clkdiv <= clkdiv + 1'b1;
        if (clkdiv == 10000000) begin
            slow_clk <= ~slow_clk;
            clkdiv <= 0;
        end
    end
     
    
      
    //The main code will run fr0m the slow clock.  The rest of the code will be in this section.  
    //The counter will decrement when button 0 is pressed and on the rising edge of the slow clk 
    //Otherwise the counter will increment
    reg target100 ;
     always @(posedge slow_clk) begin 
    
         if( target100 == 0)begin
           
             counter <= counter + 4'b1010;
             if (counter == 30)begin
                 target100 <=1;
               
             end
         end
         else if( target100 == 1)begin
               
             counter <= counter - 4'b1010;
             if (counter == 10)begin
                 counter <= counter - 4'b1010;
                 target100 <=0;
                
             end
         end
        

    end    
    
    always @(posedge target100) begin       
       case (state)
            3'b000  :  begin  EN1 =0;   DIR1=0;                     state <= state +1'b1;   end
            3'b001  :  begin  EN1 =1;   DIR1=0;    pause=pause+1;    state <= state + 1'b1;  end
            3'b010  :  begin  DIR1 =1;   EN1=0     pause=pause+1;    state <= state + 1'b1;  end
            3'b011  :  begin  EN1 =1;   DIR1=1;    if (pause==3'd5)                  state <= 3'b100;      
                                                    else          state <=3'b000;         end
            3'b100  :  begin  EN1 =0;   DIR1=0;                           end
           
            
     
        endcase
    end
 //The main code will run fr0m the slow clock. The rest of the code will be in this section. 
 //The counter will decrement when button 0 is pressed and on the rising edge of the slow 

 //Otherwise the counter will increment
 
     
   
endmodule


