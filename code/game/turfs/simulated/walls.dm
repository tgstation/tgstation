/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	var/newgirder = null
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			newgirder = new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel( src )
		else
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/plasteel( src )
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/structure/cultgirder(src)
		else
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/effect/decal/remains/human(src)

	else
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			newgirder = new /obj/structure/girder(src)
			if (mineral == "metal")
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
		else
			if (mineral == "metal")
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
				new /obj/item/stack/sheet/metal( src )

	if(newgirder)
		transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
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
			var/proba
			if (istype(src, /turf/simulated/wall/r_wall))
				proba = 15
			else
				proba = 40
			if (prob(proba))
				dismantle_wall(0,1)
		else
	return

/turf/simulated/wall/blob_act()
	if(prob(50))
		dismantle_wall()

/turf/simulated/wall/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>")
		if(prob(5) && M.force > 20)
			dismantle_wall(1)
			M.occupant_message("<span class='warning'>You smash through the wall.</span>")
			visible_message("<span class='warning'>[src.name] smashes through the wall!</span>")
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

/turf/simulated/wall/attack_paw(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	if ((HULK in user.mutations))
		if (prob(hardness))
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			user << "<span class='notice'>You smash through the wall.</span>"
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
			usr << text("<span class='notice'>You punch the wall.</span>")
			return

	return src.attack_hand(user)

/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	if(M.environment_smash >= 2)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash == 3)
				dismantle_wall(1)
				playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
				M << "<span class='notice'>You smash through the wall.</span>"
			else
				M << "<span class='warning'>This wall is far too strong for you to destroy.</span>"
		else
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			M << "<span class='notice'>You smash through the wall.</span>"
			dismantle_wall(1)
			return

/turf/simulated/wall/attack_hand(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	if (HULK in user.mutations)
		if (prob(hardness))
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			usr << text("<span class='notice'>You smash through the wall.</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
			usr << text("<span class='notice'>You punch the wall.</span>")
			return

	user << "<span class='notice'>You push the wall but nothing happens!</span>"
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	..()
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if(is_hot(W))
			thermitemelt(user)

		if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

		return


	var/turf/T = user.loc	//get user's location for delay checks
	var/slicing_duration = 100  //default time taken to slice the wall
	if( mineral == "diamond" )
		slicing_duration = 200   //diamond wall takes twice as much time

	//DECONSTRUCTION
	add_fingerprint(user)

	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			user << "<span class='notice'>You begin slicing through the outer plating.</span>"
			playsound(src, 'sound/items/Welder.ogg', 100, 1)

			if(do_after(user, slicing_duration))
				if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )
					return
				if( user.loc == T && user.get_active_hand() == WT )
					user << "<span class='notice'>You remove the outer plating.</span>"
					dismantle_wall()
		else
			return

	else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

		user << "<span class='notice'>You begin slicing through the outer plating.</span>"
		playsound(src, 'sound/items/Welder.ogg', 100, 1)

		if(do_after(user, slicing_duration*0.6))  // plasma cutter is faster than welding tool
			if( !istype(src, /turf/simulated/wall) || !user || !W || !T )
				return

			if( user.loc == T && user.get_active_hand() == W )
				user << "<span class='notice'>You remove the outer plating.</span>"
				dismantle_wall()
				visible_message("<span class='warning'>The wall was sliced apart by [user]!</span>", "<span class='warning'>You hear metal being sliced apart.</span>")
		return

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))

		user << "<span class='notice'>You begin to drill though the wall.</span>"

		if(do_after(user, slicing_duration*0.6))  // diamond drill is faster than welding tool slicing
			if( !istype(src, /turf/simulated/wall) || !user || !W || !T )
				return

			if( user.loc == T && user.get_active_hand() == W )
				user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
				dismantle_wall()
				visible_message("<span class='warning'>The wall was drilled through by [user]!</span>", "<span class='warning'>You hear the grinding of metal.</span>")
		return

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		user << "<span class='notice'>You stab \the [EB] into the wall and begin to slice it apart.</span>"
		playsound(src, "sparks", 50, 1)

		if(do_after(user, slicing_duration*0.7))  //energy blade slicing is faster than welding tool slicing
			if( !istype(src, /turf/simulated/wall) || !user || !EB || !T )
				return

			if( user.loc == T && user.get_active_hand() == W )
				EB.spark_system.start()
				playsound(src, "sparks", 50, 1)
				playsound(src, 'sound/weapons/blade1.ogg', 50, 1)
				dismantle_wall(1)
				visible_message("<span class='warning'>The wall was sliced apart by [user]!</span>", "<span class='warning'>You hear metal being sliced apart and sparks flying.</span>")
		return

	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/newscaster_frame))
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/alarm_frame))
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	else
		return attack_hand(user)
	return

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(mineral == "diamond")
		return

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