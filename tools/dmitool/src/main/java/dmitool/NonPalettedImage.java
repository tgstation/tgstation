package dmitool;

public class NonPalettedImage extends Image {
    RGBA[][] pixels;
    
    public NonPalettedImage(int w, int h, RGBA[][] pixels) {
        super(w, h);
        this.pixels = pixels;
    }
    
    RGBA getPixel(int x, int y) {
        return pixels[y][x];
    }
}