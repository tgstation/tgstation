/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/rotting = 0
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/engraving, engraving_quality //engraving on the wall
	var/del_suppress_resmoothing = 0 // Do not resmooth neighbors on Destroy. (smoothwall.dm)
	canSmoothWith = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall // WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	)

	soot_type = null

/turf/simulated/wall/examine()
	..()
	if(src.engraving) usr << src.engraving

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
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
			new /obj/structure/girder(src)
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

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
	if(rotting) severity = 1.0
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
	if(prob(50) || rotting)
		dismantle_wall()

/turf/simulated/wall/attack_paw(mob/user as mob)
	if ((M_HULK in user.mutations))
		if (prob(hardness))
			usr << text("\blue You smash through the wall.")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	return src.attack_hand(user)

/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	if(M.environment_smash >= 2)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash == 3)
				dismantle_wall(1)
				M << "<span class='info'>You smash through the wall.</span>"
			else
				M << "<span class='info'>This wall is far too strong for you to destroy.</span>"
		else
			M << "<span class='info'>You smash through the wall.</span>"
			dismantle_wall(1)
			return

/turf/simulated/wall/attack_hand(mob/user as mob)
	if (M_HULK in user.mutations)
		if (prob(hardness) || rotting)
			usr << text("\blue You smash through the wall.")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	if(rotting)
		user << "\blue The wall crumbles under your touch."
		dismantle_wall()
		return

	user << "\blue You push the wall but nothing happens!"
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	if(rotting)
		if(istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				user << "<span class='notice'>You burn away the fungi with \the [WT].</span>"
				playsound(src, 'sound/items/Welder.ogg', 10, 1)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					del E
				rotting = 0
				return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			user << "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>"
			src.dismantle_wall(1)

			var/pdiff=performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) broke a rotting wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user)
			return

		else if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			user << "<span class='notice'>You begin slicing through the outer plating.</span>"
			playsound(src, 'sound/items/Welder.ogg', 100, 1)

			sleep(100)
			if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )	return

			if( user.loc == T && user.get_active_hand() == WT )
				user << "<span class='notice'>You remove the outer plating.</span>"
				var/pdiff=performWallPressureCheck(src.loc)
				if(pdiff)
					message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) dismanted a wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
					log_admin("[user.real_name] ([user.ckey]) dismanted a wall with a pdiff of [pdiff] at [loc]!")
				dismantle_wall()
		else
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
			return

	else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

		user << "<span class='notice'>You begin slicing through the outer plating.</span>"
		playsound(src, 'sound/items/Welder.ogg', 100, 1)

		sleep(60)
		if(mineral == "diamond")//Oh look, it's tougher
			sleep(60)
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>You remove the outer plating.</span>"
			dismantle_wall()
			var/pdiff=performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) dismantled with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
				log_admin("[user.real_name] ([user.ckey]) dismantled with a pdiff of [pdiff] at [loc]!")
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was sliced apart by [user]!</span>", 1, "<span class='warning'>You hear metal being sliced apart.</span>", 2)
		return

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))

		user << "<span class='notice'>You begin to drill though the wall.</span>"

		sleep(60)
		if(mineral == "diamond")
			sleep(60)
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
			dismantle_wall()
			var/pdiff=performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) drilled a wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
				log_admin("[user.real_name] ([user.ckey]) drilled a wall with a pdiff of [pdiff] at [loc]!")
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was drilled through by [user]!</span>", 1, "<span class='warning'>You hear the grinding of metal.</span>", 2)
		return

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		user << "<span class='notice'>You stab \the [EB] into the wall and begin to slice it apart.</span>"
		playsound(src, "sparks", 50, 1)

		sleep(70)
		if(mineral == "diamond")
			sleep(70)
		if( !istype(src, /turf/simulated/wall) || !user || !EB || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			EB.spark_system.start()
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)
			dismantle_wall(1)
			var/pdiff=performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) sliced up a wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
				log_admin("[user.real_name] ([user.ckey]) sliced up a wall with a pdiff of [pdiff] at [loc]!")
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was sliced apart by [user]!</span>", 1, "<span class='warning'>You hear metal being sliced apart and sparks flying.</span>", 2)
		return

	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/airlock_controller_frame))
		var/obj/item/airlock_controller_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/access_button_frame))
		var/obj/item/access_button_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/airlock_sensor_frame))
		var/obj/item/airlock_sensor_frame/AH = W
		AH.try_build(src)
		return
	/*
	else if(istype(W,/obj/item/newscaster_frame))
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return
	*/
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

	else if(istype(W,/obj/item/rust_fuel_compressor_frame))
		var/obj/item/rust_fuel_compressor_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/rust_fuel_assembly_port_frame))
		var/obj/item/rust_fuel_assembly_port_frame/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	else
		return attack_hand(user)
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting)
		rotting = 1

		var/number_rots = rand(2,3)
		for(var/i=0, i<number_rots, i++)
			var/obj/effect/overlay/O = new/obj/effect/overlay( src )
			O.name = "Wallrot"
			O.desc = "Ick..."
			O.icon = 'icons/effects/wallrot.dmi'
			O.pixel_x += rand(-10, 10)
			O.pixel_y += rand(-10, 10)
			O.anchored = 1
			O.density = 1
			O.layer = 5
			O.mouse_opacity = 0

/turf/simulated/wall/proc/thermitemelt(var/mob/user)
	if(mineral == "diamond")
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		if(O)
			message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) thermited a wall into space at [formatJumpTo(loc)]!")
			del(O)
			user << "<span class='warning'>The thermite melts through the wall.</span>"
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	user << "<span class='warning'>The thermite melts through the wall.</span>"

	var/pdiff=performWallPressureCheck(src.loc)
	if(pdiff)
		message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) thermited a wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")

	spawn(100)
		if(O)	del(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

// Generic wall melting proc.
/turf/simulated/wall/melt()
	if(mineral == "diamond")
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	if (prob(15) && !rotting)
		dismantle_wall()
	else if(prob(70) && !rotting)
		ChangeTurf(/turf/simulated/floor/plating)
	else
		ReplaceWithLattice()
	return 0

/turf/simulated/wall/Destroy()
	for(var/obj/effect/E in src) if(E.name == "Wallrot") del E
	..()

/turf/simulated/wall/ChangeTurf(var/newtype)
	for(var/obj/effect/E in src) if(E.name == "Wallrot") del E
	..(newtype)