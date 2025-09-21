/obj/effect/decal/cleanable/blood
	name = "pool of blood"
	desc = "It's slippery and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	beauty = -100
	clean_type = CLEAN_TYPE_BLOOD
	color = BLOOD_COLOR_RED

	/// Amount of blood, in units, in this decal
	/// Spent when drying or making footprints
	var/bloodiness = BLOOD_AMOUNT_PER_DECAL
	/// Can this decal dry out?
	var/can_dry = TRUE
	/// Has this decal dried out already?
	var/dried = FALSE
	/// If TRUE our bloodiness decreases over time as we dry out
	var/decay_bloodiness = TRUE
	/// How long we have until the decal fully dries out
	var/drying_time = 5 MINUTES
	/// How much time it took us to dry from the start to the end
	var/total_dry_time = null
	/// Emissive value of the blood pool, if any
	var/emissive_alpha = 0

	/// The "base name" of the blood, IE the "pool of" in "pool of blood"
	var/base_name = "pool of"
	/// Suffix added to the name so we can have "blood trail" where "trail" is the suffix
	var/base_suffix = null
	/// When dried, this is prefixed to the name
	var/dry_prefix = "dried"
	/// When dried, this becomes the desc of the blood
	var/dry_desc = "Looks like it's been here a while. Eew."

/*
 * diseases - List of diseases to add to this decal on init
 * blood_or_dna - Either a blood type which will get added, or a full list of DNA
 */
