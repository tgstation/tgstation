/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	beauty = -100
	clean_type = CLEAN_TYPE_BLOOD
	color = BLOOD_COLOR_RED
	var/should_dry = TRUE
	var/dryname = "dried blood" //when the blood lasts long enough, it becomes dry and gets a new name
	var/drydesc = "Looks like it's been here a while. Eew." //as above
	var/drytime = 0
	var/footprint_sprite = null
	/// If we've dried already
	var/has_dried

/obj/effect/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	if(!should_dry)
		return
	if(bloodiness)
		start_drying()
	else
		dry(freshly_made = TRUE)

/obj/effect/decal/cleanable/blood/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/blood/process()
	if(world.time > drytime)
		dry()

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_DNA, no_visuals = FALSE)
	. = ..()
	if(!no_visuals && length(blood_DNA))
		color = get_blood_dna_color(blood_DNA)

/obj/effect/decal/cleanable/blood/proc/get_timer()
	drytime = world.time + 3 MINUTES

/obj/effect/decal/cleanable/blood/proc/start_drying()
	get_timer()
	START_PROCESSING(SSobj, src)

///This is what actually "dries" the blood. Returns true if it's all out of blood to dry, and false otherwise
/obj/effect/decal/cleanable/blood/proc/dry(freshly_made = FALSE)
	if(freshly_made)
		start_drying()
		return FALSE
	if(bloodiness > 20)
		bloodiness -= BLOOD_AMOUNT_PER_DECAL
		get_timer()
		return FALSE

	name = dryname
	has_dried = TRUE
	desc = drydesc
	bloodiness = 0
	STOP_PROCESSING(SSobj, src)
	// We're not using a matrix so we're free to use BlendRGB
	if(!islist(color))
		add_atom_colour(BlendRGB(color, COLOR_BLACK, 0.5), FIXED_COLOUR_PRIORITY)
		return TRUE

	// We're using a matrix, so we need to halve all values
	var/list/blood_matrix = color
	for(var/i in 1 to min(length(blood_matrix), 16))
		if (length(blood_matrix) == 12 && i > 9) // Don't modify constants
			break
		if (length(blood_matrix) >= 16 && i % 4 == 0) // Don't modify alpha either
			continue
		blood_matrix[i] *= 0.5
	color = blood_matrix
	return TRUE

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	C.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	if (bloodiness)
		C.bloodiness = min((C.bloodiness + bloodiness), BLOOD_AMOUNT_PER_DECAL)
	return ..()

/obj/effect/decal/cleanable/blood/old
	bloodiness = 0
	icon_state = "floor1-old"

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_human_blood_type())) // Needs to happen before ..()
	return ..()

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
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	random_icon_states = null
	beauty = -50
	dryname = "dried tracks"
	drydesc = "Some old bloody tracks left by wheels. Machines are evil, perhaps."

/obj/effect/decal/cleanable/blood/trail_holder
	name = "blood"
	desc = "Your instincts say you shouldn't be following these."
	icon = 'icons/effects/blood.dmi'
	icon_state = null
	random_icon_states = null
	beauty = -50
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/blood/trail_holder/replace_decal(obj/effect/decal/cleanable/blood/trail_holder/blood_decal)
	if(blood_state != blood_decal.blood_state)
		return FALSE
	return ..()

// normal version of the above trail holder object for use in less convoluted things
/obj/effect/decal/cleanable/blood/trails
	desc = "Looks like a corpse was smeared all over the floor like ketchup. Kinda makes you hungry."
	random_icon_states = list("trails_1", "trails_2")
	icon_state = "trails_1"
	beauty = -50
	dryname = "dried tracks"
	drydesc = "Looks like a corpse was smeared all over the floor like ketchup, but it's all dried up and nasty now, ew. You lose some of your appetite."

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "gib1"
	layer = GIB_LAYER
	plane = GAME_PLANE
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE

	dryname = "rotting gibs"
	drydesc = "They look bloody and gruesome while some terrible smell fills the air."
	decal_reagent = /datum/reagent/consumable/liquidgibs
	reagent_amount = 5

	is_mopped = TRUE // probably shouldn't be, but janitor powercreep

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/squish_sound)
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/decal/cleanable/blood/gibs/update_overlays()
	. = ..()
	var/mutable_appearance/gib_overlay = mutable_appearance(icon, "[icon_state]-overlay", appearance_flags = KEEP_APART|RESET_COLOR)
	if(gib_overlay)
		if(has_dried)
			gib_overlay.color = COLOR_GRAY
		. += gib_overlay

