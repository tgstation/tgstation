/mob/living/carbon/alien/humanoid/drone/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/corrosive_acid)
	verbs -= /mob/living/carbon/alien/humanoid/verb/ActivateHuggers	//<-- pointless
	add_to_mob_list(src)
//Drones use the same base as generic humanoids.
//Drone verbs

/mob/living/carbon/alien/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children"
	set category = "Alien"

	if(powerc(500))
		adjustToxLoss(-500)
		src << "\green You begin to evolve!"
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
		var/mob/living/carbon/alien/humanoid/queen/new_xeno = new (loc)
		new_xeno.UI = UI
		mind.transfer_to(new_xeno)
		del(src)
	return