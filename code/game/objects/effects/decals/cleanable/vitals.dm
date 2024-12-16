//keeping the old files to ensure compatability while things get moved to this system.
//Future me thinks this is a bad idea because of the GLOB defines. Oh well.
//Remove these comments before merge
//but yeah, unified blood decal system I guess

#define BEAUTY_IMPACT_LOW -50
#define BEAUTY_IMPACT_HIGH -100

/obj/effect/decal/cleanable/vital
	name = "vital fluids"
	desc = "Universally-generic vital fluids"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list(
	"floor1",
	"floor2",
	"floor3",
	"floor4",
	"floor5",
	"floor6",
	"floor7",)
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	beauty = BEAUTY_IMPACT_HIGH
	clean_type = CLEAN_TYPE_BLOOD
	var/should_dry = TRUE
	var/dryname = "dried blood" //when the blood lasts long enough, it becomes dry and gets a new name
	var/drydesc = "Looks like it's been here a while. Eew." //as above
	var/drytime = 0
	var/footprint_sprite = null
	var/flammable = FALSE

//changes the decal per the parameters
/obj/effect/decal/cleanable/vital/New()
	var/type_params = get_vocab()
	var/base_icon_state = icon_state
	var/base_beauty = beauty
	var/base_name = name
	var/base_desc = desc
	icon = type_params[1]
	desc = replacetext(base_desc, "%BLOOD_COLOR%", type_params[2])
	name = replacetext(base_name, "%SOURCE_SPECIES%", type_params[3])
	icon_state = "[type_params[4]][base_icon_state]"
	desc = replacetext(desc, "%SIMILAR_FOOD%", type_params[6])
	beauty = base_beauty * type_params[7]
			
/obj/effect/decal/cleanable/vital/proc/get_vocab()
//order is as follows:
	//icon
	var/blood_color
	var/blood_species_full
	var/blood_species_prefix
	//decal_reagent
	var/color_food //a food associated with the color
	var/beauty_mult
	switch(blood_state)
		if(BLOOD_STATE_HUMAN)
			return list(
			'icons/effects/blood.dmi' = icon,
			"red" = blood_color,
			"humanoid" = blood_species_full,
			"" = blood_species_prefix,
			decal_reagent,
			"ketchup" = color_food,
			1 = beauty_mult,
			)
		if(BLOOD_STATE_XENO)
			return list(
			'icons/effects/blood.dmi' = icon,
			"green" = blood_color,
			"xeno" = blood_species_full,
			"x" = blood_species_prefix,
			decal_reagent,
			"avocado" = color_food,
			2.5 = beauty_mult,
			)
		if(BLOOD_STATE_OIL)
			return list(
			'icons/mob/silicon/robots.dmi' = icon,
			"black" = blood_color,
			"robotic" = blood_species_full,
			"" = blood_species_prefix,
			/datum/reagent/fuel/oil = decal_reagent,
			"nero di seppia" = color_food,
			1 = beauty_mult,
			)
		//if(BLOOD_STATE_LATEX) - TODO: Aliens-esque synth blood
			
			//"calamari" = color_food,
		if(null)
			return
	return

//base for organic "blood"
/obj/effect/decal/cleanable/vital/organic/blood
	name = "%SOURCE_SPECIES% blood"
	desc = "It's %BLOOD_COLOR% and gooey. Perhaps it's the chef's cooking?"
	icon_state = "floor1"
	blood_state = BLOOD_STATE_HUMAN
	
//base for organic "chunk"s
/obj/effect/decal/cleanable/vital/organic/gibs
	name = "%SOURCE_SPECIES% gibs"
	desc = "They look bloody and gruesome."
	icon_state = "gib1"
	layer = BELOW_OBJ_LAYER
	plane = GAME_PLANE
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6",)
	mergeable_decal = FALSE
	blood_state = BLOOD_STATE_HUMAN

	dryname = "rotting gibs"
	drydesc = "They look bloody and gruesome while some terrible smell fills the air."
	decal_reagent = /datum/reagent/consumable/liquidgibs
	reagent_amount = 5

