//ABILITIES=============================

/*X is optional, tells the proc to check for specific stuff. C is also optional.
All the procs here assume that the character is wearing the ninja suit if they are using the procs.
They should, as I have made every effort for that to be the case.
In the case that they are not, I imagine the game will run-time error like crazy.
*/
/mob/proc/ninjacost(var/C as num,var/X as num)
	var/mob/living/carbon/human/U = src
	var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
	if(U.stat||U.incorporeal_move)
		U << "\red You must be conscious and solid to do this."
		return 0
	else if(C&&S.charge<C*10)
		U << "\red Not enough energy."
		return 0
	else if(X==1&&S.active)
		U << "\red You must deactivate the CLOAK-tech device prior to using this ability."
		return 0
	else if(X==2&&S.sbombs<=0)
		U << "\red There are no more smoke bombs remaining."
		return 0
	else if(X==3&&S.aboost<=0)
		U << "\red You do not have any more adrenaline boosters."
		return 0
	else	return 1

//Smoke
//Summons smoke in radius of user.
//Not sure why this would be useful (it's not) but whatever. Ninjas need their smoke bombs.
/mob/proc/ninjasmoke()
	set name = "Smoke Bomb"
	set desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	set category = "Ninja"

	if(ninjacost(,2))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		S.sbombs--
		src << "\blue There are <B>[S.sbombs]</B> smoke bombs remaining."
		var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
		smoke.set_up(10, 0, loc)
		smoke.start()
		playsound(loc, 'bamf.ogg', 50, 2)
	return

//9-10 Tile Teleport
//Click to to teleport 9-10 tiles in direction facing.
/mob/proc/ninjajaunt()
	set name = "Phase Jaunt"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit in direction facing."
	set category = "Ninja"

	var/C = 100
	if(ninjacost(C,1))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/list/turfs = new/list()
		var/turf/picked
		var/turf/mobloc = get_turf(loc)
		var/safety = 0
