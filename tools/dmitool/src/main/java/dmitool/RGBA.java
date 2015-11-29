package dmitool;

public class RGBA {
    int r, g, b, a;

    public RGBA(int r, int g, int b, int a) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    @Override
    public String toString() {
        String s = Long.toString(toRGBA8888());
        while(s.length() < 8)
            s = "0" + s;
        return "#" + s;
    }
    
    @Override public boolean equals(Object obj) {
        if(obj == this) return true;
        if(!(obj instanceof RGBA)) return false;
        
        RGBA o = (RGBA) obj;
        
        return r==o.r && g==o.g && b==o.b && a==o.a;
    }
    
    public long toRGBA8888() {
        return (r<<24) | (g<<16) | (b<<8) | a;
    }
}