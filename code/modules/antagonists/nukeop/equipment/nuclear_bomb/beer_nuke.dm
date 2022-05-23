/// A fake nuke that actually contains beer.
/obj/machinery/nuclearbomb/beer
	name = "\improper Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap to produce and devastatingly effective. Signs explain that though this particular device has been decommissioned, every Nanotrasen station is equipped with an equivalent one, just in case. All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	proper_bomb = FALSE
	/// The keg located within the beer nuke.
	var/obj/structure/reagent_dispensers/beerkeg/keg

/obj/machinery/nuclearbomb/beer/Initialize(mapload)
	. = ..()
	keg = new(src)
	QDEL_NULL(core)

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
		addtimer(CALLBACK(src, .proc/really_actually_explode), 11 SECONDS)
	else
		visible_message(span_notice("[src] fizzes ominously."))
		addtimer(CALLBACK(src, .proc/local_foam), 11 SECONDS)

/obj/machinery/nuclearbomb/beer/disarm_nuke(mob/disarmer)
	exploding = FALSE
	exploded = TRUE
	return ..()

/obj/machinery/nuclearbomb/beer/proc/local_foam()
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)

	var/datum/effect_system/fluid_spread/foam/foam = new
	foam.set_up(200, location = get_turf(src), carry = R)
	foam.start()
	disarm_nuke()

/obj/machinery/nuclearbomb/beer/proc/stationwide_foam()
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "Atmospherics alert")

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/vent in GLOB.machines)
		var/turf/vent_turf = get_turf(vent)
		if (!vent_turf || !is_station_level(vent_turf.z) || vent.welded)
			continue

		var/datum/reagents/beer = new /datum/reagents(1000)
		beer.my_atom = vent
		beer.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)
		beer.create_foam(/datum/effect_system/fluid_spread/foam, DIAMOND_AREA(10))

		CHECK_TICK

/obj/machinery/nuclearbomb/beer/really_actually_explode(detonation_status)
	disarm_nuke()
	stationwide_foam()
