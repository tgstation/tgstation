///A simplified version of appearence encode for overlays and underlays. Avoids the problem of recursively changing appearances.
#define FAST_APPEARANCE_ENCODE(image) "{\"[##image.icon]\";\"[##image.icon_state]\";\"[##image.name]\";[##image.appearance_flags];[##image.layer];[##image.plane == -32767 ? "" : ##image.plane];[##image.dir == 2 ? "" : ##image.dir]}"
