//keeping the old files to ensure compatability while things get moved to this system.
//but yeah, unified blood decal system I guess

#define BEAUTY_IMPACT_LOW -50
#define BEAUTY_IMPACT_HIGH -100

/obj/effect/decal/cleanable/vital
	name = "vital fluids"
	desc = "Universally-generic vital fluids"
	icon = 'icons/effects/blood.dmi'
	icon_state = "[blood_species_prefix]floor1"
	random_icon_states = list(
	"[blood_species_prefix]floor1",
	"[blood_species_prefix]floor2",
	"[blood_species_prefix]floor3",
	"[blood_species_prefix]floor4",
	"[blood_species_prefix]floor5",
	"[blood_species_prefix]floor6",
	"[blood_species_prefix]floor7",)
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	beauty = (BEAUTY_IMPACT_HIGH*beauty_mult)
	clean_type = CLEAN_TYPE_BLOOD
	var/should_dry = TRUE
	var/dryname = "dried blood" //when the blood lasts long enough, it becomes dry and gets a new name
	var/drydesc = "Looks like it's been here a while. Eew." //as above
	var/drytime = 0
	var/footprint_sprite = null
	var/blood_color
	var/color_food
	var/blood_species_full
	var/blood_species_prefix
	var/beauty_mult = 1
	switch(blood_state)
		if(BLOOD_STATE_HUMAN)
			blood_color = "red"
			blood_species_full = "human"
			color_food = "ketchup"
			blood_species_prefix = null
		if(BLOOD_STATE_XENO)
			blood_color = "green"
			blood_species_full = "xeno"
			color_food = "pandan"
			blood_species_prefix = "x"
			beautymult = 2.5
		if(BLOOD_STATE_OIL)
			icon = 'icons/mob/silicon/robots.dmi'
			blood_color = "black"
			blood_species_full = "robot"
			color_food = "nero di seppia"
			blood_species_prefix = null
		if(null)
			blood_color = "strange"
			blood_species_full = "generic"
			color_food = "unobtanium"
			blood_species_prefix = null
			
/obj/effect/decal/cleanable/vital/organic
	name = "blood"
	desc = "It's [blood_color] and gooey. Perhaps it's the chef's cooking?"
	
/obj/effect/decal/cleanable/vital/robotic
	name = "motor oil"
	desc = "It's [blood_color] and greasy. Looks like Beepsky made another mess."
	icon_state = "[blood_species_prefix]floor1"
	random_icon_states = list(
	"[blood_species_prefix]floor1",
	"[blood_species_prefix]floor2",
	"[blood_species_prefix]floor3",
	"[blood_species_prefix]floor4",
	"[blood_species_prefix]floor5",
	"[blood_species_prefix]floor6",
	"[blood_species_prefix]floor7",)
	blood_state = BLOOD_STATE_OIL
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	beauty = (BEAUTY_IMPACT_HIGH*beauty_mult)
	clean_type = CLEAN_TYPE_BLOOD
	decal_reagent = /datum/reagent/fuel/oil
	reagent_amount = 30
	var/should_dry = FALSE
	var/flammable = FALSE
	
/obj/effect/decal/cleanable/vital/robotic/attackby(obj/item/I, mob/living/user)
	var/attacked_by_hot_thing = I.get_temperature()
	if(attacked_by_hot_thing && flammable)
		user.visible_message(span_warning("[user] tries to ignite [src] with [I]!"), span_warning("You try to ignite [src] with [I]."))
		log_combat(user, src, (attacked_by_hot_thing < 480) ? "tried to ignite" : "ignited", I)
		fire_act(attacked_by_hot_thing)
		return
	return ..()
	
/obj/effect/decal/cleanable/vital/robotic/debris/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))
	
/obj/effect/decal/cleanable/vital/robotic/debris/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	if(NeverShouldHaveComeHere(loc))
		return
	if (prob(40))
		new /obj/effect/decal/cleanable/oil/streak(loc)
	else if (prob(10))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		
/obj/effect/decal/cleanable/vital/robotic/debris/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)
	
