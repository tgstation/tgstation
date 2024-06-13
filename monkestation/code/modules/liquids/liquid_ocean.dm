GLOBAL_LIST_INIT(initalized_ocean_areas, list())
/area/ocean
	name = "Ocean"

	icon = 'monkestation/icons/obj/effects/liquid.dmi'
	base_icon_state = "ocean"
	icon_state = "ocean"
	alpha = 120

	requires_power = TRUE
	always_unpowered = TRUE

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE

	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/ocean/Initialize(mapload)
	. = ..()
	GLOB.initalized_ocean_areas += src

/area/ocean/dark
	base_lighting_alpha = 0

/area/ruin/ocean
	has_gravity = TRUE

/area/ruin/ocean/listening_outpost
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bunker
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bioweapon_research
	area_flags = UNIQUE_AREA

/area/ruin/ocean/mining_site
	area_flags = UNIQUE_AREA

/area/ocean/near_station_powered
	requires_power = FALSE

/turf/open/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/open/openspace/ocean
	var/replacement_turf = /turf/open/floor/plating/ocean

/turf/open/openspace/ocean/Initialize()
	. = ..()
	ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)

/turf/open/floor/plating
	///do we still call parent but dont want other stuff?
	var/overwrites_attack_by = FALSE
/turf/open/floor/plating/ocean
	plane = FLOOR_PLANE
	layer = TURF_LAYER
	force_no_gravity = FALSE
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/open/floor/plating/ocean
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	initial_gas_mix = OSHAN_DEFAULT_ATMOS

	upgradable = FALSE
	attachment_holes = FALSE

	resistance_flags = INDESTRUCTIBLE

	overwrites_attack_by = TRUE

	var/static/obj/effect/abstract/ocean_overlay/static_overlay
	var/static/list/ocean_reagents = list(/datum/reagent/water = 10)
	var/ocean_temp = T20C
	var/list/ocean_turfs = list()
	var/list/open_turfs = list()

	///are we captured, this is easier than having to run checks on turfs for vents
	var/captured = FALSE

	var/rand_variants = 0
	var/rand_chance = 30

	/// Itemstack to drop when dug by a shovel
	var/obj/item/stack/dig_result = /obj/item/stack/ore/glass
	/// Whether the turf has been dug or not
	var/dug = FALSE

	/// do we build a catwalk or plating with rods
	var/catwalk = FALSE

/turf/open/floor/plating/ocean/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(src, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))
	if(!static_overlay)
		static_overlay = new(null, ocean_reagents)

	vis_contents += static_overlay
	light_color = static_overlay.color
	SSliquids.unvalidated_oceans |= src
	SSliquids.ocean_turfs |= src

	if(rand_variants && prob(rand_chance))
		var/random = rand(1,rand_variants)
		icon_state = "[base_icon_state][random]"
		base_icon_state = "[base_icon_state][random]"


/turf/open/floor/plating/ocean/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL))
	SSliquids.active_ocean_turfs -= src
	SSliquids.ocean_turfs -= src
	for(var/turf/open/floor/plating/ocean/listed_ocean as anything in ocean_turfs)
		listed_ocean.rebuild_adjacent()

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			to_chat(user, span_warning("You need two rods to make a [catwalk ? "catwalk" : "plating"]!"))
			return
		else
			to_chat(user, span_notice("You begin constructing a [catwalk ? "catwalk" : "plating"]..."))
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !catwalk)
					PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
					playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
					R.use(2)
					to_chat(user, span_notice("You reinforce the [src]."))
				else if(R.get_amount() >= 2 && catwalk)
					new /obj/structure/lattice/catwalk(src)
					playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
					R.use(2)
					to_chat(user, span_notice("You build a catwalk over the [src]."))

	if(istype(C, /obj/item/trench_ladder_kit) && catwalk && is_safe())
		to_chat(user, span_notice("You begin constructing a ladder..."))
		if(do_after(user, 30, target = src))
			qdel(C)
			new /obj/structure/trench_ladder(src)

	if(istype(C, /obj/item/mining_charge) && !catwalk)
		to_chat(user, span_notice("You begin laying down a breaching charge..."))
		if(do_after(user, 15, target = src))
			var/obj/item/mining_charge/boom = C
			user.dropItemToGround(boom)
			boom.Move(src)
			boom.set_explosion()
			to_chat(user, span_warning("You lay down a breaching charge, you better run."))


