/*
 * LAVA
 * PLASMA LAVA
 * MAFIA PLASMA LAVA
 */

/turf/open/lava
	name = "lava"
	icon_state = "lava"
	desc = "Looks painful to step in. Don't mine down."
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	light_on = FALSE
	bullet_bounce_sound = 'sound/items/tools/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000
	/// mobs with this trait won't burn.
	var/immunity_trait = TRAIT_LAVA_IMMUNE
	/// objects with these flags won't burn.
	var/immunity_resistance_flags = LAVA_PROOF
	/// the temperature that this turf will attempt to heat/cool gasses too in a heat exchanger, in kelvin
	var/lava_temperature = 5000
	/// The icon that covers the lava bits of our turf
	var/mask_icon = 'icons/turf/floors.dmi'
	/// The icon state that covers the lava bits of our turf
	var/mask_state = "lava-lightmask"
	/// The type for the preset fishing spot of this type of turf.
	var/fish_source_type = /datum/fish_source/lavaland
	/// The color we use for our immersion overlay
	var/immerse_overlay_color = "#a15e1b"
	/// Whether the immerse element has been added yet or not
	var/immerse_added = FALSE
	/// Lazy list of atoms that we've checked that can/cannot burn
	var/list/checked_atoms = null

/turf/open/lava/Initialize(mapload)
	. = ..()
	if(fish_source_type)
		add_lazy_fishing(fish_source_type)
	// You can release chrabs and lavaloops and likes in lava, or be an absolute scumbag and drop other fish there too.
	ADD_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)
	refresh_light()
	if(!smoothing_flags)
		update_appearance()
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_inited))

/turf/open/lava/Destroy()
	checked_atoms = null
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	for(var/mob/living/leaving_mob in contents)
		leaving_mob.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(leaving_mob, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
	return ..()

///We lazily add the immerse element when something is spawned or crosses this turf and not before.
/turf/open/lava/proc/on_atom_inited(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(burn_stuff(movable))
		START_PROCESSING(SSobj, src)
	if(immerse_added || is_type_in_typecache(movable, GLOB.immerse_ignored_movable))
		return
	AddElement(/datum/element/immerse, icon, icon_state, "immerse", immerse_overlay_color)
	immerse_added = TRUE

/**
 * turf/Initialize() calls Entered on its contents too, however
 * we need to wait for movables that still need to be initialized
 * before we add the immerse element.
 */
/turf/open/lava/Entered(atom/movable/arrived)
	. = ..()
	if(!immerse_added && !is_type_in_typecache(arrived, GLOB.immerse_ignored_movable))
		AddElement(/datum/element/immerse, icon, icon_state, "immerse", immerse_overlay_color)
		immerse_added = TRUE
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/lava/update_overlays()
	. = ..()
	. += emissive_appearance(mask_icon, mask_state, src)
	// We need a light overlay here because not every lava turf casts light, only the edge ones
	var/mutable_appearance/light = mutable_appearance(mask_icon, mask_state, LIGHTING_PRIMARY_LAYER, src, LIGHTING_PLANE)
	light.color = light_color
	light.blend_mode = BLEND_ADD
	. += light
	// Mask away our light underlay, so things don't double stack
	// This does mean if our light underlay DOESN'T look like the light we emit things will be wrong
	// But that's rare, and I'm ok with that, quartering our light source count is useful
	var/mutable_appearance/light_mask = mutable_appearance(mask_icon, mask_state, LIGHTING_MASK_LAYER, src, LIGHTING_PLANE)
	light_mask.blend_mode = BLEND_MULTIPLY
	light_mask.color = COLOR_MATRIX_INVERT
	. += light_mask

/// Refreshes this lava turf's lighting
/turf/open/lava/proc/refresh_light()
	var/border_turf = FALSE
	var/list/turfs_to_check = RANGE_TURFS(1, src)
	if(GET_LOWEST_STACK_OFFSET(z))
		var/turf/above = GET_TURF_ABOVE(src)
		if(above)
			turfs_to_check += RANGE_TURFS(1, above)
		var/turf/below = GET_TURF_BELOW(src)
		if(below)
			turfs_to_check += RANGE_TURFS(1, below)

	for(var/turf/around as anything in turfs_to_check)
		if(islava(around))
			continue
		border_turf = TRUE

	if(!border_turf)
		set_light(l_on = FALSE)
		return

	set_light(l_on = TRUE)

/turf/open/lava/ChangeTurf(path, list/new_baseturfs, flags)
	var/turf/result = ..()

	if(result && !islava(result))
		// We have gone from a lava turf to a non lava turf, time to let them know
		var/list/turfs_to_check = RANGE_TURFS(1, result)
		if(GET_LOWEST_STACK_OFFSET(z))
			var/turf/above = GET_TURF_ABOVE(result)
			if(above)
				turfs_to_check += RANGE_TURFS(1, above)
			var/turf/below = GET_TURF_BELOW(result)
			if(below)
				turfs_to_check += RANGE_TURFS(1, below)
		for(var/turf/open/lava/inform in turfs_to_check)
			inform.set_light(l_on = TRUE)

	return result

/turf/open/lava/smooth_icon()
	. = ..()
	mask_state = icon_state
	update_appearance(~UPDATE_SMOOTHING)

/turf/open/lava/ex_act(severity, target)
	if(fish_source)
		GLOB.preset_fish_sources[fish_source].spawn_reward_from_explosion(src, severity)
	return FALSE

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/lava/acid_act(acidpwr, acid_volume)
	return FALSE

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone) && !islava(gone.loc))
		gone.RemoveElement(/datum/element/perma_fire_overlay)
		REMOVE_TRAIT(gone, TRAIT_NO_EXTINGUISH, TURF_TRAIT)

