/datum/station_trait/carp_infestation
	name = "Carp infestation"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Dangerous fauna is present in the area of this station."
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Distant supply lines"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Due to the distance to our normal supply lines, cargo orders are more expensive."
	blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 1.2

/datum/station_trait/late_arrivals
	name = "Late Arrivals"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Sorry for that, we didn't expect to fly into that vomiting goose while bringing you to your new station."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	blacklist = list(/datum/station_trait/random_spawns, /datum/station_trait/hangover)

/datum/station_trait/random_spawns
	name = "Drive-by landing"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Sorry for that, we missed your station by a few miles, so we just launched you towards your station in pods. Hope you don't mind!"
	trait_to_give = STATION_TRAIT_RANDOM_ARRIVALS
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/hangover)

/datum/station_trait/hangover
	name = "Hangover"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Ohh....Man....That mandatory office party from last shift...God that was awesome..I woke up in some random toilet 3 sectors away..."
	trait_to_give = STATION_TRAIT_HANGOVER
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/random_spawns)

/datum/station_trait/hangover/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/hangover/revert()
	for (var/obj/effect/landmark/start/hangover/hangover_spot in GLOB.start_landmarks_list)
		QDEL_LIST(hangover_spot.hangover_debris)

	return ..()

/datum/station_trait/hangover/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned_mob)
	SIGNAL_HANDLER

	if(!prob(35))
		return
	var/obj/item/hat = pick(
		/obj/item/clothing/head/costume/sombrero/green,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/head/costume/ushanka,
		/obj/item/clothing/head/costume/cardborg,
		/obj/item/clothing/head/costume/pirate,
		/obj/item/clothing/head/cone,
		)
	hat = new hat(spawned_mob)
	spawned_mob.equip_to_slot_or_del(hat, ITEM_SLOT_HEAD)


/datum/station_trait/blackout
	name = "Blackout"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Station lights seem to be damaged, be safe when starting your shift today."

/datum/station_trait/blackout/on_round_start()
	. = ..()
	for(var/obj/machinery/power/apc/apc as anything in GLOB.apcs_list)
		if(is_station_level(apc.z) && prob(60))
			apc.overload_lighting()

/datum/station_trait/empty_maint
	name = "Cleaned out maintenance"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers cleaned out most of the junk in the maintenace areas."
	blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT

	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/overflow_job_bureaucracy
	name = "Overflow bureaucracy mistake"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	var/chosen_job_name

/datum/station_trait/overflow_job_bureaucracy/New()
	. = ..()
	RegisterSignal(SSjob, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(set_overflow_job_override))

/datum/station_trait/overflow_job_bureaucracy/get_report()
	return "[name] - It seems for some reason we put out the wrong job-listing for the overflow role this shift...I hope you like [chosen_job_name]s."

/datum/station_trait/overflow_job_bureaucracy/proc/set_overflow_job_override(datum/source)
	SIGNAL_HANDLER
	var/datum/job/picked_job = pick(SSjob.joinable_occupations)
	chosen_job_name = lowertext(picked_job.title) // like Chief Engineers vs like chief engineers
	SSjob.set_overflow_role(picked_job.type)

/datum/station_trait/slow_shuttle
	name = "Slow Shuttle"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to distance to our supply station, the cargo shuttle will have a slower flight time to your cargo department."
	blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5

/datum/station_trait/bot_languages
	name = "Bot Language Matrix Malfunction"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 4
	show_in_report = TRUE
	report_message = "Your station's friendly bots have had their language matrix fried due to an event, resulting in some strange and unfamiliar speech patterns."
	trait_to_give = STATION_TRAIT_BOTS_GLITCHED

/datum/station_trait/bot_languages/New()
	. = ..()
	// What "caused" our robots to go haywire (fluff)
	var/event_source = pick("an ion storm", "a syndicate hacking attempt", "a malfunction", "issues with your onboard AI", "an intern's mistakes", "budget cuts")
	report_message = "Your station's friendly bots have had their language matrix fried due to [event_source], resulting in some strange and unfamiliar speech patterns."

/datum/station_trait/bot_languages/on_round_start()
	. = ..()
	// All bots that exist round start on station Z OR on the escape shuttle have their set language randomized.
	for(var/mob/living/simple_animal/bot/found_bot as anything in GLOB.bots_list)
		found_bot.randomize_language_if_on_station()

