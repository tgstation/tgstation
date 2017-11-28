package dmitool;

import java.util.HashMap;
import java.util.HashSet;

public class IconStateDiff {
    static class ISAddress {
        int dir;
        int frame;

        public ISAddress(int dir, int frame) {
            this.dir = dir;
            this.frame = frame;
        }
        
        public String infoStr(int maxDir, int maxFrame) {
            if(maxDir == 1 && maxFrame == 1) {
                return "";
            } else if(maxDir == 1) {
                return "{" + frame + "}";
            } else if(maxFrame == 1) {
                return "{" + Main.dirs[dir] + "}";
            } else {
                return "{" + Main.dirs[dir] + " " + frame + "}";
            }
        }
    }
    int oldFrameCount = 0;
    int oldDirectionCount = 0;
    boolean oldRewind = false;
    int oldLoop = -1;
    String oldHotspot = null;
    
    int newFrameCount = 0;
    int newDirectionCount = 0;
    boolean newRewind = false;
    int newLoop = -1;
    String newHotspot = null;
    
    IconState newState;
    HashMap<ISAddress, Image> modifiedFrames = new HashMap<>();
    HashMap<ISAddress, Image> newFrames = new HashMap<>();
    HashSet<ISAddress> removedFrames = new HashSet<>();

    public IconStateDiff(IconState base, IconState mod) {
        int maxDir = Math.max(base.dirs, mod.dirs);
        int maxFrame = Math.max(base.frames, mod.frames);
        
        oldFrameCount = base.frames;
        oldDirectionCount = base.dirs;
        oldRewind = base.rewind;
        oldLoop = base.loop;
        oldHotspot = base.hotspot;
        
        newFrameCount = mod.frames;
        newDirectionCount = mod.dirs;
        newRewind = mod.rewind;
        newLoop = mod.loop;
        newHotspot = mod.hotspot;
        
        newState = mod;
        
        Image baseI, modI;
        for(int d=0; d<maxDir; d++) {
            for(int f=0; f<maxFrame; f++) {
                if(base.dirs > d && base.frames > f) {
                    baseI = base.images[f * base.dirs + d];
                } else baseI = null;
                if(mod.dirs > d && mod.frames > f) {
                    modI = mod.images[f * mod.dirs + d];
                } else modI = null;
                
                if(baseI == null && modI == null) continue;
                
                if(baseI == null) newFrames.put(new ISAddress(d, f), modI);
                else if(modI == null) removedFrames.add(new ISAddress(d, f));
                else if(!baseI.equals(modI)) {
                    modifiedFrames.put(new ISAddress(d, f), modI);
                }
            }
        }
    }
    
    @Override public String toString() {
        String s = "";
        String tmp;
        
        if(newDirectionCount != oldDirectionCount)
            s += " | dirs " + oldDirectionCount + "->" + newDirectionCount;
        
        if(newFrameCount != oldFrameCount)
            s += " | frames " + oldFrameCount + "->" + newFrameCount;
        
        if(newRewind != oldRewind) {
            s += " | rewind " + oldRewind + "->" + newRewind;
        }
        
        if(newLoop != oldLoop) {
            s += " | loop " + oldLoop + "->" + newLoop;
        }
        
        if(newHotspot == null ? oldHotspot != null : !newHotspot.equals(oldHotspot)) {
            s += " | hotspot " + oldHotspot + "->" + newHotspot;
        }
        
        if(!modifiedFrames.isEmpty()) {
            int total_frames = Math.min(oldFrameCount, newFrameCount) * Math.min(oldDirectionCount, newDirectionCount);
            tmp = "";
            for(ISAddress isa: modifiedFrames.keySet()) {
                String str = isa.infoStr(oldDirectionCount, oldFrameCount);
                if(!"".equals(str)) {
                    tmp += ", " + str;
                }
            }
            if(!"".equals(tmp)) {
                s += " | modified " + modifiedFrames.size() + " of " + total_frames + ": " + tmp.substring(1);
            } else {
                s += " | modified " + modifiedFrames.size() + " of " + total_frames;
            }
        }
        
        if("".equals(s))
            return "No change";
        return s.substring(3);
    }
}