/obj/effect/decal/cleanable/blood/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna = get_default_blood_type())
	var/can_hold_viruses = TRUE
	if(istype(blood_or_dna, /datum/blood_type))
		var/datum/blood_type/default_type = blood_or_dna
		can_hold_viruses = default_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA
	else if (islist(blood_or_dna))
		can_hold_viruses = FALSE
		for (var/blood_key in blood_or_dna)
			var/datum/blood_type/blood_type = blood_or_dna[blood_key]
			if (blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA)
				can_hold_viruses = TRUE
				break
	. = ..(diseases = can_hold_viruses ? diseases : null)
	if(islist(blood_or_dna))
		add_blood_DNA(blood_or_dna)
	else if(istype(blood_or_dna, /datum/blood_type))
		var/datum/blood_type/default_type = blood_or_dna
		add_blood_DNA(list(default_type.dna_string = default_type))

	if(dried)
		dry()
	else if(can_dry)
		total_dry_time = drying_time
		START_PROCESSING(SSblood_drying, src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if (bloodiness || GET_ATOM_BLOOD_DECAL_LENGTH(src))
		update_appearance()

/obj/effect/decal/cleanable/blood/Destroy()
	STOP_PROCESSING(SSblood_drying, src)
	return ..()

/// Returns the default blood type for this decal for maploaded decals
/obj/effect/decal/cleanable/blood/proc/get_default_blood_type()
	return random_human_blood_type()

// Add "bloodiness" of this blood's type to the human's shoes
/obj/effect/decal/cleanable/blood/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(dried)
		return

	if(isliving(AM) && bloodiness >= 40)
		SEND_SIGNAL(AM, COMSIG_STEP_ON_BLOOD, src)

/obj/effect/decal/cleanable/blood/update_name(updates)
	. = ..()
	name = initial(name)
	if(base_name)
		name = "[base_name] [get_blood_string()]"
	if(base_suffix)
		name = "[base_name ? name : get_blood_string()] [base_suffix]"
	if(dried && dry_prefix)
		name = "[dry_prefix] [name]"

/obj/effect/decal/cleanable/blood/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(dried && dry_desc)
		desc = dry_desc

/// Returns a string of all the blood reagents in the blood
/obj/effect/decal/cleanable/blood/proc/get_blood_string()
	var/list/blood_DNA = GET_ATOM_BLOOD_DECALS(src)
	var/list/all_blood_names = list()
	for(var/dna_sample in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[dna_sample]
		all_blood_names |= LOWER_TEXT(blood_type.get_blood_name())
	return english_list(all_blood_names, nothing_text = "blood")

/obj/effect/decal/cleanable/blood/update_overlays()
	. = ..()
	if(icon_state && emissive_alpha && emissive_alpha < alpha && !dried)
		. += blood_emissive(icon, icon_state)

/obj/effect/decal/cleanable/blood/proc/blood_emissive(icon_to_use, icon_state_to_use)
	return emissive_appearance(icon_to_use, icon_state_to_use, src, alpha = 255 * emissive_alpha / alpha, effect_type = EMISSIVE_NO_BLOOM)

/obj/effect/decal/cleanable/blood/lazy_init_reagents()
	if (reagents)
		return reagents

	var/list/blood_DNA = GET_ATOM_BLOOD_DNA(src)
	var/list/reagents_to_add = list()
	for(var/dna_sample in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[dna_sample]
		reagents_to_add += blood_type.reagent_type

	create_reagents(round(bloodiness * BLOOD_TO_UNITS_MULTIPLIER, CHEMICAL_VOLUME_ROUNDING))
	var/num_reagents = length(reagents_to_add)
	for(var/reagent_type in reagents_to_add)
		reagents.add_reagent(reagent_type, round(bloodiness * BLOOD_TO_UNITS_MULTIPLIER / num_reagents, CHEMICAL_VOLUME_ROUNDING))
	return reagents

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/merger)
	if(merger.dried) // New blood will lie on dry blood
		return FALSE
	return ..()

/obj/effect/decal/cleanable/blood/handle_merge_decal(obj/effect/decal/cleanable/blood/merger)
	. = ..()
	merger.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	merger.adjust_bloodiness(bloodiness)

/obj/effect/decal/cleanable/blood/process(seconds_per_tick)
	if(dried || !can_dry)
		return PROCESS_KILL

	if(decay_bloodiness)
		adjust_bloodiness(-bloodiness / drying_time * seconds_per_tick * 1 SECONDS, ignore_timer = TRUE)

	drying_time -= seconds_per_tick * 1 SECONDS
	if(drying_time <= 0)
		dry()

/// Slows down the drying time by a given amount,
/// then updates the effect, meaning the animation will slow down
/obj/effect/decal/cleanable/blood/proc/slow_dry(by_amount)
	drying_time += by_amount
	total_dry_time += by_amount
	update_atom_colour()

/// This is what actually "dries" the blood
/obj/effect/decal/cleanable/blood/proc/dry()
	dried = TRUE
	// Not deleting as doing so would cause reagents to get lazyloaded again
	reagents?.clear_reagents()
	update_appearance()
	update_atom_colour()
	STOP_PROCESSING(SSblood_drying, src)

/// Increments or decrements the bloodiness value
/obj/effect/decal/cleanable/blood/proc/adjust_bloodiness(by_amount, ignore_timer = FALSE)
	if(by_amount == 0)
		return FALSE

	if(QDELING(src))
		return FALSE

	bloodiness = clamp((bloodiness + by_amount), 0, BLOOD_POOL_MAX)
	if (bloodiness == 0)
		dry()
	else if (ignore_timer)
		slow_dry(5 SECONDS * by_amount * BLOOD_TO_UNITS_MULTIPLIER)
	return TRUE

/obj/effect/decal/cleanable/blood/update_atom_colour()
	. = ..()
	update_blood_color()

// When color changes we need to update the drying animation
/obj/effect/decal/cleanable/blood/proc/update_blood_color()
	var/base_color = BLOOD_COLOR_RED
	// Get a default color based on DNA if it ends up unset somehow
	var/list/blood_DNA = GET_ATOM_BLOOD_DECALS(src)
	if (!length(blood_DNA)) // In case we're only composed of stuff that doesn't normally have a visual
		blood_DNA = GET_ATOM_BLOOD_DNA(src)
	if (length(blood_DNA))
		base_color = get_color_from_blood_list(blood_DNA)

	if (!color)
		color = base_color

	// Stop ongoing drying animations
	animate(src)

	var/dried_color = get_dried_color(base_color)
	// If it's dried (or about to dry) we can just set color directly
	if(dried || drying_time <= 0)
		color = dried_color
		return TRUE

	if(!total_dry_time)
		return FALSE

	var/dry_coeff = round(1 - drying_time / total_dry_time, 0.01)
	// Otherwise set the color to what it should be at the current drying progress, then animate down to the dried color if we can
	color = BlendRGB(color, dried_color, dry_coeff)
	if(can_dry)
		animate(src, time = drying_time, color = dried_color)
	return TRUE

/// Calculates and returns either an RGB or a matrix color for dried blood, depending on whever our current color is RGB or matrix
/// Because BYOND does *not* like animating from text to matrix and vice versa
/obj/effect/decal/cleanable/blood/proc/get_dried_color(base_color)
	var/list/starting_color = rgb2num(base_color)

	if (!starting_color)
		starting_color = list(255, 255, 255)

	// We want a fixed offset for a fixed drop in color intensity, plus a scaling offset based on our strongest color
	// The scaling offset helps keep dark colors from turning black, while also ensurse bright colors don't stay super bright
	var/max_color = max(starting_color[1], starting_color[2], starting_color[3])
	var/red_offset = 50 + (75 * (starting_color[1] / max_color))
	var/green_offset = 50 + (75 * (starting_color[2] / max_color))
	var/blue_offset = 50 + (75 * (starting_color[3] / max_color))

	// If the color is already decently dark, we should reduce the offsets even further
	// This is intended to prevent already dark blood (mixed blood in particular) from becoming full black
	var/strength = starting_color[1] + starting_color[2] + starting_color[3]
	if(strength <= 192)
		red_offset *= 0.5
		green_offset *= 0.5
		blue_offset *= 0.5

	// Finally, get this show on the road
	return rgb(
		clamp(starting_color[1] - red_offset, 0, 255),
		clamp(starting_color[2] - green_offset, 0, 255),
		clamp(starting_color[3] - blue_offset, 0, 255),
	)

/obj/effect/decal/cleanable/blood/old
	bloodiness = 0
	dried = TRUE
	color = BLOOD_COLOR_DRIED // Just for mappers. Overriden in init

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180
	is_mopped = FALSE

/obj/effect/decal/cleanable/blood/splatter/over_window/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

/obj/effect/decal/cleanable/blood/tracks
	desc = "They look like tracks left by wheels."
	icon_state = "tracks"
	random_icon_states = null
	beauty = -50
	base_name = null
	dry_desc = "Some old bloody tracks left by wheels. Machines are evil, perhaps."

/obj/effect/decal/cleanable/blood/trail_holder
	name = "trail of blood"
	desc = "Your instincts say you shouldn't be following these."
	icon = 'icons/effects/blood.dmi'
	icon_state = "trails_1" // For mappers
	random_icon_states = null
	beauty = -50
	base_name = "trail of"
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.1

	/// All the components of the trail
	var/list/obj/effect/decal/cleanable/blood/trail/trail_components

/obj/effect/decal/cleanable/blood/trail_holder/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna = get_default_blood_type())
	. = ..()
	icon_state = "nothing"
	update_appearance() // Cut possible overlays
	if(mapload)
		add_dir_to_trail(dir)

/obj/effect/decal/cleanable/blood/trail_holder/Destroy()
	QDEL_LIST_ASSOC_VAL(trail_components)
	return ..()

/**
 * Returns the trail component corresponding to the given direction
 *
 * * for_dir: The direction to get the trail for
 * * check_reverse: If TRUE, will also check for the reverse direction
 * For example if you pass dir = EAST it will return the first EAST or WEST trail component
 * * check_diagonals: If TRUE, will also check for any diagonal directions
 * For example if you pass dir = EAST it will return the first EAST, NORTHEAST, or SOUTHEAST trail component
 * * check_reverse_diagonals: If TRUE, will also check for any reverse diagonal directions
 * For example if you pass dir = EAST it will return the first SOUTHEAST, EAST, NORTHEAST, WEST, SOUTHWEST, or NORTHWEST trail component
 */
/obj/effect/decal/cleanable/blood/trail_holder/proc/get_trail_component(for_dir, check_reverse = FALSE, check_diagonals = FALSE, check_reverse_diagonals = FALSE)
	. = LAZYACCESS(trail_components, "[for_dir]")
	if(.)
		return .

	if(check_reverse)
		. = LAZYACCESS(trail_components, "[REVERSE_DIR(for_dir)]")
		if(.)
			return .

	if(!check_diagonals)
		return null

	for(var/comp_dir_txt in trail_components)
		var/comp_dir = text2num(comp_dir_txt)
		if(comp_dir <= 0)
			continue

		if(comp_dir & for_dir)
			return LAZYACCESS(trail_components, comp_dir_txt)

		if(check_reverse_diagonals && (comp_dir & REVERSE_DIR(for_dir)))
			return LAZYACCESS(trail_components, comp_dir_txt)

	return null

/**
 * Add a new direction to this trail
 *
 * * new_dir: The direction to add
 * * source - Mob we're sourcing blood from, if any
 * * blood_to_add - Amount of bloodiness to give to the new component. Does not adjust this decal's own bloodiness
 * * half_piece - If TRUE, only creates start of a trail. Does not support corners (diagonal directions)
 * This can be a cardinal direction, a diagonal direction, or a negative number to denote a cardinal direction angled 45 degrees.
 *
 * Returns the new trail, a [/obj/effect/decal/cleanable/blood/trail]
 */
/obj/effect/decal/cleanable/blood/trail_holder/proc/add_dir_to_trail(new_dir = NORTH, mob/living/source, blood_to_add = BLOOD_AMOUNT_PER_DECAL * 0.1, half_piece = FALSE)
	var/check_reverse = TRUE
	// Do not check the reverse dir if we're a diagonal corner
	if (new_dir > 0 && !(new_dir in GLOB.cardinals))
		check_reverse = FALSE
	var/obj/effect/decal/cleanable/blood/trail/new_trail = get_trail_component(new_dir, check_reverse = check_reverse, check_diagonals = half_piece)
	var/list/blood_DNA = GET_ATOM_BLOOD_DNA(src)
	if (source)
		// Source's DNA goes first as to override possible matches in non-enzyme DNA
		blood_DNA = (source.get_blood_dna_list() || list()) | blood_DNA

	if(new_trail)
		// If we found a full trail (straight or diagonal), or a half trail that fully overlaps with us, abort this
		if (!new_trail.half_piece || half_piece && LAZYACCESS(trail_components, "[new_dir]") == new_trail)
			new_trail.adjust_bloodiness(blood_to_add)
			if (source)
				new_trail.add_mob_blood(source)
			return new_trail

		// We've found a mirrored half-piece, so we should merge into a full piece
		// Alternatively, we've found a half piece while being a straight piece that overlaps with it
		// in which case we just overlap with it which should get us the same full piece
		new_trail.half_piece = FALSE
		new_trail.update_appearance()
		new_trail.adjust_bloodiness(blood_to_add)
		if (source)
			new_trail.add_mob_blood(source)
		return new_trail

	// There's a chance that we're on the same tile as a diagonal corner, in which case we need to check for those too
	if (half_piece && new_dir > 0)
		var/first_dir = (new_dir & (NORTH|SOUTH)) ? EAST : NORTH
		var/second_dir = (new_dir & (NORTH|SOUTH)) ? WEST : SOUTH
		new_trail = get_trail_component(new_dir | first_dir) || get_trail_component(new_dir | second_dir)
		// Found a diagonal overlapping with us, abort
		if (new_trail)
			new_trail.adjust_bloodiness(blood_to_add)
			if (source)
				new_trail.add_mob_blood(source)
			return new_trail

		// Look for perpendicular pieces to merge into a diagonal with
		new_trail = get_trail_component(first_dir)
		if (!new_trail?.half_piece)
			new_trail = get_trail_component(second_dir)

		if (new_trail?.half_piece)
			new_trail.half_piece = FALSE
			LAZYREMOVE(trail_components, "[new_trail.dir]")
			new_trail.setDir(new_dir | new_trail.dir)
			LAZYSET(trail_components, "[new_trail.dir]", new_trail)
			new_trail.update_appearance()
			new_trail.adjust_bloodiness(blood_to_add)
			if (source)
				new_trail.add_mob_blood(source)
			return new_trail

	new_trail = new(src, source?.get_static_viruses(), blood_DNA)
	if (half_piece)
		new_trail.half_piece = TRUE
		new_trail.update_appearance()

	new_trail.adjust_bloodiness(blood_to_add - new_trail.bloodiness)

	if(new_dir > 0)
		// add some free sprite variation by flipping it around
		if((new_dir in GLOB.cardinals) && prob(50) && !half_piece)
			new_trail.setDir(REVERSE_DIR(new_dir))
		// otherwise the dir is the same
		else
			new_trail.setDir(new_dir)
	// negative dirs denote "straight diagonal" dirs
	else
		var/real_dir = abs(new_dir)
		new_trail.setDir(real_dir & (EAST|WEST))
		switch(real_dir)
			if(NORTHEAST)
				new_trail.transform = new_trail.transform.Turn(-45)
			if(NORTHWEST)
				new_trail.transform = new_trail.transform.Turn(45)
			if(SOUTHEAST)
				new_trail.transform = new_trail.transform.Turn(-135)
			if(SOUTHWEST)
				new_trail.transform = new_trail.transform.Turn(135)

	LAZYSET(trail_components, "[new_dir]", new_trail)
	vis_contents += new_trail
	return new_trail

/obj/effect/decal/cleanable/blood/trail
	name = "blood trail"
	desc = "A trail of blood."
	icon_state = "ltrails_1"
	random_icon_states = list("ltrails_1", "ltrails_2")
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	appearance_flags = parent_type::appearance_flags | RESET_COLOR | KEEP_APART
	beauty = -50
	decay_bloodiness = FALSE // bloodiness is used as a metric for for how big the sprite is, so don't decay passively
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.1
	base_suffix = "trail"
	/// Is this just half of a trail
	var/half_piece = FALSE
	/// Beyond a threshold we change to a bloodier icon state
	var/very_bloody = FALSE

/obj/effect/decal/cleanable/blood/trail/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna)
	. = ..()
	// Despite having VIS_INHERIT_PLANE, our emissives still inherit our plane offset, so we need to inherit our parent's offset to have them render correctly
	if(istype(loc, /obj/effect/decal/cleanable/blood/trail_holder))
		SET_PLANE_EXPLICIT(src, initial(plane), loc)
		if (emissive_alpha && !dried)
			update_appearance() // correct our emissive
		return


