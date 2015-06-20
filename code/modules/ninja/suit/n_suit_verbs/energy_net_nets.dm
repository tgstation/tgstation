/*
It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
It is possible to destroy the net by the occupant or someone else.
*/

/obj/effect/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = 1//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = 1//So you can hit it with stuff.
	anchored = 1//Can't drag/grab the trapped mob.

	var/health = 25//How much health it has.
	var/mob/living/affecting = null//Who it is currently affecting, if anyone.
	var/mob/living/master = null//Who shot web. Will let this person know if the net was successful or failed.



/obj/effect/energy_net/proc/healthcheck()
	if(health <=0)
		density = 0
		if(affecting)
			var/mob/living/carbon/M = affecting
			M.anchored = 0
			for(var/mob/O in viewers(src, 3))
				O.show_message("[M.name] was recovered from the energy net!", 1, "<span class='italics'>You hear a grunt.</span>", 2)
			if(!isnull(master))//As long as they still exist.
				master << "<span class='userdanger'>ERROR</span>: unable to initiate transport protocol. Procedure terminated."
		qdel(src)
	return



/obj/effect/energy_net/process(var/mob/living/carbon/M as mob)
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
		invisibility = 101//Make the net invisible so all the animations can play out.
		health = INFINITY//Make the net invincible so that an explosion/something else won't kill it while, spawn() is running.
		for(var/obj/item/W in M)
			if(istype(M,/mob/living/carbon/human))
				if(W==M:w_uniform)	continue//So all they're left with are shoes and uniform.
				if(W==M:shoes)	continue
			M.unEquip(W)

		spawn(0)
			playsound(M.loc, 'sound/effects/sparks4.ogg', 50, 1)
			anim(M.loc,M,'icons/mob/mob.dmi',,"phaseout",,M.dir)

		M.loc = pick(holdingfacility)//Throw mob in to the holding facility.
		M << "<span class='danger'>You appear in a strange place!</span>"

		spawn(0)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, M.loc)
			spark_system.start()
			playsound(M.loc, 'sound/effects/phasein.ogg', 25, 1)
			playsound(M.loc, 'sound/effects/sparks2.ogg', 50, 1)
			anim(M.loc,M,'icons/mob/mob.dmi',,"phasein",,M.dir)
			qdel(src)//Wait for everything to finish, delete the net. Else it will stop everything once net is deleted, including the spawn(0).

		for(var/mob/O in viewers(src, 3))
			O.show_message("[M] vanishes!", 1, "<span class='italics'>You hear sparks flying!</span>", 2)

		if(!isnull(master))//As long as they still exist.
			master << "<span class='notice'><b>SUCCESS</b>: transport procedure of \the [affecting] complete.</span>"
		M.notransform = 0

	else//And they are free.
		M << "<span class='notice'>You are free of the net!</span>"
		M.notransform = 0
	return



/obj/effect/energy_net/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	healthcheck()
	..()



/obj/effect/energy_net/ex_act(severity, target)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			health-=prob(50)?50:25
	healthcheck()
	return



/obj/effect/energy_net/blob_act()
	health-=50
	healthcheck()
	return



/obj/effect/energy_net/hitby(AM as mob|obj)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return



/obj/effect/energy_net/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	user.visible_message("<span class='danger'>[user] rips the energy net apart!</span>", \
								"<span class='notice'>You easily destroy the energy net.</span>")
	health-=50
	healthcheck()



/obj/effect/energy_net/attack_paw(mob/user)
	return attack_hand()



/obj/effect/energy_net/attack_alien(mob/living/user as mob)
	user.do_attack_animation(src)
	if (islarva(user))
		return
	playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
	health -= rand(10, 20)
	if(health > 0)
		user.visible_message("<span class='danger'>[user] claws at the energy net!</span>", \
					 "\green You claw at the net.")
	else
		user.visible_message("<span class='danger'>[user] slices the energy net apart!</span>", \
						 "\green You slice the energy net to pieces.")
	healthcheck()
	return



/obj/effect/energy_net/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	var/aforce = W.force
	health = max(0, health - aforce)
	healthcheck()
	..()
	return

