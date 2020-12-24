///Food comes in, extract comes out. Inserting stuff into the person is handled by the feeder component
/obj/machinery/plumbing/milker
	name = "people extractor"
	desc = "A mechanical rig with an input leading to the mouth and an outpu-... dear god."

	icon_state = "milker"
	buffer = 200

	layer = BELOW_MOB_LAYER
	density = FALSE
	can_buckle = TRUE

/obj/machinery/plumbing/milker/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/feeder, bolt)

/obj/machinery/plumbing/milker/update_overlays()
	. = ..()
	. += image(icon = icon, icon_state = "milker_overlay", layer = ABOVE_MOB_LAYER)

/obj/machinery/plumbing/milker/process()
	if(buckled_mobs[1]) //always fun forgetting byond starts at 1
		var/mob/living/L = buckled_mobs[1]
		if(L.reagents)
			//Attempt to turn the reagents in our system into something else and put it in the machine for extraction
			SEND_SIGNAL(L.reagents, COMSIG_MOB_EXTRACT_MILK, reagents, L.reagents)
