/**
  *This is NOW the gradual affects that each chemical applies on every process() proc. Nutrients now use a more robust reagent holder in order to apply less insane
  * stat changes as opposed to 271 lines of individual statline effects. Shoutout to the original comments on chems, I just cleaned a few up.
  */
/obj/machinery/hydroponics/proc/apply_chemicals(mob/user)
	///Contains the reagents within the tray.
	if(myseed)
		myseed.on_chem_reaction(reagents) //In case seeds have some special interactions with special chems, currently only used by vines
	//FINE WE'LL DO IT THIS WAY.
	for(var/c in reagents.reagent_list)
		var/datum/reagent/chem = c
		chem.on_hydroponics_apply(myseed, reagents, src, user)

/obj/machinery/hydroponics/proc/mutation_roll(mob/user)
	switch(rand(100))
		if(91 to 100)
			adjustHealth(-10)
			visible_message("<span class='warning'>\The [myseed.plantname] starts to wilt and burn!</span>")
			return
		if(41 to 90)
			if(myseed && !self_sustaining) //Stability
				myseed.adjust_instability(5)
				return
		if(21 to 40)
			visible_message("<span class='notice'>\The [myseed.plantname] appears unusually reactive...</span>")
			return
		if(11 to 20)
			mutateweed()
			return
		if(1 to 10)
			mutatepest(user)
			return
