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
    cmd_data_i  <= cmd_data;
    cmd_type_i  <= cmd_type;
    cmd_valid_i <= '1;
    @( posedge clk );
    cmd_data_i  <= '0;
    cmd_valid_i <= '0;
    cmd_type_i  <= '0;
  end
endtask


task automatic check_ms_proc;
  int ms_cntr;
  
  repeat(1002)
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
  
  repeat(62)
    begin
      if( s_cntr++ != seconds_o )
        begin
          $display("Fail! In simple seconds_o");
          $stop();
        end    
        
      if( s_cntr == 60 )
        s_cntr = 0;
      for( int i = 0; i < 1000; i++ )
        @( posedge clk );            
    end
  $display("Seconds simple test - OK!");
endtask


task automatic check_min_proc;
  int min_cntr;
  
  repeat(62)
    begin
      if( min_cntr++ != minutes_o )
        begin
          $display("Fail! In simple minutes_o");
          $stop();
        end    
        
      if( min_cntr == 60 )
        min_cntr = 0;
      for( int i = 0; i < 1000*60; i++)
        @( posedge clk );            
    end
    $display("Minutes simple test - OK!");
endtask


task automatic check_hr_proc;
  int h_cntr;
  
  repeat(26)
    begin
      if( h_cntr++ != hours_o )
        begin
          $display("Fail! In simple hours_o");
          $stop();
        end    
        
      if( h_cntr == 24 )
        h_cntr = 0;
      for( int i = 0; i < (1000*60*60); i++ )
        @( posedge clk );            
    end
    $display("Hours simple test - OK!");
endtask


task automatic check_set_reset;
  bit [4:0] rand_hour;
  bit [5:0] rand_minute;
  bit [5:0] rand_second;
  bit [9:0] rand_millisecond;
  bit [9:0] cmd_data;
  bit [2:0] cmd_type;
  
  $write("Testing hour set - ");
  for( int i = 0; i < 100; i++ )
    begin
      rand_hour = $urandom_range(2**5 - 1, 0);
      cmd_data[9:5] = rand_hour;
      send_cmd(cmd_data, SET_HOURS);
      @( negedge clk );
      @( negedge clk );
      
      if( hours_o != ( rand_hour % 24 ) )
        begin
          $display("Hour didn't setup!");
          $stop();
        end
      cmd_data = 0;
    end
  $display("OK!");
  
  $write("Testing minutes set - ");
  for( int i = 0; i < 100; i++ )
    begin
      rand_minute = $urandom_range(2**6 - 1, 0);
      cmd_data[9:4] = rand_minute;
      send_cmd(cmd_data, SET_MINUTES);
      @( negedge clk );
      @( negedge clk );
      
      if( minutes_o != ( rand_minute % 60 ) )
        begin
          $display("Minutes didn't setup!");
          $stop();
        end
      cmd_data = 0;
    end
  $display("OK!");
  
  $write("Testing seconds set - ");
  for( int i = 0; i < 100; i++ )
    begin
      rand_second = $urandom_range(2**6 - 1, 0);
      cmd_data[9:4] = rand_second;
      send_cmd(cmd_data, SET_SECONDS);
      @( negedge clk );
      @( negedge clk );
      
      if( seconds_o != ( rand_second % 60 ) )
        begin
          $display("Seconds didn't setup!");
          $stop();
        end
      cmd_data = 0;
    end
  $display("OK!");
  
  $write("Testing milliseconds set - ");
  for( int i = 0; i < 100; i++ )
    begin
      rand_millisecond = $urandom_range(2**10 - 1, 0);
      cmd_data = rand_millisecond;
      send_cmd(cmd_data, SET_MILLISECONDS);
      @( negedge clk );      
      @( negedge clk ); 
      
      if( milliseconds_o != ( rand_millisecond % 1000 ) )
        begin
          $display("Milliseconds didn't setup!");
          $stop();
        end
      cmd_data = 0;
    end
  $display("OK!");
  
  $write("Testing reset time - ");
  send_cmd(cmd_data, RESET_TIME);
  @( negedge clk );      
  @( negedge clk ); 
      
  if( milliseconds_o != 0 )
    begin
      $display("Milliseconds didn't reset!");
      $stop();
    end
  else if( seconds_o != 0 )
    begin
      $display("Seconds didn't reset!");
      $stop();
    end
  else if( minutes_o != 0 )
    begin
      $display("Minutes didn't reset!");
      $stop();
    end
  else if( hours_o != 0 )
    begin
      $display("Hours didn't reset!");
      $stop();
    end
  cmd_data = 0;
  
  $display("OK!");
  
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
    
    $display("\n----------------------------------------------");
    $display("Testing normal clock functionning. It might take a couple of minutes!");
    fork
      check_ms_proc();
      check_s_proc();
      check_min_proc();
      check_hr_proc();
    join
    $display("Clock is working!");
    $display("----------------------------------------------");
    
    $display("\nTesting setups and resets");
    fork
      check_set_reset();
    join
    $display("\nSet and reset are working!");
    $display("----------------------------------------------");
    
    $display("\nEverything is fine!");
    $stop();
  end


endmodule

