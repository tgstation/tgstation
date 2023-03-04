/// A fake nuke that actually contains beer.
/obj/machinery/nuclearbomb/beer
	name = "\improper Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap to produce and devastatingly effective. Signs explain that though this particular device has been decommissioned, every Nanotrasen station is equipped with an equivalent one, just in case. All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	proper_bomb = FALSE
	/// The keg located within the beer nuke.
	var/obj/structure/reagent_dispensers/beerkeg/keg
	/// Reagent that is produced once the nuke detonates.
	var/flood_reagent = /datum/reagent/consumable/ethanol/beer
	/// Round event control we might as well keep track of instead of locating every time
	var/datum/round_event_control/scrubber_overflow/every_vent/overflow_control

/obj/machinery/nuclearbomb/beer/Initialize(mapload)
	. = ..()
	keg = new(src)
	QDEL_NULL(core)
	overflow_control = locate(/datum/round_event_control/scrubber_overflow/every_vent) in SSevents.control

/obj/machinery/nuclearbomb/beer/Destroy()
	UnregisterSignal(overflow_control, COMSIG_CREATED_ROUND_EVENT)
	. = ..()

/obj/machinery/nuclearbomb/beer/examine(mob/user)
	. = ..()
	if(keg.reagents.total_volume)
		. += span_notice("It has [keg.reagents.total_volume] unit\s left.")
	else
		. += span_danger("It's empty.")

/obj/machinery/nuclearbomb/beer/attackby(obj/item/weapon, mob/user, params)
	if(weapon.is_refillable())
		weapon.afterattack(keg, user, TRUE) // redirect refillable containers to the keg, allowing them to be filled
		return TRUE // pretend we handled the attack, too.

	if(istype(weapon, /obj/item/nuke_core_container))
		to_chat(user, span_notice("[src] has had its plutonium core removed as a part of being decommissioned."))
		return TRUE

	return ..()

/obj/machinery/nuclearbomb/beer/actually_explode()
	//Unblock roundend, we're not actually exploding.
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm_nuke()
		return
	if(is_station_level(bomb_location.z))
		addtimer(CALLBACK(src, PROC_REF(really_actually_explode)), 11 SECONDS)
	else
		visible_message(span_notice("[src] fizzes ominously."))
		addtimer(CALLBACK(src, PROC_REF(local_foam)), 11 SECONDS)

/obj/machinery/nuclearbomb/beer/disarm_nuke(mob/disarmer)
	exploding = FALSE
	exploded = TRUE
	return ..()

/obj/machinery/nuclearbomb/beer/proc/local_foam()
	var/datum/reagents/tmp_holder = new/datum/reagents(1000)
	tmp_holder.my_atom = src
	tmp_holder.add_reagent(flood_reagent, 100)

	var/datum/effect_system/fluid_spread/foam/foam = new
	foam.set_up(200, holder = src, location = get_turf(src), carry = tmp_holder)
	foam.start()
	disarm_nuke()

/obj/machinery/nuclearbomb/beer/really_actually_explode(detonation_status)
	//if it's always hooked in it'll override admin choices
	RegisterSignal(overflow_control, COMSIG_CREATED_ROUND_EVENT, PROC_REF(on_created_round_event))
	disarm_nuke()
	overflow_control.runEvent()

/// signal sent from overflow control when it fires an event
/obj/machinery/nuclearbomb/beer/proc/on_created_round_event(datum/round_event_control/source_event_control, datum/round_event/scrubber_overflow/every_vent/created_event)
	SIGNAL_HANDLER
	UnregisterSignal(overflow_control, COMSIG_CREATED_ROUND_EVENT)
	created_event.forced_reagent_type = flood_reagent
