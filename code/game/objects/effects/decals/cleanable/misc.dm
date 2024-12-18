/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	icon = 'icons/obj/debris.dmi'
	icon_state = "shards"
	beauty = -50

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	icon = 'icons/obj/debris.dmi'
	icon_state = "ash"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	mergeable_decal = FALSE
	beauty = -50
	decal_reagent = /datum/reagent/ash
	reagent_amount = 30

/obj/effect/decal/cleanable/ash/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/effect/decal/cleanable/ash/NeverShouldHaveComeHere(turf/here_turf)
	return !istype(here_turf, /obj/structure/bodycontainer/crematorium) && ..()

/obj/effect/decal/cleanable/ash/large
	name = "large pile of ashes"
	icon_state = "big_ash"
	beauty = -100
	decal_reagent = /datum/reagent/ash
	reagent_amount = 60

/obj/effect/decal/cleanable/glass
	name = "tiny shards"
	desc = "Back to sand."
	icon = 'icons/obj/debris.dmi'
	icon_state = "tiny"
	beauty = -100

/obj/effect/decal/cleanable/glass/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinals))

/obj/effect/decal/cleanable/glass/ex_act()
	qdel(src)
	return TRUE

/obj/effect/decal/cleanable/glass/plasma
	icon_state = "plasmatiny"

/obj/effect/decal/cleanable/glass/titanium
	icon_state = "titaniumtiny"

/obj/effect/decal/cleanable/glass/plastitanium
	icon_state = "plastitaniumtiny"

//Screws that are dropped on the Z level below when deconstructing a reinforced floor plate.
/obj/effect/decal/cleanable/glass/plastitanium/screws //I don't know how to sprite scattered screws, this can work until a spriter gets their hands on it.
	name = "pile of screws"
	desc = "Looks like they fell from the ceiling"

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	icon = 'icons/effects/dirt.dmi'
	icon_state = "dirt-flat-0"
	base_icon_state = "dirt"
	smoothing_flags = NONE
	smoothing_groups = SMOOTH_GROUP_CLEANABLE_DIRT
	canSmoothWith = SMOOTH_GROUP_CLEANABLE_DIRT + SMOOTH_GROUP_WALLS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	beauty = -75

/obj/effect/decal/cleanable/dirt/Initialize(mapload)
	. = ..()
	icon_state = pick("dirt-flat-0","dirt-flat-1","dirt-flat-2","dirt-flat-3")
	var/obj/structure/broken_flooring/broken_flooring = locate(/obj/structure/broken_flooring) in loc
	if(!isnull(broken_flooring))
		return
	var/turf/T = get_turf(src)
	if(T.tiled_dirt)
		smoothing_flags = SMOOTH_BITMASK
		QUEUE_SMOOTH(src)
	if(smoothing_flags & USES_SMOOTHING)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/effect/decal/cleanable/dirt/Destroy()
	if(smoothing_flags & USES_SMOOTHING)
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/decal/cleanable/dirt/dust
	name = "dust"
	desc = "A thin layer of dust coating the floor."
	icon_state = "dust"
	base_icon_state = "dust"

/obj/effect/decal/cleanable/dirt/dust/Initialize(mapload)
	. = ..()
	icon_state = base_icon_state

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	icon_state = "greenglow"
	light_power = 3
	light_range = 2
	light_color = LIGHT_COLOR_GREEN
	beauty = -300

/obj/effect/decal/cleanable/greenglow/ex_act()
	return FALSE

/obj/effect/decal/cleanable/greenglow/filled
	decal_reagent = /datum/reagent/uranium
	reagent_amount = 5

/obj/effect/decal/cleanable/greenglow/filled/Initialize(mapload)
	decal_reagent = pick(/datum/reagent/uranium, /datum/reagent/uranium/radium)
	. = ..()

/obj/effect/decal/cleanable/greenglow/ecto
	name = "ectoplasmic puddle"
	desc = "You know who to call."
	light_power = 2

