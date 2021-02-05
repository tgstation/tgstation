#define MAX_DENT_DECALS 15

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of iron used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	explosion_block = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	baseturfs = /turf/open/floor/plating

	flags_ricochet = RICOCHET_HARD

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS)

	///lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/hardness = 40
	var/slicing_duration = 100  //default time taken to slice the wall
	var/sheet_type = /obj/item/stack/sheet/iron
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder

	var/list/dent_decals


/turf/closed/wall/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.station_turfs += src
	if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS && fixed_underlay) //Set underlays for the diagonal walls.
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, plane = FLOOR_PLANE)
		if(fixed_underlay["space"])
			underlay_appearance.icon = 'icons/turf/space.dmi'
			underlay_appearance.icon_state = SPACE_ICON_STATE
			underlay_appearance.plane = PLANE_SPACE
		else
			underlay_appearance.icon = fixed_underlay["icon"]
			underlay_appearance.icon_state = fixed_underlay["icon_state"]
		fixed_underlay = string_assoc_list(fixed_underlay)
		underlays += underlay_appearance


/turf/closed/wall/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()


/turf/closed/wall/examine(mob/user)
	. += ..()
	. += deconstruction_hints(user)

/turf/closed/wall/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The outer plating is <b>welded</b> firmly in place.</span>"

/turf/closed/wall/attack_tk()
	return

/turf/closed/wall/proc/dismantle_wall(devastated=0, explode=0)
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
			P.roll_and_drop(src)

	ScrapeAway()

/turf/closed/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/closed/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/sheet/iron(src)

/turf/closed/wall/ex_act(severity, target)
	if(target == src)
		dismantle_wall(1,1)
		return
	switch(severity)
		if(1)
			//SN src = null
			var/turf/NT = ScrapeAway()
			NT.contents_explosion(severity, target)
			return
		if(2)
			if (prob(50))
				dismantle_wall(0,1)
			else
				dismantle_wall(1,1)
		if(3)
			if (prob(hardness))
				dismantle_wall(0,1)
	if(!density)
		..()


/turf/closed/wall/blob_act(obj/structure/blob/B)
	if(prob(50))
		dismantle_wall()
	else
		add_dent(WALL_DENT_HIT)

/turf/closed/wall/attack_paw(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	return attack_hand(user)


/turf/closed/wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if((M.environment_smash & ENVIRONMENT_SMASH_WALLS) || (M.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		dismantle_wall(1)
		return

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
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>", \
					"<span class='danger'>You smash \the [src]!</span>", \
					"<span class='hear'>You hear a booming smash!</span>")
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

/turf/closed/wall/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 25, TRUE)
	add_fingerprint(user)

/turf/closed/wall/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	var/turf/T = user.loc	//get user's location for delay checks

	//the istype cascade has been spread among various procs for easy overriding
	if(try_clean(W, user, T) || try_wallmount(W, user, T) || try_decon(W, user, T))
		return

	return ..()

/turf/closed/wall/proc/try_clean(obj/item/W, mob/user, turf/T)
	if((user.a_intent != INTENT_HELP) || !LAZYLEN(dent_decals))
		return FALSE

	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount=0))
			return FALSE

		to_chat(user, "<span class='notice'>You begin fixing dents on the wall...</span>")
		if(W.use_tool(src, user, 0, volume=100))
			if(iswallturf(src) && LAZYLEN(dent_decals))
				to_chat(user, "<span class='notice'>You fix some dents on the wall.</span>")
				cut_overlay(dent_decals)
				dent_decals.Cut()
			return TRUE

	return FALSE

/turf/closed/wall/proc/try_wallmount(obj/item/W, mob/user, turf/T)
	//check for wall mounted frames
	if(istype(W, /obj/item/wallframe))
		var/obj/item/wallframe/F = W
		if(F.try_build(src, user))
			F.attach(src, user)
		return TRUE
	//Poster stuff
	else if(istype(W, /obj/item/poster))
		place_poster(W,user)
		return TRUE

	return FALSE

/turf/closed/wall/proc/try_decon(obj/item/I, mob/user, turf/T)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount=0))
			return FALSE

		to_chat(user, "<span class='notice'>You begin slicing through the outer plating...</span>")
		if(I.use_tool(src, user, slicing_duration, volume=100))
			if(iswallturf(src))
				to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
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

/turf/closed/wall/get_dumping_location(obj/item/storage/source, mob/user)
	return null

/turf/closed/wall/acid_act(acidpwr, acid_volume)
	if(explosion_block >= 2)
		acidpwr = min(acidpwr, 50) //we reduce the power so strong walls never get melted.
	return ..()

/turf/closed/wall/acid_melt()
	dismantle_wall(1)

/turf/closed/wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 40, "cost" = 26)
	return FALSE

/turf/closed/wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct the wall.</span>")
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

/turf/closed/wall/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ChangeTurf(/turf/closed/wall/rust)


#undef MAX_DENT_DECALS
