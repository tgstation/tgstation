/mob/living/carbon/alien/humanoid/drone/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	spawn (1)
		src.verbs += /mob/living/carbon/alien/humanoid/proc/corrode_target
		src.verbs -= /mob/living/carbon/alien/humanoid/verb/call_to
		src.stand_icon = new /icon('alien.dmi', "aliend_s")
		src.lying_icon = new /icon('alien.dmi', "aliend_l")
		src.icon = src.stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"

//Drones use the same base as generic humanoids.
//Drone verbs

/mob/living/carbon/alien/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children"
	set category = "Alien"

	if(src.stat)
		src << "\green You must be conscious to do this."
		return

	if(!src.toxloss)
		src << "\green You don't have any plasma."
		return
	if(src.toxloss >= 500)
		src.toxloss -= 500
		src << "\green You begin to evolve."
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
		var/mob/living/carbon/alien/humanoid/queen/Q = new (src.loc)

		Q.mind = new//Mind initialize stuff.
		Q.mind.current = Q
		Q.mind.assigned_role = "Alien"
		Q.mind.special_role = "Queen"
		Q.mind.key = src.key
		if(src.client)
			src.client.mob = Q
		del(src)
	else
		src << "\green Not enough plasma."

/mob/living/carbon/alien/humanoid/drone/verb/resinwall() // -- TLE
	set name = "Shape Resin Wall (100)"
	set desc = "Produce a wall of resin that blocks entry and line of sight"
	set category = "Alien"

	if(src.stat)
		src << "\green You must be conscious to do this."
		return

	if(!src.toxloss)
		src << "\green You don't have any plasma."
	if(src.toxloss >= 100)
		src.toxloss -= 100
		src << "\green You begin to shape a wall of resin."
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red <B>[src] vomits up a thick purple substance and begins to shape it!</B>"), 1)
		//var/obj/alien/resin/R = new(src.loc)
		new /obj/alien/resin(src.loc)
	else
		src << "\green Not enough plasma."