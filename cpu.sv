module cpu (
    input logic clk,
    input logic reset,
    input logic cont,
    output logic signed [10:0] out
);
    //Memory stuff:
    logic [6:0] mem_addr;
    logic signed [10:0] mem_data;
    logic mem_we;
    logic signed [10:0] mem_out;

    memory mem(.clk(clk),
               .reset(reset),
               .addr(mem_addr),
               .data(mem_data),
               .write_enable(mem_we),
               .out(mem_out));

    //Since we can't do multiple memory ACCesses in a single state
    typedef enum logic [2:0] { FETCH, LATCH, EXEC, DATA, PAUSE } cpu_state;
    cpu_state state;

    logic [6:0] PC;
    logic [10:0] CIR;
    logic signed [10:0] ACC;

    logic cont_d;

    logic signed [10:0] wrapped_ACC;
    logic [6:0] operand;
    logic [3:0] opcode;
    always_comb begin
        wrapped_ACC = ((ACC + 999) % 1999) - 999;
        opcode = CIR / 100;
        operand = CIR % 100;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
            ACC <= 0;
            state <= FETCH;
            out <= 0;
            cont_d <= 0;
        end else begin
            mem_we <= 0;
            cont_d <= cont;

            case(state)
                FETCH: begin
                    mem_addr <= PC;
                    ACC <= wrapped_ACC;
                    state <= LATCH;
                end

                LATCH: begin
                    CIR <= mem_out;
                    PC <= PC + 1; //Default
                    state <= EXEC;
                end

                EXEC: begin
                    state <= (opcode == 1 || opcode == 2 || opcode == 5) ? DATA : (opcode == 9 ? FETCH : FETCH);
                    mem_addr <= operand;

                    case(opcode)
                        3: begin //STA
                            mem_we <= 1;
                            mem_data <= ACC;
                        end
                        6: PC <= operand;                     //BRA
                        7: PC <= (ACC == 0) ? operand : PC; //BRZ
                        8: PC <= (ACC >= 0) ? operand : PC; //BRP
                        9: out <= ACC;
                    endcase
                end

                DATA: begin
                    case(opcode)
                        1: ACC <= ACC + mem_out; //ADD
                        2: ACC <= ACC - mem_out; //SUB
                        5: ACC <= mem_out; //LDA
                    endcase
                    state <= FETCH;
                end

                PAUSE: begin
                    if(cont && !cont_d)
                        state <= FETCH;
                end
            endcase
        end
    end
endmodule