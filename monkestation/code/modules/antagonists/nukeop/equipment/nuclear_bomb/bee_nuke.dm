/// A fake nuke that actually contains bee.
/obj/machinery/nuclearbomb/bee
	name = "\improper Rayne Corp brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Rayne Corporation Biological Warfare Division, their nuclear fission explosives are renowned for being affordable to produce and devastatingly effective. Signs explain that though this particular device has been (hopefully) decommissioned, you should probably be careful around it considering it's a bomb. - at least, the sign says that's what it is. There seems to be a picture of a bee on the back."
	proper_bomb = FALSE
	/// The keg located within the beer nuke.
	/// Reagent that is produced once the nuke detonates.
	/// Round event control we might as well keep track of instead of locating every time

/obj/machinery/nuclearbomb/bee/Initialize(mapload)
	. = ..()
	QDEL_NULL(core)

/obj/machinery/nuclearbomb/bee/Destroy()
	return ..()



/obj/machinery/nuclearbomb/bee/actually_explode()
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm_nuke()
		return
	if(is_station_level(bomb_location.z))
		addtimer(CALLBACK(src, PROC_REF(really_actually_explode)), 11 SECONDS)
	else
		visible_message(span_notice("[src] fizzes ominously."))


/obj/machinery/nuclearbomb/bee/disarm_nuke(mob/disarmer)
	exploding = FALSE
	exploded = TRUE
	return ..()

/obj/machinery/nuclearbomb/bee/really_actually_explode(detonation_status)
	//if it's always hooked in it'll override admin choices
	disarm_nuke()
	force_event(/datum/round_event_control/scrubber_clog/flood, "A bee nuke")

/// signal sent from overflow control when it fires an event

