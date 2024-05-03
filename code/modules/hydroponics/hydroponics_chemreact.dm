/**
 *This is NOW the gradual affects that each chemical applies on every process() proc. Nutrients now use a more robust reagent holder in order to apply less insane
 * stat changes as opposed to 271 lines of individual statline effects. Shoutout to the original comments on chems, I just cleaned a few up.
 */
/obj/machinery/hydroponics/proc/apply_chemicals(mob/user)
	///Contains the reagents within the tray.
	if(myseed)
		myseed.on_chem_reaction(reagents) //In case seeds have some special interactions with special chems, currently only used by vines


/obj/machinery/hydroponics/proc/mutation_roll(mob/user)
	switch(rand(100))
		if(91 to 100)
			adjust_plant_health(-10)
			visible_message(span_warning("\The [myseed.plantname] starts to wilt and burn!"))
			return
		if(81 to 90)
			mutatespecie_new()
			return
		if(66 to 80)
			hardmutate()
			return
		if(41 to 65)
			mutate()
			return
		if(21 to 41)
			visible_message(span_notice("\The [myseed.plantname] appears unusually reactive..."))
			return
		if(11 to 20)
			mutateweed()
			return
		if(0 to 10)
			mutatepest(user)
			return
		else
			to_chat(user, "<span class='notice'>Nothing happens...</span>")