/obj/effect/decal/cleanable/vital/robotic/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature < 480)
		return
	visible_message(span_danger("[src] catches fire!"))
	var/turf/T = get_turf(src)
	qdel(src)
	new /obj/effect/hotspot(T)

/obj/effect/decal/cleanable/oil/slippery/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 80, (NO_SLIP_WHEN_WALKING | SLIDE))

//Generic drying code
/obj/effect/decal/cleanable/vital/Initialize(mapload)
	. = ..()
	if(!should_dry)
		return
	if(bloodiness)
		start_drying()
	else
		dry()

/obj/effect/decal/cleanable/vital/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/vital/process()
	if(world.time > drytime)
		dry()

/obj/effect/decal/cleanable/vital/proc/get_timer()
	drytime = world.time + 3 MINUTES

/obj/effect/decal/cleanable/vital/proc/start_drying()
	get_timer()
	START_PROCESSING(SSobj, src)

///This is what actually "dries" the blood. Returns true if it's all out of blood to dry, and false otherwise
/obj/effect/decal/cleanable/vital/proc/dry()
	if(bloodiness > 20)
		bloodiness -= BLOOD_AMOUNT_PER_DECAL
		get_timer()
		return FALSE
	else
		name = dryname
		desc = drydesc
		bloodiness = 0
		color = COLOR_GRAY //not all blood splatters have their own sprites... It still looks pretty nice
		STOP_PROCESSING(SSobj, src)
		return TRUE

/obj/effect/decal/cleanable/vital/organic/replace_decal(obj/effect/decal/cleanable/blood/C)
	C.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	if (bloodiness)
		C.bloodiness = min((C.bloodiness + bloodiness), BLOOD_AMOUNT_PER_DECAL)
	return ..()

/obj/effect/decal/cleanable/vital/organic/old
	bloodiness = 0
	icon_state = "[blood_species_prefix]floor1-old"

/obj/effect/decal/cleanable/vital/organic/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_blood_type())) // Needs to happen before ..()
	return ..()

/obj/effect/decal/cleanable/vital/organic/splatter
	icon_state = "[blood_species_prefix]gibbl1"
	random_icon_states = list("[blood_species_prefix]gibbl1", "[blood_species_prefix]gibbl2", "[blood_species_prefix]gibbl3", "[blood_species_prefix]gibbl4", "[blood_species_prefix]gibbl5",)

/obj/effect/decal/cleanable/vital/organic/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180

/obj/effect/decal/cleanable/vital/organic/splatter/over_window/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

/obj/effect/decal/cleanable/vital/organic/tracks
	icon_state = "[blood_species_prefix]tracks"
	desc = "They look like tracks left by wheels."
	random_icon_states = null
	beauty = (BEAUTY_IMPACT_LOW*beauty_mult)
	dryname = "dried tracks"
	drydesc = "Some old bloody tracks left by wheels. Machines are evil, perhaps."

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon = 'icons/effects/blood.dmi'
	desc = "Your instincts say you shouldn't be following these."
	beauty = (BEAUTY_IMPACT_LOW*beauty_mult)
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

// normal version of the above trail holder object for use in less convoluted things
/obj/effect/decal/cleanable/vital/organic/trails
	desc = "Looks like a corpse was smeared all over the floor like ketchup. Kinda makes you hungry."
	random_icon_states = list("[blood_species_prefix]trails_1", "[blood_species_prefix]trails_2",)
	icon_state = "[blood_species_prefix]trails_1"
	beauty = (BEAUTY_IMPACT_LOW*beauty_mult)
	dryname = "dried tracks"
	drydesc = "Looks like a corpse was smeared all over the floor like ketchup, but it's all dried up and nasty now, ew. You lose some of your appetite."

/obj/effect/decal/cleanable/vital/organic/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "[blood_species_prefix]gib1"
	layer = BELOW_OBJ_LAYER
	plane = GAME_PLANE
	random_icon_states = list("[blood_species_prefix]gib1", "[blood_species_prefix]gib2", "[blood_species_prefix]gib3", "[blood_species_prefix]gib4", "[blood_species_prefix]gib5", "[blood_species_prefix]gib6",)
	mergeable_decal = FALSE

	dryname = "rotting gibs"
	drydesc = "They look bloody and gruesome while some terrible smell fills the air."
	decal_reagent = /datum/reagent/consumable/liquidgibs
	reagent_amount = 5

