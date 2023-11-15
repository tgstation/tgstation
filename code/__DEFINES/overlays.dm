// A reasonable number of maximum overlays an object needs
// If you think you need more, rethink it
#define MAX_ATOM_OVERLAYS 100

/// Checks if an atom has reached the overlay limit, and make a loud error if it does.
#define VALIDATE_OVERLAY_LIMIT(changed_on) \
	if(length(changed_on.overlays) >= MAX_ATOM_OVERLAYS) { \
		var/text_lays = overlays2text(changed_on.overlays); \
		stack_trace("Too many overlays on [changed_on.type] - [length(changed_on.overlays)], refusing to update and cutting.\
			\n What follows is a printout of all existing overlays at the time of the overflow \n[text_lays]"); \
		changed_on.overlays.Cut(); \
		changed_on.add_overlay(mutable_appearance('icons/testing/greyscale_error.dmi')); \
	} \


/// Performs any operations that ought to run after an appearance change
#define POST_OVERLAY_CHANGE(changed_on) \
	if(alternate_appearances) { \
		for(var/I in changed_on.alternate_appearances){\
			var/datum/atom_hud/alternate_appearance/AA = changed_on.alternate_appearances[I];\
			if(AA.transfer_overlays){\
				AA.copy_overlays(changed_on, TRUE);\
			}\
		} \
	}
