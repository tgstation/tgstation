package dmitool;

public class PalettedImage extends Image {
    int[][] pixels;
    RGBA[] pal;

    public PalettedImage(int w, int h, int[][] pixels, RGBA[] palette) {
        super(w, h);
        this.pixels = pixels;
        this.pal = palette;
    }
    
    RGBA getPixel(int x, int y) {
        return pal[pixels[y][x]];
    }
}