#define SUNBEAM_OBLITERATION_RANGE_FIRE 2
#define SUNBEAM_OBLITERATION_RANGE_FLATTEN 1
#define SUNBEAM_OBLITERATION_COOLDOWN (0.2 SECONDS)
#define SUNBEAM_MOVEMENT_COOLDOWN (0.3 SECONDS)
#define SUNBEAM_DEFAULT_SCALE_X 2
#define SUNBEAM_DEFAULT_SCALE_Y 2
#define SUNBEAM_OVERLAYS 16

/obj/effect/sunbeam
	name = "\improper ICARUS Sunbeam"
	desc = "A beam of light from the sun."
	icon = 'monkestation/code/modules/assault_ops/icons/sunbeam.dmi'
	icon_state = "sunray_splash"
	throwforce = 100
	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	movement_type = PHASING | FLYING
	plane = ABOVE_LIGHTING_PLANE
	light_outer_range = 6
	light_color = "#ffbf10"
	/// A reference to the target we will move towards
	var/atom/target_atom
	/// How much do we offset the mid beam?
	var/beam_offset_y = 32
	/// Our sound loop.
	var/datum/looping_sound/sunbeam/soundloop
	/// Used to control how slowly the beam moves.
	var/movement_cooldown = SUNBEAM_MOVEMENT_COOLDOWN
	/// Our obliteration cooldown.
	var/obliteration_cooldown = SUNBEAM_OBLITERATION_COOLDOWN
	/// The range of fire to spawn.
	var/obliteration_range_fire = SUNBEAM_OBLITERATION_RANGE_FIRE
	/// The range of objects and atoms to be atomised.
	var/obliteration_range_flatten = SUNBEAM_OBLITERATION_RANGE_FLATTEN

	COOLDOWN_DECLARE(oblirerate_cooldown)
	COOLDOWN_DECLARE(movement_delay)

/obj/effect/sunbeam/Initialize(mapload, atom/target, movement_cooldown_override, obliteration_cooldown_override, obliteration_range_fire_override, obliteration_range_flatten_override, scale_x = SUNBEAM_DEFAULT_SCALE_X, scale_y = SUNBEAM_DEFAULT_SCALE_Y)
	. = ..()
	if(target)
		target_atom = target
	if(movement_cooldown_override)
		movement_cooldown = movement_cooldown_override
	if(obliteration_cooldown_override)
		obliteration_cooldown = obliteration_cooldown_override
	if(obliteration_range_fire_override)
		obliteration_range_fire = obliteration_range_fire_override
	if(obliteration_range_flatten_override)
		obliteration_range_flatten = obliteration_range_flatten_override

	START_PROCESSING(SSfastprocess, src)
	update_appearance()
	if(scale_x || scale_y)
		var/matrix/our_matrix = matrix()
		our_matrix.Scale(scale_x, scale_y)
		transform = our_matrix
	notify_ghosts("An ICARUS sunbeam has been launched! [target_atom ? "Towards: [target_atom.name]" : ""]",
		source = src,
		header = "Somethings burning!",
	)
	soundloop = new(src, TRUE)

/obj/effect/sunbeam/Destroy(force)
	QDEL_NULL(soundloop)
	return ..()

/obj/effect/sunbeam/update_overlays()
	. = ..()
	for(var/i in 1 to SUNBEAM_OVERLAYS)
		var/mutable_appearance/beam_overlay = mutable_appearance(icon, "sunray")
		beam_overlay.pixel_y = beam_offset_y * i
		. += beam_overlay

/obj/effect/sunbeam/process(seconds_per_tick)
	if(target_atom && COOLDOWN_FINISHED(src, movement_delay))
		step_towards(src, target_atom)
		COOLDOWN_START(src, movement_delay, movement_cooldown)

	if(COOLDOWN_FINISHED(src, oblirerate_cooldown))
		obliterate()

	if(get_turf(src) == get_turf(target_atom))
		qdel(src)

/obj/effect/sunbeam/proc/obliterate()
	if(obliteration_range_fire)
		for(var/turf/open/turf_to_incinerate in circle_range(src, obliteration_range_fire))
			turf_to_incinerate.hotspot_expose(5500)
			new /obj/effect/hotspot(turf_to_incinerate)

	if(obliteration_range_flatten)
		for(var/atom/atom_to_obliterate in circle_range(src, obliteration_range_flatten))
			if(isclosedturf(atom_to_obliterate))
				SSexplosions.highturf += atom_to_obliterate
				continue

			if(isfloorturf(atom_to_obliterate))
				var/turf/open/floor/open_turf = atom_to_obliterate
				open_turf.break_tile_to_plating()

			if(isobj(atom_to_obliterate))
				var/obj/object_to_obliterate = atom_to_obliterate
				object_to_obliterate.take_damage(INFINITY, BRUTE, NONE, TRUE, dir, INFINITY)
				continue

			if(isliving(atom_to_obliterate))
				var/mob/living/mob_to_obliterate = atom_to_obliterate
				mob_to_obliterate.apply_damage(200, BURN)
				continue

	COOLDOWN_START(src, oblirerate_cooldown, obliteration_cooldown)

