///Food comes in, extract comes out. Inserting stuff into the person is handled by the feeder component
/obj/machinery/plumbing/extractor
	name = "people extractor"
	desc = "A mechanical rig with an input leading to the mouth and an outpu-... dear god."

	icon_state = "extractor"
	buffer = 200

	layer = BELOW_MOB_LAYER
	density = FALSE
	can_buckle = TRUE

/obj/machinery/plumbing/extractor/Initialize(mapload, bolt)
	. = ..()

	AddComponent(/datum/component/plumbing/feeder, bolt, FALSE)

/obj/machinery/plumbing/extractor/update_overlays()
	. = ..()
	. += image(icon = icon, icon_state = "extractor_overlay", layer = ABOVE_MOB_LAYER)

/obj/machinery/plumbing/extractor/process()
	if(buckled_mobs[1]) //always fun forgetting byond starts at 1
		var/mob/living/L = buckled_mobs[1]
		if(L.reagents)
			//Attempt to turn the reagents in our system into something else and put it in the machine for extraction
			SEND_SIGNAL(L.reagents, COMSIG_MOB_EXTRACT_MILK, reagents, L.reagents)

/obj/machinery/plumbing/extractor/setDir(newdir)
	return ..(SOUTH) //Do not change direction, because we don't have a multidirectional sprite and we'll end up unaligned with the bucklee

