#define HAS_SECONDARY_FLAG(atom, sflag) (atom.secondary_flags ? atom.secondary_flags[sflag] : FALSE)
#define SET_SECONDARY_FLAG(atom, sflag) if(!atom.secondary_flags) { atom.secondary_flags = list(); } atom.secondary_flags[sflag] = TRUE;
#define CLEAR_SECONDARY_FLAG(atom, sflag) if(atom.secondary_flags) atom.secondary_flags[sflag] = null
#define TOGGLE_SECONDARY_FLAG(atom, sflag) if(HAS_SECONDARY_FLAG(atom, sflag)) { CLEAR_SECONDARY_FLAG(atom, sflag); } else {SET_SECONDARY_FLAG(atom, sflag) ; }
