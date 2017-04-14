package dmitool;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

public class PNGChunk {
    int len;
    int type;
    byte[] b;
    int crc;

    public PNGChunk(DataInputStream in) throws IOException {
        len = in.readInt();
        type = in.readInt();
        b = new byte[len];
        in.read(b);
        crc = in.readInt();
    }
    
    void write(DataOutputStream out) throws IOException {
        out.writeInt(len);
        out.writeInt(type);
        out.write(b);
        out.writeInt(crc);
    }
}