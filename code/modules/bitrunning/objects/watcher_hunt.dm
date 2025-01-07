#define DISPLAY_PIXEL_ALPHA 96
/obj/bitrunning/target
	name = "target"
	desc = "A target for Target Identification."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "target"
	density = TRUE
	anchored = FALSE

	var/obj/machinery/digital_clock/score_card/my_score
	var/shot = FALSE
	var/score = 500
	var/boulder_size = BOULDER_SIZE_SMALL
	var/list/boulder_mats = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
	)
	var/list/drop_sounds = list('sound/machines/coindrop.ogg', 'sound/machines/coindrop2.ogg')
	var/starting_location
	var/obj/bitrunning/watcher_hunt_spawner/my_spawner
	var/use_human_appearance = FALSE
	var/human_outfit = /datum/outfit/job/assistant
	var/human_species = /datum/species/human
	var/r_hand = null
	var/l_hand = null
	var/bloody_slots_outfit = null


/obj/bitrunning/target/Initialize(mapload)
	. = ..()
	if(use_human_appearance)
		apply_dynamic_human_appearance(src, human_outfit, human_species, r_hand = r_hand, l_hand = l_hand, bloody_slots = bloody_slots_outfit)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_teleport))

/obj/bitrunning/target/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	if(my_spawner)
		my_spawner.current_targets.Remove(src)
	. = ..()

/obj/bitrunning/target/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	. = ..()
	if(shot)
		return
	shot = TRUE
	my_score.current_score += score * my_score.current_multiplier
	my_score.update_icon()
	my_score.check_score()
	if(score > 0)
		var/turf/my_turf = get_turf(src)
		my_turf.balloon_alert_to_viewers("+[score * my_score.current_multiplier]")
		my_score.current_multiplier++
		var/obj/item/boulder/reward_boulder = new(get_turf(my_score))
		reward_boulder.set_custom_materials(boulder_mats)

		//set size & durability
		reward_boulder.boulder_size = boulder_size
		reward_boulder.durability = rand(2, boulder_size) //randomize durability a bit for some flavor.
		reward_boulder.boulder_string = pick(list("boulder", "rock", "stone"))
		reward_boulder.update_appearance(UPDATE_ICON_STATE)

		SSore_generation.available_boulders += reward_boulder
	else if (score < 0)
		var/turf/my_turf = get_turf(src)
		my_turf.balloon_alert_to_viewers("-[score]!")
		if(my_score.current_score < 0)
			my_score.current_score = 0
		my_score.current_multiplier = 1
	else
		my_score.current_multiplier = 1
	playsound(my_score, pick(drop_sounds), 100, TRUE)
	qdel(src)

/obj/bitrunning/target/proc/check_teleport(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/obj/bitrunning/watcher_hunt_teleporter/teleport_node = locate(/obj/bitrunning/watcher_hunt_teleporter) in get_turf(src)
	if(teleport_node)
		forceMove(starting_location)

/obj/bitrunning/watcher_hunt_spawner
	name = "Watcher Hunt Spawner"
	desc = "If you can see this, file a bug report!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "animatronic_node"
	icon_state = "animatronic_node"
	color = "#FF0000"
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/list/spawn_order = list()
	var/list/fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language = list()
	var/max_spawned_targets
	var/list/current_targets = list()
	var/spawn_timer
	var/spawn_delay = 1 SECONDS
	var/replace_destroyed_targets = FALSE
	var/obj/machinery/digital_clock/score_card/my_score

/obj/bitrunning/watcher_hunt_spawner/Initialize(mapload)
	. = ..()
	alpha = 0
	fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language = spawn_order.Copy()
	max_spawned_targets = length(spawn_order)

/obj/bitrunning/watcher_hunt_spawner/proc/spawn_target()
	if(!length(fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language) && replace_destroyed_targets)
		fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language = spawn_order.Copy()
	if(length(fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language))
		if(max_spawned_targets > length(current_targets))
			var/path_to_spawn = pick_n_take(fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language)
			var/obj/bitrunning/target/my_target = new path_to_spawn(get_turf(src))
			my_target.my_spawner = src
			my_target.my_score = my_score
			my_target.starting_location = get_turf(src)
			current_targets.Add(my_target)

/obj/bitrunning/watcher_hunt_spawner/test
	spawn_order = list(
		/obj/bitrunning/target/tier1/lavaland,
		/obj/bitrunning/target/tier2/lavaland,
		/obj/bitrunning/target/tier3/lavaland
	)

/obj/bitrunning/watcher_hunt_spawner/meteor
	spawn_order = list(
		/obj/bitrunning/target/barrel/meteor
	)
	replace_destroyed_targets = TRUE

/obj/bitrunning/watcher_hunt_spawner/meteor/spawn_target()
	spawn_delay = rand(1, 5) SECONDS
	. = ..()

/obj/bitrunning/watcher_hunt_spawner/test/replace
	replace_destroyed_targets = TRUE

/obj/bitrunning/target/tier1
	score = 100
	boulder_size = BOULDER_SIZE_SMALL
	boulder_mats = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
	)

