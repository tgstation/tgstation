/*
var/mob/dead/phantasm/P = new (src.loc)
for(var/obj/O in src.contents) // Where src is a mob
	if(istype(O, /obj/item))   // Only remember carried items (sanity checking, mostly)
		src.u_equip(O)		   // Unequip the item if we're wearing it
		if (src.client)
			src.client.screen -= O // Clear out any overlays the item added, notably in the equip windows
		O.loc = src.loc			   // Honestly not sure if these two steps are necessary
		O.dropped(src)			   // but they seem to occur everywhere else in the code, so we're not taking any chances.
		O.layer = initial(O.layer)
		O.loc = P			  // Add the item to the phantasm's inventory
src.Death(0)
*/