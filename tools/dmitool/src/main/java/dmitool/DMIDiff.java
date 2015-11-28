package dmitool;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class DMIDiff {
    Map<String, IconState> newIconStates;
    Map<String, IconStateDiff> modifiedIconStates = new HashMap<>();
    Set<String> removedIconStates;
    
    DMIDiff() {
        newIconStates = new HashMap<>();
        removedIconStates = new HashSet<>();
    }

    public DMIDiff(DMI base, DMI mod) {
        if(base.h != mod.h || base.w != mod.w) throw new IllegalArgumentException("Cannot compare non-identically-sized DMIs!");
        
        HashMap<String, IconState> baseIS = new HashMap<>();
        for(IconState is: base.images) {
            baseIS.put(is.name, is);
        }
        
        HashMap<String, IconState> modIS = new HashMap<>();
        for(IconState is: mod.images) {
            modIS.put(is.name, is);
        }
        
        newIconStates = ((HashMap<String, IconState>)modIS.clone());
        for(String s: baseIS.keySet()) {
            newIconStates.remove(s);
        }
        
        removedIconStates = new HashSet<>();
        removedIconStates.addAll(baseIS.keySet());
        removedIconStates.removeAll(modIS.keySet());
        
        Set<String> retainedStates = new HashSet<>();
        retainedStates.addAll(baseIS.keySet());
        retainedStates.retainAll(modIS.keySet());
        
        for(String s: retainedStates) {
            if(!baseIS.get(s).equals(modIS.get(s))) {
                modifiedIconStates.put(s, new IconStateDiff(baseIS.get(s), modIS.get(s)));
            }
        }
    }
    /**
     * ASSUMES NO MERGE CONFLICTS - MERGE DIFFS FIRST.
     */
    public void applyToDMI(DMI dmi) {
        for(String s: removedIconStates) {
            dmi.removeIconState(s);
        }
        for(String s: modifiedIconStates.keySet()) {
            dmi.setIconState(modifiedIconStates.get(s).newState);
        }
        for(String s: newIconStates.keySet()) {
            dmi.addIconState(null, newIconStates.get(s));
        }
    }
    
    /**
     * @param other The diff to merge with
     * @param conflictDMI A DMI to add conflicted icon_states to
     * @param merged An empty DMIDiff to merge into
     * @param aName The log name for this diff
     * @param bName The log name for {@code other}
     * @return A Set<String> containing all icon_states which conflicted, along with what was done in each diff, in the format "icon_state: here|there"; here and there are one of "added", "modified", and "removed"
     */
    public Set<String> mergeDiff(DMIDiff other, DMI conflictDMI, DMIDiff merged, String aName, String bName) {
        HashSet<String> myTouched = new HashSet<>();
        myTouched.addAll(removedIconStates);
        myTouched.addAll(newIconStates.keySet());
        myTouched.addAll(modifiedIconStates.keySet());
        
        HashSet<String> otherTouched = new HashSet<>();
        otherTouched.addAll(other.removedIconStates);
        otherTouched.addAll(other.newIconStates.keySet());
        otherTouched.addAll(other.modifiedIconStates.keySet());
        
        HashSet<String> bothTouched = (HashSet<String>)myTouched.clone();
        bothTouched.retainAll(otherTouched); // this set now contains the list of icon_states that *both* diffs modified, which we'll put in conflictDMI for manual merge (unless they were deletions
        
        if(Main.VERBOSITY > 0) {
            System.out.println("a: " + Arrays.toString(myTouched.toArray()));
            System.out.println("b: " + Arrays.toString(otherTouched.toArray()));
            System.out.println("both: " + Arrays.toString(bothTouched.toArray()));
        }
        
        HashSet<String> whatHappened = new HashSet<>();
        
        for(String s: bothTouched) {
            String here, there;
            if(removedIconStates.contains(s)) {
                here = "removed";
            } else if(newIconStates.containsKey(s)) {
                here = "added";
            } else if(modifiedIconStates.containsKey(s)) {
                here = "modified";
            } else {
                System.out.println("Unknown error; state="+s);
                here = "???";
            }
            
            if(other.removedIconStates.contains(s)) {
                there = "removed";
            } else if(other.newIconStates.containsKey(s)) {
                there = "added";
            } else if(other.modifiedIconStates.containsKey(s)) {
                there = "modified";
            } else {
                System.out.println("Unknown error; state="+s);
                there = "???";
            }
            
            whatHappened.add(s + ": " + here + "|" + there);
        }
        
        // Removals
        for(String s: removedIconStates) {
            if(!bothTouched.contains(s)) {
                merged.removedIconStates.add(s);
            }
        }
        for(String s: other.removedIconStates) {
            if(!bothTouched.contains(s)) {
                merged.removedIconStates.add(s);
            }
        }
        
        // Modifications
        for(String s: modifiedIconStates.keySet()) {
            if(!bothTouched.contains(s)) {
                merged.modifiedIconStates.put(s, modifiedIconStates.get(s));
            } else {
                conflictDMI.addIconState(aName + "|" + s, modifiedIconStates.get(s).newState);
            }
        }
        for(String s: other.modifiedIconStates.keySet()) {
            if(!bothTouched.contains(s)) {
                merged.modifiedIconStates.put(s, other.modifiedIconStates.get(s));
            } else {
                conflictDMI.addIconState(bName + "|" + s, other.modifiedIconStates.get(s).newState);
            }
        }
        
        // Additions
        for(String s: newIconStates.keySet()) {
            if(!bothTouched.contains(s)) {
                merged.newIconStates.put(s, newIconStates.get(s));
            } else {
                conflictDMI.addIconState(aName + s, newIconStates.get(s));
            }
        }
        for(String s: other.newIconStates.keySet()) {
            if(!bothTouched.contains(s)) {
                merged.newIconStates.put(s, other.newIconStates.get(s));
            } else {
                conflictDMI.addIconState(bName + s, other.newIconStates.get(s));
            }
        }
        
        return whatHappened;
    }
    
    @Override public String toString() {
        String s = "";
        String t = "\t";
        String q = "\"";
        String n = "\n";
        if(!removedIconStates.isEmpty()) {
            s += "Removed:\n";
            for(String state: removedIconStates)
                s += t + q + state + q + n;
        }
        if(!modifiedIconStates.isEmpty()) {
            s += "Modified:\n";
            for(String state: modifiedIconStates.keySet())
                s += t + q + state + q + " [" + modifiedIconStates.get(state).toString() + "]\n";
        }
        if(!newIconStates.isEmpty()) {
            s += "Added:\n";
            for(String state: newIconStates.keySet())
                s += t + q + state + q + " " + newIconStates.get(state).infoStr() + n;
        }
        if("".equals(s))
            return "No changes";
        return s;
    }
}