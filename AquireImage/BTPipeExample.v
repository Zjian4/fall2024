`timescale 1 ps / 1 ps


module BTPipeExample(
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA,
    
    output CVM300_SPI_CLK,  
    output CVM300_SPI_EN,   
    output CVM300_SPI_IN,   
    input  CVM300_SPI_OUT,  
    
    input CVM300_Line_valid,
    input CVM300_Data_valid,
    input [9:0]CVM300_D,
    output CVM300_FRAME_REQ,
    output CVM300_SYS_RES_N,
    input CVM300_CLK_OUT,
    output CVM300_CLK_IN,
    output PMOD_A1,
    output PMOD_A2,
   
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp
    );
    
    wire TrigerEvent; 
    wire [23:0] ClkDivThreshold_SPI = 100; 
    wire [23:0] ClkDivThreshold_CVM = 4;   
    wire spi_clkn;
    wire spi_clkp;
    reg  SPI_FSM;
    wire  CVM_clk;
    reg cvm300_res_n;
    reg cvm300_frame_req;
    reg [23:0] clkdiv_SPI=0;
    reg [23:0] clkdiv_CVM=0;
    wire IN, ON,OUT,s_clk; 
    wire [9:0] State_SPI;
    wire  PC_control;
    wire  start_FIFO;
    wire [6:0]address;
    wire [7:0] writevalue;
    wire [7:0] readvalue;
    wire W_R;
    
    wire okClk;            //These are FrontPanel wires needed to IO communication    
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
        
    //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 1 output endpoints, hence endPt_count = 1.
    localparam  endPt_count = 8;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);    
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 2;   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),
                                      .CVM_clk(CVM_clk),                                      
                                      .ILA_Clk(ILA_Clk) );
                                      
      always @(posedge FSM_Clk) begin
       
        clkdiv_SPI <= clkdiv_SPI + 1'b1;
        if (clkdiv_SPI == ClkDivThreshold_SPI) begin
            SPI_FSM <= ~SPI_FSM;
            clkdiv_SPI <= 0;
        end
    end
    
//    always @(posedge FSM_Clk) begin
       
//        clkdiv_CVM <= clkdiv_CVM + 1'b1;
//        if (clkdiv_CVM == ClkDivThreshold_CVM) begin
//            CVM_clk <= ~CVM_clk;
//            clkdiv_CVM <= 0;
//        end
//    end
                                                                                  
    localparam STATE_INIT                = 8'd0;
    localparam STATE_RESET               = 8'd1;   
    localparam STATE_Wait2               = 8'd7;   
    localparam STATE_DELAY               = 8'd2;
    localparam STATE_RESET_FINISHED      = 8'd3;
    localparam STATE_ENABLE_WRITING      = 8'd4;
    localparam STATE_COUNT               = 8'd5;
    localparam STATE_FINISH              = 8'd6;
   
    reg [31:0] counter = 8'd0;
    reg [15:0] counter_delay = 16'd0;
    reg [15:0] counter_start =16'd0;
    reg [15:0] counter_SPI=16'd0;
    reg [15:0] counter_FRAME=16'd0;
    reg [7:0] State = STATE_INIT;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg, write_enable_counter;  
    reg write_reset, read_reset, write_enable;
    
    wire [31:0] Reset_Counter;
    wire[1:0] motor_line;
    wire [31:0] DATA_Counter;    
    wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
    wire [31:0] FIFO_data_out;
    
    
    assign led[0] = ~FIFO_empty; 
    assign led[1] = ~FIFO_full;
    assign led[2] = ~FIFO_BT_BlockSize_Full;
    assign led[3] = ~FIFO_read_enable;  
    assign led[7] = ~read_reset;
    assign led[6] = ~write_reset;
    
    assign TrigerEvent = PC_control;   
    assign OUT =CVM300_SPI_OUT;
    assign  spi_clkp=sys_clkp;
    assign spi_clkn = sys_clkn;
    assign CVM300_CLK_IN = CVM_clk;
    assign CVM300_SYS_RES_N = cvm300_res_n;
    assign CVM300_FRAME_REQ =cvm300_frame_req;
    //Instantiate the module that we like to test
    SPI SPI_1 (        
        .SPI_FSM(SPI_FSM),  
//        .sys_clkn( spi_clkn),           
//        .sys_clkp(spi_clkp),            
        .SPI_CLK_0(CVM300_SPI_CLK),           
        .SPI_EN_0(CVM300_SPI_EN),            
        .SPI_IN_0(CVM300_SPI_IN),            
        .SPI_OUT_0(CVM300_SPI_OUT),           
        .address(address),      
        .W_R( W_R),            
        .writevalue(writevalue),     
        .readvalue(readvalue), 
        .State(State_SPI),           
//        .FSM_Clk_reg(FSM_Clk) ,     
//        .ILA_Clk_reg (ILA_Clk),        
        .PC_control (PC_control),          
        .s_clk (s_clk),
        .IN(IN), 
        .OUT(OUT),
        .ON(ON)          
   
            
        );    
        
        
     motor_control motor(
     .PMOD_A1(PMOD_A1),
        .PMOD_A2(PMOD_A2),
        .CLK(CVM_clk),
//     
        .go(motor_line)
//        .led(led)
     
     
     );          
    initial begin
        write_reset <= 1'b0;
        read_reset <= 1'b0;
        write_enable <= 1'b1;
            
    end
    
   
                                         
    always @(posedge CVM_clk) begin     
//                 
         if (PC_control == 1'b1) State <= STATE_INIT; 
        
        case (State)
            
           
         
            STATE_INIT:   begin                              
                write_enable <= 1'b0;
                cvm300_frame_req =1'b0;
                
                if (start_FIFO == 1'b1) State <= STATE_RESET;                
            end
            
            STATE_RESET:   begin
                counter <= 0;
                counter_delay <= 0;
                write_reset <= 1'b1;
                read_reset <= 1'b1;  
                            
                if (start_FIFO == 1'b0) State <= STATE_Wait2;             
            end                                     
            
            STATE_Wait2: begin
              if (counter_delay == 16'b0000_0000_0000_0001)  State <= STATE_RESET_FINISHED;
                else counter_delay <= counter_delay + 1;
            end
           STATE_RESET_FINISHED:   begin
                write_reset <= 1'b0;
                read_reset <= 1'b0;  
                counter_delay <= 0;               
                State <= STATE_DELAY;                                   
            end   
                          
            STATE_DELAY:   begin
                if (counter_delay == 16'b0000_1111_1111_1111)  State <= STATE_ENABLE_WRITING;
                else counter_delay <= counter_delay + 1;
            end
            
             STATE_ENABLE_WRITING:   begin
                cvm300_frame_req =1'b1;
                //CVM_FRAM_REQ <= 1
                State <= STATE_COUNT;
             end
                                  
             STATE_COUNT:   begin
//                write_enable <= 0; 
                   
                counter <= counter+1;     
                State <= STATE_INIT;
             end

        endcase
    end    
       
    fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
        .wr_clk(~CVM300_CLK_OUT),
        .wr_rst(write_reset),
        .rd_clk(okClk),
        .rd_rst(read_reset),
        .din(CVM300_D[9:2]),
        .wr_en(CVM300_Data_valid),
        .rd_en(FIFO_read_enable),
        .dout(FIFO_data_out),
        .full(FIFO_full),
        .empty(FIFO_empty),       
        .prog_full(FIFO_BT_BlockSize_Full)        
    );
     ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State}),                             
        .probe1({FSM_Clk, TrigerEvent}),
        .probe2({CVM_clk}),
        .probe3 ({IN,OUT,ON})
        );                        
      
    okBTPipeOut CounterToPC (
        .okHE(okHE), 
        .okEH(okEHx[ 0*65 +: 65 ]),
        .ep_addr(8'ha0), 
        .ep_datain({FIFO_data_out[7:0],FIFO_data_out[15:8],FIFO_data_out[23:16],FIFO_data_out[31:24]}), 
        .ep_read(FIFO_read_enable),
        .ep_blockstrobe(BT_Strobe), 
        .ep_ready(FIFO_BT_BlockSize_Full)
    );                                      
    
   
                        
                        

    
    
                     
    okWireOut wire20 (  .okHE(okHE),
                        .okEH(okEHx[ 3*65 +: 65 ]),
                        .ep_addr(8'h20),
                        .ep_datain(readvalue));  
    
                               

     okWireIn wire10 (   .okHE(okHE), 
                        .ep_addr(8'h00), 
                        .ep_dataout(motor_line));  

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
        okWireIn wire5 (   .okHE(okHE), 
                        .ep_addr(8'h05), 
                        .ep_dataout(start_FIFO)); 
                                      
                                                   
endmodule
