
/obj/blob
	name = "blob"
	icon = 'blob.dmi'
	icon_state = "blob"
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	var
		active = 1
		health = 30
		brute_resist = 4
		blobtype = "Blob"
		blobdebug = 0
		/*Types
		Blob
		Node
		Factory
		Shield
		*/


	New(loc, var/h = 30)
		blobs += src
		active_blobs += src
		src.health = h
		src.dir = pick(1,2,4,8)
		src.update()
		..(loc)


	Del()
		blobs -= src
		if(active)
			active_blobs -= src
		if(blobtype == "Node")
			processing_objects.Remove(src)
		..()


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if( (air_group && blobtype != "Shield") || (height==0))	return 1
		if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
		return 0


	proc/check_mutations()//These could be their own objects I guess
		if(blobtype != "Blob")	return
		desc = "This really needs a better sprite."
		//Spaceeeeeeblobbb
		if((istype(src.loc, /turf/space)) || (blobdebug == 3))
			active = 0
			health = 60
			brute_resist = 2
			name = "strong blob"
			icon_state = "blob_idle"//needs a new sprite
			blobtype = "Shield"
			active_blobs -= src
			return 1
		//Commandblob
		if((blobdebug == 1))
			active = 0
			health = 100
			name = "solid blob"
			icon_state = "blob_node"//needs a new sprite
			blobtype = "Node"
			active_blobs -= src
			processing_objects.Add(src)
			return 1
		if((blobdebug == 2))
			health += 20
			name = "odd blob"
			icon_state = "blob_factory"//needs a new sprite
			blobtype = "Factory"
			return 1
		return 0


	process()
		spawn(-1)
			Life()
		return


	proc/Pulse(var/pulse = 0, var/origin_dir = 0)
		set background = 1
		if(blobtype != "Node")
			if(special_action())//If we can do something here then we dont need to pulse more
				return
			if(check_mutations())
				return

		if((blobtype == "Blob") && (pulse <= 2))
			blobdebug = 3
			check_mutations()
			return

		if(pulse > 20)	return//Inf loop check
		//Looking for another blob to pulse
		var/list/dirs = list(1,2,4,8)
		dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
		for(var/i = 1 to 4)
			if(!dirs.len)	break
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			var/turf/T = get_step(src, dirn)
			var/obj/blob/B = (locate(/obj/blob) in T)
			if(!B)
				expand(T)//No blob here so try and expand
				return
			B.Pulse((pulse+1),get_dir(src.loc,T))
			return
		return



	proc/special_action()//For things like the
		set background = 1
		switch(blobtype)
			if("Factory")
				new/obj/critter/blob(src.loc)
				return 1
			if("Node")
				spawn(0)
					Pulse(0,0)
				return 1
			if("Blob")
				if(expand())
					return 1
		return 0


	proc/Life()
		if(check_mutations())
			return 1
		if(special_action())
			return 1
		return 0


	proc/expand(var/turf/T = null)
		if(!prob(health))	return
		if(!T)
			var/list/dirs = list(1,2,4,8)
			for(var/i = 1 to 4)
				var/dirn = pick(dirs)
				dirs.Remove(dirn)
				T = get_step(src, dirn)
				if((locate(/obj/blob) in T))	continue
				else 	break
		if(T)
			var/obj/blob/B = new /obj/blob(src.loc, min(src.health, 30))
			if(T.Enter(B,src))
				B.loc = T
			else
				for(var/atom/A in T)//This might be killing the spores, it IS killing the spores
					A.blob_act()
				T.blob_act()
				del(B)
		return


	ex_act(severity)
		switch(severity)
			if(1)
				src.health -= rand(90,150)
			if(2)
				src.health -= rand(60,90)
				src.update()
			if(3)
				src.health -= rand(30,40)
				src.update()


	proc/update()//Needs to be updated with the types
		if(health <= 0)
			playsound(src.loc, 'splat.ogg', 50, 1)
			del(src)
			return
		if(blobtype != "Blob")	return
		if(health <= 10)
			icon_state = "blob_damaged"
			return
//		if(health <= 20)
//			icon_state = "blob_damaged2"
//			return


	bullet_act(var/obj/item/projectile/Proj)
		health -= Proj.damage
		..()
		update()


	attackby(var/obj/item/weapon/W, var/mob/user)
		playsound(src.loc, 'attackblob.ogg', 50, 1)
		src.visible_message("\red <B>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = 0
		switch(W.damtype)
			if("fire")
				damage = (W.force)
				if(istype(W, /obj/item/weapon/weldingtool))
					playsound(src.loc, 'Welder.ogg', 100, 1)
			if("brute")
				damage = (W.force / max(src.brute_resist,1))

		src.health -= damage
		src.update()



/datum/station_state/proc/count()
	for(var/turf/T in world)
		if(T.z != 1)
			continue

		if(istype(T,/turf/simulated/floor))
			if(!(T:burnt))
				src.floor+=2
			else
				src.floor++

		else if(istype(T, /turf/simulated/floor/engine))
			src.floor+=2

		else if(istype(T, /turf/simulated/wall))
			if(T:intact)
				src.wall+=2
			else
				src.wall++

		else if(istype(T, /turf/simulated/wall/r_wall))
			if(T:intact)
				src.r_wall+=2
			else
				src.r_wall++

	for(var/obj/O in world)
		if(O.z != 1)
			continue

		if(istype(O, /obj/window))
			src.window++
		else if(istype(O, /obj/grille))
			if(!O:destroyed)
				src.grille++
		else if(istype(O, /obj/machinery/door))
			src.door++
		else if(istype(O, /obj/machinery))
			src.mach++


/datum/station_state/proc/score(var/datum/station_state/result)
	var/r1a = min( result.floor / max(floor,1), 1.0)
	var/r1b = min(result.r_wall/ max(r_wall,1), 1.0)
	var/r1c = min(result.wall / max(wall,1), 1.0)
	var/r2a = min(result.window / max(window,1), 1.0)
	var/r2b = min(result.door / max(door,1), 1.0)
	var/r2c = min(result.grille / max(grille,1), 1.0)
	var/r3 = min(result.mach / max(mach,1), 1.0)
	//diary << "Blob scores:[r1b] [r1c] / [r2a] [r2b] [r2c] / [r3] [r1a]"
	return (4*(r1b+r1c) + 2*(r2a+r2b+r2c) + r3+r1a)/16.0

//////////////////////////////****IDLE BLOB***/////////////////////////////////////

/obj/blob/idle
	name = "blob"
	desc = "it looks... tasty"
	icon_state = "blobidle0"

	New(loc, var/h = 10)
		src.health = h
		src.dir = pick(1,2,4,8)
		src.update_idle()


	proc/update_idle()			//put in stuff here to make it transform? Maybe when its down to around 5 health?
		if(health<=0)
			del(src)
			return
		if(health<4)
			icon_state = "blobc0"
			return
		if(health<10)
			icon_state = "blobb0"
			return
		icon_state = "blobidle0"


	Del()		//idle blob that spawns a normal blob when killed.
		var/obj/blob/B = new /obj/blob( src.loc )
		spawn(30)
			B.Life()
		..()

/obj/blob/node/New()
	..()
	spawn()
		src.blobdebug = 1
		src.Life()

/obj/blob/factory/New()
	..()
	spawn()
		src.blobdebug = 2
		src.Life()