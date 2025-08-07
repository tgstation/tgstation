/obj/structure/reagent_dispensers/water_cooler/gay
	name = "gay water cooler"
	desc = "A machine that dispenses gay liquid to drink."
	icon = 'troutstation/icons/obj/machines/vending.dmi'
	icon_state = "gaywater_cooler"
	anchored = FALSE
	reagent_id = /datum/reagent/medicine/gaywater

/obj/structure/reagent_dispensers/water_cooler/gay/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	playsound(get_turf(user), 'troutstation/sound/misc/spare.ogg', 100, TRUE)
	say(pick("bable", "beble", "bible", "boble", "booble", "babie", "bebie", "bibie", "bobie", "bubie", "boobie"))

/obj/structure/reagent_dispensers/water_cooler/gay/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/reagent_dispensers/water_cooler/gay/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/reagent_dispensers/water_cooler/gay/process()
	if(prob(1))
		say(pick("bable", "beble", "bible", "boble", "booble", "babie", "bebie", "bibie", "bobie", "bubie", "boobie"))
		playsound(get_turf(src), 'troutstation/sound/misc/spare.ogg', 100, TRUE)
		sleep(750)

/obj/structure/reagent_dispensers/water_cooler/Initialize()
	if(prob(35) && !ispath(src.type, /obj/structure/reagent_dispensers/water_cooler/gay)) // 35% chance proc AND checks if the water cooler at this location is NOT gay (there are no other variants of water cooler)
		new /obj/structure/reagent_dispensers/water_cooler/gay(src.loc) // place the gay water cooler at the location original water cooler's spot
		return INITIALIZE_HINT_QDEL
	return ..()
