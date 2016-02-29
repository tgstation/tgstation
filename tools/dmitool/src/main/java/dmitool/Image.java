package dmitool;

import java.io.IOException;
import java.io.OutputStream;

public abstract class Image {
    int w, h;
    
    abstract RGBA getPixel(int x, int y);

    public Image(int w, int h) {
        this.w = w;
        this.h = h;
    }
    
    @Override public boolean equals(Object obj) {
        if(obj == this) return true;
        if(!(obj instanceof Image)) return false;
        
        Image im = (Image) obj;
        
        if(w != im.w || h != im.h) return false;
        
        for(int i=0; i<w; i++) {
            for(int j=0; j<h; j++) {
                if(!getPixel(i, j).equals(im.getPixel(i, j))) return false;
            }
        }
        
        return true;
    }
}