/// Drops itemstack when dug and changes icon
/turf/open/floor/plating/ocean/proc/getDug()
	dug = TRUE
	new dig_result(src, 5)

/// If the user can dig the turf
/turf/open/floor/plating/ocean/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_warning("Looks like someone has dug here already!"))


/turf/open/floor/plating/ocean/proc/assume_self()
	if(!atmos_adjacent_turfs)
		immediate_calculate_adjacent_turfs()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			if(isclosedturf(directional_turf))
				RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction), TRUE)
				continue
			else if(!(directional_turf in atmos_adjacent_turfs))
				var/obj/machinery/door/found_door = locate(/obj/machinery/door) in directional_turf
				if(found_door)
					RegisterSignal(found_door, COMSIG_ATOM_DOOR_OPEN, TYPE_PROC_REF(/turf/open/floor/plating/ocean, door_opened))
				RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed), TRUE)
				continue
			else
				open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	SSliquids.unvalidated_oceans -= src

/turf/open/floor/plating/ocean/proc/door_opened(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/door/found_door = source
	var/turf/turf = get_turf(found_door)

	if(turf.can_atmos_pass())
		turf.add_liquid_list(ocean_reagents, FALSE, ocean_temp)

/turf/open/floor/plating/ocean/proc/process_turf()
	for(var/direction in open_turfs)
		var/turf/directional_turf = get_step(src, direction)
		if(isspaceturf(directional_turf) || istype(directional_turf, /turf/open/floor/plating/ocean))
			RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction), TRUE)
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return
		else if(!(directional_turf in atmos_adjacent_turfs))
			RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed), TRUE)
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return

		directional_turf.add_liquid_list(ocean_reagents, FALSE, ocean_temp)

/turf/open/floor/plating/ocean/proc/rebuild_adjacent()
	ocean_turfs = list()
	open_turfs = list()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	else if(src in SSliquids.active_ocean_turfs)
		SSliquids.active_ocean_turfs -= src

/turf/open/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/dousing_rod))
		var/obj/item/dousing_rod/attacking_rod = C
		attacking_rod.deploy(src)

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	. = ..()

	if(C.tool_behaviour == TOOL_SHOVEL || C.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return TRUE

		if(!isturf(user.loc))
			return

		balloon_alert(user, "digging...")

		if(C.use_tool(src, user, 40, volume=50))
			if(!can_dig(user))
				return TRUE
			getDug()
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, C.type)
			return TRUE

	if(istype(C, /obj/item/vent_package))
		if(captured)
			return
		if(!do_after(user, 2 SECONDS, src))
			return
		var/obj/item/vent_package/attacking = C
		attacking.deploy(src)
/obj/effect/abstract/ocean_overlay
	icon = 'monkestation/icons/obj/effects/liquid.dmi'
	icon_state = "ocean"
	base_icon_state = "ocean"
	plane = AREA_PLANE //Same as weather, etc.
	layer = ABOVE_MOB_LAYER
	vis_flags = NONE
	mouse_opacity = FALSE
	alpha = 120

/obj/effect/abstract/ocean_overlay/Initialize(mapload, list/ocean_contents)
	. = ..()
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/obj/effect/abstract/ocean_overlay/proc/mix_colors(list/ocean_contents)
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/turf/open/floor/plating/ocean/proc/mob_fall(datum/source, mob/M)
	SIGNAL_HANDLER
	var/turf/T = source
	playsound(T, 'monkestation/sound/effects/splash.ogg', 50, 0)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		to_chat(C, span_userdanger("You fall in the water!"))

/turf/open/floor/plating/ocean/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(prob(30))
		var/sound_to_play = pick(list(
			'monkestation/sound/effects/water_wade1.ogg',
			'monkestation/sound/effects/water_wade2.ogg',
			'monkestation/sound/effects/water_wade3.ogg',
			'monkestation/sound/effects/water_wade4.ogg'
			))
		playsound(T, sound_to_play, 50, 0)
	if(isliving(AM))
		var/mob/living/arrived = AM
		if(!arrived.has_status_effect(/datum/status_effect/ocean_affected))
			arrived.apply_status_effect(/datum/status_effect/ocean_affected)

	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WASH)

