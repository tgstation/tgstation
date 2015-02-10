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

	// WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	canSmoothWith = "/turf/simulated/wall=0&/obj/structure/falsewall=0&/obj/structure/falserwall=0"

	soot_type = null

/turf/simulated/wall/examine(mob/user)
	..()
	if(src.engraving) user << src.engraving

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel( src )
		else
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
			M.amount = 2
			new /obj/item/stack/sheet/plasteel( src )
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			var/obj/effect/decal/cleanable/blood/B = getFromPool(/obj/effect/decal/cleanable/blood,src) //new /obj/effect/decal/cleanable/blood(src)
			B.New(src)
			new /obj/structure/cultgirder(src)
		else
			var/obj/effect/decal/cleanable/blood/B = getFromPool(/obj/effect/decal/cleanable/blood,src) //new /obj/effect/decal/cleanable/blood(src)
			B.New(src)
			new /obj/effect/decal/remains/human(src)

	else
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder(src)
			if (mineral == "metal")
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
				M.amount = 2
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
		else
			if (mineral == "metal")
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
				M.amount = 3
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
				var/obj/item/stack/sheet/metal/MM = getFromPool(/obj/item/stack/sheet/metal, src)
				MM.amount = 1

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
	user.delayNextAttack(8)
	if ((M_HULK in user.mutations))
		if (prob(hardness))
			usr << text("<span class='attack'>You smash through the wall.</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			usr << text("<span class='attack'>You punch the wall.</span>")
			return

	return src.attack_hand(user)

/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash >= 2)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash == 3)
				dismantle_wall(1)
				M << "<span class='attack'>You smash through the wall.</span>"
			else
				M << "<span class='info'>This wall is far too strong for you to destroy.</span>"
		else
			M << "<span class='attack'>You smash through the wall.</span>"
			dismantle_wall(1)
			return

/turf/simulated/wall/attack_hand(mob/user as mob)
	user.delayNextAttack(8)
	if (M_HULK in user.mutations)
		if (prob(hardness) || rotting)
			usr << text("<span class='attack'>You smash through the wall.</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			usr << text("<span class='attack'>You punch the wall.</span>")
			return

	if(rotting)
		user << "<span class='notice'>\The wall crumbles under your touch.</span>"
		dismantle_wall()
		return

	user << "<span class='notice'>You push the wall but nothing happens!</span>"
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return ..()

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	if(rotting)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				user << "<span class='notice'>You burn away the fungi with \the [WT].</span>"
				playsound(src, 'sound/items/Welder.ogg', 10, 1)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		if(istype(W,/obj/item/weapon/soap))
			user << "<span class='notice'>You forcefully scrub away the fungi with your [W].</span>"
			for(var/obj/effect/E in src) if(E.name == "Wallrot")
				qdel(E)
			rotting = 0
			return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
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

	else if( istype(W, /obj/item/weapon/pickaxe) )
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS))
			return

		user << "<span class='notice'>You begin [PK.drill_verb] through the outer plating.</span>"
		playsound(src, PK.drill_sound, 100, 1)

		sleep(PK.digspeed * 10)
		if(mineral == "diamond")//Oh look, it's tougher
			sleep(PK.digspeed * 10)
		if( !istype(src, /turf/simulated/wall) || !user || !PK || !T )	return

		if( user.loc == T && user.get_active_hand() == PK )
			user << "<span class='notice'>You remove the outer plating.</span>"
			dismantle_wall()
			var/pdiff=performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) dismantled with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
				log_admin("[user.real_name] ([user.ckey]) dismantled with a pdiff of [pdiff] at [loc]!")
			for(var/mob/O in viewers(user, 5))
				O.show_message("<span class='warning'>The wall was taken apart by [user]!</span>", 1, "<span class='warning'>You hear metal [PK.drill_verb] apart.</span>", 2)
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

	else if(istype(W, /obj/item/mounted)) //if we place it, we don't want to have a silly message
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
		if(O)	qdel(O)
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

/turf/simulated/wall/cultify()
	ChangeTurf(/turf/simulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1)
	return

/turf/simulated/wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()
