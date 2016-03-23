package dmitool;

import java.util.Arrays;
import ar.com.hjg.pngj.ImageInfo;
import ar.com.hjg.pngj.ImageLineInt;
import ar.com.hjg.pngj.PngWriter;
import ar.com.hjg.pngj.PngReader;
import ar.com.hjg.pngj.PngjInputException;
import java.io.InputStream;
import java.io.OutputStream;

public class IconState {
    String name;
    int dirs;
    int frames;
    float[] delays;
    Image[] images; // dirs come first
    boolean rewind;
    int loop;
    String hotspot;
    boolean movement;

    public String getInfoLine() {
        String extraInfo = "";
        if(rewind) extraInfo += " rewind";
        if(frames != 1) {
            extraInfo += " loop(" + (loop==-1 ? "infinite" : loop) + ")";
        }
        if(hotspot != null) extraInfo += " hotspot('" + hotspot + "')";
        if(movement) extraInfo += " movement";
        if(extraInfo.equals("")) {
            return String.format("state \"%s\", %d dir(s), %d frame(s)", name, dirs, frames);
        } else {
            return String.format("state \"%s\", %d dir(s), %d frame(s),%s", name, dirs, frames, extraInfo);
        }
    }
    
    @Override public IconState clone() {
        IconState is = new IconState(name, dirs, frames, images.clone(), delays==null ? null : delays.clone(), rewind, loop, hotspot, movement);
        is.delays = delays != null ? delays.clone() : null;
        is.rewind = rewind;
        
        return is;
    }

    public IconState(String name, int dirs, int frames, Image[] images, float[] delays, boolean rewind, int loop, String hotspot, boolean movement) {
        if(delays != null) {
            if(Main.STRICT && delays.length != frames) {
                throw new IllegalArgumentException("Delays and frames must be the same length!");
            }
        }
        this.name = name;
        this.dirs = dirs;
        this.frames = frames;
        this.images = images;
        this.rewind = rewind;
        this.loop = loop;
        this.hotspot = hotspot;
        this.delays = delays;
        this.movement = movement;
    }
    void setDelays(float[] delays) {
        this.delays = delays;
    }
    void setRewind(boolean b) {
        rewind = b;
    }
    @Override public boolean equals(Object obj) {
        if(obj == this) return true;
        if(!(obj instanceof IconState)) return false;
        
        IconState is = (IconState)obj;
        
        if(!is.name.equals(name)) return false;
        if(is.dirs != dirs) return false;
        if(is.frames != frames) return false;
        if(!Arrays.equals(images, is.images)) return false;
        if(is.rewind != rewind) return false;
        if(is.loop != loop) return false;
        if(!Arrays.equals(delays, is.delays)) return false;
        if(!(is.hotspot == null ? hotspot == null : is.hotspot.equals(hotspot))) return false;
        if(is.movement != movement) return false;
        
        return true;
    }
    public String infoStr() {
        return "[" + frames + " frame(s), " + dirs + " dir(s)]";
    }
    public String getDescriptorFragment() {
        String s = "";
        String q = "\"";
        String n = "\n";
        s += "state = " + q + name + q + n;
        s += "\tdirs = " + dirs + n;
        s += "\tframes = " + frames + n;
        if(delays != null) {
            s += "\tdelay = " + delayArrayToString(delays) + n;
        }
        if(rewind) {
            s += "\trewind = 1\n";
        }
        if(loop != -1) {
            s += "\tloop = " + loop + n;
        }
        if(hotspot != null) {
            s += "\thotspot = " + hotspot + n;
        }
        if(movement) {
            s += "\tmovement = 1\n";
        }
        return s;
    }
    
    private static String delayArrayToString(float[] d) {
        String s = "";
        for(float f: d) {
            s += ","+f;
        }
        return s.substring(1);
    }
    
