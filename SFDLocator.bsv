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
                    // After SFD found, just pass through all valid bits
                    outFifo.enq(inBit);
                end
                else begin
                    // Check for SFD pattern (looking for '11' at the end)
                    if (prev == 1'b1 && bitValue == 1'b1) begin
                        // Found the end of SFD (10101011)
                        afterSfd <= True;
                    end
                    prev <= bitValue;
                end
            end
            else begin
                // Invalid bit (end of frame marker)
                outFifo.enq(inBit);  // Pass through the invalid marker
                afterSfd <= False;    // Reset for next frame
                prev <= 0;           // Reset previous bit
            end
        endmethod
    endinterface
    
    interface out = toGet(outFifo);
endmodule
