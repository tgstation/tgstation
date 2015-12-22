//The debugger! Can be used to test pretty much anything. Make a subtype with its own effects under debug().
//Fun fact: It took 3 pull requests for this to finally get added in.

/obj/item/debugger
	name = "debugger"
	desc = "A mystical artifact used by the gods to manipulate reality for their own purposes."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield1"
	w_class = 2
	throw_range = 7
	throw_speed = 1
	var/delete_after_use = TRUE //If true, the debugger will delete itself once used. Otherwise, it has infinite uses.

/obj/item/debugger/attack_self(mob/living/M)
	debug(M)
	if(delete_after_use)
		M.drop_item()
		qdel(src)

//Used to call the debugger's effects.
/obj/item/debugger/proc/debug(var/mob/living/L)

/obj/item/debugger/witch
	name = "witch debugger"

/obj/item/debugger/witch/debug(mob/living/L)
	make_witch(L.mind)

/obj/item/debugger/affinity
	name = "affinity cycler"
	delete_after_use = FALSE

/obj/item/debugger/affinity/debug(mob/living/L)
	var/datum/witch/W = L.mind.witch
	if(!W)
		L << "<span class='warning'>You aren't a witch!</span>"
		return 0
	switch(W.affinity)
		if(0)
			W.affinity = AFFINITY_EARTH
			L << "<span class='notice'>Affinity set to EARTH</span>"
		if(AFFINITY_EARTH)
			W.affinity = AFFINITY_WATER
			L << "<span class='notice'>Affinity set to WATER</span>"
		if(AFFINITY_WATER)
			W.affinity = AFFINITY_FIRE
			L << "<span class='notice'>Affinity set to FIRE</span>"
		if(AFFINITY_FIRE)
			W.affinity = AFFINITY_AIR
			L << "<span class='notice'>Affinity set to AIR</span>"
		if(AFFINITY_AIR)
			W.affinity = AFFINITY_ETHER
			L << "<span class='notice'>Affinity set to ETHER</span>"
		if(AFFINITY_ETHER)
			W.affinity = AFFINITY_EARTH
			L << "<span class='notice'>Affinity set to EARTH</span>"
