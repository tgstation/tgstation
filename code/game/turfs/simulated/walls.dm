/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	opacity = 1
	density = 1
	blocks_air = 1
	explosion_block = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/slicing_duration = 100  //default time taken to slice the wall
	var/sheet_type = /obj/item/stack/sheet/metal
	var/obj/item/stack/sheet/builtin_sheet = null

/turf/simulated/wall/New()
	..()
	builtin_sheet = new sheet_type

/turf/simulated/wall/attack_tk()
	return

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		var/newgirder = break_wall()
		transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src

	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/proc/break_wall()
		builtin_sheet.amount = 2
		builtin_sheet.loc = src
		return (new /obj/structure/girder(src))

/turf/simulated/wall/proc/devastate_wall()
		builtin_sheet.amount = 2
		builtin_sheet.loc = src
		new /obj/item/stack/sheet/metal(src)

/turf/simulated/wall/ex_act(severity, target)
	if(target == src)
		dismantle_wall(1,1)
		return
	switch(severity)
		if(1.0)
			//SN src = null
			src.ChangeTurf(/turf/space)
			return
		if(2.0)
			if (prob(50))
				dismantle_wall(0,1)
			else
				dismantle_wall(1,1)
		if(3.0)
			if (prob(hardness))
				dismantle_wall(0,1)
			else
	if(!density)
		..()
	return

/turf/simulated/wall/blob_act()
	if(prob(50))
		dismantle_wall()

/turf/simulated/wall/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		visible_message("<span class='danger'>[M.name] has hit [src]!</span>")
		if(prob(5) && M.force > 20)
			dismantle_wall(1)
			visible_message("<span class='warning'>[src.name] smashes through the wall!</span>")
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

/turf/simulated/wall/attack_paw(mob/living/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	return src.attack_hand(user)


/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.environment_smash >= 2)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		M << "<span class='notice'>You smash through the wall.</span>"
		dismantle_wall(1)
		return

/turf/simulated/wall/attack_hulk(mob/user)
	..(user, 1)
	if(prob(hardness))
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		user << text("<span class='notice'>You smash through the wall.</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		dismantle_wall(1)

	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		user << text("<span class='notice'>You punch the wall.</span>")
	return 1

/turf/simulated/wall/attack_hand(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	user << "<span class='notice'>You push the wall but nothing happens!</span>"
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	..()
	return


/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if(is_hot(W))
			thermitemelt(user)
		return

	var/turf/T = user.loc	//get user's location for delay checks

	//the istype cascade has been spread among various procs for easy overriding
	if(try_wallmount(W,user,T) || try_decon(W,user,T) || try_destroy(W,user,T))
		return

	return


/turf/simulated/wall/proc/try_wallmount(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	//check for wall mounted frames
	if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)
		return 1
	else if(istype(W,/obj/item/newscaster_frame))
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return 1
	else if(istype(W,/obj/item/alarm_frame))
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)
		return 1
	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return 1
	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return 1
	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return 1

	return 0


/turf/simulated/wall/proc/try_decon(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			user << "<span class='notice'>You begin slicing through the outer plating...</span>"
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, slicing_duration))
				if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )
					return 1
				if( user.loc == T && user.get_active_hand() == WT )
					user << "<span class='notice'>You remove the outer plating.</span>"
					dismantle_wall()
					return 1
	else if( istype(W, /obj/item/weapon/gun/energy/plasmacutter) )
		user << "<span class='notice'>You begin slicing through the outer plating...</span>"
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, slicing_duration*0.6))  // plasma cutter is faster than welding tool
			if( !istype(src, /turf/simulated/wall) || !user || !W || !T )
				return 1
			if( user.loc == T && user.get_active_hand() == W )
				user << "<span class='notice'>You remove the outer plating.</span>"
				dismantle_wall()
				visible_message("The wall was sliced apart by [user]!", "<span class='italics'>You hear metal being sliced apart.</span>")
				return 1
	return 0


/turf/simulated/wall/proc/try_destroy(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		if(!D.bcell.use(400))
			user << "<span class='warning'>Your [D.name] doesn't have enough power to break through the [name]!</span>"
			return
		D.update_icon()
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )
			return 1
		if( user.loc == T && user.get_active_hand() == W )
			D.playDigSound()
			dismantle_wall()
			visible_message("<span class='warning'>[user] smashes through the [name] with the [W.name]!</span>", "<span class='italics'>You hear the grinding of metal.</span>")
			return 1
	return 0


/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	overlays = list()
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.opacity = 1
	O.density = 1
	O.layer = 5

	playsound(src, 'sound/items/Welder.ogg', 100, 1)

	if(thermite >= 50)
		var/turf/simulated/floor/F = ChangeTurf(/turf/simulated/floor/plating)
		F.burn_tile()
		F.icon_state = "wall_thermite"
		F.add_hiddenprint(user)
		spawn(max(100,300-thermite))
			if(O)	qdel(O)
	else
		thermite = 0
		spawn(50)
			if(O)	qdel(O)
	return

/turf/simulated/wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/wall/cult)