#ifndef UNIT_TESTS
	if (mapload)
		log_mapping("[src] spawned outside of a trail holder at [AREACOORD(src)]!")
		return INITIALIZE_HINT_QDEL
#endif

	stack_trace("[src] spawned outside of a trail holder at [AREACOORD(src)]!")
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/cleanable/blood/trail/update_desc(updates)
	. = ..()
	desc = "A [dried ? "dried " : ""]trail of [get_blood_string()]."

/obj/effect/decal/cleanable/blood/trail/lazy_init_reagents()
	if(!istype(loc, /obj/effect/decal/cleanable/blood/trail_holder))
		return ..()

/obj/effect/decal/cleanable/blood/trail/adjust_bloodiness(by_amount, ignore_timer = FALSE)
	. = ..()
	if(very_bloody || bloodiness < 0.25 * BLOOD_AMOUNT_PER_DECAL)
		return

	very_bloody = TRUE
	icon_state = pick("trails_1", "trails_2")
	base_icon_state = icon_state
	update_appearance()

/obj/effect/decal/cleanable/blood/trail/update_icon(updates)
	if (half_piece)
		icon_state = "[base_icon_state]_start"
	else
		icon_state = base_icon_state
	return ..()

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look extremely gruesome."
	icon_state = "gib1"
	layer = GIB_LAYER
	plane = GAME_PLANE
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE

	base_name = null
	dry_prefix = "rotting"
	dry_desc = "They look extremely gruesome as some terrible smell fills the air."
	decal_reagent = /datum/reagent/consumable/liquidgibs
	reagent_amount = 5
	is_mopped = TRUE // probably shouldn't be, but janitor powercreep

	/// Lazylist with information about the diseases our streaking spawns
	var/list/streak_diseases
	/// Do these gibs produce squishy sounds?
	var/squishy = TRUE
	/// Do these gibs have a separate non-blood-colored overlay?
	var/has_overlay = TRUE
	/// Should we be creating blood decals as we streak?
	var/leave_blood = TRUE

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna = get_default_blood_type())
	. = ..()
	leave_blood = has_blood_flag(GET_ATOM_BLOOD_DNA(src), BLOOD_COVER_TURFS)
	if(squishy)
		AddElement(/datum/element/squish_sound)
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))
	update_appearance(UPDATE_OVERLAYS)

