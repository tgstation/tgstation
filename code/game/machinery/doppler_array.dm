#define PRINTER_TIMEOUT 40

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array.\n"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
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

/obj/machinery/doppler_array/Initialize()
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
			var/datum/data/tachyon_record/record  = locate(params["ref"]) in records
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
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")

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

		update_icon()

/obj/machinery/doppler_array/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		if(!anchored && !isinspace())
			set_anchored(TRUE)
			to_chat(user, "<span class='notice'>You fasten [src].</span>")
		else if(anchored)
			set_anchored(FALSE)
			to_chat(user, "<span class='notice'>You unfasten [src].</span>")
		I.play_tool_sound(src)
		return
	return ..()

/obj/machinery/doppler_array/proc/rot_message(mob/user)
	to_chat(user, "<span class='notice'>You adjust [src]'s dish to face to the [dir2text(dir)].</span>")
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

	var/distance = get_dist(epicenter, zone)
	var/direct = get_dir(zone, epicenter)

	if(distance > max_dist)
		return FALSE
	if(!(direct & dir))
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
							 "Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

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
	return TRUE

/obj/machinery/doppler_array/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/doppler_array/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/doppler_array/research
	name = "tachyon-doppler research array"
	desc = "A specialized tachyon-doppler bomb detection array that uses the results of the highest yield of explosions for research."
	var/datum/techweb/linked_techweb

/obj/machinery/doppler_array/research/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range,
		took, orig_dev_range, orig_heavy_range, orig_light_range) //probably needs a way to ignore admin explosives later on
	. = ..()
	if(!.)
		return
	if(!istype(linked_techweb))
		say("Warning: No linked research system!")
		return

	var/point_gain = 0
	/*****The Point Calculator*****/
	if(orig_light_range < 10)
		say("Explosion not large enough for research calculations.")
		return
	else if(orig_light_range < 4500)
		point_gain = (83300 * orig_light_range) / (orig_light_range + 3000)
	else
		point_gain = TECHWEB_BOMB_POINTCAP

	/*****The Point Capper*****/
	if(point_gain > linked_techweb.largest_bomb_value)
		if(point_gain <= TECHWEB_BOMB_POINTCAP || linked_techweb.largest_bomb_value < TECHWEB_BOMB_POINTCAP)
			var/old_tech_largest_bomb_value = linked_techweb.largest_bomb_value //held so we can pull old before we do math
			linked_techweb.largest_bomb_value = point_gain
			point_gain -= old_tech_largest_bomb_value
			point_gain = min(point_gain,TECHWEB_BOMB_POINTCAP)
		else
			linked_techweb.largest_bomb_value = TECHWEB_BOMB_POINTCAP
			point_gain = 1000
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SCI)
		if(D)
			D.adjust_money(point_gain)
			linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, point_gain)
			say("Explosion details and mixture analyzed and sold to the highest bidder for [point_gain] cr, with a reward of [point_gain] points.")

	else //you've made smaller bombs
		say("Data already captured. Aborting.")
		return

/obj/machinery/doppler_array/research/science/Initialize()
	. = ..()
	linked_techweb = SSresearch.science_tech

#undef PRINTER_TIMEOUT