    /**
    * Dump the state to the given OutputStream in PNG format. Frames will be dumped along the X axis of the image, and directions will be dumped along the Y.
    */
    public void dumpToPNG(OutputStream outS, int minDir, int maxDir, int minFrame, int maxFrame) {
        int totalDirs = maxDir - minDir + 1;
        int totalFrames = maxFrame - minFrame + 1;
        
        int w = images[minDir + minFrame * this.dirs].w;
        int h = images[minDir + minFrame * this.dirs].h;
        
        if(Main.VERBOSITY > 0) System.out.println("Writing " + totalDirs + " dir(s), " + totalFrames + " frame(s), " + totalDirs*totalFrames + " image(s) total.");
        ImageInfo ii = new ImageInfo(totalFrames * w, totalDirs * h, 8, true);
        PngWriter out = new PngWriter(outS, ii);
        out.setCompLevel(9);
        
        Image[][] img = new Image[totalFrames][totalDirs];
        {
            for(int i=0; i<totalFrames; i++) {
                for(int j=0; j<totalDirs; j++) {
                    img[i][j] = images[(minDir+j) + (minFrame+i) * this.dirs];
                }
            }
        }
        
        for(int imY=0; imY<totalDirs; imY++) {
            for(int pxY=0; pxY<h; pxY++) {
                ImageLineInt ili = new ImageLineInt(ii);
                int[] buf = ili.getScanline();
                for(int imX=0; imX<totalFrames; imX++) {
                    Image i = img[imX][imY];
                    for(int pxX=0; pxX<w; pxX++) {
                        RGBA c = i.getPixel(pxX, pxY);
                        buf[(imX*w + pxX)*4    ] = c.r;
                        buf[(imX*w + pxX)*4 + 1] = c.g;
                        buf[(imX*w + pxX)*4 + 2] = c.b;
                        buf[(imX*w + pxX)*4 + 3] = c.a;
                    }
                }
                out.writeRow(ili);
            }
        }
        out.end();
    }
    
    public static IconState importFromPNG(DMI dmi, InputStream inS, String name, float[] delays, boolean rewind, int loop, String hotspot, boolean movement) throws DMIException {
        int w = dmi.w;
        int h = dmi.h;
        
        PngReader in;
        try {
            in = new PngReader(inS);
        } catch(PngjInputException pie) {
            throw new DMIException("Bad file format!", pie);
        }
        int pxW = in.imgInfo.cols;
        int pxH = in.imgInfo.rows;
        int frames = pxW / w; //frames are read along the X axis, dirs along the Y, much like export.
        int dirs = pxH / h;
        
        // make sure the size is an integer multiple
        if(frames * w != pxW || frames==0) throw new DMIException("Illegal image size!");
        if(dirs * h != pxH || dirs==0) throw new DMIException("Illegal image size!");
        
        int[][] px = new int[pxH][];
        for(int i=0; i<pxH; i++) {
            ImageLineInt ili = (ImageLineInt)in.readRow();
            int[] sl = ili.getScanline();
            px[i] = sl.clone();
        }
        
        Image[] images = new Image[frames*dirs];
        for(int imageY=0; imageY<dirs; imageY++) {
            for(int imageX=0; imageX<frames; imageX++) {
                RGBA[][] pixels = new RGBA[h][w];
                for(int pixelY=0; pixelY<h; pixelY++) {
                    for(int pixelX=0; pixelX<w; pixelX++) {
                        int bY = imageY*h + pixelY;
                        int bX = imageX*4*w + 4*pixelX;
                        pixels[pixelY][pixelX] = new RGBA(px[bY][bX    ],
                                                          px[bY][bX + 1],
                                                          px[bY][bX + 2],
                                                          px[bY][bX + 3]);
                    }
                }
                images[_getIndex(imageY, imageX, dirs)] = new NonPalettedImage(w, h, pixels);
            }
        }
        
        //public IconState(String name, int dirs, int frames, Image[] images, float[] delays, boolean rewind, int loop, String hotspot, boolean movement) {
        return new IconState(name, dirs, frames, images, delays, rewind, loop, hotspot, movement);
        
    }
    
    //Converts a desired dir and frame to an index into the images array.
    public int getIndex(int dir, int frame) {
        return _getIndex(dir, frame, dirs);
    }
    
    private static int _getIndex(int dir, int frame, int totalDirs) {
        return dir + frame*totalDirs;
    }
    
    public void insertDir(int dir, Image[] splice) {
        int maxFrame = frames < splice.length? frames: splice.length;
        for(int frameIdx = 0; frameIdx < maxFrame; frameIdx++) {
            insertImage(dir, frameIdx, splice[frameIdx]);
        }
    }
    
    public void insertFrame(int frame, Image[] splice) {        
        int maxDir = dirs < splice.length? dirs: splice.length;
        for(int dirIdx = 0; dirIdx < maxDir; dirIdx++) {
            insertImage(dirIdx, frame, splice[dirIdx]);
        }
    }
    
    public void insertImage(int dir, int frame, Image splice) {
        if(frame < 0 || frame >= frames)
            throw new IllegalArgumentException("Provided frame is out of range: " + frame);
        if(dir < 0 || dir >= dirs)
            throw new IllegalArgumentException("Provided dir is out of range: " + dir);
        
        images[getIndex(dir, frame)] = splice;
    }
}


































