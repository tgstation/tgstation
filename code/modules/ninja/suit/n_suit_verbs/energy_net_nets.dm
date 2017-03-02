/*
It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
It is possible to destroy the net by the occupant or someone else.
*/

/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = 1//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = 1//So you can hit it with stuff.
	anchored = 1//Can't drag/grab the trapped mob.
	layer = ABOVE_ALL_MOB_LAYER
	obj_integrity = 25//How much health it has.
	max_integrity = 25
	var/mob/living/affecting = null//Who it is currently affecting, if anyone.
	var/mob/living/master = null//Who shot web. Will let this person know if the net was successful or failed.



/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
		if(BURN)
			playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)

/obj/structure/energy_net/Destroy()
	if(affecting)
		var/mob/living/carbon/M = affecting
		M.anchored = 0
		for(var/mob/O in viewers(src, 3))
			O.show_message("[M.name] was recovered from the energy net!", 1, "<span class='italics'>You hear a grunt.</span>", 2)
		if(master)//As long as they still exist.
			master << "<span class='userdanger'>ERROR</span>: unable to initiate transport protocol. Procedure terminated."
	return ..()

/obj/structure/energy_net/process(mob/living/carbon/M)
	var/check = 30//30 seconds before teleportation. Could be extended I guess.
	var/mob_name = affecting.name//Since they will report as null if terminated before teleport.
	//The person can still try and attack the net when inside.

	M.notransform = 1 //No moving for you!

	while(!isnull(M)&&!isnull(src)&&check>0)//While M and net exist, and 30 seconds have not passed.
		check--
		sleep(10)

	if(isnull(M)||M.loc!=loc)//If mob is gone or not at the location.
		if(!isnull(master))//As long as they still exist.
			master << "<span class='userdanger'>ERROR</span>: unable to locate \the [mob_name]. Procedure terminated."
		qdel(src)//Get rid of the net.
		M.notransform = 0
		return

	if(!isnull(src))//As long as both net and person exist.
		//No need to check for countdown here since while() broke, it's implicit that it finished.

		density = 0//Make the net pass-through.
		invisibility = INVISIBILITY_ABSTRACT//Make the net invisible so all the animations can play out.
		resistance_flags |= INDESTRUCTIBLE //Make the net invincible so that an explosion/something else won't kill it while, spawn() is running.
		for(var/obj/item/W in M)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(W == H.w_uniform)
					continue//So all they're left with are shoes and uniform.
				if(W == H.shoes)
					continue
			M.dropItemToGround(W)

		playsound(M.loc, 'sound/effects/sparks4.ogg', 50, 1)
		new /obj/effect/overlay/temp/dir_setting/ninja/phase/out(get_turf(M), M.dir)

		visible_message("[M] suddenly vanishes!")
		M.forceMove(pick(holdingfacility)) //Throw mob in to the holding facility.
		M << "<span class='danger'>You appear in a strange place!</span>"

		if(!isnull(master))//As long as they still exist.
			master << "<span class='notice'><b>SUCCESS</b>: transport procedure of \the [affecting] complete.</span>"
		M.notransform = 0
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, M.loc)
		spark_system.start()
		playsound(M.loc, 'sound/effects/phasein.ogg', 25, 1)
		playsound(M.loc, 'sound/effects/sparks2.ogg', 50, 1)
		new /obj/effect/overlay/temp/dir_setting/ninja/phase(get_turf(M), M.dir)
		qdel(src)

	else//And they are free.
		M << "<span class='notice'>You are free of the net!</span>"
		M.notransform = 0
	return



/obj/structure/energy_net/attack_paw(mob/user)
	return attack_hand()


