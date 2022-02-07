#define PRINTER_TIMEOUT 40

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array.\n"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	base_icon_state = "tdoppler"
	density = TRUE
	verb_say = "states coldly"
	var/cooldown = 10
	var/next_announce = 0
	var/max_dist = 150
	/// Number which will be part of the name of the next record, increased by one for each already created record
	var/record_number = 1
	/// Cooldown for the print function
	var/printer_ready = 0
	/// List of all explosion records in the form of /datum/data/tachyon_record
	var/list/records = list()

/obj/machinery/doppler_array/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, .proc/sense_explosion)
	RegisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED, .proc/power_change)
	printer_ready = world.time + PRINTER_TIMEOUT

/obj/machinery/doppler_array/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE,null,null,CALLBACK(src,.proc/rot_message))

/datum/data/tachyon_record
	name = "Log Recording"
	var/timestamp
	var/coordinates = ""
	var/displacement = 0
	var/factual_radius = list()
	var/theory_radius = list()

/obj/machinery/doppler_array/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TachyonArray", name)
		ui.open()

/obj/machinery/doppler_array/ui_data(mob/user)
	var/list/data = list()
	data["records"] = list()
	for(var/datum/data/tachyon_record/R in records)
		var/list/record_data = list(
			name = R.name,
			timestamp = R.timestamp,
			coordinates = R.coordinates,
			displacement = R.displacement,
			factual_epicenter_radius = R.factual_radius["epicenter_radius"],
			factual_outer_radius = R.factual_radius["outer_radius"],
			factual_shockwave_radius = R.factual_radius["shockwave_radius"],
			theory_epicenter_radius = R.theory_radius["epicenter_radius"],
			theory_outer_radius = R.theory_radius["outer_radius"],
			theory_shockwave_radius = R.theory_radius["shockwave_radius"],
			ref = REF(R)
		)
		data["records"] += list(record_data)
	return data

/obj/machinery/doppler_array/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("delete_record")
			var/datum/data/tachyon_record/record = locate(params["ref"]) in records
			if(!records || !(record in records))
				return
			records -= record
			return TRUE
		if("print_record")
			var/datum/data/tachyon_record/record = locate(params["ref"]) in records
			if(!records || !(record in records))
				return
			print(usr, record)
			return TRUE

/obj/machinery/doppler_array/proc/print(mob/user, datum/data/tachyon_record/record)
	if(!record)
		return
	if(printer_ready < world.time)
		printer_ready = world.time + PRINTER_TIMEOUT
		new /obj/item/paper/record_printout(loc, record)
	else if(user)
		to_chat(user, span_warning("[src] is busy right now."))

/obj/item/paper/record_printout
	name = "paper - Log Recording"

