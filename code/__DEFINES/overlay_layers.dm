#define batch_overlay_redraw(thingy) addtimer(thingy, "redraw_overlays", 1, TRUE)
#define OVERLAY_APPEARANCE 			1
#define OVERLAY_PRIORITY			2

#define UNDERLAY_PRIORITY			1
#define UNDERLAY_APPEARANCE			2


//Overlay and underlay channels shared by mutiple places:
//do not add to here if its not used in mutiple places, as defines slow down compile

#define OVERLAY_CHANNEL_FIRE "on_fire"