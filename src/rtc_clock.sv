module rtc_clock (
  input              clk_i,
  input              srst_i,
  
  input              cmd_valid_i,
  input        [2:0] cmd_type_i,  
  input        [9:0] cmd_data_i,
  
  output logic [4:0] hours_o,
  output logic [5:0] minutes_o,
  output logic [5:0] seconds_o,
  output logic [9:0] milliseconds_o
);


localparam logic [2:0] SET_HOURS        = 3'b111;
localparam logic [2:0] SET_MINUTES      = 3'b110;
localparam logic [2:0] SET_SECONDS      = 3'b101;
localparam logic [2:0] SET_MILLISECONDS = 3'b011;
localparam logic [2:0] RESET_TIME       = 3'b010;

logic milliseconds_overflow;
logic seconds_overflow;
logic minutes_overflow;

logic [9:0] cmd_data_reg;
logic reset_cmd;
logic set_ms_cmd;
logic set_sec_cmd;
logic set_min_cmd;
logic set_hour_cmd;

always_ff @( posedge clk_i )
  begin
    if( cmd_valid_i )
      begin
        cmd_data_reg <= cmd_data_i;
        case( cmd_type_i )
          SET_HOURS:        set_hour_cmd <= '1;
          SET_MINUTES:      set_min_cmd  <= '1;
          SET_SECONDS:      set_sec_cmd  <= '1;
          SET_MILLISECONDS: set_ms_cmd   <= '1;
          RESET_TIME:       reset_cmd    <= '1;
        endcase
      end
    else
      begin
        set_ms_cmd   <= '0;
        set_sec_cmd  <= '0;
        set_min_cmd  <= '0;
        set_hour_cmd <= '0;
        reset_cmd    <= '0;
      end
  end

// hours_o
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        hours_o <= '0;
      end
    else if( reset_cmd )
      begin
        hours_o <= '0;
      end
    else if( set_hour_cmd )
      begin
        if( cmd_data_reg[9:5] > 5'd23 )
          hours_o <= ( cmd_data_reg[9:5] % 5'd24 );
        else
          hours_o <= cmd_data_reg[9:5];
      end
    else if( minutes_overflow )
      begin
        if( hours_o == 5'd23 )
          hours_o <= '0;
        else
          hours_o <= hours_o + 1'b1;
      end
  end

// minutes_o
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        minutes_o <= '0;
      end
    else if( reset_cmd )
      begin
        minutes_o <= '0;
      end
    else if( set_min_cmd )
      begin
        if( cmd_data_reg[9:4] > 6'd59 )
          minutes_o <= ( cmd_data_reg[9:4] % 6'd59 );
        else
          minutes_o <= cmd_data_reg[9:4];
      end
    else if( seconds_overflow )
      begin
        if( minutes_o == 6'd59 )
          begin
            minutes_overflow <= '1;
            minutes_o        <= '0;
          end
        else
          begin
            minutes_overflow <= '0;
            minutes_o        <= minutes_o + 1'b1;
          end
      end
  end

// seconds_o
always_ff @( posedge clk_i )
  begin  
    if( srst_i )
      begin
        seconds_o <= '0;
      end
    else if( reset_cmd )
      begin
        seconds_o <= '0;
      end
    else if( set_sec_cmd )
      begin
        if( cmd_data_reg[9:4] > 6'd59 )
          seconds_o <= ( cmd_data_reg[9:4] % 6'd59 );
        else
          seconds_o <= cmd_data_reg[9:4];
      end
    else if( milliseconds_overflow )
      begin
        if( seconds_o == 6'd59)
          begin
            seconds_overflow <= '1;
            seconds_o        <= '0;
          end
        else
          begin
            seconds_overflow <= '0;
            seconds_o        <= seconds_o + 1'b1;
          end
      end
  end

  

// milliseconds_o
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        milliseconds_o <= '0;
      end
    else if( reset_cmd )
      begin
        milliseconds_o <= '0;
      end
    else if( set_ms_cmd )
      begin
        if( cmd_data_reg > 10'd999 )
          milliseconds_o <= ( cmd_data_reg % 10'd1000 );
        else
          milliseconds_o <= cmd_data_reg;
      end
    else
      begin        
        if( milliseconds_o == 10'd999 )
          begin
            milliseconds_overflow <= '1;
            milliseconds_o        <= '0;
          end
        else
          begin
            milliseconds_overflow <= '0;
            milliseconds_o        <= milliseconds_o + 1'b1;
          end
      end
  end



endmodule