/obj/bitrunning/target/tier2
	score = 200
	boulder_size = BOULDER_SIZE_MEDIUM
	boulder_mats = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5,
	)

/obj/bitrunning/target/tier3
	score = 600
	boulder_size = BOULDER_SIZE_LARGE
	boulder_mats = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 5,
	)
	drop_sounds = list('sound/machines/roulette/roulettejackpot.ogg')

/obj/bitrunning/target/tier4
	score = 2000
	boulder_size = BOULDER_SIZE_LARGE
	boulder_mats = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 10,
	)
	drop_sounds = list('sound/machines/roulette/roulettejackpot.ogg')

/obj/bitrunning/target/tier3/lavaland
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "basilisk"

/obj/bitrunning/target/tier2/lavaland
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "brimdemon"

/obj/bitrunning/target/tier1/lavaland
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "ash_whelp"

/obj/bitrunning/target/barrel
	icon = 'icons/obj/structures.dmi'
	icon_state = "barrel"
	base_icon_state = "barrel"
	score = 0
	drop_sounds = list(
		'sound/misc/bitrunner/wood_plank_break1.ogg',
		'sound/misc/bitrunner/wood_plank_break2.ogg',
		'sound/misc/bitrunner/wood_plank_break3.ogg',
		'sound/misc/bitrunner/wood_plank_break4.ogg',
	)

/obj/bitrunning/target/barrel/meteor
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	base_icon_state = "small1"

/obj/bitrunning/target/barrel/meteor/Initialize(mapload)
	. = ..()
	icon_state = pick(list("small1", "large1"))

/obj/bitrunning/target/barrel/assistant // conditioning to disrespect assistants
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/assistant

/obj/bitrunning/target/tier1/revolutionary
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/rev_cutout

/obj/bitrunning/target/tier1/revolutionary
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/traitor_cutout

/obj/bitrunning/target/tier2/cultist
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/cult_cutout

/obj/bitrunning/target/tier2/nukeop
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/syndicate/full

/obj/bitrunning/target/tier3/wizard
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/wizard

/obj/bitrunning/target/tier4/clown
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/clown

/obj/bitrunning/target/bad
	score = -250
	drop_sounds = list(
		'sound/machines/synth/synth_no.ogg'
	)

/obj/bitrunning/target/bad/ian
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "corgi"

/obj/bitrunning/target/bad/security_officer
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/security
	r_hand = /obj/item/melee/baton/security/loaded

/obj/bitrunning/target/bad/hos
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/hos
	r_hand = /obj/item/melee/baton/security/loaded
	l_hand = /obj/item/gun/energy/laser

/obj/bitrunning/target/bad/captain
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/captain

/obj/bitrunning/target/bad/doctor
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/doctor

