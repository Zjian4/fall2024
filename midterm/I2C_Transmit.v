`timescale 1ns / 1ps

module I2C_Transmit(    
//    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    output ADT7420_A0,
    output ADT7420_A1,
//    output LPS35_SDO,
//    output LPS35_CS,
//    output HTS221_SPIenable,
    output I2C_SCL_1,
    inout  I2C_SDA_1,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg Clk_stop,
    output reg [8:0] ACK_bit,
    output reg SCL,
    output reg SDA,
    output reg [9:0] State,
    output wire PC_control,
    output wire data_ready,
    output wire     byte,
    output wire [5:0] stop,
//    output reg [30:0] SDA_value,
//    output reg [7:0] SensorID_W, SensorID_R, registerAddress,
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,   
    inout wire okAA,   
    output reg [15:0] XSingleByteData1,
    output reg [15:0] YSingleByteData2,
    output reg [15:0] ZSingleByteData3,
    output reg [15:0] XSingleByteData4,
    output reg [15:0] YSingleByteData5,
    output reg [15:0] ZSingleByteData6,
    output reg        go,
    output reg [15:0] X
    
//    output reg    R_W 
    );
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold =100;   
    wire FSM_Clk, ILA_Clk, Clk_stop; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk), 
                                      .Clk_stop(Clk_stop),                                     
                                      .ILA_Clk(ILA_Clk) );
                                      
//    reg [15:0] SingleByteData = 16'b1111111111111111;                                             
    wire error_bit = 1'b1;      
//    wire [30:0] SDA_value;
    wire [7:0] CNRL;   
    wire [7:0] registerAddress; 
    wire [6:0] Linear_acceleration;
    wire [6:0] Magnetic_field;
    wire [7:0] X_axis;
    
    okWireIn wire11 (   .okHE(okHE), 
                        .ep_addr(8'h11), 
                        .ep_dataout(data_ready)); 
    okWireIn wire10 (   .okHE(okHE),                
                       .ep_addr(8'h00),            
                       .ep_dataout(PC_control)); 
                         
    okWireIn wire01 (   .okHE(okHE), 
                        .ep_addr(8'h01), 
                        .ep_dataout(CNRL));

     okWireIn wire02 (   .okHE(okHE), 
                        .ep_addr(8'h02), 
                        .ep_dataout(registerAddress));
     okWireIn wire03 (   .okHE(okHE), 
                        .ep_addr(8'h03), 
                        .ep_dataout(Linear_acceleration));
      
     okWireIn wire04 (   .okHE(okHE), 
                        .ep_addr(8'h04), 
                        .ep_dataout(X_axis));
     okWireIn wire12 (   .okHE(okHE), 
                        .ep_addr(8'h12), 
                        .ep_dataout(byte));                   
     okWireIn wire13 (   .okHE(okHE), 
                        .ep_addr(8'h13), 
                        .ep_dataout(stop));     



  
    
    localparam STATE_INIT       = 10'd0;    
//    assign led[7] = ACK_bit;
//    assign led[6] = error_bit;
    assign ADT7420_A0 = 1'b0;
    assign ADT7420_A1 = 1'b0;
    assign I2C_SCL_1 = SCL;
    assign I2C_SDA_1 = SDA; 

    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 9'b111111111;   
        XSingleByteData1 = 16'b1111111111111111;
      YSingleByteData2 = 16'b1111111111111111;
      ZSingleByteData3 = 16'b1111111111111111;
      XSingleByteData4 = 16'b1111111111111111;
      YSingleByteData5 = 16'b1111111111111111;
      ZSingleByteData6 = 16'b1111111111111111; 
        State = 10'd0; 
        go=0;
    end
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;   
    end   
                               
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                
                 if (PC_control == 1'b1) State <= 10'd1;                    
                 else begin                 
                     
                    SCL = 1'b1;
                    SDA = 1'b1;
                    State <= STATE_INIT;  
                    ACK_bit = 9'b111111111;   
                    go=0;
                  end
            end            
            
            // This is the Start sequence            
            10'd1  :   begin 
                   if (data_ready ==1'b1 ) begin
                                
                                 SCL <= 1'b1;
                                 SDA <= 1'b0;
                                State <= State + 1'b1;
                                  
                     
                        
                          end    
                        else begin 
                        State <=10'd1;
                        go=1;
                        end
                    end
                    
                          
            10'd2  :  begin
                             SCL <= 1'b0; SDA <= 1'b0;                   State <= State + 1'b1;  end
            

            // sensorID bit 7   
            10'd3  :   begin SCL <= 1'b0; SDA <= Linear_acceleration [6];               State <= State + 1'b1;  end   
            10'd4  :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd5  :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd6  :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // sensorID bit 6                              
            10'd7  :   begin SCL <= 1'b0; SDA <= Linear_acceleration [5];              State <= State + 1'b1;  end   
            10'd8  :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd9  :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd10 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                        
            // sensorID bit 5                           
            10'd11 :   begin SCL <= 1'b0; SDA <= Linear_acceleration [4];              State <= State + 1'b1;  end   
            10'd12 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd13 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd14 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                              
            // sensorID bit 4                                 
            10'd15 :   begin SCL <= 1'b0; SDA <= Linear_acceleration [3];              State <= State + 1'b1;  end   
            10'd16 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd17 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd18 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // sensorID bit 3                              
            10'd19 :   begin SCL <= 1'b0; SDA <= Linear_acceleration [2];               State <= State + 1'b1;  end   
            10'd20 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd21 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd22 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // sensorID bit 2                              
            10'd23 :   begin SCL <= 1'b0; SDA <= Linear_acceleration [1];              State <= State + 1'b1;  end   
            10'd24 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd25 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd26 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
            // sensorID bit 1                              
            10'd27 :   begin SCL <= 1'b0; SDA <= Linear_acceleration [0];               State <= State + 1'b1;  end   
            10'd28 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd29 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd30 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // R/W'                                        
            10'd31 :   begin SCL <= 1'b0; SDA <= 0;                                    State <= State + 1'b1;  end   
            10'd32 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd33 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd34 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   

            //ACK
            10'd35 :   begin SCL <= 1'b0; SDA<= 1'bz;                                  State <= State + 1'b1;  end   
            10'd36 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd37 :   begin SCL <= 1'b1;  ACK_bit[0] <=SDA;                            State <= State + 1'b1;  end   
            10'd38 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
 
 
         //////////////////////////////////////////////////////////////////////////////////////////////////////    
           
            
            // registerAddress bit 7                    
                                                                             
            10'd39 :   begin SCL <= 1'b0; SDA <= registerAddress[7];                    State <= State + 1'b1;  end  
            10'd40 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd41 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd42 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            // registerAddress bit 6                                                                                      
            10'd43 :   begin SCL <= 1'b0; SDA <= registerAddress[6];                   State <= State + 1'b1;  end  
            10'd44 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd45 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd46 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            // registerAddress bit 5                                                                                      
           10'd47 :   begin SCL <= 1'b0; SDA <= registerAddress[5];                  State <= State + 1'b1;  end  
           10'd48 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
           10'd49 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
           10'd50 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            // registerAddress bit 4                                                                                      
            10'd51 :   begin SCL <= 1'b0; SDA <= registerAddress[4];                    State <= State + 1'b1;  end  
            10'd52 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd53 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd54 :  begin SCL <= 1'b0;                                               State <= State + 1'b1;  end  
                                                                                                                   
            // registerAddress bit 3                                                                                      
           10'd55 :   begin SCL <= 1'b0; SDA <= registerAddress[3];                      State <= State + 1'b1;  end  
           10'd56 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
           10'd57 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
           10'd58 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            // registerAddress bit 2                                                                                       
            10'd59 :   begin SCL <= 1'b0; SDA <= registerAddress[2];                   State <= State + 1'b1;  end  
            10'd60 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd61 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd62 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
            // registerAddress bit 1                                                                                      
           10'd63 :   begin SCL <= 1'b0; SDA <= registerAddress[1];                   State <= State + 1'b1;  end  
           10'd64 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
           10'd65 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
           10'd66 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            // R/W'                                                                                                
            10'd67 :   begin SCL <= 1'b0; SDA <= registerAddress[0];                   State <= State + 1'b1;  end  
            10'd68 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd69 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd70 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            //ACK                                                                                                  
            10'd71 :   begin SCL <= 1'b0; SDA<= 1'bz;                                  State <= State + 1'b1;  end  
            10'd72 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd73 :   begin SCL <= 1'b1; ACK_bit[1] <=SDA;                            State <= State + 1'b1;  end  
            10'd74 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
            
        //////////////////////////////////////////////////////////////////////////////////////////////////////    
            
         
         
         
            
            10'd75 :   begin SCL <= 1'b0; SDA <= CNRL [7];                             State <= State + 1'b1;  end   
            10'd76 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd77 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd78 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // sensorID bit 6                              
            10'd79 :   begin SCL <= 1'b0; SDA <= CNRL [6];                             State <= State + 1'b1;  end   
            10'd80 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd81 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd82 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                        
            // sensorID bit 5                            
           10'd83 :   begin SCL <= 1'b0; SDA <= CNRL [5];                             State <= State + 1'b1;  end   
           10'd84 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd85 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd86 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                              
            // sensorID bit 4                                 
           10'd87 :   begin SCL <= 1'b0; SDA <= CNRL [4];                             State <= State + 1'b1;  end   
           10'd88 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd89 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd90 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // sensorID bit 3                              
           10'd91 :   begin SCL <= 1'b0; SDA <= CNRL [3];                             State <= State + 1'b1;  end   
           10'd92 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd93 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd94 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
            // sensorID bit 2                              
            10'd95 :   begin SCL <= 1'b0; SDA <= CNRL [2];                             State <= State + 1'b1;  end   
            10'd96 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd97 :   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd98 :   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
            // sensorID bit 1                              
            10'd99 :   begin SCL <= 1'b0; SDA <= CNRL [1];                             State <= State + 1'b1;  end   
            10'd100:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd101:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd102:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   
                                                           
              // sensorID bit 0                                          
            10'd103:   begin SCL <= 1'b0; SDA <= CNRL [0];                             State <= State + 1'b1;  end   
            10'd104:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd105:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
            10'd106:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end   

            //ACK
           10'd107:   begin SCL <= 1'b0; SDA<= 1'bz;                                  State <= State + 1'b1;  end   
           10'd108:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end   
           10'd109:   begin SCL <= 1'b1; ACK_bit[2] <=SDA;                            State <= State + 1'b1;  end   
           10'd110:   begin SCL <= 1'b0;                                              State <=  10'd500;  end 
          
          
               //stop 
               
           10'd500:  begin SCL <= 1'b1; SDA <= 0;                                    State <= State + 1'b1;  end     
           10'd501:   begin SCL <= 1'b1; SDA <= 1;                                    State <= State + 1'b1;  end    
                //start
            10'd502:   begin SCL <= 1'b1;   SDA <= 1'b1;                          State <= State + 1'b1;  end      
            10'd503:   begin SCL <= 1'b1;   SDA <= 1'b0;                          State <=  10'd111 ;    end      
//              10'd400  :   begin SCL <= 1'b1;  SDA <= 1'b1;                   State <= State + 1'b1;  end      
//              10'd401  :   begin SCL <= 1'b0;  SDA <= 1'b0;                   State <= 8'd75;         end      
                                                                                                               
                   // sensorID bit 7                    
                                                                             
            10'd111:   begin SCL <= 1'b0;SDA <= Linear_acceleration [6];          State <= State + 1'b1;  end  
            10'd112:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
            10'd113:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
            10'd114:   begin SCL <= 1'b0;                                                      State <= State + 1'b1;  end  
                                                                                                                           
            // sensorID bit 6                                                                                              
            10'd115:   begin SCL <= 1'b0;SDA <= Linear_acceleration [5];          State <= State + 1'b1;  end  
            10'd116:   begin SCL <= 1'b1;                                                               State <= State + 1'b1;  end  
            10'd117:   begin SCL <= 1'b1;                                                               State <= State + 1'b1;  end  
            10'd118:   begin SCL <= 1'b0;                                                               State <= State + 1'b1;  end  
                                                                                                                           
            // sensorID bit 5                                                                                              
           10'd119:   begin SCL <= 1'b0; SDA <= Linear_acceleration [4];         State <= State + 1'b1;  end  
           10'd120:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
           10'd121:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
           10'd122:   begin SCL <= 1'b0;                                                      State <= State + 1'b1;  end  
                                                                                                                           
            // sensorID bit 4                                                                                              
           10'd123:   begin SCL <= 1'b0; SDA <= Linear_acceleration [3];                       State <= State + 1'b1;  end  
           10'd124:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
           10'd125:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
           10'd126:  begin SCL <= 1'b0;                                                        State <= State + 1'b1;  end  
                                                                                                                           
            // sensorID bit 3                                                                                              
            10'd127:   begin SCL <= 1'b0;SDA <= Linear_acceleration [2];                           State <= State + 1'b1;  end  
            10'd128:   begin SCL <= 1'b1;                                                           State <= State + 1'b1;  end  
            10'd129:   begin SCL <= 1'b1;                                                       State <= State + 1'b1;  end  
            10'd130:   begin SCL <= 1'b0;                                                       State <= State + 1'b1;  end  
                                                                                                                           
            // sensorID bit 2                                                                                               
           10'd131:   begin SCL <= 1'b0; SDA <= Linear_acceleration [1];                      State <= State + 1'b1;  end  
           10'd132:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
           10'd133:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
           10'd134:   begin SCL <= 1'b0;                                                      State <= State + 1'b1;  end  
            
            // sensorID bit 1                                                                                              
            10'd135:   begin SCL <= 1'b0; SDA <= Linear_acceleration [0];                      State <= State + 1'b1;  end  
            10'd136:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
            10'd137:   begin SCL <= 1'b1;                                                      State <= State + 1'b1;  end  
            10'd138:   begin SCL <= 1'b0;                                                      State <= State + 1'b1;  end  
                                                                                                                           
            // R/W'                                                                                                        
            10'd139:   begin SCL <= 1'b0;     SDA <= 0;                                          State <= State + 1'b1;  end  
            10'd140:   begin SCL <= 1'b1;                                                        State <= State + 1'b1;  end  
            10'd141:   begin SCL <= 1'b1;                                                        State <= State + 1'b1;  end  
            10'd142:   begin SCL <= 1'b0;                                                        State <= State + 1'b1;  end  
                                                                                                                   
            //ACK                                                                                                  
           10'd143:   begin SCL <= 1'b0;      SDA<= 1'bz;                               State <= State + 1'b1;  end  
           10'd144:   begin SCL <= 1'b1;                                                 State <= State + 1'b1;  end  
           10'd145:   begin SCL <= 1'b1;      ACK_bit[3] <=SDA;                          State <= State + 1'b1;  end  
           10'd146:   begin SCL <= 1'b0;                                                 State <= State +1'b1;  end
           
            
             
          
                                                                                                                
 // sensorID bit 7                                                                                  
                                                                                                    
           10'd147:   begin SCL <= 1'b0;    SDA <= X_axis [7];                      State <= State + 1'b1;  end
           10'd148:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end
           10'd149:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end
           10'd150:   begin SCL <= 1'b0;                                            State <= State + 1'b1;  end
                                                                                                             
            // sensorID bit 6                                                                                
            10'd151:   begin SCL <= 1'b0;   SDA <= X_axis [6];                        State <= State + 1'b1;  end 
            10'd152:   begin SCL <= 1'b1;                                             State <= State + 1'b1;  end 
            10'd153:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end  
            10'd154:   begin SCL <= 1'b0;                                             State <= State + 1'b1;  end 
                                                                                                             
            // sensorID bit 5                                                                                
            10'd155:   begin SCL <= 1'b0;   SDA <= X_axis [5];               State <= State + 1'b1;  end 
            10'd156:   begin SCL <= 1'b1;                                    State <= State + 1'b1;  end 
            10'd157:   begin SCL <= 1'b1;                                   State <= State + 1'b1;  end  
            10'd158:   begin SCL <= 1'b0;                                    State <= State + 1'b1;  end 
                                                                                                             
            // sensorID bit 4                                                                                
            10'd159:   begin SCL <= 1'b0;   SDA <= X_axis [4];                State <= State + 1'b1;  end 
            10'd160:   begin SCL <= 1'b1;                                     State <= State + 1'b1;  end 
            10'd161:   begin SCL <= 1'b1;                                     State <= State + 1'b1;  end  
            10'd162:  begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
                                                                                                             
            // sensorID bit 3                                                                                
            10'd163:   begin SCL <= 1'b0;   SDA <= X_axis [3];                State <= State + 1'b1;  end   
            10'd164:   begin SCL <= 1'b1;                                     State <= State + 1'b1;  end   
            10'd165:   begin SCL <= 1'b1;                                    State <= State + 1'b1;  end    
            10'd166:   begin SCL <= 1'b0;                                     State <= State + 1'b1;  end   
                                                                                                             
            // sensorID bit 2                                                                                
            10'd167:   begin SCL <= 1'b0;   SDA <= X_axis [2];               State <= State + 1'b1;  end 
            10'd168:   begin SCL <= 1'b1;                                    State <= State + 1'b1;  end 
            10'd169:   begin SCL <= 1'b1;                                   State <= State + 1'b1;  end  
            10'd170:   begin SCL <= 1'b0;                                    State <= State + 1'b1;  end 
            // sensorID bit 1                                                                                
            10'd171:   begin SCL <= 1'b0;   SDA <= X_axis [1];               State <= State + 1'b1;  end 
            10'd172:   begin SCL <= 1'b1;                                    State <= State + 1'b1;  end 
            10'd173:   begin SCL <= 1'b1;                                    State <= State + 1'b1;  end  
            10'd174:    begin SCL <= 1'b0;                                     State <= State + 1'b1;  end 
                                                                                                             
            // R/W'                                                                                          
            10'd175:   begin SCL <= 1'b0;     SDA <= X_axis [0];              State <= State + 1'b1;  end 
            10'd176:   begin SCL <= 1'b1;                                     State <= State + 1'b1;  end 
            10'd177:   begin SCL <= 1'b1;                                     State <= State + 1'b1;  end  
            10'd178:   begin SCL <= 1'b0;                                     State <= State + 1'b1;  end 
                                                                                                               
            //ACK                                                                                              
            10'd179:   begin SCL <= 1'b0;     SDA<= 1'bz;                            State <= State + 1'b1;  end   
            10'd180:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end   
            10'd181:   begin SCL <= 1'b1;    ACK_bit[4]<= SDA ;                      State <= State + 1'b1;  end    
            10'd182:   begin SCL <= 1'b0;                                            State <= 10'd504;  end     
                                   
           
            10'd504:   begin SCL <= 1'b1;   SDA <= 1'b1;                          State <= State + 1'b1;  end    
            10'd505:   begin SCL <= 1'b1;   SDA <= 1'b1;                          State <= State + 1'b1;  end  
            10'd506:   begin SCL <= 1'b1;   SDA <= 1'b0;                          State <=  10'd183 ;    end     
                                                                                                       
            
             // sensorID bit 7                    
                                                                             
           10'd183:   begin SCL <= 1'b0; SDA <= Linear_acceleration [6];               State <= State + 1'b1;  end  
           10'd184:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd185:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd186:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end  
                                                                                                                    
            // sensorID bit 6                                                                                       
           10'd187:   begin SCL <= 1'b0; SDA <= Linear_acceleration [5];               State <= State + 1'b1;  end  
           10'd188:   begin SCL <= 1'b1;                                                        State <= State + 1'b1;  end  
           10'd189:   begin SCL <= 1'b1;                                                        State <= State + 1'b1;  end  
           10'd190:   begin SCL <= 1'b0;                                                        State <= State + 1'b1;  end  
                                                                                                                    
            // sensorID bit 5                                                                                       
           10'd191:   begin SCL <= 1'b0; SDA <= Linear_acceleration [4];      State <= State + 1'b1;  end  
           10'd192:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd193:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd194:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end  
                                                                                                                    
            // sensorID bit 4                                                                                       
            10'd195:   begin SCL <= 1'b0;SDA <= Linear_acceleration [3];        State <= State + 1'b1;  end  
            10'd196:   begin SCL <= 1'b1;                                                State <= State + 1'b1;  end  
            10'd197:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
            10'd198:  begin SCL <= 1'b0;                                                 State <= State + 1'b1;  end  
                                                                                                                    
            // sensorID bit 3                                                                                       
           10'd199:   begin SCL <= 1'b0; SDA <= Linear_acceleration [2];       State <= State + 1'b1;  end  
           10'd200:   begin SCL <= 1'b1;                                                State <= State + 1'b1;  end  
           10'd201:   begin SCL <= 1'b1;                                                State <= State + 1'b1;  end  
           10'd202:   begin SCL <= 1'b0;                                                State <= State + 1'b1;  end  
                                                                                                                    
            // sensorID bit 2                                                                                        
           10'd203:   begin SCL <= 1'b0; SDA <= Linear_acceleration [1];      State <= State + 1'b1;  end  
           10'd204:  begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd205:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd206:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end  
            // sensorID bit 1                                                                                       
           10'd207:   begin SCL <= 1'b0; SDA <= Linear_acceleration [0];      State <= State + 1'b1;  end  
           10'd208:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd209:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
           10'd210:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end  
                                                                                                                    
            // R/W'                                                                                                 
            10'd211:   begin SCL <= 1'b0;     SDA <= 1;                            State <= State + 1'b1;  end  
            10'd212:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end  
            10'd213:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end  
            10'd214:   begin SCL <= 1'b0;                                          State <= State + 1'b1;  end  
                                                                                                                   
            //ACK                                                                                                  
           10'd215:   begin SCL <= 1'b0;     SDA<= 1'bz;                          State <= State + 1'b1;  end  
           10'd216:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end  
           10'd217:   begin SCL <= 1'b1;     ACK_bit[5]<=SDA ;                    State <= State + 1'b1;  end  
           10'd218:   begin SCL <= 1'b0;                                          State <= State + 1'b1;  end
            
            
                                                                                                                
 // sensorID bit 7                                                                                  
                                                                                                    
            10'd219:   begin SCL <= 1'b0;     SDA<= 1'bz;                              State <= State + 1'b1;  end
            10'd220:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end
            10'd221:   begin     
                              SCL <= 1'b1;  XSingleByteData1[7] <=SDA;      State <= State + 1'b1; 
//                             if  (byte==2'b10) begin SCL <= 1'b1;  XSingleByteData4[15] <=SDA;     State <= State + 1'b1;  end;    
                       end
            10'd222:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end
                                                                                                               
            // sensorID bit 6                                                                                  
            10'd223:   begin SCL <= 1'b0;     SDA<= 1'bz;                               State <= State + 1'b1;  end 
            10'd224:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end 
            10'd225:   begin SCL <= 1'b1;     XSingleByteData1[6] <=SDA;                State <= State + 1'b1;  end  
            10'd226:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end 
                                                                                                               
            // sensorID bit 5                                                                                  
           10'd227:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
           10'd228:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
           10'd229:   begin SCL <= 1'b1;     XSingleByteData1[5] <=SDA;       State <= State + 1'b1;  end  
           10'd230:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
                                                                                                               
            // sensorID bit 4                                                                                  
           10'd231:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
           10'd232:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
           10'd233:   begin SCL <= 1'b1;      XSingleByteData1[4] <=SDA;        State <= State + 1'b1;  end  
           10'd234:  begin SCL <= 1'b0;                                        State <= State + 1'b1;  end 
                                                                                                               
            // sensorID bit 3                                                                                  
           10'd235:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end   
           10'd236:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end   
           10'd237:   begin SCL <= 1'b1;      XSingleByteData1[3] <=SDA;       State <= State + 1'b1;  end    
           10'd238:   begin SCL <= 1'b0;                                       State <= State + 1'b1;  end   
                                                                                                               
            // sensorID bit 2                                                                                  
           10'd239:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end 
           10'd240:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
           10'd241:   begin SCL <= 1'b1;      XSingleByteData1[2] <=SDA;      State <= State + 1'b1;  end  
           10'd242:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            // sensorID bit 1                                                                                  
           10'd243:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
           10'd244:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
           10'd245:   begin SCL <= 1'b1;     XSingleByteData1[1] <=SDA;        State <= State + 1'b1;  end  
           10'd246:    begin SCL <= 1'b0;                                       State <= State + 1'b1;  end 
                                                                                                               
            // R/W'                                                                                            
           10'd247:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
           10'd248:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
           10'd249:   begin SCL <= 1'b1;      XSingleByteData1[0] <=SDA;        State <= State + 1'b1;  end  
           10'd250:   begin SCL <= 1'b0;      ACK_bit[6]<=0;                   State <= State + 1'b1;  end 
                                                                                                               
            //ACK                                                                                              
           10'd251:   begin SCL <= 1'b0;      SDA<= ACK_bit[6];                        State <= State + 1'b1;  end   
           10'd252:   begin SCL <= 1'b1;                                         State <= State + 1'b1;  end   
           10'd253:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end    
           10'd254:   begin SCL <= 1'b0;                                         State <= State + 1'b1;  end     
                                   
            
            
            
            
             // sensorID bit 7                    
                                                                             
           10'd255:   begin SCL <= 1'b0;     SDA<= 1'bz;                              State <= State + 1'b1;  end  
            10'd256:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd257:   begin SCL <= 1'b1;     XSingleByteData1[15] <=SDA;                State <= State + 1'b1;  end  
            10'd258:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
                                                                                                                   
            // sensorID bit 6                                                                                      
            10'd259:   begin SCL <= 1'b0;     SDA<= 1'bz;                              State <= State + 1'b1;  end  
            10'd260:   begin SCL <= 1'b1;                                                       State <= State + 1'b1;  end  
            10'd261:   begin SCL <= 1'b1;     XSingleByteData1[14] <=SDA;                         State <= State + 1'b1;  end  
            10'd262:   begin SCL <= 1'b0;                                                       State <= State + 1'b1;  end  
            //                                                                                                     
            // sensorID bit 5                                                                                      
            10'd263:   begin SCL <= 1'b0;     SDA<= 1'bz;                     State <= State + 1'b1;  end  
            10'd264:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd265:   begin SCL <= 1'b1;     XSingleByteData1[13] <=SDA;                State <= State + 1'b1;  end  
            10'd266:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
            //                                                                                                      
            /// sensorID bit 4                                                                                      
            10'd267:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end  
            10'd268:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
            10'd269:   begin SCL <= 1'b1;      XSingleByteData1[12]<=SDA;                State <= State + 1'b1;  end  
            10'd270:  begin SCL <= 1'b0;                                                State <= State + 1'b1;  end  
            //                                                                                                      
            /// sensorID bit 3                                                                                      
            10'd271:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end  
            10'd272:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end  
            10'd273:   begin SCL <= 1'b1;      XSingleByteData1[11] <=SDA;                State <= State + 1'b1;  end  
            10'd274:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end  
            //                                                                                                      
            /// sensorID bit 2                                                                                       
            10'd275:   begin SCL <= 1'b0;      SDA<= 1'bz;                    State <= State + 1'b1;  end  
            10'd276:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd277:   begin SCL <= 1'b1;      XSingleByteData1[10] <=SDA;               State <= State + 1'b1;  end  
            10'd278:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
            /// sensorID bit 1                                                                                      
            10'd279:   begin SCL <= 1'b0;     SDA<= 1'bz;                     State <= State + 1'b1;  end  
            10'd280:   begin SCL <= 1'b1;                                              State <= State + 1'b1;  end  
            10'd281:   begin SCL <= 1'b1;     XSingleByteData1[9] <=SDA;                State <= State + 1'b1;  end  
            10'd282:   begin SCL <= 1'b0;                                              State <= State + 1'b1;  end  
            //                                                                                                      
            /// R/W'                                                                                                
            10'd283:   begin SCL <= 1'b0;      SDA<= 1'bz;                        State <= State + 1'b1;  end  
            10'd284:   begin SCL <= 1'b1;                                         State <= State + 1'b1;  end  
            10'd285:   begin SCL <= 1'b1;      XSingleByteData1[8] <=SDA;          State <= State + 1'b1;  end  
            10'd286:   begin SCL <= 1'b0;     ACK_bit[7]<=0;                      State <= State + 1'b1;  end  
            //                                                                                                      
            ///ACK                                                                                                  
            10'd287:   begin SCL <= 1'b0;     SDA<= ACK_bit[7];                          State <= State + 1'b1;  end  
            10'd288:   begin SCL <= 1'b1;    
//            if  (byte ==2'b00)begin
//                             State <= State + 1'b1;
//                             end
//                             else begin
//                             State <= 10'd288; 
//                             end                  
                                                                                   State <= State + 1'b1;  end  
            10'd289:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end  
            10'd290:   begin 
//                            if  (byte ==2'b00)begin
//                             State <= State + 1'b1;
//                             end
//                             else begin
                            
                             SCL <= 1'b0;  ACK_bit[6]<=1;  ACK_bit[7]<=1; State <= State + 1'b1;
//                             State <= 10'd218; 
                            
//                             ACK_bit[6]<=1;
//                             ACK_bit[7]<=1;
//                             end
                             
                        end
            
            
            
//            if (byte ==1'b0)
                                                                                                              
// // sensorID10bit 7                                                                                  
//            //                                                                                       
            10'd291:   begin SCL <= 1'b0;     SDA<= 1'bz;                                   State <= State + 1'b1;  end
            10'd292:   begin SCL <= 1'b1;                                                   State <= State + 1'b1;   end
            10'd293:   begin SCL <= 1'b1;     YSingleByteData2[7] <=SDA;                    State <= State + 1'b1;  end
            10'd294:   begin SCL <= 1'b0;                                                   State <= State + 1'b1;  end
            //                                                                                                  
            // sensorID bit 6                                                                                  
            10'd295:   begin SCL <= 1'b0;     SDA<= 1'bz;                               State <= State + 1'b1;  end 
            10'd296:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end 
            10'd297:   begin SCL <= 1'b1;     YSingleByteData2[6] <=SDA;                State <= State + 1'b1;  end  
            10'd298:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 5                                                                                  
            10'd299:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd300:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd301:   begin SCL <= 1'b1;     YSingleByteData2[5] <=SDA;       State <= State + 1'b1;  end  
            10'd302:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 4                                                                                  
            10'd303:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd304:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd305:   begin SCL <= 1'b1;      YSingleByteData2[4] <=SDA;        State <= State + 1'b1;  end  
            10'd306:  begin SCL <= 1'b0;                                        State <= State + 1'b1;  end 
           //                                                                                                  
           /// sensorID bit 3                                                                                  
            10'd307:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end   
            10'd308:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end   
            10'd309:   begin SCL <= 1'b1;      YSingleByteData2[3] <=SDA;       State <= State + 1'b1;  end    
            10'd310:   begin SCL <= 1'b0;                                       State <= State + 1'b1;  end   
            //                                                                                                  
            /// sensorID bit 2                                                                                  
            10'd311:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end 
            10'd312:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd313:   begin SCL <= 1'b1;      YSingleByteData2[2] <=SDA;      State <= State + 1'b1;  end  
            10'd314:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            // sensorID bit 1                                                                                  
            10'd315:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd316:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd317:   begin SCL <= 1'b1;     YSingleByteData2[1] <=SDA;        State <= State + 1'b1;  end  
            10'd318:    begin SCL <= 1'b0;                                       State <= State + 1'b1;  end 
           //                                                                                                  
           /// R/W'                                                                                            
            10'd319:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd320:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd321:   begin SCL <= 1'b1;      YSingleByteData2[0] <=SDA;        State <= State + 1'b1;  end  
            10'd322:   begin SCL <= 1'b0;       ACK_bit[6]<=0;                   State <= State + 1'b1;  end 
            //                                                                                                   
            ///ACK                                                                                               
            10'd323:   begin SCL <= 1'b0;       SDA<= ACK_bit[6];                  State <= State + 1'b1;  end   
            10'd324:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end   
            10'd325:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end    
            10'd326:   begin SCL <= 1'b0;                                          State <= State + 1'b1;  end     
            
            
            
            10'd327:   begin SCL <= 1'b0;     SDA<= 1'bz;                                   State <= State + 1'b1;  end
            10'd328:   begin SCL <= 1'b1;                                                   State <= State + 1'b1;   end
            10'd329:   begin SCL <= 1'b1;     YSingleByteData2[15] <=SDA;                    State <= State + 1'b1;  end
            10'd330:   begin SCL <= 1'b0;                                                   State <= State + 1'b1;  end
            //                                                                                                  
            // sensorID bit 6                                                                                  
            10'd331:   begin SCL <= 1'b0;     SDA<= 1'bz;                               State <= State + 1'b1;  end 
            10'd332:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end 
            10'd333:   begin SCL <= 1'b1;     YSingleByteData2[14] <=SDA;                State <= State + 1'b1;  end  
            10'd334:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 5                                                                                  
            10'd335:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd336:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd337:   begin SCL <= 1'b1;     YSingleByteData2[13] <=SDA;       State <= State + 1'b1;  end  
            10'd338:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 4                                                                                  
            10'd339:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd340:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd341:   begin SCL <= 1'b1;      YSingleByteData2[12] <=SDA;        State <= State + 1'b1;  end  
            10'd342:  begin SCL <= 1'b0;                                        State <= State + 1'b1;  end 
           //                                                                                                  
           /// sensorID bit 3                                                                                  
            10'd343:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end   
            10'd344:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end   
            10'd345:   begin SCL <= 1'b1;      YSingleByteData2[11] <=SDA;       State <= State + 1'b1;  end    
            10'd346:   begin SCL <= 1'b0;                                       State <= State + 1'b1;  end   
            //                                                                                                  
            /// sensorID bit 2                                                                                  
            10'd347:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end 
            10'd348:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd349:   begin SCL <= 1'b1;      YSingleByteData2[10] <=SDA;      State <= State + 1'b1;  end  
            10'd350:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            // sensorID bit 1                                                                                  
            10'd351:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd352:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd353:   begin SCL <= 1'b1;     YSingleByteData2[9] <=SDA;        State <= State + 1'b1;  end  
            10'd354:    begin SCL <= 1'b0;                                       State <= State + 1'b1;  end 
           //                                                                                                  
           /// R/W'                                                                                            
            10'd355:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd356:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd357:   begin SCL <= 1'b1;      YSingleByteData2[8] <=SDA;        State <= State + 1'b1;  end  
            10'd358:   begin SCL <= 1'b0;       ACK_bit[7]<=0;                   State <= State + 1'b1;  end 
            //                                                                                                   
            ///ACK                                                                                               
            10'd359:   begin SCL <= 1'b0;       SDA<= ACK_bit[7];                  State <= State + 1'b1;  end   
            10'd360:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end   
            10'd361:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end    
            10'd362:   begin SCL <= 1'b0;                                          State <= State + 1'b1;  end    
            
            
            
            
            
            
            10'd363:   begin SCL <= 1'b0;     SDA<= 1'bz;                                   State <= State + 1'b1;  end
            10'd364:   begin SCL <= 1'b1;                                                   State <= State + 1'b1;   end
            10'd365:   begin SCL <= 1'b1;     ZSingleByteData3[7] <=SDA;                    State <= State + 1'b1;  end
            10'd366:   begin SCL <= 1'b0;                                                   State <= State + 1'b1;  end
            //                                                                                                  
            // sensorID bit 6                                                                                  
            10'd367:   begin SCL <= 1'b0;     SDA<= 1'bz;                               State <= State + 1'b1;  end 
            10'd368:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end 
            10'd369:   begin SCL <= 1'b1;     ZSingleByteData3[6] <=SDA;                State <= State + 1'b1;  end  
            10'd370:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 5                                                                                  
            10'd371:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd372:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd373:   begin SCL <= 1'b1;     ZSingleByteData3[5] <=SDA;       State <= State + 1'b1;  end  
            10'd374:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 4                                                                                  
            10'd375:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd376:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd377:   begin SCL <= 1'b1;      ZSingleByteData3[4] <=SDA;        State <= State + 1'b1;  end  
            10'd378:  begin SCL <= 1'b0;                                        State <= State + 1'b1;  end 
           //                                                                                                  
           /// sensorID bit 3                                                                                  
            10'd379:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end   
            10'd380:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end   
            10'd381:   begin SCL <= 1'b1;      ZSingleByteData3[3] <=SDA;       State <= State + 1'b1;  end    
            10'd382:   begin SCL <= 1'b0;                                       State <= State + 1'b1;  end   
            //                                                                                                  
            /// sensorID bit 2                                                                                  
            10'd383:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end 
            10'd384:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd385:  begin SCL <= 1'b1;      ZSingleByteData3[2] <=SDA;      State <= State + 1'b1;  end  
            10'd386:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            // sensorID bit 1                                                                                  
            10'd387:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd388:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd389:   begin SCL <= 1'b1;     ZSingleByteData3[1] <=SDA;        State <= State + 1'b1;  end  
            10'd390:    begin SCL <= 1'b0;                                       State <= State + 1'b1;  end 
           //                                                                                                  
           /// R/W'                                                                                            
            10'd391:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd392:  begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd393:   begin SCL <= 1'b1;      ZSingleByteData3[0] <=SDA;        State <= State + 1'b1;  end  
            10'd394:   begin SCL <= 1'b0;       ACK_bit[6]<=0;                   State <= State + 1'b1;  end 
            //                                                                                                   
            ///ACK                                                                                               
            10'd395:   begin SCL <= 1'b0;       SDA<= ACK_bit[6];                  State <= State + 1'b1;  end   
            10'd396:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end   
            10'd397:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end    
            10'd398:   begin SCL <= 1'b0;                                          State <= State + 1'b1;  end    
            
            
            
            
            
            10'd399:   begin SCL <= 1'b0;     SDA<= 1'bz;                                   State <= State + 1'b1;  end
            10'd400:   begin SCL <= 1'b1;                                                   State <= State + 1'b1;   end
            10'd401:   begin SCL <= 1'b1;     ZSingleByteData3[15] <=SDA;                    State <= State + 1'b1;  end
            10'd402:   begin SCL <= 1'b0;                                                   State <= State + 1'b1;  end
            //                                                                                                  
            // sensorID bit 6                                                                                  
            10'd403:   begin SCL <= 1'b0;     SDA<= 1'bz;                               State <= State + 1'b1;  end 
            10'd404:   begin SCL <= 1'b1;                                               State <= State + 1'b1;  end 
            10'd405:   begin SCL <= 1'b1;     ZSingleByteData3[14] <=SDA;                State <= State + 1'b1;  end  
            10'd406:   begin SCL <= 1'b0;                                               State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 5                                                                                  
            10'd407:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd408:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd409:   begin SCL <= 1'b1;     ZSingleByteData3[13] <=SDA;       State <= State + 1'b1;  end  
            10'd410:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            //                                                                                                  
            /// sensorID bit 4                                                                                  
            10'd411:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd412:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd413:   begin SCL <= 1'b1;      ZSingleByteData3[12] <=SDA;        State <= State + 1'b1;  end  
            10'd414:  begin SCL <= 1'b0;                                        State <= State + 1'b1;  end 
           //                                                                                                  
           /// sensorID bit 3                                                                                  
            10'd415:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end   
            10'd416:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end   
            10'd417:   begin SCL <= 1'b1;      ZSingleByteData3[11] <=SDA;       State <= State + 1'b1;  end    
            10'd418:   begin SCL <= 1'b0;                                       State <= State + 1'b1;  end   
            //                                                                                                  
            /// sensorID bit 2                                                                                  
            10'd419:   begin SCL <= 1'b0;      SDA<= 1'bz;                     State <= State + 1'b1;  end 
            10'd420:  begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd421:   begin SCL <= 1'b1;      ZSingleByteData3[10] <=SDA;      State <= State + 1'b1;  end  
            10'd422:   begin SCL <= 1'b0;                                      State <= State + 1'b1;  end 
            // sensorID bit 1                                                                                  
            10'd423:   begin SCL <= 1'b0;     SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd424:   begin SCL <= 1'b1;                                      State <= State + 1'b1;  end 
            10'd425:   begin SCL <= 1'b1;     ZSingleByteData3[9] <=SDA;        State <= State + 1'b1;  end  
            10'd426:    begin SCL <= 1'b0;                                       State <= State + 1'b1;  end 
           //                                                                                                  
           /// R/W'                                                                                            
            10'd427:   begin SCL <= 1'b0;      SDA<= 1'bz;                      State <= State + 1'b1;  end 
            10'd428:   begin SCL <= 1'b1;                                       State <= State + 1'b1;  end 
            10'd429:   begin SCL <= 1'b1;      ZSingleByteData3[8] <=SDA;        State <= State + 1'b1;  end  
            10'd430:   begin SCL <= 1'b0;       ACK_bit[7]<=0;                   State <= State + 1'b1;  end 
            //                                                                                                   
            ///ACK                                                                                               
            10'd431:   begin SCL <= 1'b0;       SDA<= ACK_bit[7];                  State <= State + 1'b1;  end   
            10'd432:   begin SCL <= 1'b1;                                          State <= State + 1'b1;  end   
            10'd433:   begin SCL <= 1'b1;                                            State <= State + 1'b1;  end    
            10'd434:   begin SCL <= 1'b0;                                          State <= State + 1'b1;  end    
            
            
            10'd435:   begin SCL <= 1'b1;        SDA<= 1'b0;                        State <= State + 1'b1;  end    
            10'd436:   begin SCL <= 1'b1;        SDA<= 1'b1;                        State <= 10'b0;  end    
            
            
            
            
     
                                   
            
            
            
         endcase
         
        
         
     end     
   
    always @(*) begin
    XSingleByteData4 = {XSingleByteData1[15:8], XSingleByteData1[7:0]};
    YSingleByteData5 = {YSingleByteData2[15:8], YSingleByteData2[7:0]};
    ZSingleByteData6= {ZSingleByteData3[15:8], ZSingleByteData3[7:0]};
    end
    
    // OK Interface
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
    
     okWireOut wire21 (  .okHE(okHE),                    
                     .okEH(okEHx[ 1*65 +: 65 ]),     
                     .ep_addr(8'h22),                
                     .ep_datain(ACK_bit[8:0]));      
                     
    okWireOut wire20 (  .okHE(okHE),
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h21),
                        .ep_datain(XSingleByteData1[15:0]));  
    okWireOut wire23 (  .okHE(okHE),
                        .okEH(okEHx[ 2*65 +: 65 ]),
                        .ep_addr(8'h23),
                        .ep_datain(YSingleByteData2[15:0]));   
    okWireOut wire24 (  .okHE(okHE),
                        .okEH(okEHx[ 3*65 +: 65 ]),
                        .ep_addr(8'h24),
                        .ep_datain(ZSingleByteData3[15:0]));                                          
                                      
   okWireOut wire25 (  .okHE(okHE),
                        .okEH(okEHx[ 4*65 +: 65 ]),
                        .ep_addr(8'h25),
                        .ep_datain(XSingleByteData4[15:0])); 
    okWireOut wire26 (  .okHE(okHE),
                        .okEH(okEHx[ 5*65 +: 65 ]),
                        .ep_addr(8'h26),
                        .ep_datain(YSingleByteData5[15:0]));   
     okWireOut wire28 (  .okHE(okHE),
                        .okEH(okEHx[ 7*65 +: 65 ]),
                        .ep_addr(8'h28),
                        .ep_datain(ZSingleByteData6[15:0]));                                              
   
   okWireOut wire27 (  .okHE(okHE),
                        .okEH(okEHx[ 6*65 +: 65 ]),
                        .ep_addr(8'h27),
                        .ep_datain(go));    

    
                        
                        
                        
                                       
endmodule
