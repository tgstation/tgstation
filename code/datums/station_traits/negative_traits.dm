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

///A negative trait that reduces the amount of products available from vending machines throughout the station.
/datum/station_trait/vending_shortage
	name = "Vending products shortage"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	can_revert = FALSE //Because it touches every maploaded vending machine on the station.
	report_message = "We haven't had the time to take care of the station's vending machines. Some may be tilted, and some products may be unavailable."
	trait_to_give = STATION_TRAIT_VENDING_SHORTAGE

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
	for(var/obj/machinery/power/apc/apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
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
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 3
	event_control_path = /datum/round_event_control/ion_storm
	weight_multiplier = 2

/datum/station_trait/random_event_weight_modifier/rad_storms
	name = "Radiation Stormfront"
	report_message = "A radioactive stormfront is passing through your station's system. Expect an increased likelihood of radiation storms passing over your station, as well the potential for multiple radiation storms to occur during your shift."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 2
	event_control_path = /datum/round_event_control/radiation_storm
	weight_multiplier = 1.5
	max_occurrences_modifier = 2

/datum/station_trait/random_event_weight_modifier/dust_storms
	name = "Dust Stormfront"
	report_message = "The space around your station is clouded by heavy pockets of space dust. Expect an increased likelyhood of space dust storms damaging the station hull."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 2
	event_control_path = /datum/round_event_control/meteor_wave/dust_storm
	weight_multiplier = 2
	max_occurrences_modifier = 3

/datum/station_trait/cramped_escape_pods
	name = "Cramped Escape Pods"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to budget cuts, we have downsized your escape pods."
	trait_to_give = STATION_TRAIT_SMALLER_PODS
	blacklist = list(/datum/station_trait/luxury_escape_pods)

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
						vendor_to_trash.tilt(get_turf(vendor_to_trash), 0) // crit effects can do some real weird shit, lets disable it

					if(prob(50))
						vendor_to_trash.take_damage(150)
					continue

				if(istype(current_thing, /obj/structure/fireaxecabinet)) //A staple of revolutionary behavior
					current_thing.take_damage(90)
					continue

				if(istype(current_thing, /obj/item/bedsheet/captain))
					new /obj/item/bedsheet/rev(current_thing.loc)
					qdel(current_thing)
					continue

				if(istype(current_thing, /obj/item/bedsheet/captain/double))
					new /obj/item/bedsheet/rev/double(current_thing.loc)
					qdel(current_thing)
					continue

			CHECK_TICK

///Station traits that influence the space background and apply some unique effects!
/datum/station_trait/nebula
	name = "Nebula"
	trait_flags = STATION_TRAIT_ABSTRACT
	weight = 0

	show_in_report = TRUE

	///The parallax layer of the nebula
	var/nebula_layer = /atom/movable/screen/parallax_layer/random/space_gas
	///If set, gives the basic carp different colors
	var/carp_color_override

/datum/station_trait/nebula/New()
	. = ..()

	SSparallax.swap_out_random_parallax_layer(nebula_layer)

	//Color the carp in unique colors to better blend with the nebula
	if(carp_color_override)
		GLOB.carp_colors = carp_color_override

///Station nebula that incur some sort of effect if no shielding is created
/datum/station_trait/nebula/hostile
	trait_flags = STATION_TRAIT_ABSTRACT
	trait_processes = TRUE

	///Intensity of the nebula
	VAR_PRIVATE/nebula_intensity = -1
	///The max intensity of a nebula
	VAR_PROTECTED/maximum_nebula_intensity = 2 HOURS
	///How long it takes to go to the next nebula level/intensity
	VAR_PROTECTED/intensity_increment_time = INFINITE
	///Objects that we use to calculate the current shielding level
	var/list/shielding = list()

/datum/station_trait/nebula/hostile/process(seconds_per_tick)
	calculate_nebula_strength()

	apply_nebula_effect(nebula_intensity - get_shielding_level())

/datum/station_trait/nebula/hostile/on_round_start()
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(send_instructions)), 30 SECONDS)

///Announce to the station what's going on and what they need to do
/datum/station_trait/nebula/hostile/proc/send_instructions()
	return

///Calculate how strong we currently are
/datum/station_trait/nebula/hostile/proc/calculate_nebula_strength()
	nebula_intensity = min(STATION_TIME_PASSED() / intensity_increment_time, maximum_nebula_intensity)

///Check how strong the stations shielding is
/datum/station_trait/nebula/hostile/proc/get_shielding_level()
	var/shield_strength = 0
	for(var/atom/movable/shielder as anything in shielding)
		if(!is_station_level(shielder.z))
			continue
		var/datum/callback/callback = shielding[shielder]
		shield_strength += callback.Invoke()

	return shield_strength

///Add a shielding unit to ask for shielding
/datum/station_trait/nebula/hostile/proc/add_shielder(atom/movable/shielder, shielding_proc)
	shielding[shielder] = CALLBACK(shielder, shielding_proc)

	RegisterSignal(shielder, COMSIG_QDELETING, PROC_REF(remove_shielder))