/*		switch(dir)//This can be done better but really isn't worth it in my opinion.
			if(NORTH)
				//highest Y
				//X the same
				for(var/turf/T in orange(10))
					if(T.density) continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					if((T.y-mobloc.y)<9 || ((T.x+mobloc.x+1)-(mobloc.x*2))>2)	continue
					turfs += T
			if(SOUTH)
				//lowest Y
				//X the same
				for(var/turf/T in orange(10))
					if(T.density) continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					if((mobloc.y-T.y)<9 || ((T.x+mobloc.x+1)-(mobloc.x*2))>2)	continue
					turfs += T
			if(EAST)
				//highest X
				//Y the same
				for(var/turf/T in orange(10))
					if(T.density) continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					if((T.x-mobloc.x)<9 || ((T.y+mobloc.y+1)-(mobloc.y*2))>2)	continue
					turfs += T
			if(WEST)
				//lowest X
				//Y the same
				for(var/turf/T in orange(10))
					if(T.density) continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					if((mobloc.x-T.x)<9 || ((T.y+mobloc.y+1)-(mobloc.y*2))>2)	continue
					turfs += T
			else
				safety = 1*/
		var/locx
		var/locy
		switch(dir)//Gets rectengular range for target.
			if(NORTH)
				locx = mobloc.x
				locy = (mobloc.y+9)
				for(var/turf/T in block(locate(locx-3,locy-1,loc.z), locate(locx+3,locy+1,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			if(SOUTH)
				locx = mobloc.x
				locy = (mobloc.y-9)
				for(var/turf/T in block(locate(locx-3,locy-1,loc.z), locate(locx+3,locy+1,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			if(EAST)
				locy = mobloc.y
				locx = (mobloc.x+9)
				for(var/turf/T in block(locate(locx-1,locy-3,loc.z), locate(locx+1,locy+3,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			if(WEST)
				locy = mobloc.y
				locx = (mobloc.x-9)
				for(var/turf/T in block(locate(locx-1,locy-3,loc.z), locate(locx+1,locy+3,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			else	safety = 1

		if(turfs.len&&!safety)//Cancels the teleportation if no valid turf is found. Usually when teleporting near map edge.
			picked = pick(turfs)
			spawn(0)
				playsound(loc, "sparks", 50, 1)
				anim(mobloc,'mob.dmi',src,"phaseout")

			loc = picked

			spawn(0)
				S.spark_system.start()
				playsound(loc, 'Deconstruct.ogg', 50, 1)
				playsound(loc, "sparks", 50, 1)
				anim(loc,'mob.dmi',src,"phasein")

			spawn(0)//Any living mobs in teleport area are gibbed.
				for(var/mob/living/M in picked)
					if(M==src)	continue
					M.gib()
			S.charge-=(C*10)
		else
			src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
	return

//Right Click Teleport
//Right click to teleport somewhere, almost exactly like admin jump to turf.
/mob/proc/ninjashift(var/turf/T in oview())
	set name = "Phase Shift"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit to a destination in view."
	set category = null//So it does not show up on the panel but can still be right-clicked.

	var/C = 200
	if(ninjacost(C,1))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		if(!T.density)
			var/turf/mobloc = get_turf(loc)
			spawn(0)
				playsound(loc, 'sparks4.ogg', 50, 1)
				anim(mobloc,'mob.dmi',src,"phaseout")

			loc = T

			spawn(0)
				S.spark_system.start()
				playsound(loc, 'Deconstruct.ogg', 50, 1)
				playsound(loc, 'sparks2.ogg', 50, 1)
				anim(loc,'mob.dmi',src,"phasein")

			spawn(0)//Any living mobs in teleport area are gibbed.
				for(var/mob/living/M in T)
					if(M==src)	continue
					M.gib()
			S.charge-=(C*10)
		else
			src << "\red You cannot teleport into solid walls."
	return

//EMP Pulse
//Disables nearby tech equipment.
/mob/proc/ninjapulse()
	set name = "EM Burst"
	set desc = "Disable any nearby technology with a electro-magnetic pulse."
	set category = "Ninja"

	var/C = 250
	if(ninjacost(C,1))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		playsound(loc, 'EMPulse.ogg', 60, 2)
		empulse(src, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		S.charge-=(C*10)
	return

//Summon Energy Blade
//Summons a blade of energy in active hand.
/mob/proc/ninjablade()
	set name = "Energy Blade"
	set desc = "Create a focused beam of energy in your active hand."
	set category = "Ninja"

	var/C = 50
	if(ninjacost(C))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		if(!S.kamikaze)
			if(!get_active_hand()&&!istype(get_inactive_hand(), /obj/item/weapon/blade))
				var/obj/item/weapon/blade/W = new()
				W.spark_system.start()
				playsound(loc, "sparks", 50, 1)
				put_in_hand(W)
				S.charge-=(C*10)
			else
				src << "\red You can only summon one blade. Try dropping an item first."
		else//Else you can run around with TWO energy blades. I don't know why you'd want to but cool factor remains.
			if(!get_active_hand())
				var/obj/item/weapon/blade/W = new()
				put_in_hand(W)
			if(!get_inactive_hand())
				var/obj/item/weapon/blade/W = new()
				put_in_inactive_hand(W)
			S.spark_system.start()
			playsound(loc, "sparks", 50, 1)
	return

//Shoot Ninja Stars
//Shoots ninja stars at random people.
//This could be a lot better but I'm too tired atm.
/mob/proc/ninjastar()
	set name = "Energy Star"
	set desc = "Launches an energy star at a random living target."
	set category = "Ninja"

	var/C = 30
	if(ninjacost(C))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/targets[]//So yo can shoot while yo throw dawg
		targets = new()
		for(var/mob/living/M in oview(7))
			if(M.stat==2)	continue//Doesn't target corpses.
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)//The point here is to pick a random, living mob in oview to shoot stuff at.

			var/turf/curloc = loc
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || !curloc)
				return
			if (targloc == curloc)
				return
			var/obj/bullet/neurodart/A = new /obj/bullet/neurodart(loc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			S.charge-=(C*10)
			A.process()
		else
			src << "\red There are no targets in view."
	return

//Adrenaline Boost
//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.
/mob/proc/ninjaboost()
	set name = "Adrenaline Boost"
	set desc = "Inject a secret chemical that will counteract all movement-impairing effects."
	set category = "Ninja"

	if(ninjacost(,3))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		//Wouldn't need to track adrenaline boosters if there was a miracle injection to get rid of paralysis and the like instantly.
		//For now, adrenaline boosters ARE the miracle injection. Well, radium, really.
		paralysis = 0
		stunned = 0
		weakened = 0
		spawn(30)
			say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"))
		spawn(70)
			S.reagents.reaction(src, 2)
			S.reagents.trans_id_to(src, "radium", S.amount_per_transfer_from_this)
			src << "\red You are beginning to feal the after-effects of the injection."
		S.aboost--
	return

//KAMIKAZE=============================
//Or otherwise known as anime mode. Which also happens to be ridiculously powerful.

//Allows for incorporeal movement.
//Also makes you move like you're on crack.
/mob/proc/ninjawalk()
	set name = "Shadow Walk"
	set desc = "Combines the VOID-shift and CLOAK-tech devices to freely move between solid matter. Toggle on or off."
	set category = "Ninja"

	if(!usr.incorporeal_move)
		incorporeal_move = 1
		density = 0
		src << "\blue You will now phase through solid matter."
	else
		incorporeal_move = 0
		density = 1
		src << "\blue You will no-longer phase through solid matter."
	return

/*
Added click-spam protection of 1 second.
Allows to gib up to five squares in a straight line. Seriously.*/
/mob/proc/ninjaslayer()
	set name = "Phase Slayer"
	set desc = "Utilizes the internal VOID-shift device to mutilate creatures in a straight line."
	set category = "Ninja"

	if(ninjacost())
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/locx
		var/locy
		var/turf/mobloc = get_turf(loc)
		var/safety = 0

		switch(dir)
			if(NORTH)
				locx = mobloc.x
				locy = (mobloc.y+5)
				if(locy>world.maxy)
					safety = 1
			if(SOUTH)
				locx = mobloc.x
				locy = (mobloc.y-5)
				if(locy<1)
					safety = 1
			if(EAST)
				locy = mobloc.y
				locx = (mobloc.x+5)
				if(locx>world.maxx)
					safety = 1
			if(WEST)
				locy = mobloc.y
				locx = (mobloc.x-5)
				if(locx<1)
					safety = 1
			else	safety = 1
		if(!safety)//Cancels the teleportation if no valid turf is found. Usually when teleporting near map edge.
			say("Ai Satsugai!")
			verbs -= /mob/proc/ninjaslayer
			var/turf/picked = locate(locx,locy,mobloc.z)
			spawn(0)
				playsound(loc, "sparks", 50, 1)
				anim(mobloc,'mob.dmi',src,"phaseout")

			spawn(0)
				for(var/turf/T in getline(mobloc, picked))
					spawn(0)
						for(var/mob/living/M in T)
							if(M==src)	continue
							spawn(0)
								M.gib()
					if(T==mobloc||T==picked)	continue
					spawn(0)
						anim(T,'mob.dmi',src,"phasein")

			loc = picked

			spawn(0)
				S.spark_system.start()
				playsound(loc, 'Deconstruct.ogg', 50, 1)
				playsound(loc, "sparks", 50, 1)
				anim(loc,'mob.dmi',src,"phasein")
			spawn(10)
				verbs += /mob/proc/ninjaslayer
		else
			src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
	return

//Appear behind a randomly chosen mob while a few decoy teleports appear.
//This is so anime it hurts. But that's the point.
/mob/proc/ninjamirage()
	set name = "Spider Mirage"
	set desc = "Utilizes the internal VOID-shift device to create decoys and teleport behind a random target."
	set category = "Ninja"

	if(ninjacost())//Simply checks for stat.
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/targets[]
		targets = new()
		for(var/mob/living/M in oview(6))
			if(M.stat==2)	continue//Doesn't target corpses.
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)
			var/locx
			var/locy
			var/turf/mobloc = get_turf(target.loc)
			var/safety = 0
			switch(target.dir)
				if(NORTH)
					locx = mobloc.x
					locy = (mobloc.y-1)
					if(locy<1)
						safety = 1
				if(SOUTH)
					locx = mobloc.x
					locy = (mobloc.y+1)
					if(locy>world.maxy)
						safety = 1
				if(EAST)
					locy = mobloc.y
					locx = (mobloc.x-1)
					if(locx<1)
						safety = 1
				if(WEST)
					locy = mobloc.y
					locx = (mobloc.x+1)
					if(locx>world.maxx)
						safety = 1
				else	safety=1

			if(!safety)
				say("Kumo no Shinkiro!")
				verbs -= /mob/proc/ninjamirage
				var/turf/picked = locate(locx,locy,mobloc.z)
				spawn(0)
					playsound(loc, "sparks", 50, 1)
					anim(mobloc,'mob.dmi',src,"phaseout")

				spawn(0)
					var/limit = 4
					for(var/turf/T in oview(5))
						if(prob(20))
							spawn(0)
								anim(T,'mob.dmi',src,"phasein")
							limit--
						if(limit<=0)	break

				loc = picked
				dir = target.dir

				spawn(0)
					S.spark_system.start()
					playsound(loc, 'Deconstruct.ogg', 50, 1)
					playsound(loc, "sparks", 50, 1)
					anim(loc,'mob.dmi',src,"phasein")

				spawn(10)
					verbs += /mob/proc/ninjamirage
			else
				src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
		else
			src << "\red There are no targets in view."
	return