/turf/open/floor/plating/ocean/proc/add_turf_direction(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

	if(istype(direction_turf, /turf/open/floor/plating/ocean) || istype(direction_turf, /turf/closed/mineral/random/ocean))
		return

	open_turfs.Add(get_dir(src, direction_turf))

	if(!(src in SSliquids.active_ocean_turfs))
		SSliquids.active_ocean_turfs |= src

/turf/open/floor/plating/ocean/proc/add_turf_direction_non_closed(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

	if(!(direction_turf in atmos_adjacent_turfs))
		return

	open_turfs.Add(get_dir(src, direction_turf))

	if(!(src in SSliquids.active_ocean_turfs))
		SSliquids.active_ocean_turfs |= src


GLOBAL_LIST_INIT(scrollable_turfs, list())
GLOBAL_LIST_INIT(the_lever, list())
/turf/open/floor/plating/ocean/false_movement
	icon = 'goon/icons/turf/ocean.dmi'
	icon_state = "sand"
	var/scroll_state = "scroll"
	var/moving = FALSE


/turf/open/floor/plating/ocean/false_movement/Initialize()
	. = ..()
	GLOB.scrollable_turfs += src
	if(GLOB.the_lever.len)
		for(var/obj/machinery/movement_lever/lever as anything in GLOB.the_lever)
			set_scroll(lever.lever_on)
			break

/turf/open/floor/plating/ocean/false_movement/Destroy()
	. = ..()
	GLOB.scrollable_turfs -= src


/turf/open/floor/plating/ocean/false_movement/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(moving)
		if(!HAS_TRAIT(arrived, TRAIT_HYPERSPACED) && !HAS_TRAIT(arrived, TRAIT_FREE_HYPERSPACE_MOVEMENT))
			arrived.AddComponent(/datum/component/shuttle_cling/water, dir, old_loc)

/turf/open/floor/plating/ocean/false_movement/proc/set_scroll(is_scrolling)
	if(is_scrolling)
		icon_state = "sand_[scroll_state]"
		moving = TRUE
	else
		icon_state = "sand"
		moving = FALSE


/obj/machinery/movement_lever
	name = "braking lever"
	desc = "Stops the ship from moving."

	icon = 'goon/icons/obj/decorations.dmi'
	icon_state = "lever1"
	var/static/lever_on = TRUE
	var/static/lever_locked = FALSE

/obj/machinery/movement_lever/Initialize(mapload)
	. = ..()
	GLOB.the_lever += src

/obj/machinery/movement_lever/Destroy()
	. = ..()
	GLOB.the_lever -= src

/obj/machinery/movement_lever/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(lever_locked)
		to_chat(user, span_notice("The lever is locked in place and can't be moved"))
		return
	lever_on = !lever_on
	update_appearance()
	for(var/turf/open/floor/plating/ocean/false_movement/listed_turf as anything in GLOB.scrollable_turfs)
		listed_turf.set_scroll(lever_on)

/obj/machinery/movement_lever/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		if(do_after(user, 10 SECONDS, src))
			if(!lever_locked)
				visible_message(span_warning("[user] locks the [src] preventing it from being pulled."))
				lever_locked = TRUE
			else
				visible_message(span_warning("[user] unlocks the [src] allowing it to be pulled."))
				lever_locked = FALSE
			update_appearance()

/obj/machinery/movement_lever/update_icon(updates)
	. = ..()
	icon_state = "lever[lever_on]"
	if(lever_locked)
		icon_state = "[icon_state]-locked"

/datum/component/shuttle_cling/water
	hyperspace_type = /turf/open/floor/plating/ocean/false_movement



/turf/closed/mineral/random/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/high_chance/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/low_chance/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/stationside/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"



/turf/open/floor/plating/ocean/dark/ironsand
	baseturfs = /turf/open/floor/plating/ocean/dark/ironsand
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"
	rand_variants = 15
	rand_chance = 100

/turf/open/floor/plating/ocean/dark/rock
	name = "rock"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	rand_variants = 0

/turf/open/floor/plating/ocean/dark/rock/warm
	ocean_temp = T20C + 30

/turf/open/floor/plating/ocean/dark/rock/warm/fissure
	name = "fissure"
	icon = 'monkestation/icons/turf/fissure.dmi'
	icon_state = "fissure-0"
	base_icon_state = "fissure"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FISSURE
	canSmoothWith = SMOOTH_GROUP_FISSURE
	light_outer_range = 3
	light_color = LIGHT_COLOR_LAVA

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/Destroy()
	for(var/mob/living/leaving_mob in contents)
		leaving_mob.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(leaving_mob, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
	return ..()

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone) && !islava(gone.loc))
		gone.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(gone, TRAIT_NO_EXTINGUISH, TURF_TRAIT)

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/process(seconds_per_tick)
	if(!burn_stuff(null, seconds_per_tick))
		STOP_PROCESSING(SSobj, src)

///Generic return value of the can_burn_stuff() proc. Does nothing.
#define LAVA_BE_IGNORING 0
/// Another. Won't burn the target but will make the turf start processing.
#define LAVA_BE_PROCESSING 1
/// Burns the target and makes the turf process (depending on the return value of do_burn()).
#define LAVA_BE_BURNING 2

///Proc that sets on fire something or everything on the turf that's not immune to lava. Returns TRUE to make the turf start processing.
/turf/open/floor/plating/ocean/dark/rock/warm/fissure/proc/burn_stuff(atom/movable/to_burn, seconds_per_tick = 1)
	var/thing_to_check = src
	if (to_burn)
		thing_to_check = list(to_burn)
	for(var/atom/movable/burn_target as anything in thing_to_check)
		switch(can_burn_stuff(burn_target))
			if(LAVA_BE_IGNORING)
				continue
			if(LAVA_BE_BURNING)
				if(!do_burn(burn_target, seconds_per_tick))
					continue
		. = TRUE

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/proc/can_burn_stuff(atom/movable/burn_target)
	if(burn_target.movement_type & (FLYING|FLOATING)) //you're flying over it.
		return LAVA_BE_IGNORING

	if(isobj(burn_target))
		if(burn_target.throwing) // to avoid gulag prisoners easily escaping, throwing only works for objects.
			return LAVA_BE_IGNORING
		var/obj/burn_obj = burn_target
		if((burn_obj.resistance_flags & LAVA_PROOF))
			return LAVA_BE_PROCESSING
		return LAVA_BE_BURNING

	if (!isliving(burn_target))
		return LAVA_BE_IGNORING

	if(HAS_TRAIT(burn_target, TRAIT_LAVA_IMMUNE))
		return LAVA_BE_PROCESSING
	var/mob/living/burn_living = burn_target
	var/atom/movable/burn_buckled = burn_living.buckled
	if(burn_buckled)
		if(burn_buckled.movement_type & (FLYING|FLOATING))
			return LAVA_BE_PROCESSING
		if(isobj(burn_buckled))
			var/obj/burn_buckled_obj = burn_buckled
			if(burn_buckled_obj.resistance_flags & LAVA_PROOF)
				return LAVA_BE_PROCESSING
		else if(HAS_TRAIT(burn_buckled, TRAIT_LAVA_IMMUNE))
			return LAVA_BE_PROCESSING

	if(iscarbon(burn_living))
		var/mob/living/carbon/burn_carbon = burn_living
		var/obj/item/clothing/burn_suit = burn_carbon.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		var/obj/item/clothing/burn_helmet = burn_carbon.get_item_by_slot(ITEM_SLOT_HEAD)
		if(burn_suit?.clothing_flags & LAVAPROTECT && burn_helmet?.clothing_flags & LAVAPROTECT)
			return LAVA_BE_PROCESSING

	return LAVA_BE_BURNING

#undef LAVA_BE_BURNING
#undef LAVA_BE_PROCESSING
#undef LAVA_BE_IGNORING

/turf/open/floor/plating/ocean/dark/rock/warm/fissure/proc/do_burn(atom/movable/burn_target, seconds_per_tick = 1)
	if(QDELETED(burn_target))
		return FALSE

	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if(burn_obj.resistance_flags & ON_FIRE) // already on fire; skip it.
			return TRUE
		if(!(burn_obj.resistance_flags & FLAMMABLE))
			burn_obj.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
		if(burn_obj.resistance_flags & FIRE_PROOF)
			burn_obj.resistance_flags &= ~FIRE_PROOF
		if(burn_obj.get_armor_rating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
			burn_obj.set_armor_rating(FIRE, 50)
		burn_obj.fire_act(10000, 1000 * seconds_per_tick)
		if(istype(burn_obj, /obj/structure/closet))
			for(var/burn_content in burn_target)
				burn_stuff(burn_content)
		return TRUE

	if(isliving(burn_target))
		var/mob/living/burn_living = burn_target
		if(!HAS_TRAIT_FROM(burn_living, TRAIT_NO_EXTINGUISH, TURF_TRAIT))
			burn_living.AddElement(/datum/element/perma_fire_overlay)
			ADD_TRAIT(burn_living, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
		burn_living.adjust_fire_stacks(20 * seconds_per_tick)
		burn_living.ignite_mob()
		burn_living.adjustFireLoss(20 * seconds_per_tick)
		return TRUE

	return FALSE

/turf/open/floor/plating/ocean/dark/rock/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/medium

/turf/open/floor/plating/ocean/dark/rock/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy

/area/ocean/generated
	base_lighting_alpha = 0
	//map_generator = /datum/map_generator/ocean_generator
	map_generator = /datum/map_generator/cave_generator/trench
	area_flags = UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED


/area/ocean/generated_above
	map_generator = /datum/map_generator/ocean_generator
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED

/turf/open/floor/plating/ocean/pit
	name = "pit"

	icon = 'goon/icons/turf/outdoors.dmi'
	icon_state = "pit"
	baseturfs = /turf/open/floor/plating/ocean/pit
	catwalk = TRUE

/turf/open/floor/plating/ocean/pit/wall
	icon_state = "pit_wall"

/turf/open/floor/plating/ocean/pit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(is_safe())
		return
	if(arrived.movement_type & FLYING)
		return
	if(isprojectile(arrived))
		return
	var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
	visible_message("[arrived] falls helplessly into \the [src]")
	arrived.forceMove(turf)

/turf/open/floor/plating/ocean/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't drop things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/lattice/lava))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	return LAZYLEN(found_safeties)

/turf/closed/mineral/random/ocean/gets_drilled(mob/user, give_exp)
	SShotspots.disturb_turf(src)
	. = ..()

/turf/closed/mineral/random/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/closed/mineral/random/high_chance/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/closed/mineral/random/low_chance/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/closed/mineral/random/stationside/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/open/floor/plating/ocean/ironsand
	baseturfs = /turf/open/floor/plating/ocean/dark/ironsand
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"
	rand_variants = 15
	rand_chance = 100

/turf/open/floor/plating/ocean/rock
	name = "rock"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	rand_variants = 0

/turf/open/floor/plating/ocean/rock/warm
	ocean_temp = T20C + 30

/turf/open/floor/plating/ocean/rock/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"
	baseturfs = /turf/open/floor/plating/ocean/rock/medium

/turf/open/floor/plating/ocean/rock/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"
	baseturfs = /turf/open/floor/plating/ocean/rock/heavy

GLOBAL_VAR_INIT(lavaland_points_generated, 0)
/turf/closed/mineral/random/regrowth
	turf_transforms = FALSE
	color = "#58606b"

	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE


/turf/closed/mineral/random/regrowth/New(loc, mineral_increase)
	if(isnum(mineral_increase))
		src.mineralChance += mineral_increase
	. = ..()

/turf/closed/mineral/random/regrowth/Destroy(force)
	. = ..()
	var/timer = max(1 MINUTES - round(max(1, GLOB.lavaland_points_generated) / 1000), 5 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(regrow_mineral), get_turf(src)), timer)

/proc/regrow_mineral(turf/location)
	var/mineral_increase = 0
	if(GLOB.lavaland_points_generated > 55000)
		mineral_increase = min(87, (GLOB.lavaland_points_generated - 55000) / 1000)
	var/turf/closed/mineral/random/regrowth/regrowth_turf = location.ChangeTurf(/turf/closed/mineral/random/regrowth, flags = CHANGETURF_INHERIT_AIR)
	regrowth_turf?.mineralChance += mineral_increase

/turf/closed/mineral/random/regrowth/underwater
	turf_type = /turf/open/floor/plating/ocean/dark
	baseturfs = /turf/open/floor/plating/ocean/dark