/// Don't override our reagents with our bloodtype ones, if bloodtypes want unique reagents they need to do it themselves (like oil)
/obj/effect/decal/cleanable/blood/gibs/lazy_init_reagents()
	if (reagents)
		return reagents

	if (!decal_reagent)
		return

	create_reagents(reagent_amount)
	reagents.add_reagent(decal_reagent, reagent_amount)
	return reagents

/obj/effect/decal/cleanable/blood/gibs/update_overlays()
	. = ..()
	if(!has_overlay)
		return
	var/mutable_appearance/gib_overlay = mutable_appearance(icon, "[icon_state]-overlay", appearance_flags = KEEP_APART|RESET_COLOR)
	if(dried)
		gib_overlay.color = COLOR_GRAY
	else if (total_dry_time)
		gib_overlay.color = BlendRGB(COLOR_WHITE, COLOR_GRAY, 1 - drying_time / total_dry_time)
	. += gib_overlay

/obj/effect/decal/cleanable/blood/gibs/get_blood_string()
	return null

/obj/effect/decal/cleanable/blood/gibs/Destroy()
	LAZYNULL(streak_diseases)
	return ..()

/obj/effect/decal/cleanable/blood/gibs/replace_decal(obj/effect/decal/cleanable/C)
	return FALSE //Never fail to place us

