module rtc_clock_tb;

parameter int CLK_T = 1000;

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
  .clk_i          ( clk_i          ),
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


initial
  begin
    clk <= '0;
    rst <= '0;
    
    fork
      clk_gen();
    join_none
    
    apply_rst();
    
    $display("Starting testbench!");
    
    
    
    $display("Everything is fine!");
  end


endmodule

