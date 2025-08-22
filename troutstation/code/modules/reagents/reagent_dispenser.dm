/obj/structure/reagent_dispensers/water_cooler/proc/burble()
	playsound(get_turf(src), 'troutstation/sound/misc/spare.ogg', 100, TRUE)
	say(pick("bable", "beble", "bible", "boble", "booble", "babie", "bebie", "bibie", "bobie", "bubie", "boobie"))

/obj/structure/reagent_dispensers/water_cooler/proc/start_burbling()
	burbling = TRUE
	START_PROCESSING(SSprocessing, src)

/obj/structure/reagent_dispensers/water_cooler/proc/stop_burbling()
	burbling = FALSE
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/reagent_dispensers/water_cooler/process()
	if(prob(1))
		burble()
		sleep(750)

// Kept in the event someone wants to map it in I guess??
/obj/structure/reagent_dispensers/water_cooler/gay
	name = "gay water cooler"
	desc = "A machine that dispenses gay water to drink. Pretty vocal."
	reagent_id = /datum/reagent/medicine/gaywater