/datum/station_trait/revenge_of_pun_pun
	name = "Revenge of Pun Pun"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2

	// Way too much is done on atoms SS to be reverted, and it'd look
	// kinda clunky on round start. It's not impossible to make this work,
	// but it's a project for...someone else.
	can_revert = FALSE

	var/static/list/weapon_types

/datum/station_trait/revenge_of_pun_pun/New()
	if(!weapon_types)
		weapon_types = list(
			/obj/item/chair = 20,
			/obj/item/tailclub = 10,
			/obj/item/melee/baseball_bat = 10,
			/obj/item/melee/chainofcommand/tailwhip = 10,
			/obj/item/melee/chainofcommand/tailwhip/kitty = 10,
			/obj/item/reagent_containers/cup/glass/bottle = 20,
			/obj/item/reagent_containers/cup/glass/bottle/kong = 5,
			/obj/item/switchblade/extended = 10,
			/obj/item/sign/random = 10,
			/obj/item/gun/ballistic/automatic/pistol = 1,
		)

	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(arm_monke))

/datum/station_trait/revenge_of_pun_pun/proc/arm_monke()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/species/monkey/punpun/punpun = GLOB.the_one_and_only_punpun
	if(!punpun)
		return
	var/weapon_type = pick_weight(weapon_types)
	var/obj/item/weapon = new weapon_type
	if(!punpun.put_in_l_hand(weapon) && !punpun.put_in_r_hand(weapon))
		// Guess they did all this with whatever they have in their hands already
		qdel(weapon)
		weapon = punpun.get_active_held_item() || punpun.get_inactive_held_item()

	weapon?.add_mob_blood(punpun)
	punpun.add_mob_blood(punpun)

	new /datum/ai_controller/monkey/angry(punpun)

	var/area/place = get_area(punpun)

	var/list/area_open_turfs = list()
	for(var/turf/location in place)
		if(location.density)
			continue
		area_open_turfs += location

	punpun.forceMove(pick(area_open_turfs))

	for(var/i in 1 to rand(10, 40))
		new /obj/effect/decal/cleanable/blood(pick(area_open_turfs))

	var/list/blood_path = list()
	for(var/i in 1 to 10) // Only 10 attempts
		var/turf/destination = pick(area_open_turfs)
		var/turf/next_step = get_step_to(punpun, destination)
		for(var/k in 1 to 30) // Max 30 steps
			if(!next_step)
				break
			blood_path += next_step
			next_step = get_step_to(next_step, destination)
		if(length(blood_path))
			break
	if(!length(blood_path))
		CRASH("Unable to make a path from punpun")

	var/turf/last_location
	for(var/turf/location as anything in blood_path)
		last_location = location

		if(prob(80))
			new /obj/effect/decal/cleanable/blood(location)

		if(prob(50))
			var/static/blood_types = list(
				/obj/effect/decal/cleanable/blood/splatter,
				/obj/effect/decal/cleanable/blood/gibs,
			)
			var/blood_type = pick(blood_types)
			new blood_type(get_turf(pick(orange(location, 2))))

	new /obj/effect/decal/cleanable/blood/gibs/torso(last_location)

// Abstract station trait used for traits that modify a random event in some way (their weight or max occurrences).
/datum/station_trait/random_event_weight_modifier
	name = "Random Event Modifier"
	report_message = "A random event has been modified this shift! Someone forgot to set this!"
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_ABSTRACT
	weight = 0

	/// The path to the round_event_control that we modify.
	var/event_control_path
	/// Multiplier applied to the weight of the event.
	var/weight_multiplier = 1
	/// Flat modifier added to the amount of max occurances the random event can have.
	var/max_occurrences_modifier = 0

/datum/station_trait/random_event_weight_modifier/on_round_start()
	. = ..()
	var/datum/round_event_control/modified_event = locate(event_control_path) in SSevents.control
	if(!modified_event)
		CRASH("[type] could not find a round event controller to modify on round start (likely has an invalid event_control_path set)!")

	modified_event.weight *= weight_multiplier
	modified_event.max_occurrences += max_occurrences_modifier

