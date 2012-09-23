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

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel( src )
		else
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/plasteel( src )
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/structure/cultgirder(src)
		else
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/effect/decal/remains/human(src)

	else
		if(!devastated)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
			switch(mineral)
				if("metal")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/metal( src )
					new /obj/item/stack/sheet/metal( src )
				if("gold")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/gold( src )
					new /obj/item/stack/sheet/gold( src )
				if("silver")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/silver( src )
					new /obj/item/stack/sheet/silver( src )
				if("diamond")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/diamond( src )
					new /obj/item/stack/sheet/diamond( src )
				if("uranium")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/uranium( src )
					new /obj/item/stack/sheet/uranium( src )
				if("plasma")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/plasma( src )
					new /obj/item/stack/sheet/plasma( src )
				if("clown")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/clown( src )
					new /obj/item/stack/sheet/clown( src )
				if("sandstone")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/sandstone( src )
					new /obj/item/stack/sheet/sandstone( src )
				if("wood")
					new /obj/structure/girder(src)
					new /obj/item/stack/sheet/wood( src )
					new /obj/item/stack/sheet/wood( src )

		else
			switch(mineral)
				if("metal")
					new /obj/item/stack/sheet/metal( src )
					new /obj/item/stack/sheet/metal( src )
					new /obj/item/stack/sheet/metal( src )
				if("gold")
					new /obj/item/stack/sheet/gold( src )
					new /obj/item/stack/sheet/gold( src )
					new /obj/item/stack/sheet/metal( src )
				if("silver")
					new /obj/item/stack/sheet/silver( src )
					new /obj/item/stack/sheet/silver( src )
					new /obj/item/stack/sheet/metal( src )
				if("diamond")
					new /obj/item/stack/sheet/diamond( src )
					new /obj/item/stack/sheet/diamond( src )
					new /obj/item/stack/sheet/metal( src )
				if("uranium")
					new /obj/item/stack/sheet/uranium( src )
					new /obj/item/stack/sheet/uranium( src )
					new /obj/item/stack/sheet/metal( src )
				if("plasma")
					new /obj/item/stack/sheet/plasma( src )
					new /obj/item/stack/sheet/plasma( src )
					new /obj/item/stack/sheet/metal( src )
				if("clown")
					new /obj/item/stack/sheet/clown( src )
					new /obj/item/stack/sheet/clown( src )
					new /obj/item/stack/sheet/metal( src )
				if("sandstone")
					new /obj/item/stack/sheet/sandstone( src )
					new /obj/item/stack/sheet/sandstone( src )
					new /obj/item/stack/sheet/metal( src )
				if("wood")
					new /obj/item/stack/sheet/wood( src )
					new /obj/item/stack/sheet/wood( src )
					new /obj/item/stack/sheet/metal( src )

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/effect/decal/poster))
			var/obj/effect/decal/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src
	ReplaceWithPlating(explode)

/turf/simulated/wall/examine()
	set src in oview(1)

	usr << "It looks like a regular wall."
	return

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			src.ReplaceWithSpace()
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

/turf/simulated/wall/attack_paw(mob/user as mob)
	if ((HULK in user.mutations))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	return src.attack_hand(user)


/turf/simulated/wall/attack_animal(mob/living/simple_animal/M as mob)
	if(M.wall_smash)
		if (istype(src, /turf/simulated/wall/r_wall))
			M << text("\blue This wall is far too strong for you to destroy.")
			return
		else
			if (prob(40))
				M << text("\blue You smash through the wall.")
				dismantle_wall(1)
				return
			else
				M << text("\blue You smash against the wall.")
				return

	M << "\blue You push the wall but nothing happens!"
	return

/turf/simulated/wall/attack_hand(mob/user as mob)
	if ((HULK in user.mutations) || (SUPRSTR in user.augmentations))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	user << "\blue You push the wall but nothing happens!"
	playsound(src.loc, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

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
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			user << "<span class='notice'>You begin slicing through the outer plating.</span>"
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

			sleep(100)
			if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )	return

			if( user.loc == T && user.get_active_hand() == WT )
				user << "<span class='notice'>You remove the outer plating.</span>"
				dismantle_wall()
		else
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
			return

	else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

		user << "<span class='notice'>You begin slicing through the outer plating.</span>"
		playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

		sleep(60)
		if(mineral == "diamond")//Oh look, it's tougher
			sleep(60)
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>You remove the outer plating.</span>"
			dismantle_wall()
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
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was drilled through by [user]!</span>", 1, "<span class='warning'>You hear the grinding of metal.</span>", 2)
		return

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		user << "<span class='notice'>You stab \the [EB] into the wall and begin to slice it apart.</span>"
		playsound(src.loc, "sparks", 50, 1)

		sleep(70)
		if(mineral == "diamond")
			sleep(70)
		if( !istype(src, /turf/simulated/wall) || !user || !EB || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			EB.spark_system.start()
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			dismantle_wall(1)
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was sliced apart by [user]!</span>", 1, "<span class='warning'>You hear metal being sliced apart and sparks flying.</span>", 2)
		return

	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
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
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	var/turf/simulated/floor/F = ReplaceWithPlating()
	F.burn_tile()
	F.icon_state = "wall_thermite"
	user << "<span class='warning'>The thermite melts through the wall.</span>"

	spawn(100)
		if(O)	del(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	if (prob(15))
		dismantle_wall()
	else if(prob(70))
		ReplaceWithPlating()
	else
		ReplaceWithLattice()
	return 0