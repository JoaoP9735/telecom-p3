import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkManchesterDecoder(FrameBitProcessor);
    Reg#(Maybe#(Bit#(1))) prev <- mkReg(Invalid);
    Reg#(Bit#(3)) i <- mkReg(0);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) in_bit); // Renomeado 'in' para 'in_bit' para clareza
            if(!isValid(in_bit))
            begin
                i <= 0;
                outFifo.enq(Invalid);
            end
            else if (in_bit matches tagged Valid .x) 
            begin
                let index = i;
                if (prev matches tagged Valid .prev_ &&& x != prev_) begin
                    if (index % 4 == 3) begin
                        index = index + 1;
                    end 
                    else if (index % 4 == 1) begin
                        index = index - 1;
                    end
                    if (index == 4) begin
                        outFifo.enq(Valid(x));
                    end
                end
                i <= index + 1;
            end
            prev <= in_bit;
        endmethod
    endinterface
    interface out = toGet(outFifo);
endmodule