/obj/effect/decal/cleanable/blood/gibs/replace_decal(obj/effect/decal/cleanable/C)
	return FALSE //Never fail to place us

/obj/effect/decal/cleanable/blood/gibs/dry(freshly_made = FALSE)
	. = ..()
	if(!.)
		return
	update_appearance(UPDATE_OVERLAYS)
	AddComponent(/datum/component/rot, 0, 5 MINUTES, 0.7)

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

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions, mapload=FALSE)
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions)
	var/direction = pick(directions)
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return

	if(!mapload)
		var/datum/move_loop/loop = GLOB.move_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))
		return

	for (var/i in 1 to range)
		var/turf/my_turf = get_turf(src)
		if(!isgroundlessturf(my_turf) || GET_TURF_BELOW(my_turf))
			var/obj/effect/decal/cleanable/blood/splatter/new_splatter = new /obj/effect/decal/cleanable/blood/splatter(my_turf)
			new_splatter.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))

		if (!step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/blood/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	if(NeverShouldHaveComeHere(loc))
		return
	var/obj/effect/decal/cleanable/blood/splatter/new_splatter = new /obj/effect/decal/cleanable/blood/splatter(loc)
	new_splatter.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))

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
	icon_state = "gib1-old"
	bloodiness = 0
	should_dry = FALSE
	dryname = "old rotting gibs"
	drydesc = "Space Jesus, why didn't anyone clean this up? They smell terrible."

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	setDir(pick(1,2,4,8))
	add_blood_DNA(list("Non-human DNA" = random_human_blood_type()))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 10)
	dry()

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1
	dryname = "drips of blood"
	drydesc = "It's red."

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE

//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "blood_shoes_enter"
	random_icon_states = null
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from
	var/entered_dirs = 0
	var/exited_dirs = 0

	/// List of shoe or other clothing that covers feet types that have made footprints here.
	var/list/shoe_types = list()

	/// List of species that have made footprints here.
	var/list/species_types = list()

	dryname = "dried footprints"
	drydesc = "HMM... SOMEONE WAS HERE!"

/obj/effect/decal/cleanable/blood/footprints/Initialize(mapload, footprint_sprite)
	src.footprint_sprite = footprint_sprite
	. = ..()
	icon_state = "" //All of the footprint visuals come from overlays
	if(mapload)
		entered_dirs |= dir //Keep the same appearance as in the map editor
	update_appearance(mapload ? (ALL) : (UPDATE_NAME | UPDATE_DESC))