/obj/item/paper/record_printout/Initialize(mapload, datum/data/tachyon_record/record)
	. = ..()

	if(record)
		name = "paper - [record.name]"

		info += {"<h2>[record.name]</h2>
		<ul><li>Timestamp: [record.timestamp]</li>
		<li>Coordinates: [record.coordinates]</li>
		<li>Displacement: [record.displacement] seconds</li>
		<li>Epicenter Radius: [record.factual_radius["epicenter_radius"]]</li>
		<li>Outer Radius: [record.factual_radius["outer_radius"]]</li>
		<li>Shockwave Radius: [record.factual_radius["shockwave_radius"]]</li></ul>"}

		if(length(record.theory_radius))
			info += {"<ul><li>Theoretical Epicenter Radius: [record.theory_radius["epicenter_radius"]]</li>
			<li>Theoretical Outer Radius: [record.theory_radius["outer_radius"]]</li>
			<li>Theoretical Shockwave Radius: [record.theory_radius["shockwave_radius"]]</li></ul>"}

		update_appearance()

/obj/machinery/doppler_array/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		if(!anchored && !isinspace())
			set_anchored(TRUE)
			to_chat(user, span_notice("You fasten [src]."))
		else if(anchored)
			set_anchored(FALSE)
			to_chat(user, span_notice("You unfasten [src]."))
		I.play_tool_sound(src)
		return
	return ..()

/obj/machinery/doppler_array/proc/rot_message(mob/user)
	to_chat(user, span_notice("You adjust [src]'s dish to face to the [dir2text(dir)]."))
	playsound(src, 'sound/items/screwdriver2.ogg', 50, TRUE)

/obj/machinery/doppler_array/proc/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range,
			took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER

	if(machine_stat & NOPOWER)
		return FALSE
	var/turf/zone = get_turf(src)
	if(zone.z != epicenter.z)
		return FALSE

	if(next_announce > world.time)
		return FALSE
	next_announce = world.time + cooldown

	if((get_dist(epicenter, zone) > max_dist) || !(get_dir(zone, epicenter) & dir))
		return FALSE

	var/datum/data/tachyon_record/R = new /datum/data/tachyon_record()
	R.name = "Log Recording #[record_number]"
	R.timestamp = station_time_timestamp()
	R.coordinates = "[epicenter.x], [epicenter.y]"
	R.displacement = took
	R.factual_radius["epicenter_radius"] = devastation_range
	R.factual_radius["outer_radius"] = heavy_impact_range
	R.factual_radius["shockwave_radius"] = light_impact_range

	var/list/messages = list("Explosive disturbance detected.",
		"Epicenter at: grid ([epicenter.x], [epicenter.y]). Temporal displacement of tachyons: [took] seconds.",
		"Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].",
	)

	// If the bomb was capped, say its theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."
		R.theory_radius["epicenter_radius"] = orig_dev_range
		R.theory_radius["outer_radius"] = orig_heavy_range
		R.theory_radius["shockwave_radius"] = orig_light_range

	for(var/message in messages)
		say(message)

	record_number++
	records += R

	SEND_SIGNAL(src, COMSIG_DOPPLER_ARRAY_EXPLOSION_DETECTED, epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)

	return TRUE

/obj/machinery/doppler_array/powered()
	return anchored && ..()

/obj/machinery/doppler_array/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]-broken"
		return ..()
	icon_state = "[base_icon_state][powered() ? null : "-off"]"
	return ..()

/obj/machinery/doppler_array/research
	name = "tachyon-doppler research array"
	desc = "A specialized tachyon-doppler bomb detection array that uses complex on-board software to record data for experiments."
	circuit = /obj/item/circuitboard/machine/doppler_array
	var/datum/techweb/linked_techweb

/obj/machinery/doppler_array/research/Initialize(mapload)
	..()
	linked_techweb = SSresearch.science_tech
	return INITIALIZE_HINT_LATELOAD

// Late initialize to allow the server machinery to initialize first
/obj/machinery/doppler_array/research/LateInitialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/explosion), \
		config_mode = EXPERIMENT_CONFIG_UI, \
		config_flags = EXPERIMENT_CONFIG_ALWAYS_ACTIVE)

/obj/machinery/doppler_array/research/attackby(obj/item/I, mob/user, params)
	if (default_deconstruction_screwdriver(user, "tdoppler", "tdoppler", I) || default_deconstruction_crowbar(I))
		update_icon()
		return
	return ..()

/obj/machinery/doppler_array/research/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range,
		took, orig_dev_range, orig_heavy_range, orig_light_range) //probably needs a way to ignore admin explosives later on
	. = ..()
	if(!.)
		return

	if(!istype(linked_techweb))
		say("Warning: no linked research system!")
		return

	var/cash_gain = 0

	/*****The Point Calculator*****/
	if(orig_light_range < TECHWEB_BOMB_MIN_RANGE)
		say("Explosion not large enough for profitability.")
		return
	else if(orig_light_range < TECHWEB_BOMB_MAX_RANGE)
		cash_gain = (TECHWEB_BOMB_SCALE_CONST * orig_light_range) / (TECHWEB_BOMB_SCALE_DIVISOR + orig_light_range)
	else
		cash_gain = TECHWEB_BOMB_CASHCAP

	/*****The Point Capper*****/
	if(cash_gain > linked_techweb.largest_bomb_value)
		if(cash_gain <= TECHWEB_BOMB_CASHCAP || linked_techweb.largest_bomb_value < TECHWEB_BOMB_CASHCAP)
			var/old_tech_largest_bomb_value = linked_techweb.largest_bomb_value //held so we can pull old before we do math
			linked_techweb.largest_bomb_value = cash_gain
			cash_gain -= old_tech_largest_bomb_value
			cash_gain = min(cash_gain, TECHWEB_BOMB_CASHCAP)
		else
			linked_techweb.largest_bomb_value = TECHWEB_BOMB_CASHCAP
			cash_gain = 1000
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SCI)
		if(D)
			D.adjust_money(cash_gain)
			say("Explosion details and mixture analysis sold to the highest bidder for [cash_gain] cr.")
	else //you've made smaller bombs
		say("Data already captured. Aborting.")
		return

/obj/machinery/doppler_array/research/science/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/machinery/doppler_array/research/ui_data(mob/user)
	. = ..()
	.["is_research"] = TRUE

/obj/machinery/doppler_array/research/ui_act(action, list/params)
	. = ..()
	if (.)
		return

#undef PRINTER_TIMEOUT