/obj/effect/decal/cleanable/blood/gibs/dry()
	. = ..()
	if(!.)
		return
	AddComponent(/datum/component/rot, 0, 5 MINUTES, 0.7)
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions, mapload = FALSE)
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions)
	var/direction = pick(directions)
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return

	if(!mapload)
		var/datum/move_loop/loop = GLOB.move_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
		if (leave_blood)
			RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))
		return

	for (var/i in 1 to range)
		if (leave_blood)
			create_splatter()

		if (!step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/blood/gibs/proc/create_splatter()
	var/turf/my_turf = get_turf(src)
	if(!isgroundlessturf(my_turf) || GET_TURF_BELOW(my_turf))
		new /obj/effect/decal/cleanable/blood/splatter(my_turf, streak_diseases, GET_ATOM_BLOOD_DNA(src))

/obj/effect/decal/cleanable/blood/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	if(!NeverShouldHaveComeHere(loc))
		new /obj/effect/decal/cleanable/blood/splatter(loc, streak_diseases, GET_ATOM_BLOOD_DNA(src))

/obj/effect/decal/cleanable/blood/gibs/up
	icon_state = "gibup1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	icon_state = "gibdown1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	icon_state = "gibtorso"
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/torso
	icon_state = "gibtorso"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/gibs/limb
	icon_state = "gibleg"
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	icon_state = "gibmid1"
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/effect/decal/cleanable/blood/gibs/old
	name = "old rotting gibs"
	desc = "Space Jesus, why didn't anyone clean this up? They smell terrible."
	color = BLOOD_COLOR_DRIED // Just for mappers. Overriden in init
	bloodiness = 0
	dried = TRUE
	dry_prefix = null
	dry_desc = null

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna = get_default_blood_type())
	. = ..()
	setDir(pick(GLOB.cardinals))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 10)

