class storing_element;

  protected int initialValue;
  
  
  function new (int initialValue = 0); 
    this.initialValue = initialValue;
  endfunction 
  
  
  
  function void write (int initialValue); 
    this.initialValue = initialValue;
  endfunction  
  
  
  function int read (); 
    return this.initialValue;
  endfunction
  
  
  function void clear ();
    this.initialValue = 0;
  endfunction  
  
  
  
  
endclass




class register extends storing_element;

  local string register_type;
  local static int count;
  
  
  function new (int initialValue = 0); 
    super.new(initialValue);
    count++;
  endfunction
  
  function void set_type(string register_type);
    this.register_type=register_type;
  endfunction
  
  function void display_type();
    $display ("Register Type is %s",register_type);
  endfunction
  
  
  static function int return_count();
    return count;
  endfunction

endclass



class memory extends storing_element;

  local string memory_type;
  local static int count;
  
  
  function new (int initialValue = 0); 
    super.new(initialValue);
    count++;
  endfunction
  
  function void set_type(string memory_type);
    this.memory_type=memory_type;
  endfunction
  
  function void display_type();
    $display ("Memory Type is %s",memory_type);
  endfunction
  
  static function int return_count();
    return count;
  endfunction

endclass



class processor;
  
  local memory ram, rom;
  local register instruction, address;
  
  
  function new(int ram_prop=0, int rom_prop=0, int inst_prop=0, int address_prop=0);
    ram = new(ram_prop);
    rom = new(rom_prop);
    instruction = new(inst_prop);
    address = new(address_prop);
    ram.set_type("RAM");
    rom.set_type("ROM");
    instruction.set_type("Instruction REG");
    address.set_type("Address REG");
  endfunction
  
  
  function void show();
    
    
    ram.display_type();
    $display ("with value %d", ram.read());
    
    rom.display_type();
    $display ("with value %d", rom.read());
    
    instruction.display_type(); 
    $display ("with value %d", instruction.read());
    
    address.display_type();
    $display ("with value %d",  address.read());
  endfunction
  
  function void set_val(int ram_val, rom_val, instr_val, addr_val);
    ram.write(ram_val);
    rom.write(rom_val);
    instruction.write(instr_val);
    address.write(addr_val);
  endfunction
  
  
endclass



module tb();


  storing_element SE;
  register R, RR, RRR;
  memory M, MM;
  processor P;  
  processor P2;

  initial begin

    SE = new(3);
    display_SE();
    
    SE.clear();
    display_SE();
    
    SE.write(77);
    display_SE();

    R = new(5);
    display_R();
    
    R.set_type("PC");
    R.display_type();
    
    R.set_type("PC+1");
    R.display_type();
    

    M = new(10);
    display_M();
    
    M.set_type("RAM");
    M.display_type();
    

    MM = new();
    RR = new();
    RRR = new();
    
    display_R_count();
    display_M_count();
    
    $display();
    $display("Testing Processor Class");
    $display();
    

    P = new(100, 200, 300, 400);
    $display("Processor initial state:");
    P.show();
    
  
    $display("\nUpdating processor values to 500, 600, 700, 800:");
    P.set_val(500, 600, 700, 800);
    $display("Processor state after update:");
    P.show();
    
    
    $display("\nClearing RAM and Instruction via write (simulating clear):");
    P.set_val(0, 600, 0, 800); 
    P.show();
    

    P2 = new();  
    $display("\nSecond processor instance (defaults):");
    P2.show();
    

    display_R_count(); 
    display_M_count(); 
    
    $finish;
  end
  
  task display_SE();
    $display("storing_element value: %d", SE.read());
  endtask
  
  task display_R();
    $display("register value: %d", R.read());
  endtask
  
  task display_M();
    $display("memory value: %d", M.read());
  endtask
  
  task display_M_count();
    $display("Number of created Memory Objects: %d", memory::return_count());
  endtask
  
  task display_R_count();
    $display("Number of created Register Objects: %d", register::return_count());
  endtask
  
endmodule