/turf/open/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process(seconds_per_tick)
	if(!burn_stuff(null, seconds_per_tick))
		checked_atoms = null
		return PROCESS_KILL

/turf/open/lava/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_TURF && the_rcd.rcd_design_path == /turf/open/floor/plating/rcd)
		return list("delay" = 0, "cost" = 3)
	return FALSE

/turf/open/lava/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_TURF && rcd_data["[RCD_DESIGN_PATH]"] == /turf/open/floor/plating/rcd)
		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/lava/singularity_act()
	return

/turf/open/lava/singularity_pull(atom/singularity, current_size)
	return

/turf/open/lava/GetHeatCapacity()
	. = 700000

/turf/open/lava/GetTemperature()
	. = lava_temperature

/turf/open/lava/TakeTemperature(temp)

/turf/open/lava/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/rods/lava))
		var/obj/item/stack/rods/lava/R = C
		var/obj/structure/lattice/lava/H = locate(/obj/structure/lattice/lava, src)
		if(H)
			to_chat(user, span_warning("There is already a lattice here!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/items/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/lava(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one rod to build a heatproof lattice."))
		return
	// Light a cigarette in the lava
	if(istype(C, /obj/item/cigarette))
		var/obj/item/cigarette/ciggie = C
		if(ciggie.lit)
			to_chat(user, span_warning("\The [ciggie] is already lit!"))
			return TRUE
		var/clumsy_modifier = HAS_TRAIT(user, TRAIT_CLUMSY) ? 2 : 1
		if(prob(25 * clumsy_modifier) && isliving(user))
			ciggie.light(span_warning("[user] expertly dips \the [ciggie.name] into [src], along with the rest of [user.p_their()] arm. What a dumbass."))
			var/mob/living/burned_guy = user
			burned_guy.apply_damage(90, BURN, user.get_active_hand())
		else
			ciggie.light(span_rose("[user] expertly dips \the [ciggie.name] into [src], lighting it with the scorching heat of the planet. Witnessing such a feat is almost enough to make you cry."))
		return TRUE

/turf/open/lava/proc/is_safe()
	return HAS_TRAIT(src, TRAIT_LAVA_STOPPED)

///Generic return value of the can_burn_stuff() proc. Does nothing.
#define LAVA_BE_IGNORING 0
/// Another. Won't burn the target but will make the turf start processing.
#define LAVA_BE_PROCESSING 1
/// Burns the target and makes the turf process (depending on the return value of do_burn()).
#define LAVA_BE_BURNING 2

///Proc that sets on fire something or everything on the turf that's not immune to lava. Returns TRUE to make the turf start processing.
/turf/open/lava/proc/burn_stuff(atom/movable/to_burn, seconds_per_tick = 1)
	if(is_safe())
		return FALSE

	LAZYSETLEN(checked_atoms, 0)
	var/thing_to_check = src
	if (to_burn)
		thing_to_check = list(to_burn)
	for(var/atom/movable/burn_target as anything in thing_to_check)
		switch(cache_burn_check(burn_target))
			if(LAVA_BE_IGNORING)
				continue
			if(LAVA_BE_BURNING)
				if(!do_burn(burn_target, seconds_per_tick))
					continue
		. = TRUE