/obj/effect/decal/cleanable/blood/drip
	name = "drop of blood"
	desc = "A spattering."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	base_name = "drop of"
	dry_desc = "A dried spattering."

/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "blood1"
	random_icon_states = null
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	bloodiness = 0 // set based on the bloodiness of the foot
	base_name = null
	dry_desc = "HMM... SOMEONE WAS HERE!"

	var/entered_dirs = 0
	var/exited_dirs = 0

	/// Lazylist of shoe or other clothing that covers feet types that have made footprints here.
	var/list/shoe_types

	/// Lazylist of species that have made footprints here.
	var/list/species_types

/obj/effect/decal/cleanable/blood/footprints/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna = get_default_blood_type())
	. = ..()
	icon_state = "" // All of the footprint visuals come from overlays
	if(mapload)
		entered_dirs |= dir // Keep the same appearance as in the map editor
	update_appearance()

/obj/effect/decal/cleanable/blood/footprints/get_blood_string()
	return null

//Rotate all of the footprint directions too
/obj/effect/decal/cleanable/blood/footprints/setDir(newdir)
	if(dir == newdir)
		return ..()

	var/ang_change = dir2angle(newdir) - dir2angle(dir)
	var/old_entered_dirs = entered_dirs
	var/old_exited_dirs = exited_dirs
	entered_dirs = NONE
	exited_dirs = NONE

	for(var/Ddir in GLOB.cardinals)
		if(old_entered_dirs & Ddir)
			entered_dirs |= angle2dir_cardinal(dir2angle(Ddir) + ang_change)
		if(old_exited_dirs & Ddir)
			exited_dirs |= angle2dir_cardinal(dir2angle(Ddir) + ang_change)

	update_appearance()
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()
	var/static/list/bloody_footprints_cache = list()
	var/icon_state_to_use = "blood"
	if(LAZYACCESS(species_types, BODYPART_ID_DIGITIGRADE))
		icon_state_to_use += "claw"
	else if(LAZYACCESS(species_types, SPECIES_MONKEY))
		icon_state_to_use += "paw"
	else if(LAZYACCESS(species_types, "bot"))
		icon_state_to_use += "bot"

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/enter_state = "entered-[icon_state_to_use]-[Ddir]"
			var/image/bloodstep_overlay = bloody_footprints_cache[enter_state]
			if(!bloodstep_overlay)
				bloodstep_overlay = image(icon, "[icon_state_to_use]1", dir = Ddir)
				bloody_footprints_cache[enter_state] = bloodstep_overlay
			. += bloodstep_overlay

			if(emissive_alpha && emissive_alpha < alpha && !dried)
				var/enter_emissive_state = "[enter_state]_emissive-[emissive_alpha]"
				var/mutable_appearance/emissive_overlay = bloody_footprints_cache[enter_emissive_state]
				if(!emissive_overlay)
					emissive_overlay = blood_emissive(icon, "[icon_state_to_use]1")
					emissive_overlay.dir = Ddir
					bloody_footprints_cache[enter_emissive_state] = emissive_overlay
				. += emissive_overlay

		if(exited_dirs & Ddir)
			var/exit_state = "exited-[icon_state_to_use]-[Ddir]"
			var/image/bloodstep_overlay = bloody_footprints_cache[exit_state]
			if(!bloodstep_overlay)
				bloodstep_overlay = image(icon, "[icon_state_to_use]2", dir = Ddir)
				bloody_footprints_cache[exit_state] = bloodstep_overlay
			. += bloodstep_overlay

			if(emissive_alpha && emissive_alpha < alpha && !dried)
				var/exit_emissive_state = "[exit_state]_emissive-[emissive_alpha]"
				var/mutable_appearance/emissive_overlay = bloody_footprints_cache[exit_emissive_state]
				if(!emissive_overlay)
					emissive_overlay = blood_emissive(icon, "[icon_state_to_use]2")
					emissive_overlay.dir = Ddir
					bloody_footprints_cache[exit_emissive_state] = emissive_overlay
				. += emissive_overlay

