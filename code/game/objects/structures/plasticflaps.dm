/obj/structure/plasticflaps
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps. Definitely can't get past those. No way."
	gender = PLURAL
	icon = 'icons/obj/structures.dmi'
	icon_state = "plasticflaps"
	armor_type = /datum/armor/structure_plasticflaps
	density = FALSE
	anchored = TRUE
	can_atmos_pass = ATMOS_PASS_NO
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	integrity_failure = 0.75
	// This layer only matters for determining when you click it vs other objects
	layer = BELOW_OPEN_DOOR_LAYER
	/// If TRUE, we can't pass through unless the mob is resting (or fulfills more specific requirements)
	var/require_resting = TRUE
	/// Layer the flaps render on
	var/flaps_layer = ABOVE_MOB_LAYER
	/// Alpha of the flaps
	var/flaps_alpha = 255
	/// Limits how much damage from environmental fire we can take per second
	COOLDOWN_DECLARE(burn_damage_cd)

/datum/armor/structure_plasticflaps
	melee = 100
	bullet = 80
	laser = 80
	energy = 100
	bomb = 50
	fire = 50
	acid = 50

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/kitchen
	name = "cold room plastic flaps"
	desc = "Light and airtight plastic flaps made to keep the cold room cold and the warm room warm."
	armor_type = /datum/armor/structure_plasticflaps/kitchen
	require_resting = FALSE
	flaps_alpha = 150