/obj/bitrunning/target/bad/miner
	use_human_appearance = TRUE
	human_outfit = /datum/outfit/job/miner
	r_hand = /obj/item/gun/energy/recharge/kinetic_accelerator


/obj/bitrunning/watcher_hunt_spawner/station_low
	spawn_order = list(
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/bad/security_officer,
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/tier1/revolutionary,
		/obj/bitrunning/target/tier1/revolutionary,
	)
	replace_destroyed_targets = TRUE
	spawn_delay = 2 SECONDS

/obj/bitrunning/watcher_hunt_spawner/station_low/no_replace
	replace_destroyed_targets = FALSE
	spawn_delay = 1.5 SECONDS

/obj/bitrunning/watcher_hunt_spawner/station_medium
	spawn_order = list(
		/obj/bitrunning/target/tier2/cultist,
		/obj/bitrunning/target/bad/security_officer,
		/obj/bitrunning/target/tier2/cultist,
		/obj/bitrunning/target/tier2/cultist,
		/obj/bitrunning/target/tier2/cultist,
		/obj/bitrunning/target/tier2/cultist,
		/obj/bitrunning/target/bad/security_officer,
		/obj/bitrunning/target/tier2/cultist,
	)
	replace_destroyed_targets = TRUE
	spawn_delay = 2 SECONDS

/obj/bitrunning/watcher_hunt_spawner/station_medium/no_replace
	replace_destroyed_targets = FALSE
	spawn_delay = 1.5 SECONDS

/obj/bitrunning/watcher_hunt_spawner/station_high
	spawn_order = list(
		/obj/bitrunning/target/tier3/wizard,
		/obj/bitrunning/target/bad/security_officer,
		/obj/bitrunning/target/tier3/wizard,
		/obj/bitrunning/target/tier3/wizard,
		/obj/bitrunning/target/tier3/wizard,
		/obj/bitrunning/target/bad/ian,
		/obj/bitrunning/target/tier3/wizard,
		/obj/bitrunning/target/tier3/wizard,
	)
	replace_destroyed_targets = TRUE
	spawn_delay = 2 SECONDS

/obj/bitrunning/watcher_hunt_spawner/station_high/no_replace
	replace_destroyed_targets = FALSE
	spawn_delay = 1.5 SECONDS

/obj/bitrunning/watcher_hunt_spawner/station_max
	spawn_order = list(
		/obj/bitrunning/target/tier4/clown
	)
	replace_destroyed_targets = FALSE

/obj/bitrunning/watcher_hunt_teleporter
	name = "Watcher Hunt Teleporter"
	desc = "If you can see this, file a bug report!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "animatronic_node"
	icon_state = "animatronic_node"
	color = "#00FF00"
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE

/obj/bitrunning/watcher_hunt_teleporter/Initialize(mapload)
	. = ..()
	alpha = 0

/obj/machinery/digital_clock/score_card
	name = "score tracker"
	desc = "How many points you've gotten versus how many you need!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "score_machine"
	flags_1 = INDESTRUCTIBLE
	var/started = FALSE
	var/finished = FALSE
	var/current_round = 0
	var/current_multiplier = 1
	var/current_score = 0
	var/target_score = 0
	var/round_timer
	var/round_length = 30 SECONDS
	var/list/found_spawners = list()

/obj/machinery/digital_clock/score_card/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!started)
		started = TRUE
		current_score = 0
		update_icon()
		start_next_round()

/obj/machinery/digital_clock/score_card/proc/start_next_round()
	if(finished)
		return
	for(var/obj/bitrunning/watcher_hunt_spawner/spawner in found_spawners)
		spawner.fucking_real_spawn_order_fuck_you_byond_stupid_fucking_language = spawner.spawn_order.Copy()
		spawner.spawn_target() // force the first spawn to keep shit in sync
		spawner.spawn_timer = addtimer(CALLBACK(spawner, TYPE_PROC_REF(/obj/bitrunning/watcher_hunt_spawner, spawn_target)), spawner.spawn_delay, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)

	round_timer = addtimer(CALLBACK(src, PROC_REF(time_out_round)), round_length, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)