/obj/effect/decal/cleanable/vital/organic/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/squish_sound)
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))

/obj/effect/decal/cleanable/vital/organic/gibs/Destroy()
	return ..()

/obj/effect/decal/cleanable/vital/organic/gibs/replace_decal(obj/effect/decal/cleanable/C)
	return FALSE //Never fail to place us

/obj/effect/decal/cleanable/vital/organic/gibs/dry()
	. = ..()
	if(!.)
		return
	AddComponent(/datum/component/rot, 0, 5 MINUTES, 0.7)

/obj/effect/decal/cleanable/vital/organic/gibs/ex_act(severity, target)
	return FALSE

/obj/effect/decal/cleanable/vital/organic/gibs/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/vital/organic/gibs/proc/streak(list/directions, mapload=FALSE)
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions)
	var/direction = pick(directions)
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return
	if(mapload)
		for (var/i in 1 to range)
			var/turf/my_turf = get_turf(src)
			if(!isgroundlessturf(my_turf) || GET_TURF_BELOW(my_turf))
				new /obj/effect/decal/cleanable/vital/organic/splatter(my_turf)
			if (!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = GLOB.move_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

/obj/effect/decal/cleanable/vital/organic/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	if(NeverShouldHaveComeHere(loc))
		return
	new /obj/effect/decal/cleanable/vital/organic/splatter(loc)

//segments for misc organic vitals
/obj/effect/decal/cleanable/vital/organic/gibs/up
	icon_state = "[blood_species_prefix]gibup1"
	random_icon_states = list(
	"[blood_species_prefix]gib1",
	"[blood_species_prefix]gib2", 
	"[blood_species_prefix]gib3", 
	"[blood_species_prefix]gib4", 
	"[blood_species_prefix]gib5", 
	"[blood_species_prefix]gib6", 
	"[blood_species_prefix]gibup1", 
	"[blood_species_prefix]gibup1", 
	"[blood_species_prefix]gibup1",)

/obj/effect/decal/cleanable/vital/organic/gibs/down
	icon_state = "[blood_species_prefix]gibdown1"
	random_icon_states = list(
	"[blood_species_prefix]gib1",
	"[blood_species_prefix]gib2",
	"[blood_species_prefix]gib3",
	"[blood_species_prefix]gib4",
	"[blood_species_prefix]gib5",
	"[blood_species_prefix]gib6",
	"[blood_species_prefix]gibdown1",
	"[blood_species_prefix]gibdown1",
	"[blood_species_prefix]gibdown1",)

/obj/effect/decal/cleanable/vital/organic/gibs/body
	icon_state = "[blood_species_prefix]gibtorso"
	random_icon_states = list(
	"[blood_species_prefix]gibhead",
	"[blood_species_prefix]gibtorso",)

/obj/effect/decal/cleanable/vital/organic/gibs/torso
	icon_state = "[blood_species_prefix]gibtorso"
	random_icon_states = null

/obj/effect/decal/cleanable/vital/organic/gibs/limb
	icon_state = "[blood_species_prefix]gibleg"
	random_icon_states = list(
	"[blood_species_prefix]gibleg",
	"[blood_species_prefix]gibarm",)

/obj/effect/decal/cleanable/vital/organic/gibs/core
	icon_state = "[blood_species_prefix]gibmid1"
	random_icon_states = list(
	"[blood_species_prefix]gibmid1",
	"[blood_species_prefix]gibmid2",
	"[blood_species_prefix]gibmid3",)

/obj/effect/decal/cleanable/vital/organic/gibs/old
	name = "old rotting gibs"
	desc = "Space Jesus, why didn't anyone clean this up? They smell terrible."
	icon_state = "[blood_species_prefix]gib1-old"
	bloodiness = 0
	should_dry = FALSE
	dryname = "old rotting gibs"
	drydesc = "Space Jesus, why didn't anyone clean this up? They smell terrible."

/obj/effect/decal/cleanable/vital/organic/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	setDir(pick(1,2,4,8))
	add_blood_DNA(list("Non-human DNA" = random_blood_type()))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 10)
	dry()

