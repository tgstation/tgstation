package dmitool;

import ar.com.hjg.pngj.ImageInfo;
import ar.com.hjg.pngj.ImageLineInt;
import ar.com.hjg.pngj.PngReader;
import ar.com.hjg.pngj.PngWriter;
import ar.com.hjg.pngj.PngjInputException;
import ar.com.hjg.pngj.chunks.PngChunkPLTE;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;

public class DMI implements Comparator<IconState> {
    int w, h;
    List<IconState> images;
    int totalImages = 0;
    RGBA[] palette;
    boolean isPaletted;
    
    public DMI(int w, int h) {
        this.w = w;
        this.h = h;
        images = new ArrayList<>();
        isPaletted = false;
        palette = null;
    }
    
    public DMI(String f) throws DMIException, FileNotFoundException {
        this(new File(f));
    }
    
    public DMI(File f) throws DMIException, FileNotFoundException {
        if(f.length() == 0) { // Empty .dmi is empty file
            w = 32;
            h = 32;
            images = new ArrayList<>();
            isPaletted = false;
            palette = null;
            return;
        }
        InputStream in = new FileInputStream(f);
        PngReader pngr;
        try {
            pngr = new PngReader(in);
        } catch(PngjInputException pie) {
            throw new DMIException("Bad file format!", pie);
        }
        String descriptor = pngr.getMetadata().getTxtForKey("Description");
        String[] lines = descriptor.split("\n");
        
        if(Main.VERBOSITY > 0) System.out.println("Descriptor has " + lines.length + " lines.");
        if(Main.VERBOSITY > 3) {
            System.out.println("Descriptor:");
            System.out.println(descriptor);
        }
        
        /* length 6 is:
            # BEGIN DMI
            version = 4.0
            state = "state"
                dirs = 1
                frames = 1
            # END DMI
        */
        if(lines.length < 6) throw new DMIException(null, 0, "Descriptor too short!");
        
        if(!"# BEGIN DMI".equals(lines[0]))             throw new DMIException(lines, 0, "Expected '# BEGIN DMI'");
        if(!"# END DMI".equals(lines[lines.length-1]))  throw new DMIException(lines, lines.length-1, "Expected '# END DMI'");
        if(!"version = 4.0".equals(lines[1]))           throw new DMIException(lines, 1, "Unknown version, expected 'version = 4.0'");
        
        this.w = 32;
        this.h = 32;
        
        int i = 2;
        
        if(lines[i].startsWith("\twidth = ")) {
            this.w = Integer.parseInt(lines[2].substring("\twidth = ".length()));
            i++;
        }
        if(lines[i].startsWith("\theight = ")) {
            this.h = Integer.parseInt(lines[3].substring("\theight = ".length()));
            i++;
        }
        
        List<IconState> states = new ArrayList<>();
        
        while(i < lines.length - 1) {
            long imagesInState = 1;
            if(!lines[i].startsWith("state = \"") || !lines[i].endsWith("\"")) throw new DMIException(lines, i, "Error reading state string");
            String stateName = lines[i].substring("state = \"".length(), lines[i].length()-1);
            i++;
            int dirs = 1;
            int frames = 1;
            float[] delays = null;
            boolean rewind = false;
            int loop = -1;
            String hotspot = null;
            boolean movement = false;
            while(lines[i].startsWith("\t")) {
                if(lines[i].startsWith("\tdirs = ")) {
                    dirs = Integer.parseInt(lines[i].substring("\tdirs = ".length()));
                    imagesInState *= dirs;
                    i++;
                } else if(lines[i].startsWith("\tframes = ")) {
                    frames = Integer.parseInt(lines[i].substring("\tframes = ".length()));
                    imagesInState *= frames;
                    i++;
                } else if(lines[i].startsWith("\tdelay = ")) {
                    String delayString = lines[i].substring("\tdelay = ".length());
                    String[] delayVals = delayString.split(",");
                    delays = new float[delayVals.length];
                    for(int d=0; d<delays.length; d++) {
                        delays[d] = Float.parseFloat(delayVals[d]);
                    }
                    i++;
                } else if(lines[i].equals("\trewind = 1")) {
                    rewind = true;
                    i++;
                } else if(lines[i].startsWith("\tloop = ")) {
                    loop = Integer.parseInt(lines[i].substring("\tloop = ".length()));
                    i++;
                } else if(lines[i].startsWith("\thotspot = ")) {
                    hotspot = lines[i].substring("\thotspot = ".length());
                    i++;
                } else if(lines[i].equals("\tmovement = 1")) {
                    movement = true;
                    i++;
                } else {
                    System.out.println("Unknown line '" + lines[i] + "' in state '" + stateName + "'!");
                    i++;
                }
            }
            if(delays != null) {
                if((Main.STRICT && delays.length != frames) || delays.length < frames) {
                    throw new DMIException(null, 0, "Frames must be equal to delays (" + stateName + "; " + frames + " frames, " + delays.length + " delays)!");
                }
            }
            IconState is = new IconState(stateName, dirs, frames, null, delays, rewind, loop, hotspot, movement);
            totalImages += imagesInState;
            states.add(is);
        }
        images = states;
        
        PngChunkPLTE pal = (PngChunkPLTE)pngr.getChunksList().getById1("PLTE");
        
        isPaletted = pal != null;
        
        if(isPaletted) {
            if(Main.VERBOSITY > 0) System.out.println(pal.getNentries() + " palette entries");

            palette = new RGBA[pal.getNentries()];
            int[] rgb = new int[3];
            for(int q=0; q<pal.getNentries(); q++) {
                pal.getEntryRgb(q, rgb);
                palette[q] = new RGBA(rgb[0], rgb[1], rgb[2], q==0 ? 0 : 255);
            }
        } else {
            if(Main.VERBOSITY > 0) System.out.println("Non-paletted image");
        }
        
        int iw = pngr.imgInfo.cols;
        int ih = pngr.imgInfo.rows;
        
        if(totalImages > iw * ih)
            throw new DMIException(null, 0, "Impossible number of images!");
        
        if(Main.VERBOSITY > 0) System.out.println("Image size " + iw+"x"+ih);
        int[][] px = new int[ih][];
        
        for(int y=0; y<ih; y++) {
            ImageLineInt ili = (ImageLineInt)pngr.readRow();
            int[] sl = ili.getScanline();
            if(sl.length != (isPaletted ? iw : iw*4))
                throw new DMIException(null, 0, "Error processing image!");
            px[y] = sl.clone();
        }
        
        int statesX = iw / w;
        int statesY = ih / h;
        
        int x=0, y=0;
        for(IconState is: states) {
            int numImages = is.dirs * is.frames;
            Image[] img = new Image[numImages];
            for(int q=0; q<numImages; q++) {
                if(isPaletted) {
                    int[][] idat = new int[h][w];
                    for(int sy = 0; sy < h; sy++) {
                        for(int sx = 0; sx < w; sx++) {
                            idat[sy][sx] = px[y*h + sy][x*w + sx];
                        }
                    }
                    img[q] = new PalettedImage(w, h, idat, palette);
                } else {
                    RGBA[][] idat = new RGBA[h][w];
                    for(int sy = 0; sy < h; sy++) {
                        for(int sx = 0; sx < w; sx++) {
                            idat[sy][sx] = new RGBA(px[y*h + sy][x*4*w + 4*sx], px[y*h + sy][x*4*w + 4*sx + 1], px[y*h + sy][x*4*w + 4*sx + 2], px[y*h + sy][x*4*w + 4*sx + 3]);
                        }
                    }
                    img[q] = new NonPalettedImage(w, h, idat);
                }
                
                x++;
                if(x == statesX) {
                    x = 0;
                    y++;
                    if(y > statesY)
                        // this should NEVER happen, we pre-check it
                        throw new DMIException(null, 0, "CRITICAL: End of image reached with states to go!");
                }
            }
            if(is.delays != null) {
                if((Main.STRICT && is.delays.length*is.dirs != img.length) || is.delays.length*is.dirs < img.length)
                    throw new DMIException(null, 0, "Delay array size mismatch: " + is.delays.length*is.dirs + " vs " + img.length + "!");
            }
            is.images = img;
        }
    }
    