/obj/effect/decal/cleanable/greenglow/radioactive
	name = "radioactive goo"
	desc = "Holy crap, stop looking at this and move away immediately! It's radioactive!"
	light_power = 5
	light_range = 3
	light_color = LIGHT_COLOR_NUCLEAR

/obj/effect/decal/cleanable/greenglow/radioactive/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddComponent(
		/datum/component/radioactive_emitter, \
		cooldown_time = 5 SECONDS, \
		range = 4, \
		threshold = RAD_MEDIUM_INSULATION, \
	)

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	gender = NEUTER
	plane = GAME_PLANE
	layer = WALL_OBJ_LAYER
	icon = 'icons/effects/web.dmi'
	icon_state = "cobweb1"
	resistance_flags = FLAMMABLE
	beauty = -100
	clean_type = CLEAN_TYPE_HARD_DECAL
	is_mopped = FALSE

/obj/effect/decal/cleanable/cobweb/cobweb2
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/molten_object
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	gender = NEUTER
	icon = 'icons/effects/effects.dmi'
	icon_state = "molten"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	mergeable_decal = FALSE
	beauty = -150
	clean_type = CLEAN_TYPE_HARD_DECAL

/obj/effect/decal/cleanable/molten_object/large
	name = "big gooey grey mass"
	icon_state = "big_molten"
	beauty = -300

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	beauty = -150

/obj/effect/decal/cleanable/vomit/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isflyperson(H))
			playsound(get_turf(src), 'sound/items/drink.ogg', 50, TRUE) //slurp
			H.visible_message(span_alert("[H] extends a small proboscis into the vomit pool, sucking it with a slurping sound."))
			reagents.trans_to(H, reagents.total_volume, transferred_by = user, methods = INGEST)
			qdel(src)

/obj/effect/decal/cleanable/vomit/toxic // this has a more toned-down color palette, which may be why it's used as the default in so many spots
	icon_state = "vomittox_1"
	random_icon_states = list("vomittox_1", "vomittox_2", "vomittox_3", "vomittox_4")

/obj/effect/decal/cleanable/vomit/purple // ourple
	icon_state = "vomitpurp_1"
	random_icon_states = list("vomitpurp_1", "vomitpurp_2", "vomitpurp_3", "vomitpurp_4")

/obj/effect/decal/cleanable/vomit/nanites
	name = "nanite-infested vomit"
	desc = "Gosh, you can see something moving in there."
	icon_state = "vomitnanite_1"
	random_icon_states = list("vomitnanite_1", "vomitnanite_2", "vomitnanite_3", "vomitnanite_4")

/obj/effect/decal/cleanable/vomit/nebula
	name = "nebula vomit"
	desc = "Gosh, how... beautiful."
	icon_state = "vomitnebula_1"
	random_icon_states = list("vomitnebula_1", "vomitnebula_2", "vomitnebula_3", "vomitnebula_4")
	beauty = 10

/obj/effect/decal/cleanable/vomit/nebula/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/decal/cleanable/vomit/nebula/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = src.alpha)

/// Nebula vomit with extra guests
/obj/effect/decal/cleanable/vomit/nebula/worms

/obj/effect/decal/cleanable/vomit/nebula/worms/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	for (var/i in 1 to rand(2, 3))
		new /mob/living/basic/hivelord_brood(loc)

/obj/effect/decal/cleanable/vomit/old
	name = "crusty dried vomit"
	desc = "You try not to look at the chunks, and fail."

/obj/effect/decal/cleanable/vomit/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state += "-old"
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 10)

/obj/effect/decal/cleanable/vomit/old/black_bile
	name = "black bile"
	desc = "There's something wiggling in there..."
	color = COLOR_DARK

/obj/effect/decal/cleanable/chem_pile
	name = "chemical pile"
	desc = "A pile of chemicals. You can't quite tell what's inside it."
	gender = NEUTER
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	icon = 'icons/obj/debris.dmi'
	icon_state = "ash"