//base for xenomorph blood
/obj/effect/decal/cleanable/vital/organic/xenoblood
	name = "%SOURCE_SPECIES% blood"
	desc = "It's %BLOOD_COLOR% and acidic. It looks like... <i>blood?</i>"
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_XENO
	beauty = BEAUTY_IMPACT_HIGH

/obj/effect/decal/cleanable/vital/organic/xenoblood/Initialize(mapload)
	. = ..()
	add_blood_DNA(list("UNKNOWN DNA" = "X*"))
	
//base for xenomorph gibs
/obj/effect/decal/cleanable/vital/organic/xgibs
	name = "%SOURCE_SPECIES% blood"
	desc = "Gnarly..."
	icon_state = "gib1"
	plane = GAME_PLANE
	layer = BELOW_OBJ_LAYER
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/vital/organic/xgibs/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))

//base for robotic "blood"
/obj/effect/decal/cleanable/vital/robotic/oil
	name = "motor oil"
	desc = "It's %BLOOD_COLOR% and greasy. Looks like Beepsky made another mess."
	icon_state = "floor1"
	random_icon_states = list(
	"floor1",
	"floor2",
	"floor3",
	"floor4",
	"floor5",
	"floor6",
	"floor7",)
	blood_state = BLOOD_STATE_OIL
	beauty = BEAUTY_IMPACT_HIGH
	decal_reagent = /datum/reagent/fuel/oil
	reagent_amount = 30
	should_dry = FALSE
	flammable = TRUE
	
