virtual class storing_element;
  protected int initialValue;
  protected string storing_element_type;
  
  function new(int initialValue = 0); 
    this.initialValue = initialValue;
    this.storing_element_type = "Default";
  endfunction 
  
  function void write(int initialValue); 
    this.initialValue = initialValue;
  endfunction  
  
  function int read(); 
    return this.initialValue;
  endfunction  
  
  function void clear();
    this.initialValue = 0;
  endfunction  
  
  virtual function void display_type();
    $display("In storing_element class, type is %s", storing_element_type);
  endfunction
  
  function void set_type(string storing_element_type);
    this.storing_element_type = storing_element_type;
  endfunction
  
  function string get_type();
    return this.storing_element_type;
  endfunction
endclass

class register extends storing_element;
  local static int count;
  
  function new(int initialValue = 0); 
    super.new(initialValue);
    count++;
  endfunction
  
  function void display_type();
    $display("Register Type is %s", storing_element_type);
  endfunction
  
  static function int return_count();
    return count;
  endfunction
endclass

class memory extends storing_element;
  local static int count;
  
  function new(int initialValue = 0); 
    super.new(initialValue);
    count++;
  endfunction
  
  function void display_type();
    $display("Memory Type is %s", storing_element_type);
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
    $display("with value %d", ram.read());
    
    rom.display_type();
    $display("with value %d", rom.read());
    
    instruction.display_type(); 
    $display("with value %d", instruction.read());
    
    address.display_type();
    $display("with value %d", address.read());
  endfunction
  
  function void set_val(int ram_val, rom_val, instr_val, addr_val);
    ram.write(ram_val);
    rom.write(rom_val);
    instruction.write(instr_val);
    address.write(addr_val);
  endfunction
endclass

module tb();
  storing_element se_handle;
  memory mem_instance;
  memory mem_handle;
  
  initial begin
    mem_instance = new(100);
    mem_instance.set_type("RAM");
    
    se_handle = mem_instance;
    
    $display("\nCalling display_type through storing_element handle:");
    se_handle.display_type();
    
    if ($cast(mem_handle, se_handle)) begin
      $display("\nSuccessful cast to memory handle");
      $display("Calling display_type through memory handle:");
      mem_handle.display_type();
    end else begin
      $display("\nCast failed!");
    end
    
    $finish;
  end
endmodule
