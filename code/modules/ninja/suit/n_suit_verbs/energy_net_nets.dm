/*
It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
It is possible to destroy the net by the occupant or someone else.
*/

/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = TRUE//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = MOUSE_OPACITY_ICON//So you can hit it with stuff.
	anchored = TRUE//Can't drag/grab the trapped mob.
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 25 //How much health it has.
	var/mob/living/carbon/affecting = null//Who it is currently affecting, if anyone.
	var/mob/living/carbon/master = null//Who shot web. Will let this person know if the net was successful or failed.



/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
		if(BURN)
			playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)

/obj/structure/energy_net/process()
	if(!affecting)
		return
	var/check = 30//30 seconds before teleportation. Could be extended I guess.

	affecting.anchored = TRUE //No moving for you!
	//The person can still try and attack the net when inside.

	while(check>0)//While 30 seconds have not passed.
		check--
		sleep(10)
		if(isnull(src)||isnull(affecting)||affecting.loc!=loc)
			if(affecting)
				affecting.anchored = FALSE
				for(var/mob/O in viewers(3, affecting))
					O.show_message("[affecting.name] was recovered from the energy net!", 1, "<span class='italics'>You hear a grunt.</span>", 2)
			if(master)//As long as they still exist.
				to_chat(master, "<span class='userdanger'>ERROR</span>: unable to initiate transport protocol. Procedure terminated.")
			qdel(src)//Get rid of the net.
			return

	qdel(src)
	if(ishuman(affecting))
		var/mob/living/carbon/human/H = affecting
		for(var/obj/item/W in H)
			if(W == H.w_uniform)
				continue//So all they're left with are shoes and uniform.
			if(W == H.shoes)
				continue
			H.dropItemToGround(W)

	playsound(affecting.loc, 'sound/effects/sparks4.ogg', 50, 1)
	new /obj/effect/temp_visual/dir_setting/ninja/phase/out(get_turf(affecting), affecting.dir)

	visible_message("[affecting] suddenly vanishes!")
	affecting.forceMove(pick(GLOB.holdingfacility)) //Throw mob in to the holding facility.
	to_chat(affecting, "<span class='danger'>You appear in a strange place!</span>")

	if(!isnull(master))//As long as they still exist.
		to_chat(master, "<span class='notice'><b>SUCCESS</b>: transport procedure of \the [affecting] complete.</span>")
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, affecting.loc)
	spark_system.start()
	playsound(affecting.loc, 'sound/effects/phasein.ogg', 25, 1)
	playsound(affecting.loc, 'sound/effects/sparks2.ogg', 50, 1)
	new /obj/effect/temp_visual/dir_setting/ninja/phase(get_turf(affecting), affecting.dir)
	affecting.anchored = FALSE

/obj/structure/energy_net/attack_paw(mob/user)
	return attack_hand()