/obj/effect/decal/cleanable/shreds
	name = "shreds"
	desc = "The shredded remains of what appears to be clothing."
	icon_state = "shreds"
	gender = PLURAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/shreds/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE) //so shreds created during an explosion aren't deleted by the explosion.
		qdel(src)
		return TRUE

	return FALSE

/obj/effect/decal/cleanable/shreds/Initialize(mapload, oldname)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	if(!isnull(oldname))
		desc = "The sad remains of what used to be [oldname]"
	. = ..()

/obj/effect/decal/cleanable/glitter
	name = "generic glitter pile"
	desc = "The herpes of arts and crafts."
	icon = 'icons/effects/atmospherics.dmi'
	icon_state = "plasma_old"
	gender = NEUTER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/cleanable/glitter/pink
	name = "pink glitter"
	icon_state = "plasma"

/obj/effect/decal/cleanable/glitter/white
	name = "white glitter"
	icon_state = "nitrous_oxide"

/obj/effect/decal/cleanable/glitter/blue
	name = "blue glitter"
	icon_state = "freon"

/obj/effect/decal/cleanable/plasma
	name = "stabilized plasma"
	desc = "A puddle of stabilized plasma."
	icon_state = "flour"
	icon = 'icons/effects/tomatodecal.dmi'
	color = "#2D2D2D"

/obj/effect/decal/cleanable/insectguts
	name = "insect guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")

/obj/effect/decal/cleanable/confetti
	name = "confetti"
	desc = "Tiny bits of colored paper thrown about for the janitor to enjoy!"
	icon = 'icons/effects/confetti_and_decor.dmi'
	icon_state = "confetti"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT //the confetti itself might be annoying enough

/obj/effect/decal/cleanable/plastic
	name = "plastic shreds"
	desc = "Bits of torn, broken, worthless plastic."
	icon = 'icons/obj/debris.dmi'
	icon_state = "shards"
	color = "#c6f4ff"

/obj/effect/decal/cleanable/wrapping
	name = "wrapping shreds"
	desc = "Torn pieces of cardboard and paper, left over from a package."
	icon = 'icons/obj/debris.dmi'
	icon_state = "paper_shreds"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER

/obj/effect/decal/cleanable/wrapping/pinata
	name = "pinata shreds"
	desc = "Torn pieces of papier-mâché, left over from a pinata"
	icon_state = "pinata_shreds"

/obj/effect/decal/cleanable/wrapping/pinata/syndie
	icon_state = "syndie_pinata_shreds"

/obj/effect/decal/cleanable/wrapping/pinata/donk
	icon_state = "donk_pinata_shreds"

/obj/effect/decal/cleanable/garbage
	name = "decomposing garbage"
	desc = "A split open garbage bag, its stinking content seems to be partially liquified. Yuck!"
	icon = 'icons/obj/debris.dmi'
	icon_state = "garbage"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	beauty = -150
	clean_type = CLEAN_TYPE_HARD_DECAL

/obj/effect/decal/cleanable/garbage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 15)

/obj/effect/decal/cleanable/ants
	name = "space ants"
	desc = "A small colony of space ants. They're normally used to the vacuum of space, so they can't climb too well."
	icon = 'icons/obj/debris.dmi'
	icon_state = "ants"
	beauty = -150
	plane = GAME_PLANE
	layer = LOW_OBJ_LAYER
	decal_reagent = /datum/reagent/ants
	reagent_amount = 5
	/// Sound the ants make when biting
	var/bite_sound = 'sound/items/weapons/bite.ogg'

/obj/effect/decal/cleanable/ants/Initialize(mapload)
	if(mapload && reagent_amount > 2)
		reagent_amount = rand((reagent_amount - 2), reagent_amount)
	. = ..()
	update_ant_damage()

/obj/effect/decal/cleanable/ants/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, bite_sound))
		update_ant_damage()

/obj/effect/decal/cleanable/ants/handle_merge_decal(obj/effect/decal/cleanable/merger)
	. = ..()
	var/obj/effect/decal/cleanable/ants/ants = merger
	ants.update_ant_damage()