/obj/machinery/digital_clock/score_card/proc/time_out_round()
	deltimer(round_timer)
	playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 100, FALSE)
	for(var/obj/bitrunning/watcher_hunt_spawner/spawner in found_spawners)
		deltimer(spawner.spawn_timer)
		for(var/obj/target in spawner.current_targets)
			qdel(target)
	started = FALSE
	update_icon()

/obj/machinery/digital_clock/score_card/proc/check_score()
	if(current_score >= target_score)
		deltimer(round_timer)
		for(var/obj/bitrunning/watcher_hunt_spawner/spawner in found_spawners)
			deltimer(spawner.spawn_timer)
			for(var/obj/target in spawner.current_targets)
				qdel(target)
		finished = TRUE
		say("Target quota reached! Thank you for being a reformed employee!")
		say("Deposit this box to return to reality!")
		new /obj/structure/closet/crate/secure/bitrunning/encrypted/security(get_step(src, SOUTH))

/obj/machinery/digital_clock/score_card/update_time()
	var/current_score_text = "[current_score]"
	var/target_score_text = "[target_score]"
	var/zeroes_to_add_current = 6 - length(current_score_text)
	var/zeroes_to_add_target = 6 - length(target_score_text)
	for(var/i in 1 to zeroes_to_add_current)
		current_score_text = "0[current_score_text]"
	for(var/i in 1 to zeroes_to_add_target)
		target_score_text = "0[target_score_text]"
	var/return_overlays = list()

	if(!started)
		var/mutable_appearance/click_me_point = mutable_appearance('icons/hud/screen_gen.dmi', "arrow_perma", offset_spokesman = src, plane = POINT_PLANE)
		click_me_point.pixel_z = 10
		return_overlays += click_me_point
		return return_overlays

	var/current_offset_x = -20

	current_offset_x = -16
	for(var/i in 1 to 6)
		var/number_to_use = "+[current_score_text[i]]"
		var/target_number_to_use = "+[target_score_text[i]]"
		var/mutable_appearance/current_number = mutable_appearance('icons/obj/machines/bitrunning.dmi', number_to_use)
		var/mutable_appearance/current_number_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', number_to_use, src, alpha = DISPLAY_PIXEL_ALPHA)
		var/mutable_appearance/target_number = mutable_appearance('icons/obj/machines/bitrunning.dmi', target_number_to_use)
		var/mutable_appearance/target_number_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', target_number_to_use, src, alpha = DISPLAY_PIXEL_ALPHA)
		current_number.pixel_z = 4
		current_number.pixel_w = current_offset_x
		current_number_e.pixel_z = 4
		current_number_e.pixel_w = current_offset_x
		target_number.pixel_z = -6
		target_number.pixel_w = current_offset_x
		target_number_e.pixel_z = -6
		target_number_e.pixel_w = current_offset_x
		current_offset_x += 4 // move 4 to the left every time
		return_overlays += current_number
		return_overlays += current_number_e
		return_overlays += target_number
		return_overlays += target_number_e

	return return_overlays

/obj/machinery/conveyor/auto/slow
	speed = 0.4

/obj/machinery/conveyor/auto/fast
	speed = 0.1

/obj/machinery/conveyor/auto/very_fast
	speed = 0.05

/obj/machinery/conveyor/auto/slow/inverted
	icon_state = "conveyor_map_inverted"
	flipped = TRUE

/obj/machinery/conveyor/auto/fast/inverted
	icon_state = "conveyor_map_inverted"
	flipped = TRUE

/obj/machinery/conveyor/auto/very_fast/inverted
	icon_state = "conveyor_map_inverted"
	flipped = TRUE
#undef DISPLAY_PIXEL_ALPHA
