#define SLAM_JAM_DELAY 15 SECONDS

/obj/machinery/power/colony_ore_thumper
	name = "ore thumper"
	desc = "A frame with a heavy block of metal suspended atop a pipe. \
		Must be deployed outdoors and given a wired power connection. \
		Forces pressurized gas into the ground which brings up buried resources."
	icon = 'modular_doppler/kahraman_equipment/icons/ore_thumper.dmi'
	icon_state = "thumper_idle"
	density = TRUE
	max_integrity = 250
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 50 // Should be 50 kw or an entire SOFIE generator's power production
	anchored = TRUE
	can_change_cable_layer = FALSE
	circuit = null
	layer = ABOVE_MOB_LAYER
	/// Are we currently working?
	var/thumping = FALSE
	/// Our looping fan sound that we play when turned on
	var/datum/looping_sound/ore_thumper_fan/soundloop
	/// How many times we've slammed, counts up until the number is high enough to make a box of materials
	var/slam_jams = 0
	/// How many times we need to slam in order to produce a box of materials
	var/slam_jams_needed = 30
	/// List of the thumping sounds we can choose from
	var/static/list/list_of_thumper_sounds = list(
		'modular_doppler/kahraman_equipment/sounds/thumper_thump/punch_press_1.wav',
		'modular_doppler/kahraman_equipment/sounds/thumper_thump/punch_press_2.wav',
	)
	/// Keeps track of the callback timer to make sure we don't have more than one
	var/callback_tracker
	/// Weighted list of the ores we can spawn
	var/static/list/ore_weight_list = list(
		/obj/item/stack/ore/iron = 5,
		/obj/item/stack/ore/glass/basalt = 5,
		/obj/item/stack/ore/plasma = 4,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/silver = 3,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/titanium = 3,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)
	/// How much of the listed types of ores should we spawn when spawning ore
	var/static/list/ore_spawn_values = list(
		/obj/item/stack/ore/iron = 25,
		/obj/item/stack/ore/glass/basalt = 25,
		/obj/item/stack/ore/plasma = 15,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/silver = 10,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)
	/// What's the limit for ore near us? Counts by stacks, not individual amounts of ore
	var/nearby_ore_limit = 5
	/// How far away does ore spawn?
	var/ore_spawn_range = 2
	/// What do we undeploy into
	var/undeploy_type = /obj/item/flatpacked_machine/ore_thumper

