
module randomization;

  logic [7:0] randomData;

  initial begin
        integer seed;
    if (!$value$plusargs("SEED=%d", seed)) seed = $urandom;
    $srandom(seed);
    $display("Seed used: %0d", seed);
    $display();
    $display("Randomization for numbers 80-135 even");
    $display();

    repeat (10)begin
        if (randomize(randomData) with {
          randomData inside {[81:134]};
                randomData % 2 == 0;
                }) begin
                        $display("Random = %d", randomData);
                        end
        else begin
                        $display("Randomization failed");
        end
    end

    $display();
    $display("Randomization for letters A-Z");
    $display();

    repeat (10)begin
        if (randomize(randomData) with {
                randomData inside {[8'h41:8'h5a]};
                })      begin
                                $display("Random = %c", randomData);
                        end
        else begin
                        $display("Randomization failed");
        end
    end

    $display();
    $display("Randomization for numbers 0-9 in ASCII");
    $display();

    repeat (10)begin
        if (randomize(randomData) with {
                randomData inside {[8'h30:8'h39]};
                })      begin
                                $display("Random = %c", randomData);
                        end
        else begin
                        $display("Randomization failed");
        end
    end


    $display();
    $display("Randomization for 80 UPPER 20 LOWER ASCII");
    $display();

    repeat (10)begin
        if (randomize(randomData) with {
          randomData dist{
            [8'h41:8'h5a]:=4,
            [8'h61:8'h7a]:=1
          };
        })
                begin
                        $display("Random = %c", randomData);
                end
        else begin
                 $display("Randomization failed");
        end


    end

  end

endmodule