//base for robotic "chunks"
/obj/effect/decal/cleanable/vital/robotic/debris
	name = "%SOURCE_SPECIES% debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	icon_state = "gib1"
	plane = GAME_PLANE
	layer = BELOW_OBJ_LAYER
	random_icon_states = list(
	"gib1",
	"gib2",
	"gib3",
	"gib4",
	"gib5",
	"gib6", 
	"gib7",)
	mergeable_decal = FALSE
	beauty = BEAUTY_IMPACT_LOW 
	blood_state = BLOOD_STATE_OIL
	
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
		new /obj/effect/decal/cleanable/vital/robotic/oil/streak(loc)
	else if (prob(10))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/obj/effect/decal/cleanable/vital/robotic/debris/proc/streak(list/directions, mapload=FALSE)
	var/direction = pick(directions)
	var/delay = 2
	var/range = pick(1, 200; 2, 150; 3, 50; 4, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return
	if(mapload)
		for (var/i in 1 to range)
			var/turf/my_turf = get_turf(src)
			if(prob(40) && (!isgroundlessturf(my_turf) || GET_TURF_BELOW(my_turf)))
				new /obj/effect/decal/cleanable/vital/robotic/oil/streak(my_turf)
			if (!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = GLOB.move_manager.move(src, direction, delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

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

/obj/effect/decal/cleanable/vital/robotic/oil/slippery/Initialize(mapload)
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

/obj/effect/decal/cleanable/vital/organic/replace_decal(obj/effect/decal/cleanable/vital/organic/C)
	C.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	if (bloodiness)
		C.bloodiness = min((C.bloodiness + bloodiness), BLOOD_AMOUNT_PER_DECAL)
	return ..()

/obj/effect/decal/cleanable/vital/organic/blood/old
	bloodiness = 0
	icon_state = "floor1-old"

/obj/effect/decal/cleanable/vital/organic/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_blood_type())) // Needs to happen before ..()
	return ..()

/obj/effect/decal/cleanable/vital/organic/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5",)

/obj/effect/decal/cleanable/vital/organic/blood/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180

/obj/effect/decal/cleanable/vital/organic/blood/splatter/over_window/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

/obj/effect/decal/cleanable/vital/organic/blood/tracks
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	random_icon_states = null
	beauty = BEAUTY_IMPACT_LOW 
	dryname = "dried tracks"
	drydesc = "Some old bloody tracks left by wheels. Machines are evil, perhaps."

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon = 'icons/effects/blood.dmi'
	desc = "Your instincts say you shouldn't be following these."
	beauty = (BEAUTY_IMPACT_LOW)
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

// normal version of the above trail holder object for use in less convoluted things
/obj/effect/decal/cleanable/vital/organic/trails
	desc = "Looks like a corpse was smeared all over the floor like %SIMILAR_FOOD%. Kinda makes you hungry."
	random_icon_states = list("trails_1", "trails_2",)
	icon_state = "trails_1"
	beauty = BEAUTY_IMPACT_LOW 
	dryname = "dried tracks"
	drydesc = "Looks like a corpse was smeared all over the floor like %SIMILAR_FOOD%, but it's all dried up and nasty now, ew. You lose some of your appetite."



//handlers for organic "chunk"s

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
				new /obj/effect/decal/cleanable/vital/organic/blood/splatter(my_turf)
			if (!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = GLOB.move_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

/obj/effect/decal/cleanable/vital/organic/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	if(NeverShouldHaveComeHere(loc))
		return
	new /obj/effect/decal/cleanable/vital/organic/blood/splatter(loc)

/obj/effect/decal/cleanable/vital/organic/gibs/up
	icon_state = "gibup1"
	random_icon_states = list(
	"gib1",
	"gib2", 
	"gib3", 
	"gib4", 
	"gib5", 
	"gib6", 
	"gibup1", 
	"gibup1", 
	"gibup1",)

/obj/effect/decal/cleanable/vital/organic/gibs/down
	icon_state = "gibdown1"
	random_icon_states = list(
	"gib1",
	"gib2",
	"gib3",
	"gib4",
	"gib5",
	"gib6",
	"gibdown1",
	"gibdown1",
	"gibdown1",)

/obj/effect/decal/cleanable/vital/organic/gibs/body
	icon_state = "gibtorso"
	random_icon_states = list(
	"gibhead",
	"gibtorso",)

/obj/effect/decal/cleanable/vital/organic/gibs/torso
	icon_state = "gibtorso"
	random_icon_states = null

/obj/effect/decal/cleanable/vital/organic/gibs/limb
	icon_state = "gibleg"
	random_icon_states = list(
	"gibleg",
	"gibarm",)

/obj/effect/decal/cleanable/vital/organic/gibs/core
	icon_state = "gibmid1"
	random_icon_states = list(
	"gibmid1",
	"gibmid2",
	"gibmid3",)

/obj/effect/decal/cleanable/vital/organic/gibs/old
	name = "old rotting gibs"
	desc = "Space Jesus, why didn't anyone clean this up? They smell terrible."
	icon_state = "gib1-old"
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

//handlers for organic "blood"
/obj/effect/decal/cleanable/vital/organic/blood/drip
	name = "drips of blood"
	desc = "It's %BLOOD_COLOR%."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list(
	"drip1",
	"drip2",
	"drip3",
	"drip4",
	"drip5",)
	bloodiness = 0
	var/drips = 1
	dryname = "drips of blood"
	drydesc = "It's %BLOOD_COLOR%."

/obj/effect/decal/cleanable/vital/organic/blood/drip/can_bloodcrawl_in()
	return TRUE

//handlers for xeno "blood"

/obj/effect/decal/cleanable/vital/organic/xenoblood/xsplatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

//handlers for xeno "gib"s

/obj/effect/decal/cleanable/vital/organic/xgibs/proc/streak(list/directions, mapload=FALSE)
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
				new /obj/effect/decal/cleanable/vital/organic/xenoblood/xsplatter(my_turf)
			if (!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = GLOB.move_manager.move(src, direction, delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

/obj/effect/decal/cleanable/vital/organic/xgibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	if(NeverShouldHaveComeHere(loc))
		return
	new /obj/effect/decal/cleanable/vital/organic/xenoblood/xsplatter(loc)

/obj/effect/decal/cleanable/vital/organic/xgibs/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/vital/organic/xgibs/ex_act()
	return FALSE

/obj/effect/decal/cleanable/vital/organic/xgibs/up
	icon_state = "xgibup1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/vital/organic/xgibs/down
	icon_state = "xgibdown1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/vital/organic/xgibs/body
	icon_state = "xgibtorso"
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/vital/organic/xgibs/torso
	icon_state = "xgibtorso"
	random_icon_states = list("xgibtorso")

/obj/effect/decal/cleanable/vital/organic/xgibs/limb
	icon_state = "xgibleg"
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/vital/organic/xgibs/core
	icon_state = "xgibmid1"
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/vital/organic/xgibs/larva
	icon_state = "xgiblarva1"
	random_icon_states = list("xgiblarva1", "xgiblarva2")

/obj/effect/decal/cleanable/vital/organic/xgibs/larva/body
	icon_state = "xgiblarvatorso"
	random_icon_states = list("xgiblarvahead", "xgiblarvatorso")

//handlers for for robotic "blood"

/obj/effect/decal/cleanable/vital/robotic/oil/streak
	icon_state = "streak1"
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")
	beauty = BEAUTY_IMPACT_LOW 

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
/obj/effect/decal/cleanable/vital/organic/blood/footprints
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

/obj/effect/decal/cleanable/vital/organic/blood/footprints/Initialize(mapload, footprint_sprite)
	src.footprint_sprite = footprint_sprite
	. = ..()
	icon_state = "" //All of the footprint visuals come from overlays
	if(mapload)
		entered_dirs |= dir //Keep the same appearance as in the map editor
	update_appearance(mapload ? (ALL) : (UPDATE_NAME | UPDATE_DESC))

//Rotate all of the footprint directions too
/obj/effect/decal/cleanable/vital/organic/blood/footprints/setDir(newdir)
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

/obj/effect/decal/cleanable/vital/organic/blood/footprints/update_name(updates)
	switch(footprint_sprite)
		if(FOOTPRINT_SPRITE_CLAWS)
			name = "clawprints"
		if(FOOTPRINT_SPRITE_SHOES)
			name = "footprints"
		if(FOOTPRINT_SPRITE_PAWS)
			name = "pawprints"
	dryname = "dried [name]"
	return ..()

/obj/effect/decal/cleanable/vital/organic/blood/footprints/update_desc(updates)
	desc = "WHOSE [uppertext(name)] ARE THESE?"
	return ..()

/obj/effect/decal/cleanable/vital/organic/blood/footprints/update_icon()
	. = ..()
	alpha = max(BLOODY_FOOTPRINT_BASE_ALPHA, min(255 * (bloodiness / 15), 255))

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

/obj/effect/decal/cleanable/vital/organic/blood/footprints/update_overlays()
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


/obj/effect/decal/cleanable/vital/organic/blood/footprints/examine(mob/user)
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

/obj/effect/decal/cleanable/vital/organic/blood/footprints/replace_decal(obj/effect/decal/cleanable/vital/organic/blood/blood_decal)
	if(blood_state != blood_decal.blood_state || footprint_sprite != blood_decal.footprint_sprite) //We only replace footprints of the same type as us
		return FALSE
	return ..()

/obj/effect/decal/cleanable/vital/organic/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return TRUE
	return FALSE
	
//hitsplatter code
/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3",)
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

/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/Initialize(mapload, splatter_strength)
	. = ..()
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/Destroy()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		if(blood_dna_info)
			loc.add_blood_DNA(blood_dna_info)
	return ..()

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	var/delay = 2
	var/datum/move_loop/loop = GLOB.move_manager.move_towards(src, target_turf, delay, timeout = delay * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/proc/post_move(datum/move_loop/source)
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

/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/Bump(atom/bumped_atom)
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
			var/obj/effect/decal/cleanable/vital/organic/blood/splatter/over_window/final_splatter = new(prev_loc)
			final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
			final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))
	else // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		qdel(src)

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/vital/organic/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!the_window.fulltile)
		return
	var/obj/effect/decal/cleanable/vital/organic/blood/splatter/over_window/final_splatter = new
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	the_window.bloodied = TRUE
	qdel(src)

#undef BEAUTY_IMPACT_LOW
#undef BEAUTY_IMPACT_HIGH