//Rotate all of the footprint directions too
/obj/effect/decal/cleanable/blood/footprints/setDir(newdir)
	if(dir == newdir)
		return ..()

	var/ang_change = dir2angle(newdir) - dir2angle(dir)
	var/old_entered_dirs = entered_dirs
	var/old_exited_dirs = exited_dirs
	entered_dirs = 0
	exited_dirs = 0

	for(var/Ddir in GLOB.cardinals)
		if(old_entered_dirs & Ddir)
			entered_dirs |= turn_cardinal(Ddir, ang_change)
		if(old_exited_dirs & Ddir)
			exited_dirs |= turn_cardinal(Ddir, ang_change)

	update_appearance()
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_name(updates)
	switch(footprint_sprite)
		if(FOOTPRINT_SPRITE_CLAWS)
			name = "clawprints"
		if(FOOTPRINT_SPRITE_SHOES)
			name = "footprints"
		if(FOOTPRINT_SPRITE_PAWS)
			name = "pawprints"
	dryname = "dried [name]"
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_desc(updates)
	desc = "WHOSE [uppertext(name)] ARE THESE?"
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_icon()
	. = ..()
	alpha = max(BLOODY_FOOTPRINT_BASE_ALPHA, min(255 * (bloodiness / 15), 255))

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()
	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[footprint_sprite]-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[footprint_sprite]-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]_[footprint_sprite]_enter", dir = Ddir)
			bloodstep_overlay.color = color
			. += bloodstep_overlay

		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[footprint_sprite]-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[footprint_sprite]-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]_[footprint_sprite]_exit", dir = Ddir)
			bloodstep_overlay.color = color
			. += bloodstep_overlay


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if(length(shoe_types) + length(species_types) == 0)
		return

	. += "You recognise \the [src] as belonging to:"

	for(var/sole in shoe_types)
		var/obj/item/clothing/item = sole
		var/article = initial(item.gender) == PLURAL ? "Some" : "A"
		. += "[icon2html(initial(item.icon), user, initial(item.icon_state))] [article] <B>[initial(item.name)]</B>."

	for(var/species in species_types)
		// god help me
		if(species == "unknown")
			. += "Some <B>feet</B>."
		else if(species == SPECIES_MONKEY)
			. += "[icon2html('icons/mob/human/human.dmi', user, "monkey")] Some <B>monkey paws</B>."
		else if(species == SPECIES_HUMAN)
			. += "[icon2html('icons/mob/human/bodyparts.dmi', user, "default_human_l_leg")] Some <B>human feet</B>."
		else
			. += "[icon2html('icons/mob/human/bodyparts.dmi', user, "[species]_l_leg")] Some <B>[species] feet</B>."

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/blood/blood_decal)
	if(blood_state != blood_decal.blood_state || footprint_sprite != blood_decal.footprint_sprite) //We only replace footprints of the same type as us
		return FALSE
	return ..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return TRUE
	return FALSE

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")
	plane = GAME_PLANE
	layer = ABOVE_WINDOW_LAYER
	is_mopped = FALSE
	/// The turf we just came from, so we can back up when we hit a wall
	var/turf/prev_loc
	/// The cached info about the blood
	var/list/blood_dna_info
	/// Skip making the final blood splatter when we're done, like if we're not in a turf
	var/skip = FALSE
	/// How many tiles/items/people we can paint red
	var/splatter_strength = 3
	/// Insurance so that we don't keep moving once we hit a stoppoint
	var/hit_endpoint = FALSE

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, splatter_strength)
	. = ..()
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/proc/expire()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		if(blood_dna_info)
			loc.add_blood_DNA(blood_dna_info)
	qdel(src)

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	var/delay = 2
	var/datum/move_loop/loop = GLOB.move_manager.move_towards(src, target_turf, delay, timeout = delay * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/blood/hitsplatter/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER

	for(var/atom/movable/iter_atom in loc)
		if(hit_endpoint)
			return
		if(iter_atom == src || iter_atom.invisibility || iter_atom.alpha <= 0 || (isobj(iter_atom) && !iter_atom.density))
			continue
		if(splatter_strength <= 0)
			break

		iter_atom.add_blood_DNA(blood_dna_info)
		splatter_strength--

	if(splatter_strength <= 0) // we used all the puff so we delete it.
		expire()

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
		land_on_window(bumped_atom)
		return

	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new(prev_loc)
	final_splatter.add_blood_DNA(blood_dna_info)
	final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
	final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!the_window.fulltile)
		return
	var/obj/effect/decal/cleanable/final_splatter = new /obj/effect/decal/cleanable/blood/splatter/over_window(prev_loc)
	final_splatter.add_blood_DNA(blood_dna_info)
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	the_window.bloodied = TRUE
	expire()
