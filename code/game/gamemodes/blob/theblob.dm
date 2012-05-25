//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//I will need to recode parts of this but I am way too tired atm
/obj/effect/blob
	name = "blob"
	icon = 'blob.dmi'
	icon_state = "blob"
	desc = "Some blob creature thingy"
	density = 1
	opacity = 0
	anchored = 1
	var/active = 1
	var/health = 30
	var/brute_resist = 4
	var/fire_resist = 1
	var/blobtype = "Blob"
	var/blobdebug = 0
		/*Types
	var/Blob
	var/Node
	var/Core
	var/Factory
	var/Shield
		*/


	New(loc, var/h = 30)
		blobs += src
		src.health = h
		src.dir = pick(1,2,4,8)
		src.update()
		..(loc)


	Del()
		blobs -= src
		if((blobtype == "Node") || (blobtype == "Core"))
			processing_objects.Remove(src)
		..()


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if((air_group && blobtype != "Shield") || (height==0))	return 1
		if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
		return 0


	proc/check_mutations()//These could be their own objects I guess
		if(blobtype != "Blob")	return
		//Spaceeeeeeblobbb
		if((istype(src.loc, /turf/space)) || (blobdebug == 4))
			active = 0
			health = min(health*2, 100)
			brute_resist = 1
			fire_resist = 2
			name = "strong blob"
			icon_state = "blob_idle"//needs a new sprite
			blobtype = "Shield"
			return 1
		//Commandblob
		if((blobdebug == 1))
			active = 0
			health = min(health*4, 200)
			brute_resist = 2
			fire_resist = 2
			name = "blob core"
			icon_state = "blob_core"
			blobtype = "Core"
			blob_cores += src
			processing_objects.Add(src)
			return 1
		//Nodeblob
		if((blobdebug == 2))
			active = 0
			health = min(health*3, 150)
			brute_resist = 1
			fire_resist = 2
			name = "blob node"
			icon_state = "blob_node"//needs a new sprite
			blobtype = "Node"
			blob_nodes += src
			processing_objects.Add(src)
			return 1
		if((blobdebug == 3))
			health = min(health*2, 100)
			name = "porous blob"
			icon_state = "blob_factory"//needs a new sprite
			blobtype = "Factory"
			return 1
		return 0


	process()
		spawn(-1)
			Life()
		return


	proc/Pulse(var/pulse = 0, var/origin_dir = 0)//Todo: Fix spaceblob expand
		set background = 1
		if((blobtype != "Node") && (blobtype != "Core"))//This is so bad
			if(special_action())//If we can do something here then we dont need to pulse more
				return
			if(check_mutations())
				return

		if((blobtype == "Blob") && (pulse <= 2) && (prob(30)))
			blobdebug = 4
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
			var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
			if(!B)
				expand(T)//No blob here so try and expand
				return
			B.Pulse((pulse+1),get_dir(src.loc,T))
			return
		return


	proc/special_action()
		set background = 1
		switch(blobtype)
			if("Factory")
				new/obj/effect/critter/blob(src.loc)
				return 1
			if("Core")
				spawn(0)
					Pulse(0,1)
					Pulse(0,2)
					Pulse(0,4)
					Pulse(0,8)
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
		update()
		if(check_mutations())
			return 1
		if(special_action())
			return 1
		return 0

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if(temperature > T0C+200)
			health -= 0.01 * temperature
			update()

	proc/expand(var/turf/T = null)
		if(!prob(health))	return//TODO: Change this to prob(health + o2 mols or such)
		if(!T)
			var/list/dirs = list(1,2,4,8)
			for(var/i = 1 to 4)
				var/dirn = pick(dirs)
				dirs.Remove(dirn)
				T = get_step(src, dirn)
				if((locate(/obj/effect/blob) in T))
					T = null
					continue
				else 	break
		if(T)
			var/obj/effect/blob/B = new /obj/effect/blob(src.loc, min(src.health, 30))
			if(T.Enter(B,src))
				B.loc = T
			else
				T.blob_act()
				del(B)
			for(var/atom/A in T)
				A.blob_act()
		return


	ex_act(severity)
		switch(severity)
			if(1)
				src.health -= rand(40,60)
			if(2)
				src.health -= rand(20,40)
			if(3)
				src.health -= rand(15,20)
		src.update()


	proc/update()//Needs to be updated with the types
		if(health <= 0)
			playsound(src.loc, 'splat.ogg', 50, 1)
			del(src)
			return
		if(blobtype != "Blob")	return
		if(health <= 15)
			icon_state = "blob_damaged"
			return
//		if(health <= 20)
//			icon_state = "blob_damaged2"
//			return


	bullet_act(var/obj/item/projectile/Proj)
		if(!Proj)	return
		src.health -= Proj.damage
		update()
		return 0


	attackby(var/obj/item/weapon/W, var/mob/user)
		playsound(src.loc, 'attackblob.ogg', 50, 1)
		src.visible_message("\red <B>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = 0
		switch(W.damtype)
			if("fire")
				damage = (W.force / max(src.fire_resist,1))
				if(istype(W, /obj/item/weapon/weldingtool))
					playsound(src.loc, 'Welder.ogg', 100, 1)
			if("brute")
				damage = (W.force / max(src.brute_resist,1))

		src.health -= damage
		src.update()
		return


	proc/revert()
		name = "blob"
		icon_state = "blob"
		brute_resist = 4
		fire_resist = 1
		blobtype = "Blob"
		blobdebug = 0
		health = (health/2)
		src.update()
		return 1


//////////////////////////////****IDLE BLOB***/////////////////////////////////////

/obj/effect/blob/idle
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
		var/obj/effect/blob/B = new /obj/effect/blob( src.loc )
		spawn(30)
			B.Life()
		..()



/obj/effect/blob/core/New()
	..()
	spawn()
		src.blobdebug = 1
		src.Life()

/obj/effect/blob/node/New()
	..()
	spawn()
		src.blobdebug = 2
		src.Life()

/obj/effect/blob/factory/New()
	..()
	spawn()
		src.blobdebug = 3
		src.Life()


/obj/effect/blob/proc/create_fragments(var/wave_size = 1)
	var/list/candidates = list()
	for(var/mob/dead/observer/G in world)
		if(G.client && G.client.be_alien)
			if(G.corpse)
				if(G.corpse.stat==2)
					candidates.Add(G)
			else
				candidates.Add(G)

	for(var/i = 0 to wave_size)
		if(!candidates.len)	break
		var/mob/dead/observer/G = pick(candidates)
		var/mob/living/blob/B = new/mob/living/blob(src.loc)
		if(G.client)
			G.client.screen.len = null
			B.ghost_name = G.real_name
			G.client.mob = B
			del(G)