/obj/effect/decal/cleanable/vital/organic/drip
	name = "drips of blood"
	desc = "It's [blood_color]."
	icon_state = "[blood_species_prefix]drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list(
	"[blood_species_prefix]drip1",
	"[blood_species_prefix]drip2",
	"[blood_species_prefix]drip3",
	"[blood_species_prefix]drip4",
	"[blood_species_prefix]drip5",)
	bloodiness = 0
	var/drips = 1
	dryname = "drips of blood"
	drydesc = "It's [blood_color]."

/obj/effect/decal/cleanable/vital/organic/drip/can_bloodcrawl_in()
	return TRUE

//segment for misc robotic vitals

/obj/effect/decal/cleanable/vital/robotic/streak
	icon_state = "streak1"
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")
	beauty = (BEAUTY_IMPACT_LOW*beauty_mult)

/obj/effect/decal/cleanable/vital/robotic/debris
	name = "robot debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	icon_state = "gib1"
	plane = GAME_PLANE
	layer = BELOW_OBJ_LAYER
	random_icon_states = list(
	"[blood_species_prefix]gib1",
	"[blood_species_prefix]gib2",
	"[blood_species_prefix]gib3",
	"[blood_species_prefix]gib4",
	"[blood_species_prefix]gib5",
	"[blood_species_prefix]gib6", 
	"[blood_species_prefix]gib7",)
	mergeable_decal = FALSE
	beauty = (BEAUTY_IMPACT_LOW*beauty_mult)

/obj/effect/decal/cleanable/vital/robotic/debris/ex_act()
	return FALSE

/obj/effect/decal/cleanable/vital/robotic/debris/limb
	icon_state = "gibarm"
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/vital/robotic/debris/up
	icon_state = "gibup"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibup","gibup")

/obj/effect/decal/cleanable/vital/robotic/debris/down
	icon_state = "gibdown"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibdown","gibdown")

//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/vital/organic/footprints
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

/obj/effect/decal/cleanable/vital/organic/footprints/Initialize(mapload, footprint_sprite)
	src.footprint_sprite = footprint_sprite
	. = ..()
	icon_state = "" //All of the footprint visuals come from overlays
	if(mapload)
		entered_dirs |= dir //Keep the same appearance as in the map editor
	update_appearance(mapload ? (ALL) : (UPDATE_NAME | UPDATE_DESC))

//Rotate all of the footprint directions too
/obj/effect/decal/cleanable/vital/organic/footprints/setDir(newdir)
	if(dir == newdir)
		return ..()

	var/ang_change = dir2angle(newdir) - dir2angle(dir)
	var/old_entered_dirs = entered_dirs
	var/old_exited_dirs = exited_dirs
	entered_dirs = 0
	exited_dirs = 0

	for(var/Ddir in GLOB.cardinals)
		if(old_entered_dirs & Ddir)
			entered_dirs |= angle2dir_cardinal(dir2angle(Ddir) + ang_change)
		if(old_exited_dirs & Ddir)
			exited_dirs |= angle2dir_cardinal(dir2angle(Ddir) + ang_change)

	update_appearance()
	return ..()

/obj/effect/decal/cleanable/vital/organic/footprints/update_name(updates)
	switch(footprint_sprite)
		if(FOOTPRINT_SPRITE_CLAWS)
			name = "clawprints"
		if(FOOTPRINT_SPRITE_SHOES)
			name = "footprints"
		if(FOOTPRINT_SPRITE_PAWS)
			name = "pawprints"
	dryname = "dried [name]"
	return ..()

/obj/effect/decal/cleanable/vital/organic/footprints/update_desc(updates)
	desc = "WHOSE [uppertext(name)] ARE THESE?"
	return ..()

/obj/effect/decal/cleanable/vital/organic/footprints/update_icon()
	. = ..()
	alpha = max(BLOODY_FOOTPRINT_BASE_ALPHA, min(255 * (bloodiness / 15), 255))

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