    public IconState getIconState(String name) {
        for(IconState is: images) {
            if(is.name.equals(name)) {
                return is;
            }
        }
        return null;
    }
    
    /**
     * Makes a copy, unless name is null.
     */
    public void addIconState(String name, IconState is) {
        if(name == null) {
            images.add(is);
            totalImages += is.dirs * is.frames;
        } else {
            IconState newState = (IconState)is.clone();
            newState.name = name;
            images.add(newState);
            totalImages += is.dirs * is.frames;
        }
    }
    
    public boolean removeIconState(String name) {
        for(IconState is: images) {
            if(is.name.equals(name)) {
                images.remove(is);
                totalImages -= is.dirs * is.frames;
                return true;
            }
        }
        return false;
    }
    
    public boolean setIconState(IconState is) {
        for(int i=0; i<images.size(); i++) {
            IconState ic = images.get(i);
            if(ic.name.equals(is.name)) {
                totalImages -= ic.dirs * ic.frames;
                totalImages += is.dirs * is.frames;
                images.set(i, is);
                return true;
            }
        }
        return false;
    }
    
    private static final int IEND = 0x49454e44;
    private static final int zTXt = 0x7a545874;
    private static final int IHDR = 0x49484452;
    private static void fixChunks(DataInputStream in, DataOutputStream out) throws IOException {
        if(Main.VERBOSITY > 0) System.out.println("Fixing PNG chunks...");
        out.writeInt(in.readInt());
        out.writeInt(in.readInt());
        
        Deque<PNGChunk> notZTXT = new ArrayDeque<>();
        
        PNGChunk c = null;
        
        while(c == null || c.type != IEND) {
            c = new PNGChunk(in);
            if(c.type == zTXt && notZTXT != null) {
                PNGChunk cc = null;
                while(cc == null || cc.type != IHDR) {
                    cc = notZTXT.pop();
                    cc.write(out);
                }
                c.write(out);
                while(notZTXT.size() != 0) {
                    PNGChunk pc = notZTXT.pop();
                    pc.write(out);
                }
                notZTXT = null;
            } else if(notZTXT != null) {
                notZTXT.add(c);
            } else {
                c.write(out);
            }
        }
        if(Main.VERBOSITY > 0) System.out.println("Chunks fixed.");
    }