/// Wrapper for can_burn_stuff that checks if something can be burnt and caches the result
/turf/open/lava/proc/cache_burn_check(atom/movable/burn_target)
	var/check_result = checked_atoms[burn_target.weak_reference]
	if(isnull(check_result))
		check_result = can_burn_stuff(burn_target)
		checked_atoms[WEAKREF(burn_target)] = check_result
	return check_result

/turf/open/lava/proc/can_burn_stuff(atom/movable/burn_target)
	if(QDELETED(burn_target))
		return LAVA_BE_IGNORING
	if((burn_target.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || burn_target.throwing || !burn_target.has_gravity()) //you're flying over it.
		return LAVA_BE_IGNORING
	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if(HAS_TRAIT(src, TRAIT_ELEVATED_TURF) && !HAS_TRAIT(burn_obj, TRAIT_ELEVATING_OBJECT))
			return LAVA_BE_PROCESSING
		if((burn_obj.resistance_flags & immunity_resistance_flags))
			return LAVA_BE_PROCESSING
		return LAVA_BE_BURNING

	if (!isliving(burn_target))
		return LAVA_BE_IGNORING

	if(HAS_TRAIT(burn_target, immunity_trait))
		return LAVA_BE_PROCESSING

	if(HAS_TRAIT(burn_target, TRAIT_MOB_ELEVATED))
		return LAVA_BE_PROCESSING

	var/mob/living/burn_living = burn_target
	var/atom/movable/burn_buckled = burn_living.buckled
	if(burn_buckled && cache_burn_check(burn_buckled) != LAVA_BE_BURNING)
		return LAVA_BE_PROCESSING

	if(iscarbon(burn_living))
		var/mob/living/carbon/burn_carbon = burn_living
		var/obj/item/clothing/burn_suit = burn_carbon.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		var/obj/item/clothing/burn_helmet = burn_carbon.get_item_by_slot(ITEM_SLOT_HEAD)
		if(burn_suit?.clothing_flags & LAVAPROTECT && burn_helmet?.clothing_flags & LAVAPROTECT)
			return LAVA_BE_PROCESSING

	return LAVA_BE_BURNING

#undef LAVA_BE_IGNORING
#undef LAVA_BE_PROCESSING
#undef LAVA_BE_BURNING

/turf/open/lava/proc/do_burn(atom/movable/burn_target, seconds_per_tick = 1)
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
		burn_obj.fire_act(temperature_damage, 1000 * seconds_per_tick)
		if(istype(burn_obj, /obj/structure/closet))
			for(var/burn_content in burn_target)
				burn_stuff(burn_content)
		return TRUE

	if(isliving(burn_target))
		var/mob/living/burn_living = burn_target
		if(!HAS_TRAIT_FROM(burn_living, TRAIT_NO_EXTINGUISH, TURF_TRAIT))
			burn_living.AddElement(/datum/element/perma_fire_overlay)
			ADD_TRAIT(burn_living, TRAIT_NO_EXTINGUISH, TURF_TRAIT)
		burn_living.adjust_fire_stacks(lava_firestacks * seconds_per_tick)
		burn_living.ignite_mob()
		burn_living.adjustFireLoss(lava_damage * seconds_per_tick)
		return TRUE

	return FALSE

/turf/open/lava/can_cross_safely(atom/movable/crossing)
	return HAS_TRAIT(src, TRAIT_LAVA_STOPPED) || HAS_TRAIT(crossing, immunity_trait ) || HAS_TRAIT(crossing, TRAIT_MOVE_FLYING)

/turf/open/lava/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/lava/smooth
	name = "lava"
	baseturfs = /turf/open/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	mask_icon = 'icons/turf/floors/lava_mask.dmi'
	icon_state = "lava-255"
	mask_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_LAVA
	canSmoothWith = SMOOTH_GROUP_FLOOR_LAVA
	underfloor_accessibility = 2 //This avoids strangeness when routing pipes / wires along catwalks over lava
	immerse_overlay_color = "#F98511"

/// Smooth lava needs to take after basalt in order to blend better. If you make a /turf/open/lava/smooth subtype for an area NOT surrounded by basalt; you should override this proc.
/turf/open/lava/smooth/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = /turf/open/misc/asteroid/basalt::icon
	underlay_appearance.icon_state = /turf/open/misc/asteroid/basalt::icon_state
	return TRUE

/turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/lava/smooth/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/lava/plasma
	name = "liquid plasma"
	desc = "A flowing stream of chilled liquid plasma. You probably shouldn't get in."
	icon_state = "liquidplasma"
	initial_gas_mix = BURNING_COLD
	baseturfs = /turf/open/lava/plasma
	fish_source_type = /datum/fish_source/lavaland/icemoon

	light_range = 3
	light_power = 0.75
	light_color = LIGHT_COLOR_PURPLE
	immunity_trait = TRAIT_SNOWSTORM_IMMUNE
	immunity_resistance_flags = FREEZE_PROOF
	lava_temperature = 100
	immerse_overlay_color = "#CD4C9F"

/turf/open/lava/plasma/examine(mob/user)
	. = ..()
	. += span_info("Some <b>liquid plasma<b> could probably be scooped up with a <b>container</b>.")

/turf/open/lava/plasma/attackby(obj/item/I, mob/user, params)
	if(!I.is_open_container())
		return ..()
	if(!I.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(5, 10)))
		to_chat(user, span_warning("[I] is full."))
		return
	user.visible_message(span_notice("[user] scoops some plasma from the [src] with [I]."), span_notice("You scoop out some plasma from the [src] using [I]."))