/obj/machinery/power/colony_ore_thumper/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	AddElement(/datum/element/repackable, undeploy_type, 4 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/machinery/power/colony_ore_thumper/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	if(isnull(held_item))
		if(panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Activate Thumper"
			return CONTEXTUAL_SCREENTIP_SET
		return NONE


/obj/machinery/power/colony_ore_thumper/examine(mob/user)
	. = ..()
	var/area/thumper_area = get_area(src)
	if(!thumper_area.outdoors)
		. += span_notice("Its must be constructed <b>outdoors</b> to function.")
	if(!istype(get_turf(src), /turf/open/misc))
		. += span_notice("It must be constructed on <b>suitable terrain</b>, like ash, snow, or sand.")
	. += span_notice("It must have a powered, <b>wired connection</b> running beneath it with <b>[display_power(active_power_usage, convert = FALSE)]</b> of excess power to function.")
	. += span_notice("It will produce a box of materials after it has slammed [slam_jams_needed] times.")
	. += span_notice("Currently, it has slammed [slam_jams] / [slam_jams_needed] times needed.")
	. += span_notice("It will stop producing resources if there are <b>too many piles of ore</b> near it.")
	. += span_notice("The thumper cannot work if it is <b>too close to another thumper</b>, needing <b>at least [ore_spawn_range] spaces</b> in all directions between it another thumper.")


/obj/machinery/power/colony_ore_thumper/process()
	var/turf/our_turf = get_turf(src)
	var/obj/structure/cable/cable_under_us = locate() in our_turf
	var/energy_needed = power_to_energy(active_power_usage)
	if(!cable_under_us && powernet)
		disconnect_from_network()
	else if(cable_under_us && !powernet)
		connect_to_network()
	if(thumping)
		if(!see_if_we_can_work(our_turf))
			balloon_alert_to_viewers("invalid location!")
			cut_that_out()
			return
		if(avail(energy_needed))
			add_load(energy_needed)
		else
			balloon_alert_to_viewers("not enough power!")
			cut_that_out()


/// Checks the turf we are on to make sure we are outdoors and on a misc turf
/obj/machinery/power/colony_ore_thumper/proc/see_if_we_can_work(turf/our_turf)
	var/area/our_current_area = get_area(src)
	if(!our_current_area.outdoors)
		return FALSE
	if(!istype(get_turf(src), /turf/open/misc))
		return FALSE
	return TRUE


/obj/machinery/power/colony_ore_thumper/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	to_chat(user, span_notice("You toggle [src]'s power button."))

	if(thumping)
		cut_that_out(user)
		return
	start_her_up(user)


/obj/machinery/power/colony_ore_thumper/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/power/colony_ore_thumper/attack_robot(mob/user)
	return attack_hand(user)


/// Attempts turning the thumper on, failing if any of the conditions aren't met
/obj/machinery/power/colony_ore_thumper/proc/start_her_up(mob/user)
	var/turf/our_turf = get_turf(src)
	var/obj/structure/cable/cable_under_us = locate() in our_turf
	if(!cable_under_us && powernet)
		balloon_alert(user, "not connected to wire")
		return
	if(!avail(active_power_usage))
		balloon_alert(user, "not enough power")
		return

	thumping = TRUE
	soundloop.start()

	if(callback_tracker)
		deltimer(callback_tracker)

	balloon_alert(user, "thumper started")

	callback_tracker = addtimer(CALLBACK(src, PROC_REF(slam_it_down)), SLAM_JAM_DELAY, TIMER_DELETE_ME | TIMER_STOPPABLE)


/// Attempts to shut the thumper down
/obj/machinery/power/colony_ore_thumper/proc/cut_that_out(mob/user)
	thumping = FALSE
	soundloop.stop()
	if(user)
		balloon_alert(user, "thumper stopped")


/// Makes the machine slam down, producing a box of ore if it has been slamming long enough
/obj/machinery/power/colony_ore_thumper/proc/slam_it_down()
	if(!thumping)
		return
	var/turf/our_turf = get_turf(src)
	if(!see_if_we_can_work(our_turf))
		balloon_alert_to_viewers("invalid location!")
		cut_that_out()
		return
	// Down we go
	flick("thumper_slam", src)
	playsound(src, pick(list_of_thumper_sounds), 80, TRUE)
	if(slam_jams < (slam_jams_needed + 1))
		slam_jams += 1

	if(callback_tracker)
		deltimer(callback_tracker)

	callback_tracker = addtimer(CALLBACK(src, PROC_REF(slam_it_down)), SLAM_JAM_DELAY, TIMER_DELETE_ME | TIMER_STOPPABLE,)

	// If the number of slams is less than that of what we need, then we can stop here
	if(!(slam_jams >= slam_jams_needed))
		return

	var/nearby_ore = 0
	var/is_there_a_thumper_too = FALSE
	for(var/turf/nearby_turf in orange(ore_spawn_range, src))
		for(var/ore as anything in nearby_turf.contents)
			if(istype(ore, /obj/item/stack/ore))
				nearby_ore += 1
				continue
			if(istype(ore, /obj/machinery/power/colony_ore_thumper))
				if(ore == src)
					continue
				is_there_a_thumper_too = TRUE
				break

	if(nearby_ore > nearby_ore_limit)
		balloon_alert_to_viewers("nearby ore too saturated")
		// Makes the thumper rumble around when something's wrong
		Shake(2, 2, 2 SECONDS)
		return

	if(is_there_a_thumper_too)
		balloon_alert_to_viewers("too close to another thumper")
		// Makes the thumper rumble around when something's wrong
		Shake(2, 2, 2 SECONDS)
		return

	addtimer(CALLBACK(src, PROC_REF(make_some_ore)), 3 SECONDS, TIMER_DELETE_ME)


/// Spawns an ore box on top of the thumper
/obj/machinery/power/colony_ore_thumper/proc/make_some_ore()
	var/list/nearby_valid_turfs = list()
	for(var/turf/nearby_turf in orange(ore_spawn_range, src))
		if(nearby_turf.is_blocked_turf(TRUE))
			continue
		if(!ismiscturf(nearby_turf))
			continue
		nearby_valid_turfs.Add(nearby_turf)
	// Fallback in case somehow there are no valid nearby turfs
	if(!length(nearby_valid_turfs))
		nearby_valid_turfs.Add(get_turf(src))

	for(var/iteration in 1 to rand(2, 4))
		var/turf/target_turf = pick(nearby_valid_turfs)
//		var/obj/item/stack/new_ore = pick_weight(ore_weight_list)
//		var/obj/new_ore_pile = new new_ore(target_turf, ore_spawn_values[new_ore.type])
		new /obj/effect/temp_visual/mook_dust(target_turf)
//		playsound(new_ore_pile, 'modular_nova/master_files/sound/effects/robot_sit.ogg', 25, TRUE) port tallborgs soon

	slam_jams -= slam_jams_needed


// Item for deploying ore thumpers
/obj/item/flatpacked_machine/ore_thumper
	name = "flat-packed ore thumper"
	icon = 'modular_doppler/kahraman_equipment/icons/ore_thumper_item.dmi'
	icon_state = "thumper_packed"
	type_to_deploy = /obj/machinery/power/colony_ore_thumper
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/item/flatpacked_machine/ore_thumper/examine(mob/user)
	. = ..()
	. += span_notice("Its must be constructed <b>outdoors</b> to function.")
	. += span_notice("It must be constructed on <b>suitable terrain</b>, like ash, snow, or sand.")
	. += span_notice("It must have a powered, <b>wired connection</b> running beneath it to function.")

/obj/item/flatpacked_machine/ore_thumper/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)
