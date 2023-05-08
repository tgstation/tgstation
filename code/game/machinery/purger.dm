/obj/machinery/purger
	name = "Purge-O-Matic 3000"
	desc = "Purges addictions, chemicals, and (until we can work out the kinks) a considerable amount of blood from the user."
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"
	circuit = /obj/item/circuitboard/machine/purger
	state_open = FALSE
	density = TRUE
	var/datum/looping_sound/microwave/soundloop

/obj/machinery/purger/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)
	open_machine()
	update_appearance()

/obj/machinery/purger/attackby(obj/item/I, mob/user, params)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_appearance()
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

///Reduces addiction points, purges chems until there are only 10 reagents left.
///Purged chems are released as a very small gas cloud.
/obj/machinery/purger/process()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		for(var/datum/addiction in mob_occupant.mind?.active_addictions)
			mob_occupant.mind.remove_addiction_points(addiction, 10)