/datum/looping_sound/sunbeam
	mid_sounds = list('monkestation/code/modules/assault_ops/sound/sunbeam_loop.ogg' = 1)
	mid_length = 6.7 SECONDS
	volume = 100
	extra_range = 25

/client/proc/spawn_sunbeam()
	set category = "Admin.Fun"
	set name = "Spawn Sunbeam"
	set desc = "Spawns an ICARUS sunbeam at your location and sends it towards a target."

	var/mob/living/target_mob = tgui_input_list(usr, "Select a mob", "Mob", GLOB.mob_living_list)

	if(!target_mob)
		return

	var/edit_ranges = tgui_alert(usr, "Change beam specifications?", "Beam Specifications", list("Yes", "No"))

	if(edit_ranges == "Yes")
		var/edit_range_fire = tgui_input_number(usr, "Fire range in tiles", "Fire Range", SUNBEAM_OBLITERATION_RANGE_FIRE, 20, 0)
		var/edit_range_flatten = tgui_input_number(usr, "Flatten range in tiles", "Flatten Range", SUNBEAM_OBLITERATION_RANGE_FLATTEN, 20, 0)
		var/edit_cooldown = tgui_input_number(usr, "Cooldown in seconds", "Cooldown", SUNBEAM_OBLITERATION_COOLDOWN, 20, 0)
		var/edit_movement_cooldown = tgui_input_number(usr, "Movement cooldown in seconds", "Movement Cooldown", SUNBEAM_MOVEMENT_COOLDOWN, 20, 0)
		var/edit_scale_x = tgui_input_number(usr, "Scale X", "Scale X", SUNBEAM_DEFAULT_SCALE_X, 20, 0)
		var/edit_scale_y = tgui_input_number(usr, "Scale Y", "Scale Y", SUNBEAM_DEFAULT_SCALE_Y, 20, 0)

		new /obj/effect/sunbeam(usr, target_mob, edit_movement_cooldown, edit_cooldown, edit_range_fire, edit_range_flatten, edit_scale_x, edit_scale_y)
		return

	new /obj/effect/sunbeam(usr, target_mob)


/datum/round_event_control/icarus_sunbeam
	name = "ICARUS Weapons System Ignition"
	typepath = /datum/round_event/icarus_sunbeam
	max_occurrences = 0
	weight = 0
	category = EVENT_CATEGORY_SPACE
	description = "Forces the ICARUS weapons system to fire a sunbeam at a random location. Causing massive devistation to the station."

/datum/round_event/icarus_sunbeam
	announce_when = 1 // Instant announcement

/datum/round_event/icarus_sunbeam/announce(fake)
	priority_announce("/// ICARUS SUNBEAM WEAPONS SYSTEM ACTIVATED, USE EXTREME CAUTION! ///", "GoldenEye Defence Network", ANNOUNCER_ICARUS)
	alert_sound_to_playing('monkestation/code/modules/assault_ops/sound/sunbeam_fire.ogg')

/datum/round_event/icarus_sunbeam/start()
	var/startside = pick(GLOB.cardinals)
	var/turf/end_turf = get_edge_target_turf(get_safe_random_station_turf(), turn(startside, 180))
	var/turf/start_turf = spaceDebrisStartLoc(startside, end_turf.z)
	new /obj/effect/sunbeam(start_turf, end_turf)

#undef SUNBEAM_OBLITERATION_RANGE_FIRE
#undef SUNBEAM_OBLITERATION_RANGE_FLATTEN
#undef SUNBEAM_OBLITERATION_COOLDOWN
#undef SUNBEAM_MOVEMENT_COOLDOWN
#undef SUNBEAM_DEFAULT_SCALE_X
#undef SUNBEAM_DEFAULT_SCALE_Y

///This is quite franlky the most important proc relating to global sounds, it uses area definition to play sounds depending on your location, and respects the players announcement volume. Generally if you're sending an announcement you want to use priority_announce.
/proc/alert_sound_to_playing(soundin, vary = FALSE, frequency = 0, falloff = FALSE, channel = 0, pressure_affected = FALSE, sound/S, override_volume = FALSE, list/players)
	if(!S)
		S = sound(get_sfx(soundin))
	var/static/list/quiet_areas = typecacheof(typesof(/area/station/maintenance) + typesof(/area/space) + typesof(/area/station/commons/dorms))
	if(!players)
		players = GLOB.player_list
	for(var/m in players)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			if(M.client?.prefs.read_preference(/datum/preference/toggle/sound_announcements) && M.can_hear())
				if(override_volume)
					M.playsound_local(get_turf(M), S, 80, FALSE)
				else
					var/area/A = get_area(M)
					if(is_type_in_typecache(A, quiet_areas)) //These areas don't hear it as loudly
						M.playsound_local(get_turf(M), S, 10, FALSE)
					else
						M.playsound_local(get_turf(M), S, 70, FALSE)
