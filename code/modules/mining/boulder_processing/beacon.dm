///Beacon to launch a new mining setup when activated. For testing and speed!
/obj/item/boulder_beacon
	name = "boulder beacon"
	desc = "N.T. approved boulder beacon, toss it down and you will have a full bouldertech mining station."
	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "floor_beacon"
	/// Number of activations left on this beacon. Uses will be removed as the beacon is used and each triggers a different machine to be spawned from it.
	var/uses = 3

/obj/item/boulder_beacon/attack_self()
	visible_message(span_warning("\The [src] begins to beep loudly!"))
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 1 SECONDS)

/**
 * Spawns a new bouldertech machine from the beacon, then removes a use from the beacon.
 * Use one spawns a BRM teleporter, then a refinery, and lastly a smelter.
 */
/obj/item/boulder_beacon/proc/launch_payload()
	playsound(src, SFX_SPARKS, 80, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	switch(uses)
		if(3)
			new /obj/machinery/brm(drop_location())
		if(2)
			new /obj/machinery/bouldertech/refinery(drop_location())
		if(1)
			new /obj/machinery/bouldertech/refinery/smelter(drop_location())
			qdel(src)
	uses--
