#define LEANING_OFFSET 11

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of iron used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	explosive_resistance = 1
	rust_resistance = RUST_RESISTANCE_BASIC

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 62500 //a little over 5 cm thick , 62500 for 1 m by 2.5 m by 0.25 m iron wall. also indicates the temperature at wich the wall will melt (currently only able to melt with H/E pipes)

	baseturfs = /turf/open/floor/plating

	flags_ricochet = RICOCHET_HARD

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS

	rcd_memory = RCD_MEMORY_WALL
	///bool on whether this wall can be chiselled into
	var/can_engrave = TRUE
	///lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/hardness = 40
	var/slicing_duration = 100  //default time taken to slice the wall
	var/sheet_type = /obj/item/stack/sheet/iron
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder
	/// A turf that will replace this turf when this turf is destroyed
	var/decon_type

	var/list/dent_decals

/turf/closed/wall/mouse_drop_receive(atom/dropping, mob/user, params)
	if(dropping != user)
		return
	if(!iscarbon(dropping) && !iscyborg(dropping))
		return
	var/mob/living/leaner = dropping
	if(INCAPACITATED_IGNORING(leaner, INCAPABLE_RESTRAINTS) || leaner.stat != CONSCIOUS || HAS_TRAIT(leaner, TRAIT_NO_TRANSFORM))
		return
	if(!leaner.density || leaner.pulledby || leaner.buckled || !(leaner.mobility_flags & MOBILITY_STAND))
		return
	if(HAS_TRAIT_FROM(leaner, TRAIT_UNDENSE, LEANING_TRAIT))
		return
	var/turf/checked_turf = get_step(leaner, REVERSE_DIR(leaner.dir))
	if(checked_turf != src)
		return
	leaner.start_leaning(src)

/mob/living/proc/start_leaning(turf/closed/wall/wall)
	var/new_y = base_pixel_y + pixel_y
	var/new_x = base_pixel_x + pixel_x
	switch(dir)
		if(SOUTH)
			new_y += LEANING_OFFSET
		if(NORTH)
			new_y -= LEANING_OFFSET
		if(WEST)
			new_x += LEANING_OFFSET
		if(EAST)
			new_x -= LEANING_OFFSET

	animate(src, 0.2 SECONDS, pixel_x = new_x, pixel_y = new_y)
	add_traits(list(TRAIT_UNDENSE, TRAIT_EXPANDED_FOV), LEANING_TRAIT)
	visible_message(
		span_notice("[src] leans against [wall]."),
		span_notice("You lean against [wall]."),
	)
	RegisterSignals(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_LIVING_DISARM_HIT,
		COMSIG_LIVING_GET_PULLED,
		COMSIG_MOVABLE_TELEPORTING,
		COMSIG_ATOM_DIR_CHANGE,
	), PROC_REF(stop_leaning))
	update_fov()

/mob/living/proc/stop_leaning()
	SIGNAL_HANDLER
	UnregisterSignal(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_LIVING_DISARM_HIT,
		COMSIG_LIVING_GET_PULLED,
		COMSIG_MOVABLE_TELEPORTING,
		COMSIG_ATOM_DIR_CHANGE,
	))
	animate(src, 0.2 SECONDS, pixel_x = base_pixel_x, pixel_y = base_pixel_y)
	remove_traits(list(TRAIT_UNDENSE, TRAIT_EXPANDED_FOV), LEANING_TRAIT)
	update_fov()

/turf/closed/wall/Initialize(mapload)
	. = ..()
	if(!can_engrave)
		ADD_TRAIT(src, TRAIT_NOT_ENGRAVABLE, INNATE_TRAIT)
	if(is_station_level(z))
		GLOB.station_turfs += src
	if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS && fixed_underlay) //Set underlays for the diagonal walls.
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = LOW_FLOOR_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)
		if(fixed_underlay["space"])
			generate_space_underlay(underlay_appearance, src)
		else
			underlay_appearance.icon = fixed_underlay["icon"]
			underlay_appearance.icon_state = fixed_underlay["icon_state"]
		fixed_underlay = string_assoc_list(fixed_underlay)
		underlays += underlay_appearance

/turf/closed/wall/atom_destruction(damage_flag)
	. = ..()
	dismantle_wall(TRUE, FALSE)

/turf/closed/wall/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()


/turf/closed/wall/examine(mob/user)
	. += ..()
	. += deconstruction_hints(user)

/turf/closed/wall/proc/deconstruction_hints(mob/user)
	return span_notice("The outer plating is <b>welded</b> firmly in place.")

/turf/closed/wall/attack_tk()
	return

/turf/closed/wall/proc/dismantle_wall(devastated = FALSE, explode = FALSE)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		var/newgirder = break_wall()
		if(newgirder) //maybe we don't /want/ a girder!
			transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			INVOKE_ASYNC(P, TYPE_PROC_REF(/obj/structure/sign/poster, roll_and_drop), src)
	if(decon_type)
		ChangeTurf(decon_type, flags = CHANGETURF_INHERIT_AIR)
	else
		ScrapeAway()
	QUEUE_SMOOTH_NEIGHBORS(src)

/turf/closed/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		return new girder_type(src)

/turf/closed/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/sheet/iron(src)

