module rtc_clock_tb;

parameter int CLK_T = 1000;


localparam logic [2:0] SET_HOURS        = 3'b111;
localparam logic [2:0] SET_MINUTES      = 3'b110;
localparam logic [2:0] SET_SECONDS      = 3'b101;
localparam logic [2:0] SET_MILLISECONDS = 3'b011;
localparam logic [2:0] RESET_TIME       = 3'b010;


logic       clk;
logic       rst;

logic       cmd_valid_i;
logic [2:0] cmd_type_i; 
logic [9:0] cmd_data_i;

logic [4:0] hours_o;
logic [5:0] minutes_o;
logic [5:0] seconds_o;
logic [9:0] milliseconds_o;


rtc_clock 
  rtc_clock_1     (
  .clk_i          ( clk            ),
  .srst_i         ( rst            ),
  
  .cmd_valid_i    ( cmd_valid_i    ),
  .cmd_type_i     ( cmd_type_i     ),
  .cmd_data_i     ( cmd_data_i     ),
  
  .hours_o        ( hours_o        ),
  .minutes_o      ( minutes_o      ),
  .seconds_o      ( seconds_o      ),
  .milliseconds_o ( milliseconds_o )
);


task automatic clk_gen;

  forever
    begin
      # ( CLK_T / 2 );
      clk <= ~clk;
    end
  
endtask


task automatic apply_rst;
  
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;
  @( posedge clk );

endtask


task automatic send_cmd;
  input [9:0] cmd_data;
  input [2:0] cmd_type;
  
  begin
    cmd_data_i <= cmd_data;
    cmd_type_i <= cmd_type;
    cmd_data_i <= '1;
    @( posedge clk );
    cmd_data_i <= '1;
    cmd_data_i <= '0;
    cmd_type_i <= '0;
  end
endtask


task automatic check_ms_proc;
  int ms_cntr;
  
  repeat(1000)
    begin
      if( ms_cntr++ != milliseconds_o )
        begin
          $display("Fail! In simple milliseconds_o");
          $stop();
        end    
        
      if( ms_cntr == 1000 )
        ms_cntr = 0;
        
      @( posedge clk );            
    end
  $display("Milliseconds simple test - OK!");


endtask


task automatic check_s_proc;
  int s_cntr;
  
  repeat(1000*60)
    begin
      if( s_cntr++ != seconds_o )
        begin
          $display("Fail! In simple seconds_o");
          $stop();
        end    
        
      if( s_cntr == 1000*60 )
        s_cntr = 0;
        
      @( posedge clk );            
    end
  $display("Seconds simple test - OK!");
endtask


task automatic check_min_proc;
  int min_cntr;
  
  repeat(1000*60*60)
    begin
      if( min_cntr++ != minutes_o )
        begin
          $display("Fail! In simple minutes_o");
          $stop();
        end    
        
      if( min_cntr == 1000*60*60 )
        min_cntr = 0;
        
      @( posedge clk );            
    end
    $display("Minutes simple test - OK!");
endtask


task automatic check_hr_proc;
  int h_cntr;
  
  repeat(1000*60*60*24)
    begin
      if( h_cntr++ != hours_o )
        begin
          $display("Fail! In simple hours_o");
          $stop();
        end    
        
      if( h_cntr == 1000*60*60*24 )
        h_cntr = 0;
        
      @( posedge clk );            
    end
    $display("Hours simple test - OK!");
endtask


initial
  begin
    clk <= '0;
    rst <= '0;
    
    fork
      clk_gen();
    join_none
    
    apply_rst();
    
    $display("Starting testbench!");
    fork
      check_ms_proc();
      check_s_proc();
      check_min_proc();
      check_hr_proc();
    join
    
    
    $display("Everything is fine!");
  end


endmodule

