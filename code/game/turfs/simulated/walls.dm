/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	explosion_block = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/slicing_duration = 100  //default time taken to slice the wall
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder

	canSmoothWith = list(
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork)
	smooth = SMOOTH_TRUE

/turf/closed/wall/attack_tk()
	return

/turf/closed/wall/handle_ricochet(obj/item/projectile/P)			//A huge pile of shitcode!
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = get_angle_of_incidence(face_angle, P.Angle)
	var/new_angle = face_angle + incidence_s
	var/new_angle_s = new_angle
	while(new_angle_s > 180)	// Translate to regular projectile degrees
		new_angle_s -= 360
	while(new_angle_s < -180)
		new_angle_s += 360
	P.Angle = new_angle_s
	return TRUE

/turf/closed/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we don't /want/ a girder!
			transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	ChangeTurf(/turf/open/floor/plating)

/turf/closed/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/closed/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/sheet/metal(src)

/turf/closed/wall/ex_act(severity, target)
	if(target == src)
		dismantle_wall(1,1)
		return
	switch(severity)
		if(1)
			//SN src = null
			var/turf/NT = ChangeTurf(baseturf)
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

/turf/closed/wall/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	switch(M.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			visible_message("<span class='danger'>[M.name] has hit [src]!</span>", null, null, COMBAT_MESSAGE_RANGE)
			if(prob(hardness + M.force) && M.force > 20)
				dismantle_wall(1)
				playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, 1)
		if(TOX)
			playsound(src, 'sound/effects/spray2.ogg', 100, 1)
			return 0

/turf/closed/wall/attack_paw(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	return src.attack_hand(user)


/turf/closed/wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.environment_smash >= 2)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		dismantle_wall(1)
		return

/turf/closed/wall/attack_hulk(mob/user, does_attack_animation = 0)
	..(user, 1)
	if(prob(hardness))
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		dismantle_wall(1)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		to_chat(user, text("<span class='notice'>You punch the wall.</span>"))
	return 1

/turf/closed/wall/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	..()


/turf/closed/wall/attackby(obj/item/weapon/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if(W.is_hot())
			thermitemelt(user)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//the istype cascade has been spread among various procs for easy overriding
	if(try_wallmount(W,user,T) || try_decon(W,user,T) || try_destroy(W,user,T))
		return


/turf/closed/wall/proc/try_wallmount(obj/item/weapon/W, mob/user, turf/T)
	//check for wall mounted frames
	if(istype(W, /obj/item/wallframe))
		var/obj/item/wallframe/F = W
		if(F.try_build(src, user))
			F.attach(src, user)
		return 1
	//Poster stuff
	else if(istype(W, /obj/item/weapon/poster))
		place_poster(W,user)
		return 1

	return 0


/turf/closed/wall/proc/try_decon(obj/item/weapon/W, mob/user, turf/T)
	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			to_chat(user, "<span class='notice'>You begin slicing through the outer plating...</span>")
			playsound(src, W.usesound, 100, 1)
			if(do_after(user, slicing_duration*W.toolspeed, target = src))
				if(!iswallturf(src) || !user || !WT || !WT.isOn() || !T)
					return 1
				if( user.loc == T && user.get_active_held_item() == WT )
					to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
					dismantle_wall()
					return 1
	else if( istype(W, /obj/item/weapon/gun/energy/plasmacutter) )
		to_chat(user, "<span class='notice'>You begin slicing through the outer plating...</span>")
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		if(do_after(user, slicing_duration*W.toolspeed, target = src))
			if(!iswallturf(src) || !user || !W || !T)
				return 1
			if( user.loc == T && user.get_active_held_item() == W )
				to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
				dismantle_wall()
				visible_message("The wall was sliced apart by [user]!", "<span class='italics'>You hear metal being sliced apart.</span>")
				return 1
	return 0


/turf/closed/wall/proc/try_destroy(obj/item/weapon/W, mob/user, turf/T)
	if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		if(!iswallturf(src) || !user || !W || !T)
			return 1
		if( user.loc == T && user.get_active_held_item() == W )
			D.playDigSound()
			dismantle_wall()
			visible_message("<span class='warning'>[user] smashes through the [name] with the [W.name]!</span>", "<span class='italics'>You hear the grinding of metal.</span>")
			return 1
	return 0


/turf/closed/wall/proc/thermitemelt(mob/user)
	cut_overlays()
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = TRUE
	O.opacity = 1
	O.density = TRUE
	O.layer = FLY_LAYER

	playsound(src, 'sound/items/welder.ogg', 100, 1)

	if(thermite >= 50)
		var/burning_time = max(100,300 - thermite)
		var/turf/open/floor/F = ChangeTurf(/turf/open/floor/plating)
		F.burn_tile()
		F.add_hiddenprint(user)
		QDEL_IN(O, burning_time)
	else
		thermite = 0
		QDEL_IN(O, 50)

/turf/closed/wall/singularity_pull(S, current_size)
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

/turf/closed/wall/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/clockwork)

/turf/closed/wall/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/turf/closed/wall/acid_act(acidpwr, acid_volume)
	if(explosion_block >= 2)
		acidpwr = min(acidpwr, 50) //we reduce the power so strong walls never get melted.
	. = ..()

/turf/closed/wall/acid_melt()
	dismantle_wall(1)

/turf/closed/wall/rcd_vals(mob/user, obj/item/weapon/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 40, "cost" = 26)
	return FALSE

/turf/closed/wall/rcd_act(mob/user, obj/item/weapon/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct the wall.</span>")
			ChangeTurf(/turf/open/floor/plating)
			return TRUE
	return FALSE