/obj/effect/decal/cleanable/ants/proc/update_ant_damage(ant_min_damage, ant_max_damage)
	if(!ant_max_damage)
		ant_max_damage = min(10, round((reagents.get_reagent_amount(/datum/reagent/ants) * 0.1),0.1)) // 100u ants = 10 max_damage
	if(!ant_min_damage)
		ant_min_damage = 0.1
	var/ant_flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN) /// Small amounts of ants won't be able to bite through shoes.
	if(ant_max_damage > 1)
		ant_flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

	var/datum/component/caltrop/caltrop_comp = GetComponent(/datum/component/caltrop)
	if(caltrop_comp)
		caltrop_comp.min_damage = ant_min_damage
		caltrop_comp.max_damage = ant_max_damage
		caltrop_comp.flags = ant_flags
		caltrop_comp.soundfile = bite_sound
	else
		AddComponent(/datum/component/caltrop, min_damage = ant_min_damage, max_damage = ant_max_damage, flags = ant_flags, soundfile = bite_sound)

	update_appearance(UPDATE_ICON)

/obj/effect/decal/cleanable/ants/update_icon_state()
	if(istype(src, /obj/effect/decal/cleanable/ants/fire)) //i fucking hate this but you're forced to call parent in update_icon_state()
		return ..()
	if(!(flags_1 & INITIALIZED_1))
		return ..()

	var/datum/component/caltrop/caltrop_comp = GetComponent(/datum/component/caltrop)
	if(!caltrop_comp)
		return ..()

	switch(caltrop_comp.max_damage)
		if(0 to 1)
			icon_state = initial(icon_state)
		if(1.1 to 4)
			icon_state = "[initial(icon_state)]_2"
		if(4.1 to 7)
			icon_state = "[initial(icon_state)]_3"
		if(7.1 to INFINITY)
			icon_state = "[initial(icon_state)]_4"
	return ..()

/obj/effect/decal/cleanable/ants/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_light", src, alpha = src.alpha)

/obj/effect/decal/cleanable/ants/fire_act(exposed_temperature, exposed_volume)
	new /obj/effect/decal/cleanable/ants/fire(loc)
	qdel(src)

/obj/effect/decal/cleanable/ants/fire
	name = "space fire ants"
	desc = "A small colony no longer. We are the fire nation."
	decal_reagent = /datum/reagent/ants/fire
	icon_state = "fire_ants"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/ants/fire/update_ant_damage(ant_min_damage, ant_max_damage)
	return ..(15, 25)

/obj/effect/decal/cleanable/ants/fire/fire_act(exposed_temperature, exposed_volume)
	return

/obj/effect/decal/cleanable/fuel_pool
	name = "pool of fuel"
	desc = "A pool of flammable fuel. Its probably wise to clean this off before something ignites it..."
	icon_state = "fuel_pool"
	beauty = -50
	clean_type = CLEAN_TYPE_BLOOD
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	resistance_flags = UNACIDABLE | ACID_PROOF | FIRE_PROOF | FLAMMABLE //gross way of doing this but would need to disassemble fire_act call stack otherwise
	/// Maximum amount of hotspots this pool can create before deleting itself
	var/burn_amount = 3
	/// Is this fuel pool currently burning?
	var/burning = FALSE
	/// Type of hotspot fuel pool spawns upon being ignited
	var/hotspot_type = /obj/effect/hotspot

/obj/effect/decal/cleanable/fuel_pool/Initialize(mapload, burn_stacks)
	. = ..()
	var/static/list/ignition_trigger_connections = list(
		COMSIG_TURF_MOVABLE_THROW_LANDED = PROC_REF(ignition_trigger),
	)
	AddElement(/datum/element/connect_loc, ignition_trigger_connections)
	for(var/obj/effect/decal/cleanable/fuel_pool/pool in get_turf(src)) //Can't use locate because we also belong to that turf
		if(pool == src)
			continue
		pool.burn_amount =  max(min(pool.burn_amount + burn_stacks, 10), 1)
		return INITIALIZE_HINT_QDEL

	if(burn_stacks)
		burn_amount = max(min(burn_stacks, 10), 1)

	return INITIALIZE_HINT_LATELOAD