/datum/armor/structure_plasticflaps/kitchen
	melee = 50
	fire = 20
	acid = 20

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	alpha = 0
	gen_overlay()
	air_update_turf(TRUE, TRUE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(play_plastic_sound),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	var/static/list/adjacent_loc_connections = list(
		COMSIG_TURF_EXPOSE = PROC_REF(check_melt),
	)
	AddComponent(/datum/component/connect_range, tracked = src, connections = adjacent_loc_connections, range = 1, works_in_containers = FALSE)

/obj/structure/plasticflaps/proc/play_plastic_sound(obj/source, atom/movable/exiting)
	SIGNAL_HANDLER
	if(isitem(exiting))
		var/obj/item/item_exiter = exiting
		if(item_exiter.w_class <= WEIGHT_CLASS_NORMAL)
			return
		if(item_exiter.item_flags & ABSTRACT)
			return
	if(isliving(exiting))
		var/mob/living/living_exiter = exiting
		if(living_exiter.mob_size <= MOB_SIZE_TINY)
			return
		// you're crawling under them
		if(living_exiter.body_position == LYING_DOWN)
			return
		if(living_exiter.incorporeal_move)
			return
	if(HAS_TRAIT(exiting, TRAIT_MAGICALLY_PHASED))
		return
	if(locate(/obj/structure/plasticflaps) in exiting.loc)
		return
	playsound(src, 'sound/effects/plasticflaps.ogg', 50, TRUE, ignore_walls = FALSE, falloff_exponent = 8, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/structure/plasticflaps/proc/check_melt(turf/source, datum/gas_mixture/air, temperature)
	SIGNAL_HANDLER
	if(temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return
	if(!COOLDOWN_FINISHED(src, burn_damage_cd))
		return

	COOLDOWN_START(src, burn_damage_cd, 1 SECONDS)

	var/percent_damage_taken = clamp(0.2 * (temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 2.5)), 0.05, 0.25)
	take_damage(max_integrity * percent_damage_taken, BURN, FIRE, sound_effect = FALSE)

/obj/structure/plasticflaps/atom_break(damage_flag)
	if(damage_flag == FIRE)
		visible_message(span_warning("[src] start\s to melt from the heat!"))
	return ..()

/obj/structure/plasticflaps/atom_destruction(damage_flag)
	if(damage_flag == FIRE)
		visible_message(span_warning("[src] melt\s away into plastic goo!"))
	return ..()

/obj/structure/plasticflaps/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(!same_z_layer)
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		gen_overlay()
	return ..()

/obj/structure/plasticflaps/setDir(newdir)
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	gen_overlay()

/obj/structure/plasticflaps/proc/gen_overlay()
	var/turf/our_turf = get_turf(src)
	//you see mobs under it, but you hit them like they are above it
	SSvis_overlays.add_vis_overlay(src, icon, icon_state,
		layer = flaps_layer,
		plane = MUTATE_PLANE(GAME_PLANE, our_turf),
		dir = dir,
		alpha = flaps_alpha,
		add_appearance_flags = RESET_ALPHA,
	)

/obj/structure/plasticflaps/vv_edit_var(var_name, var_val)
	. = ..()
	var/list/relevant_vars = list(
		NAMEOF(src, flaps_layer),
		NAMEOF(src, flaps_alpha),
		NAMEOF(src, dir),
		NAMEOF(src, icon),
		NAMEOF(src, icon_state),
	)
	if(var_name in relevant_vars)
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		gen_overlay()

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("[src] are <b>screwed</b> to the floor.")
	else
		. += span_notice("[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>cut</b> apart.")

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	add_fingerprint(user)
	var/action = anchored ? "unscrews [src] from" : "screws [src] to"
	var/uraction = anchored ? "unscrew [src] from" : "screw [src] to"
	user.visible_message(span_warning("[user] [action] the floor."), span_notice("You start to [uraction] the floor..."), span_hear("You hear rustling noises."))
	if(!W.use_tool(src, user, 100, volume=100, extra_checks = CALLBACK(src, PROC_REF(check_anchored_state), anchored)))
		return TRUE
	set_anchored(!anchored)
	update_atmos_behaviour()
	air_update_turf(TRUE)
	to_chat(user, span_notice("You [uraction] the floor."))
	return TRUE

///Update the flaps behaviour to gases, if not anchored will let air pass through
/obj/structure/plasticflaps/proc/update_atmos_behaviour()
	can_atmos_pass = anchored ? ATMOS_PASS_NO : ATMOS_PASS_YES

/obj/structure/plasticflaps/wirecutter_act(mob/living/user, obj/item/W)
	. = ..()
	if(!anchored)
		user.visible_message(span_warning("[user] cuts apart [src]."), span_notice("You start to cut apart [src]."), span_hear("You hear cutting."))
		if(W.use_tool(src, user, 50, volume=100))
			if(anchored)
				return TRUE
			to_chat(user, span_notice("You cut apart [src]."))
			var/obj/item/stack/sheet/plastic/five/P = new(loc)
			if (!QDELETED(P))
				P.add_fingerprint(user)
			qdel(src)
		return TRUE

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	if(anchored != check_anchored)
		return FALSE
	return TRUE

/obj/structure/plasticflaps/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!require_resting)
		return TRUE
	if(pass_info.is_living)
		if(pass_info.is_bot)
			return TRUE
		if(pass_info.can_ventcrawl && pass_info.mob_size != MOB_SIZE_TINY)
			return FALSE
	if(pass_info.pass_flags & PASSFLAPS)
		return TRUE
	if(pass_info.pulling_info)
		return CanAStarPass(to_dir, pass_info.pulling_info)
	return TRUE //diseases, stings, etc can pass


/obj/structure/plasticflaps/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover.pass_flags & PASSFLAPS) //For anything specifically engineered to cross plastic flaps.
		return TRUE
	if((mover.pass_flags & PASSGLASS) && prob(60))
		return TRUE
	if(!require_resting)
		return TRUE

	if(istype(mover, /obj/structure/bed))
		var/obj/structure/bed/bed_mover = mover
		if(bed_mover.density || bed_mover.has_buckled_mobs())//if it's a bed/chair and is dense or someone is buckled, it will not pass
			return FALSE

	else if(istype(mover, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/cardboard_mover = mover
		if(cardboard_mover.move_delay)
			return FALSE

	else if(ismecha(mover))
		return FALSE

	else if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/living_mover = mover
		if(istype(living_mover.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE

		if(living_mover.body_position == STANDING_UP && living_mover.mob_size != MOB_SIZE_TINY && !(HAS_TRAIT(living_mover, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(living_mover, TRAIT_VENTCRAWLER_NUDE)))
			return FALSE //If you're not laying down, or a small creature, or a ventcrawler, then no pass.

	return .

/obj/structure/plasticflaps/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/plastic/five(loc)

/obj/structure/plasticflaps/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf(TRUE, FALSE)
