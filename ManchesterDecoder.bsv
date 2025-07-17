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
            // MUDANÇA 1: Usamos 'if matches' para definir 'x' com o valor de entrada.
            else if (in_bit matches tagged Valid .x) 
            begin
                let index = i;
                // 'prev' é lido aqui antes de ser atualizado no fim do método
                if (prev matches tagged Valid .prev_ &&& x != prev_) begin
                    if (index % 4 == 3) begin
                        index = index + 1;
                    end 
                    else if (index % 4 == 1) begin
                        index = index - 1;
                    end
                    // MUDANÇA 2: Corrigida a lógica. O meio do símbolo é em 4.
                    if (index == 4) begin
                        outFifo.enq(Valid(x));
                    end
                end
                i <= index + 1;
            end
            // MUDANÇA 3: 'prev' é atualizado no final para a próxima chamada.
            prev <= in_bit;
        endmethod
    endinterface
    interface out = toGet(outFifo);
endmodule