// Just in case of fires, do this after mapload.
/obj/effect/decal/cleanable/fuel_pool/LateInitialize()
// We don't want to burn down the create_and_destroy test area
#ifndef UNIT_TESTS
	RegisterSignal(src, COMSIG_ATOM_TOUCHED_SPARKS, PROC_REF(ignition_trigger))
#endif

/obj/effect/decal/cleanable/fuel_pool/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	ignite()

/**
 * Ignites the fuel pool. This should be the only way to ignite fuel pools.
 */
/obj/effect/decal/cleanable/fuel_pool/proc/ignite()
	if(burning)
		return
	burning = TRUE
	burn_process()

/**
 * Spends 1 burn_amount and spawns a hotspot. If burn_amount is equal to 0, deletes the fuel pool.
 * Else, queues another call of this proc upon hotspot getting deleted and ignites other fuel pools around itself after 0.5 seconds.
 * THIS SHOULD NOT BE CALLED DIRECTLY.
 */
/obj/effect/decal/cleanable/fuel_pool/proc/burn_process()
	SIGNAL_HANDLER

	burn_amount -= 1
	var/obj/effect/hotspot/hotspot = new hotspot_type(get_turf(src))
	addtimer(CALLBACK(src, PROC_REF(ignite_others)), 0.5 SECONDS)

	if(!burn_amount)
		qdel(src)
		return

	RegisterSignal(hotspot, COMSIG_QDELETING, PROC_REF(burn_process))

/**
 * Ignites other oil pools around itself.
 */
/obj/effect/decal/cleanable/fuel_pool/proc/ignite_others()
	for(var/obj/effect/decal/cleanable/fuel_pool/oil in range(1, get_turf(src)))
		oil.ignite()

/obj/effect/decal/cleanable/fuel_pool/bullet_act(obj/projectile/hit_proj)
	. = ..()
	ignite()

/obj/effect/decal/cleanable/fuel_pool/attackby(obj/item/item, mob/user, params)
	if(item.ignition_effect(src, user))
		ignite()
	return ..()

/obj/effect/decal/cleanable/fuel_pool/on_entered(datum/source, atom/movable/entered_atom)
	. = ..()
	if(entered_atom.throwing) // don't light from things being thrown over us, we handle that somewhere else
		return
	ignition_trigger(source = src, enflammable_atom = entered_atom)

/obj/effect/decal/cleanable/fuel_pool/proc/ignition_trigger(datum/source, atom/movable/enflammable_atom)
	SIGNAL_HANDLER

	if(isitem(enflammable_atom))
		var/obj/item/enflamed_item = enflammable_atom
		if(enflamed_item.get_temperature() > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			ignite()
		return
	else if(isliving(enflammable_atom))
		var/mob/living/enflamed_liver = enflammable_atom
		if(enflamed_liver.on_fire)
			ignite()
	else if(istype(enflammable_atom, /obj/effect/particle_effect/sparks))
		ignite()


/obj/effect/decal/cleanable/fuel_pool/hivis
	icon_state = "fuel_pool_hivis"

/obj/effect/decal/cleanable/rubble
	name = "rubble"
	desc = "A pile of rubble."
	icon = 'icons/obj/debris.dmi'
	icon_state = "rubble"
	mergeable_decal = FALSE
	beauty = -10
	plane = GAME_PLANE
	layer = GIB_LAYER
	clean_type = CLEAN_TYPE_HARD_DECAL
	is_mopped = FALSE

/obj/effect/decal/cleanable/rubble/Initialize(mapload)
	. = ..()
	flick("rubble_bounce", src)
	icon_state = "rubble"
	update_appearance(UPDATE_ICON_STATE)
