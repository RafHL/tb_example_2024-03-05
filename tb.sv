`timescale 1ns/10ps

module tb;

    reg CLK;
    reg [9:0] SW;
    integer loc;

    top dut (
        .CLK_50(CLK),
        .LED(),
        .SW(SW)
    );

    integer file, file_out, gold_out;

    always begin
        #1 CLK <= 0;
        #1 CLK <= 1;
    end

    task drive;
        input integer file_out;
        input         fault;
        input [6:0]   fault_loc;
        begin
            SW[9]   = fault;
            SW[6:0] = fault_loc;

            // Skip 22 clocks
            #44;

            // Save output value
            $fwrite(file_out, "%h\n", dut.out);
        end
    endtask


    initial begin
        gold_out=$fopen("ciphertexts.txt");
        file_out=$fopen("ciphertexts_faults.txt");
        $dumpfile("tb.vcd");
        $dumpvars(0,tb);

        for (loc = 0; loc < 128; loc = loc + 1) begin
            drive(
                gold_out, // Output file
                1'b0,     // Fault
                loc[6:0]  // Bit for the fault to occur
            );
            drive(
                file_out, // Output file
                1'b1,     // Fault
                loc[6:0]  // Bit for the fault to occur
            );
        end

        $fclose(gold_out);
        $fclose(file_out);
        #30 $finish;
    end
endmodule