///Remove a shielding unit from our tracking
/datum/station_trait/nebula/hostile/proc/remove_shielder(atom/movable/shielder)
	SIGNAL_HANDLER

	shielding.Remove(shielder)

///The station did not set up shielding, start creating effects
/datum/station_trait/nebula/hostile/proc/apply_nebula_effect(effect_strength = 0)
	return

/proc/add_to_nebula_shielding(atom/movable/shielder, nebula_type, shielding_proc)
	var/datum/station_trait/nebula/hostile/nebula = locate(nebula_type) in SSstation.station_traits
	if(!nebula)
		return FALSE

	nebula.add_shielder(shielder, shielding_proc)

/// Name of the glow we use for the radioation effect outside
#define GLOW_NEBULA "glow_nebula"

///The station will be inside a radioactive nebula! Space is radioactive and the station needs to start setting up nebula shielding
/datum/station_trait/nebula/hostile/radiation
	name = "Radioactive Nebula"
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_SPACE_BOUND //maybe when we can LOOK UP
	weight = 1
	show_in_report = TRUE
	report_message = "This station is located inside a radioactive nebula. Setting up nebula shielding is top-priority."
	trait_to_give = STATION_TRAIT_RADIOACTIVE_NEBULA

	blacklist = list(/datum/station_trait/random_event_weight_modifier/rad_storms)
	threat_reduction = 30
	dynamic_threat_id = "Radioactive Nebula"

	intensity_increment_time = 5 MINUTES
	maximum_nebula_intensity = 1 HOURS + 40 MINUTES

	nebula_layer = /atom/movable/screen/parallax_layer/random/space_gas/radioactive
	carp_color_override = list(
		COLOR_CARP_GREEN = 1,
		COLOR_CARP_TEAL = 1,
		COLOR_CARP_PALE_GREEN = 1,
		COLOR_CARP_DARK_GREEN = 1,
	)
	///When are we going to send them a care package?
	COOLDOWN_DECLARE(send_care_package_at)
	///How long does the storm have to last for us to send a care package?
	VAR_PROTECTED/send_care_package_time = 5 MINUTES
	///The glow of 'fake' radioactive objects in space
	var/nebula_radglow = "#66ff33"
	/// Area's that are part of the radioactive nebula
	var/radioactive_areas = /area/space

/datum/station_trait/nebula/hostile/radiation/New()
	. = ..()

	for(var/area/target as anything in get_areas(radioactive_areas))
		RegisterSignals(target, list(COMSIG_AREA_ENTERED, COMSIG_AREA_INITIALIZED_IN), PROC_REF(on_entered))
		RegisterSignal(target, COMSIG_AREA_EXITED, PROC_REF(on_exited))

/datum/station_trait/nebula/hostile/radiation/on_round_start()
	. = ..()

	//Let people order more nebula shielding
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/engineering/rad_nebula_shielding_kit]
	pack.special_enabled = TRUE

	//Give robotics some radiation protection modules for modsuits
	var/datum/supply_pack/supply_pack_modsuits = new /datum/supply_pack/engineering/rad_protection_modules()
	send_supply_pod_to_area(supply_pack_modsuits.generate(null), /area/station/science/robotics, /obj/structure/closet/supplypod/centcompod)

	//Send a nebula shielding unit to engineering
	var/datum/supply_pack/supply_pack_shielding = new /datum/supply_pack/engineering/rad_nebula_shielding_kit()
	if(!send_supply_pod_to_area(supply_pack_shielding.generate(null), /area/station/engineering/main, /obj/structure/closet/supplypod/centcompod))
		//if engineering isnt valid, just send it to the bridge
		send_supply_pod_to_area(supply_pack_shielding.generate(null), /area/station/command/bridge, /obj/structure/closet/supplypod/centcompod)

	// Let the viro know resistence is futile
	send_fax_to_area(new /obj/item/paper/fluff/radiation_nebula_virologist(), /area/station/medical/virology, "NT Virology Department", \
	force = TRUE, force_pod_type = /obj/structure/closet/supplypod/centcompod)

	//Disables radstorms, they don't really make sense since we already have the nebula causing storms
	var/datum/round_event_control/modified_event = locate(/datum/round_event_control/radiation_storm) in SSevents.control
	modified_event.weight = 0

///They entered space? START BOMBING WITH RADS HAHAHAHA. old_area can be null for new objects
/datum/station_trait/nebula/hostile/radiation/proc/on_entered(area/space, atom/movable/enterer, area/old_area)
	SIGNAL_HANDLER

	if(iscarbon(enterer))//Don't actually make EVERY. SINGLE. THING. RADIOACTIVE. Just irradiate people
		if(!istype(old_area, radioactive_areas)) //old area wasnt radioactive
			enterer.AddComponent( \
				/datum/component/radioactive_exposure, \
				minimum_exposure_time = NEBULA_RADIATION_MINIMUM_EXPOSURE_TIME, \
				irradiation_chance_base = RADIATION_EXPOSURE_NEBULA_BASE_CHANCE, \
				irradiation_chance_increment = RADIATION_EXPOSURE_NEBULA_CHANCE_INCREMENT, \
				irradiation_interval = RADIATION_EXPOSURE_NEBULA_CHECK_INTERVAL, \
				source = src, \
				radioactive_areas = radioactive_areas, \
			)

	else if(isobj(enterer)) //and fake the rest
		//outline clashes too much with other outlines and creates pretty ugly lines
		enterer.add_filter(GLOW_NEBULA, 2, list("type" = "drop_shadow", "color" = nebula_radglow, "size" = 2))

