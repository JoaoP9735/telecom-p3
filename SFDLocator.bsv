import GetPut::*;
import FIFOF::*;
import CommonIfc::*;

module mkSFDLocator(FrameBitProcessor);
    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bool) afterSfd <- mkReg(False);
    FIFOF#(Maybe#(Bit#(1))) outFifo <- mkFIFOF;

    interface Put in;
        method Action put(Maybe#(Bit#(1)) inBit) if (outFifo.notFull);
            if (inBit matches tagged Valid .bitValue) begin
                if (afterSfd) begin
                    outFifo.enq(inBit);
                end
                else begin
                    if (prev == 1'b1 && bitValue == 1'b1) begin
                        afterSfd <= True;
                    end
                    prev <= bitValue;
                end
            end
            else begin
                outFifo.enq(inBit);  
                afterSfd <= False;  
                prev <= 0;          
            end
        endmethod
    endinterface
    
    interface out = toGet(outFifo);
endmodule