/datum/station_trait/random_event_weight_modifier/ion_storms
	name = "Ionic Stormfront"
	report_message = "An ionic stormfront is passing over your station's system. Expect an increased likelihood of ion storms afflicting your station's silicon units."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = NONE
	weight = 3
	event_control_path = /datum/round_event_control/ion_storm
	weight_multiplier = 2

/datum/station_trait/random_event_weight_modifier/rad_storms
	name = "Radiation Stormfront"
	report_message = "A radioactive stormfront is passing through your station's system. Expect an increased likelihood of radiation storms passing over your station, as well the potential for multiple radiation storms to occur during your shift."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = NONE
	weight = 2
	event_control_path = /datum/round_event_control/radiation_storm
	weight_multiplier = 1.5
	max_occurrences_modifier = 2

/datum/station_trait/cramped_escape_pods
	name = "Cramped Escape Pods"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to budget cuts, we have downsized your escape pods."
	trait_to_give = STATION_TRAIT_SMALLER_PODS
	blacklist = list(/datum/station_trait/luxury_escape_pods)

///A special trait, used only for when a revolution was won in the previous round. See /obj/effect/mapping_helpers/revolution_trash for more information.
/datum/station_trait/revolutionary_trashing
	name = "Post-Revolutionary Fervor"
	show_in_report = TRUE
	report_message = "Your station was recently reclaimed from a revolutionary commune. We couldn't clean up after them in time."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_to_give = STATION_TRAIT_REVOLUTIONARY_TRASHING
	weight = 2
	///The IDs of the graffiti designs that we will generate.
	var/static/list/trash_talk = list(
		"amyjon",
		"antilizard",
		"body",
		"cyka",
		"danger",
		"electricdanger",
		"face",
		"guy",
		"matt",
		"peace",
		"poseur tag",
		"prolizard",
		"radiation",
		"revolution",
		"shotgun",
		"skull",
		"splatter",
		"star",
		"stickman",
		"toilet",
		"toolbox",
		"uboa",
	)

/datum/station_trait/revolutionary_trashing/on_round_start()
	. = ..()

	INVOKE_ASYNC(src, PROC_REF(trash_this_place)) //Must be called asynchronously

/**
 * "Trashes" the command areas of the station.
 *
 * Creates random graffiti and damages certain machinery/structures in the
 * command areas of the station.
 */

/datum/station_trait/revolutionary_trashing/proc/trash_this_place()
	for(var/area/station/command/area_to_trash in GLOB.areas)

		for(var/turf/current_turf as anything in area_to_trash.get_contained_turfs())
			if(isclosedturf(current_turf))
				continue
			if(prob(25))
				var/obj/effect/decal/cleanable/crayon/created_art
				created_art = new(current_turf, RANDOM_COLOUR, pick(trash_talk))
				created_art.pixel_x = rand(-10, 10)
				created_art.pixel_y = rand(-10, 10)

			if(prob(0.01))
				new /obj/effect/mob_spawn/corpse/human/assistant(current_turf)
				continue

			for(var/atom/current_thing as anything in current_turf.contents)
				if(istype(current_thing, /obj/machinery/light) && prob(40))
					var/obj/machinery/light/light_to_smash = current_thing
					light_to_smash.break_light_tube(skip_sound_and_sparks = TRUE)
					continue

				if(istype(current_thing, /obj/structure/window))
					if(prob(15))
						current_thing.take_damage(rand(30, 90))
					continue

				if(istype(current_thing, /obj/structure/table) && prob(40))
					current_thing.take_damage(100)
					continue

				if(istype(current_thing, /obj/structure/chair) && prob(60))
					current_thing.take_damage(150)
					continue

				if(istype(current_thing, /obj/machinery/computer) && prob(30))
					if(istype(current_thing, /obj/machinery/computer/communications))
						continue //To prevent the shuttle from getting autocalled at the start of the round
					current_thing.take_damage(160)
					continue

				if(istype(current_thing, /obj/machinery/vending) && prob(45))
					var/obj/machinery/vending/vendor_to_trash = current_thing
					if(prob(50))
						vendor_to_trash.tilt(get_turf(vendor_to_trash))

					if(prob(50))
						vendor_to_trash.take_damage(150)
					continue

				if(istype(current_thing, /obj/structure/fireaxecabinet)) //A staple of revolutionary behavior
					current_thing.take_damage(90)
					continue

			CHECK_TICK