/turf/closed/wall/ex_act(severity, target)
	if(target == src)
		dismantle_wall(1,1)
		return TRUE

	switch(severity)
		if(EXPLODE_DEVASTATE)
			//SN src = null
			var/turf/NT = ScrapeAway()
			NT.contents_explosion(severity, target)
			return TRUE
		if(EXPLODE_HEAVY)
			dismantle_wall(prob(50), TRUE)
		if(EXPLODE_LIGHT)
			if (prob(hardness))
				dismantle_wall(0,1)

	if(!density)
		return ..()

	return TRUE


/turf/closed/wall/blob_act(obj/structure/blob/B)
	if(prob(50))
		dismantle_wall()
	else
		add_dent(WALL_DENT_HIT)

/turf/closed/wall/attack_paw(mob/living/user, list/modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	return attack_hand(user, modifiers)

/turf/closed/wall/attack_hulk(mob/living/carbon/user)
	..()
	var/obj/item/bodypart/arm = user.hand_bodyparts[user.active_hand_index]
	if(!arm)
		return
	if(arm.bodypart_disabled)
		return
	if(prob(hardness))
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		hulk_recoil(arm, user)
		dismantle_wall(1)

	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		add_dent(WALL_DENT_HIT)
		user.visible_message(span_danger("[user] smashes \the [src]!"), \
					span_danger("You smash \the [src]!"), \
					span_hear("You hear a booming smash!"))
	return TRUE

/**
 *Deals damage back to the hulk's arm.
 *
 *When a hulk manages to break a wall using their hulk smash, this deals back damage to the arm used.
 *This is in its own proc just to be easily overridden by other wall types. Default allows for three
 *smashed walls per arm. Also, we use CANT_WOUND here because wounds are random. Wounds are applied
 *by hulk code based on arm damage and checked when we call break_an_arm().
 *Arguments:
 **arg1 is the arm to deal damage to.
 **arg2 is the hulk
 */
/turf/closed/wall/proc/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 20)
	arm.receive_damage(brute = damage, blocked = 0, wound_bonus = CANT_WOUND)
	var/datum/mutation/human/hulk/smasher = locate(/datum/mutation/human/hulk) in hulkman.dna.mutations
	if(!smasher || !damage) //sanity check but also snow and wood walls deal no recoil damage, so no arm breaky
		return
	smasher.break_an_arm(arm)

/turf/closed/wall/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_notice("You push the wall but nothing happens!"))
	playsound(src, 'sound/weapons/genhit.ogg', 25, TRUE)
	add_fingerprint(user)

/turf/closed/wall/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	//get the user's location
	if(!isturf(user.loc))
		return //can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	//the istype cascade has been spread among various procs for easy overriding
	if(try_clean(W, user) || try_wallmount(W, user) || try_decon(W, user))
		return

	return ..()

/turf/closed/wall/proc/try_clean(obj/item/W, mob/living/user)
	if((user.combat_mode) || !LAZYLEN(dent_decals))
		return FALSE

	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount=1))
			return FALSE

		to_chat(user, span_notice("You begin fixing dents on the wall..."))
		if(W.use_tool(src, user, 0, volume=100))
			if(iswallturf(src) && LAZYLEN(dent_decals))
				to_chat(user, span_notice("You fix some dents on the wall."))
				cut_overlay(dent_decals)
				dent_decals.Cut()
			return TRUE

	return FALSE

/turf/closed/wall/proc/try_wallmount(obj/item/W, mob/user)
	//check for wall mounted frames
	if(istype(W, /obj/item/wallframe))
		var/obj/item/wallframe/F = W
		if(F.try_build(src, user))
			F.attach(src, user)
			return TRUE
		return FALSE
	//Poster stuff
	else if(istype(W, /obj/item/poster) && Adjacent(user)) //no tk memes.
		return place_poster(W,user)

	return FALSE

/turf/closed/wall/proc/try_decon(obj/item/I, mob/user)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount=round(slicing_duration / 50)))
			return FALSE

		to_chat(user, span_notice("You begin slicing through the outer plating..."))
		if(I.use_tool(src, user, slicing_duration, volume=100))
			if(iswallturf(src))
				to_chat(user, span_notice("You remove the outer plating."))
				dismantle_wall()
			return TRUE

	return FALSE

/turf/closed/wall/singularity_pull(S, current_size)
	..()
	wall_singularity_pull(current_size)

/turf/closed/wall/proc/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/mineral/cult)

/turf/closed/wall/get_dumping_location()
	return null

/turf/closed/wall/acid_melt()
	dismantle_wall(1)

/turf/closed/wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("delay" = 4 SECONDS, "cost" = 26)
		if(RCD_WALLFRAME)
			return list("delay" = 1 SECONDS, "cost" = 8)
	return FALSE

/turf/closed/wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_WALLFRAME)
			var/obj/item/wallframe/wallmount = rcd_data["[RCD_DESIGN_PATH]"]
			var/obj/item/wallframe/new_wallmount = new wallmount(user.drop_location())
			return try_wallmount(new_wallmount, user, src)
		if(RCD_DECONSTRUCT)
			ScrapeAway()
			return TRUE
	return FALSE

/turf/closed/wall/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

/turf/closed/wall/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ScrapeAway()
		return

	return ..()

/turf/closed/wall/metal_foam_base
	girder_type = /obj/structure/foamedmetal

/turf/closed/wall/Bumped(atom/movable/bumped_atom)
	. = ..()
	SEND_SIGNAL(bumped_atom, COMSIG_LIVING_WALL_BUMP, src)

/turf/closed/wall/Exited(atom/movable/gone, direction)
	. = ..()
	SEND_SIGNAL(gone, COMSIG_LIVING_WALL_EXITED, src)

#undef LEANING_OFFSET
