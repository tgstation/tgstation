var/list/gemspawners = list()
var/list/allgems = list()
/datum/controller/subsystem/ticker/PostSetup()
	..()
	//if(gemloopstarted == FALSE)
	//	gemloopstarted = TRUE
	for(var/obj/effect/mob_spawn/human/gem/spawner in world)
		gemspawners.Add(spawner) //grab all spawners.
	spawn(25)
	checkgemloop()

/proc/checkgemloop()
	var/gems = 0
	var/cgamm = 0
	var/fmamm = 0
	for(var/obj/effect/mob_spawn/human/gem/A in world)
		if(A.status != "Rebel")
			gems = gems+1
	for(var/var/mob/living/carbon/human/A in world)
		if(A.key != null && isgem(A)) //don't count ghosted gems
			if(SSmapping.level_trait(A.z,ZTRAIT_STATION) && A.health > 0) //gotta be on the planet.
				if(A.mind.assigned_role == "Crystal Gem")
					cgamm = cgamm+1
				if(A.mind.assigned_role == "Freemason")
					fmamm = fmamm+1
				if(A.mind.assigned_role != "Freemason" && A.mind.assigned_role != "Crystal Gem")
					gems = gems+1
	if(gems == 0)
		//NO GEMS!!!
		var/special = FALSE
		if(cgamm >= 1) //Pink diamond fakes their shattering.
			special = TRUE
			to_chat(world, "<span class='big bold'>Homeworld has failed!</span>")
			to_chat(world, "<span class='boldannounce'>Pink Diamond stages their shattering to save all life on earth!</span>")
			to_chat(world, "<span class='boldannounce'>The Diamonds will be retaliating soon.</span>")
		else if(fmamm >= 1) //Pink diamond is ACTUALLY shattered.
			special = TRUE
			to_chat(world, "<span class='big bold'>Homeworld has failed!</span>")
			to_chat(world, "<span class='boldannounce'>A Freemason Bismuth shatters Pink Diamond using the Breaking Point!</span>")
			to_chat(world, "<span class='boldannounce'>The Diamonds will be retaliating soon.</span>")
		else if(special == FALSE)
			to_chat(world, "<span class='big bold'>Homeworld has failed!</span>")
			to_chat(world, "<span class='boldannounce'>There are no gems alive on Earth.</span>")
			to_chat(world, "<span class='boldannounce'>Your managers have been informed of your incompetence.</span>")
		SSticker.force_ending = 1
	if(SSticker.force_ending != 1)
		spawn(25)
		checkgemloop()