/obj/effect/decal/cleanable/vital/organic/footprints/update_overlays()
	. = ..()
	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[footprint_sprite]-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[footprint_sprite]-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]_[footprint_sprite]_enter", dir = Ddir)
			. += bloodstep_overlay

		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[footprint_sprite]-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[footprint_sprite]-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]_[footprint_sprite]_exit", dir = Ddir)
			. += bloodstep_overlay


/obj/effect/decal/cleanable/vital/organic/footprints/examine(mob/user)
	. = ..()
	if((shoe_types.len + species_types.len) > 0)
		. += "You recognise the [name] as belonging to:"
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

/obj/effect/decal/cleanable/vital/organic/footprints/replace_decal(obj/effect/decal/cleanable/blood/blood_decal)
	if(blood_state != blood_decal.blood_state || footprint_sprite != blood_decal.footprint_sprite) //We only replace footprints of the same type as us
		return FALSE
	return ..()

/obj/effect/decal/cleanable/vital/organic/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return TRUE
	return FALSE

/obj/effect/decal/cleanable/vital/organic/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "[blood_species_prefix]hitsplatter1"
	random_icon_states = list("[blood_species_prefix]hitsplatter1", "[blood_species_prefix]hitsplatter2", "[blood_species_prefix]hitsplatter3",)
	plane = GAME_PLANE
	layer = ABOVE_WINDOW_LAYER
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

/obj/effect/decal/cleanable/vital/organic/hitsplatter/Initialize(mapload, splatter_strength)
	. = ..()
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/vital/organic/hitsplatter/Destroy()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		if(blood_dna_info)
			loc.add_blood_DNA(blood_dna_info)
	return ..()

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/vital/organic/hitsplatter/proc/fly_towards(turf/target_turf, range)
	var/delay = 2
	var/datum/move_loop/loop = GLOB.move_manager.move_towards(src, target_turf, delay, timeout = delay * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/vital/organic/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/vital/organic/hitsplatter/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	for(var/atom/iter_atom in get_turf(src))
		if(hit_endpoint)
			return
		if(splatter_strength <= 0)
			break

		if(isitem(iter_atom))
			iter_atom.add_blood_DNA(blood_dna_info)
			splatter_strength--
		else if(ishuman(iter_atom))
			var/mob/living/carbon/human/splashed_human = iter_atom
			if(splashed_human.wear_suit)
				splashed_human.wear_suit.add_blood_DNA(blood_dna_info)
				splashed_human.update_worn_oversuit()    //updates mob overlays to show the new blood (no refresh)
			if(splashed_human.w_uniform)
				splashed_human.w_uniform.add_blood_DNA(blood_dna_info)
				splashed_human.update_worn_undersuit()    //updates mob overlays to show the new blood (no refresh)
			splatter_strength--
	if(splatter_strength <= 0) // we used all the puff so we delete it.
		qdel(src)

/obj/effect/decal/cleanable/vital/organic/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/decal/cleanable/vital/organic/hitsplatter/Bump(atom/bumped_atom)
	if(!iswallturf(bumped_atom) && !istype(bumped_atom, /obj/structure/window))
		qdel(src)
		return

	if(istype(bumped_atom, /obj/structure/window))
		var/obj/structure/window/bumped_window = bumped_atom
		if(!bumped_window.fulltile)
			hit_endpoint = TRUE
			qdel(src)
			return

	hit_endpoint = TRUE
	if(isturf(prev_loc))
		abstract_move(bumped_atom)
		skip = TRUE
		//Adjust pixel offset to make splatters appear on the wall
		if(istype(bumped_atom, /obj/structure/window))
			land_on_window(bumped_atom)
		else
			var/obj/effect/decal/cleanable/vital/organic/splatter/over_window/final_splatter = new(prev_loc)
			final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
			final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))
	else // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		qdel(src)

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/vital/organic/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!the_window.fulltile)
		return
	var/obj/effect/decal/cleanable/vital/organic/splatter/over_window/final_splatter = new
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	the_window.bloodied = TRUE
	qdel(src)

#undef BEAUTY_IMPACT_LOW
#undef BEAUTY_IMPACT_HIGH