    @Override public int compare(IconState arg0, IconState arg1) {
        return arg0.name.compareTo(arg1.name);
    }
    
    public void writeDMI(OutputStream os) throws IOException {
        writeDMI(os, false);
    }
    public void writeDMI(OutputStream os, boolean sortStates) throws IOException {
        if(totalImages == 0) { // Empty .dmis are empty files
            os.close();
            return;
        }
        
        // Setup chunk-fix buffer
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        if(sortStates) {
            Collections.sort(images, this);
        }
        
        // Write the dmi into the buffer
        int sx = (int)Math.ceil(Math.sqrt(totalImages));
        int sy = totalImages / sx;
        if(sx*sy < totalImages) {
            sy++;
        }
        if(Main.VERBOSITY > 0) System.out.println("Image size: " + w + "x" + h + "; number of images " + sx + "x" + sy + " (" + totalImages + ")");
        int ix = sx * w;
        int iy = sy * h;
        ImageInfo ii = new ImageInfo(ix, iy, 8, true);
        PngWriter out = new PngWriter(baos, ii);
        out.setCompLevel(9); // Maximum compression
        String description = getDescriptor();
        if(Main.VERBOSITY > 0) System.out.println("Descriptor has " + (description.split("\n").length) + " lines.");
        out.getMetadata().setText("Description", description, true, true);
        
        Image[][] img = new Image[sx][sy];
        {
            int k = 0;
            int r = 0;
            for(IconState is: images) {
                for(Image i: is.images) {
                    img[k++][r] = i;
                    
                    if(k == sx) {
                        k = 0;
                        r++;
                    }
                }
            }
        }
        
        for(int irow=0; irow<iy; irow++) {
            ImageLineInt ili = new ImageLineInt(ii);
            int[] buf = ili.getScanline();
            for(int icol=0; icol<ix; icol++) {
                int imageX = icol / w;
                int pixelX = icol % w;
                
                int imageY = irow / h;
                int pixelY = irow % h;
                
                Image i = img[imageX][imageY];
                if(i != null) {
                    RGBA c = i.getPixel(pixelX, pixelY);
                    buf[icol*4    ] = c.r;
                    buf[icol*4 + 1] = c.g;
                    buf[icol*4 + 2] = c.b;
                    buf[icol*4 + 3] = c.a;
                } else {
                    buf[icol*4    ] = 0;
                    buf[icol*4 + 1] = 0;
                    buf[icol*4 + 2] = 0;
                    buf[icol*4 + 3] = 0;
                }
            }
            out.writeRow(ili);
        }
        out.end();
        
        ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray());
        fixChunks(new DataInputStream(bais), new DataOutputStream(os));
    }
    
    private String getDescriptor() {
        String s = "";
        String n = "\n";
        String q = "\"";
        
          s += "# BEGIN DMI\n";
          s += "version = 4.0\n";
          s += "	width = " + w + n;
          s += "	height = " + h + n;
        for(IconState is: images) {
          s += is.getDescriptorFragment();
        }
          s += "# END DMI\n";
        
        return s;
    }
    
    public void printInfo() {
        System.out.println(totalImages + " images, " + images.size() + " states, size "+w+"x"+h);
    }
    
    public void printStateList() {
        for(IconState s: images) {
            System.out.println(s.getInfoLine());
        }
    }

    @Override public boolean equals(Object obj) {
        if(obj == this) return true;
        if(!(obj instanceof DMI)) return false;
        DMI dmi = (DMI)obj;
        
        // try to find a simple difference before we dive into icon_state comparisons
        if(dmi.w != w || dmi.h != h) return false;
        if(dmi.isPaletted != isPaletted) return false;
        if(dmi.totalImages != totalImages) return false;
        if(dmi.images.size() != images.size()) return false;
        HashMap<String, IconState> myIS = new HashMap<>();
        HashMap<String, IconState> dmiIS = new HashMap<>();
        
        for(IconState is: images) {
            myIS.put(is.name, is);
        }
        for(IconState is: dmi.images) {
            dmiIS.put(is.name, is);
        }
        if(!myIS.keySet().equals(dmiIS.keySet())) return false;
        for(String s: myIS.keySet()) {
            if(!myIS.get(s).equals(dmiIS.get(s))) return false;
        }
        
        return true;
    }
}