/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if(LAZYLEN(species_types) + LAZYLEN(shoe_types) == 0)
		return

	. += "You recognise the footprints as belonging to:"
	for(var/obj/item/clothing/shoes/sole as anything in shoe_types)
		var/article = initial(sole.article) || (initial(sole.gender) == PLURAL ? "Some" : "A")
		. += "[icon2html(initial(sole.icon), user, initial(sole.icon_state))] [article] <B>[initial(sole.name)]</B>."

	for(var/species in species_types)
		switch(species)
			if("unknown")
				. += "&bull; Some <B>creature's feet</B>."
			if(SPECIES_MONKEY)
				. += "&bull; Some <B>monkey feet</B>."
			if(SPECIES_HUMAN)
				. += "&bull; Some <B>human feet</B>."
			else
				. += "&bull; Some <B>[species] feet</B>."

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")

	plane = GAME_PLANE
	layer = ABOVE_WINDOW_LAYER
	is_mopped = FALSE

	base_name = null
	base_suffix = "splatter"
	can_dry = FALSE // No point

	/// The turf we just came from, so we can back up when we hit a wall
	var/turf/prev_loc
	/// Skip making the final blood splatter when we're done, like if we're not in a turf
	var/skip = FALSE
	/// How many tiles/items/people we can paint red
	var/splatter_strength = 3
	/// Insurance so that we don't keep moving once we hit a stoppoint
	var/hit_endpoint = FALSE
	/// How fast the splatter moves
	var/splatter_speed = 0.1 SECONDS
	/// Tracks what direction we're flying
	var/flight_dir = NONE
	/// Should we be leaving any decals, or just adding DNA to mobs?
	var/leave_blood = TRUE

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, list/datum/disease/diseases, list/blood_or_dna = get_default_blood_type(), splatter_strength)
	. = ..()
	leave_blood = has_blood_flag(GET_ATOM_BLOOD_DNA(src), BLOOD_COVER_TURFS)
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/proc/expire()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		loc.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	qdel(src)

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	flight_dir = get_dir(src, target_turf)
	var/datum/move_loop/loop = GLOB.move_manager.move_towards(src, target_turf, splatter_speed, timeout = splatter_speed * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/blood/hitsplatter/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	if(loc == prev_loc || !isturf(loc))
		return

	for(var/atom/movable/iter_atom in loc)
		if(hit_endpoint)
			return
		if(iter_atom == src || iter_atom.invisibility || iter_atom.alpha <= 0 || (isobj(iter_atom) && !iter_atom.density))
			continue
		if(splatter_strength <= 0)
			break
		iter_atom.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))

	splatter_strength--
	// we used all our blood so go away
	if(splatter_strength <= 0)
		expire()
		return

	if(!leave_blood)
		loc.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
		return

	// make a trail
	var/obj/effect/decal/cleanable/blood/fly_trail = new(loc, null, GET_ATOM_BLOOD_DNA(src))
	fly_trail.dir = dir
	if(ISDIAGONALDIR(flight_dir))
		fly_trail.transform = fly_trail.transform.Turn((flight_dir == NORTHEAST || flight_dir == SOUTHWEST) ? 135 : 45)
	fly_trail.icon_state = pick("trails_1", "trails_2")
	fly_trail.adjust_bloodiness(fly_trail.bloodiness * -0.66)
	fly_trail.update_appearance()

/obj/effect/decal/cleanable/blood/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		expire()

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/bumped_atom)
	if(!iswallturf(bumped_atom) && !istype(bumped_atom, /obj/structure/window))
		expire()
		return

	if(istype(bumped_atom, /obj/structure/window))
		var/obj/structure/window/bumped_window = bumped_atom
		if(!bumped_window.fulltile)
			hit_endpoint = TRUE
			expire()
			return

	hit_endpoint = TRUE
	if(!isturf(prev_loc)) // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		expire()
		return

	abstract_move(bumped_atom)
	skip = TRUE
	//Adjust pixel offset to make splatters appear on the wall
	if(istype(bumped_atom, /obj/structure/window))
		if(land_on_window(bumped_atom))
			return

	if(!leave_blood)
		prev_loc.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
		return

	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new(prev_loc, null, GET_ATOM_BLOOD_DNA(src))
	final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
	final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!leave_blood)
		the_window.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
		return TRUE

	if(!the_window.fulltile)
		return FALSE

	var/obj/effect/decal/cleanable/final_splatter = new /obj/effect/decal/cleanable/blood/splatter/over_window(prev_loc, null, GET_ATOM_BLOOD_DNA(src))
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	expire()
	return TRUE