/turf/open/lava/plasma/do_burn(atom/movable/burn_target, seconds_per_tick = 1)
	. = TRUE
	if(!isliving(burn_target))
		return FALSE

	var/mob/living/burn_living = burn_target
	var/need_mob_update
	// This is from plasma, so it should obey plasma biotype requirements
	need_mob_update += burn_living.adjustToxLoss(15, updating_health = FALSE, required_biotype = MOB_ORGANIC)
	need_mob_update += burn_living.adjustFireLoss(25, updating_health = FALSE)
	if(need_mob_update)
		burn_living.updatehealth()

	if(QDELETED(burn_living) \
		|| !ishuman(burn_living) \
		|| HAS_TRAIT(burn_living, TRAIT_NODISMEMBER) \
		|| HAS_TRAIT(burn_living, TRAIT_NO_PLASMA_TRANSFORM) \
		|| SPT_PROB(65, seconds_per_tick) \
	)
		return

	var/mob/living/carbon/human/burn_human = burn_living

	var/list/immune_parts = list() // Parts we can't transform because they're not organic or can't be dismembered
	var/list/transform_parts = list() // Parts we want to transform

	for(var/obj/item/bodypart/burn_limb as anything in burn_human.bodyparts)
		if(!IS_ORGANIC_LIMB(burn_limb) || !burn_limb.can_dismember())
			immune_parts += burn_limb
			continue
		if(burn_limb.limb_id == SPECIES_PLASMAMAN)
			continue
		transform_parts += burn_limb

	if(length(transform_parts))
		var/obj/item/bodypart/burn_limb = pick_n_take(transform_parts)
		burn_human.emote("scream")
		var/obj/item/bodypart/plasmalimb
		switch(burn_limb.body_zone) //get plasmaman limb to swap in
			if(BODY_ZONE_L_ARM)
				plasmalimb = new /obj/item/bodypart/arm/left/plasmaman
			if(BODY_ZONE_R_ARM)
				plasmalimb = new /obj/item/bodypart/arm/right/plasmaman
			if(BODY_ZONE_L_LEG)
				plasmalimb = new /obj/item/bodypart/leg/left/plasmaman
			if(BODY_ZONE_R_LEG)
				plasmalimb = new /obj/item/bodypart/leg/right/plasmaman
			if(BODY_ZONE_CHEST)
				plasmalimb = new /obj/item/bodypart/chest/plasmaman
			if(BODY_ZONE_HEAD)
				plasmalimb = new /obj/item/bodypart/head/plasmaman

		burn_human.del_and_replace_bodypart(plasmalimb, special = TRUE)
		burn_human.update_body_parts()
		burn_human.emote("scream")
		burn_human.visible_message(span_warning("[burn_human]'s [burn_limb.plaintext_zone] melts down to the bone!"), \
			span_userdanger("You scream out in pain as your [burn_limb.plaintext_zone] melts down to the bone, held together only by strands of purple fungus!"))

	// If all of your limbs are plasma then congrats: you are plasma man
	if(length(immune_parts) || length(transform_parts))
		return
	burn_human.ignite_mob()
	burn_human.set_species(/datum/species/plasmaman)
	burn_human.visible_message(span_warning("[burn_human] bursts into flame as the last of [burn_human.p_their()] body is coated in fungus!"), \
		span_userdanger("Your senses numb as what remains of your flesh sloughs off, revealing the plasma-encrusted bone beneath!"))

//mafia specific tame happy plasma (normal atmos, no slowdown)
/turf/open/lava/plasma/mafia
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/lava/plasma/mafia
	slowdown = 0
	fish_source_type = null

//basketball specific lava (normal atmos, no slowdown)
/turf/open/lava/smooth/basketball
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	slowdown = 0
	fish_source_type = null