///Called when an atom leaves space, so we can remove the radiation effect
/datum/station_trait/nebula/hostile/radiation/proc/on_exited(area/space, atom/movable/exiter, direction)
	SIGNAL_HANDLER

	exiter.remove_filter(GLOW_NEBULA)
	// The component handles its own removal

/datum/station_trait/nebula/hostile/radiation/apply_nebula_effect(effect_strength = 0)
	//big bombad now
	if(effect_strength > 0)
		if(!SSweather.get_weather_by_type(/datum/weather/rad_storm/nebula))
			COOLDOWN_START(src, send_care_package_at, send_care_package_time)
			SSweather.run_weather(/datum/weather/rad_storm/nebula)

		//Send a care package to temporarily lift the storm!
		if(COOLDOWN_FINISHED(src, send_care_package_at))
			COOLDOWN_START(src, send_care_package_at, send_care_package_time)
			var/obj/machinery/nebula_shielding/emergency/rad_shield = /obj/machinery/nebula_shielding/emergency/radiation

			priority_announce(
				{"Is everything okay there? We're getting high radiation readings from inside the station. \
				We're sending an emergency shielding unit for now, it will last [initial(rad_shield.detonate_in) / (1 MINUTES)] minutes. \n\n\
				Set up the nebula shielding. You can order construction kits at cargo if yours have been lost.
				"}
			)

			addtimer(CALLBACK(src, PROC_REF(send_care_package)), 10 SECONDS)
		return

	//No storms, shielding is good!
	var/datum/weather/weather = SSweather.get_weather_by_type(/datum/weather/rad_storm/nebula)
	weather?.wind_down()
	COOLDOWN_RESET(src, send_care_package_at)

///Send a care package because it is not going well
/datum/station_trait/nebula/hostile/radiation/proc/send_care_package()
	new /obj/effect/pod_landingzone (get_safe_random_station_turf(), new /obj/structure/closet/supplypod/centcompod (), new /obj/machinery/nebula_shielding/emergency/radiation ())

/datum/station_trait/nebula/hostile/radiation/send_instructions()
	var/obj/machinery/nebula_shielding/shielder = /obj/machinery/nebula_shielding/radiation
	var/obj/machinery/gravity_generator/main/innate_shielding = /obj/machinery/gravity_generator/main
	//How long do we have untill the first shielding unit needs to be up?
	var/deadline = "[(initial(innate_shielding.radioactive_nebula_shielding) * intensity_increment_time) / (1 MINUTES)] minute\s"
	//For how long each shielding unit will protect for
	var/shielder_time = "[(initial(shielder.shielding_strength) * intensity_increment_time) / (1 MINUTES)] minute\s"
	//Max shielders, excluding the grav-gen to avoid confusion when that goes down
	var/max_shielders = ((maximum_nebula_intensity / intensity_increment_time)) / initial(shielder.shielding_strength)

	var/announcement = {"Your station has been constructed inside a radioactive nebula. \
		Standard spacesuits will not protect against the nebula and using them is strongly discouraged. \n\n\

		EXTREME IMPORTANCE: The station is falling deeper into the nebula, and the gravity generator's innate radiation shielding \
		will not hold very long. Your engineering department has been supplied with all the necessary supplies to set up \
		shields to protect against the nebula. Additional supply crates can be ordered at cargo. \n\n\
		You have [deadline] before the nebula enters the station. \
		Every shielding unit will provide an additional [shielder_time] of protection, fully protecting the station with [max_shielders] shielding units.
	"}

	priority_announce(announcement, sound = 'sound/misc/notice1.ogg')

	//Set the display screens to the radiation alert
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	signal.data["command"] = "alert"
	signal.data["picture_state"] = "radiation"

	var/atom/movable/virtualspeaker/virtual_speaker = new(null)
	frequency.post_signal(virtual_speaker, signal)

/datum/station_trait/nebula/hostile/radiation/get_decal_color(atom/thing_to_color, pattern)
	if(istype(get_area(thing_to_color), /area/station/hallway)) //color hallways green
		return COLOR_GREEN

///Starts a storm on roundstart
/datum/station_trait/storm
	trait_flags = STATION_TRAIT_ABSTRACT
	var/datum/weather/storm_type

/datum/station_trait/storm/on_round_start()
	. = ..()

	SSweather.run_weather(storm_type)

/// Calls down an eternal storm on planetary stations
/datum/station_trait/storm/foreverstorm
	name = "Forever Storm"
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_PLANETARY
	weight = 3
	show_in_report = TRUE
	report_message = "It looks like the storm is not gonna calm down anytime soon, stay safe out there."

	storm_type = /datum/weather/snow_storm/forever_storm

