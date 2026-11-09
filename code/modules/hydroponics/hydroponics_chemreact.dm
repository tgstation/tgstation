/**
 *This is NOW the gradual affects that each chemical applies on every process() proc. Nutrients now use a more robust reagent holder in order to apply less insane
 * stat changes as opposed to 271 lines of individual statline effects. Shoutout to the original comments on chems, I just cleaned a few up.
 */
/obj/machinery/hydroponics/proc/apply_chemicals(mob/user)
	///Contains the reagents within the tray.
	if(myseed)
		myseed.on_chem_reaction(reagents) //In case seeds have some special interactions with special chems, currently only used by vines
	for(var/datum/reagent/chem as anything in reagents.reagent_list)
		if(chem.volume < 1)
			continue
		chem.on_hydroponics_apply(src, user)

/obj/machinery/hydroponics/expose_reagents(list/reagents, datum/reagents/source, methods = TOUCH, volume_modifier = 1, show_message = TRUE)
	. = ..()
	if(. & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	if(src.reagents.holder_full())
		return

	for(var/datum/reagent/reagent as anything in reagents)
		if(istype(reagent, /datum/reagent/water))
			adjust_waterlevel(round(reagents[reagent]))
		else
			src.reagents.add_reagent(reagent.type, reagents[reagent])
	update_appearance()

/// Called when a radioactive reagent is applied to the tray
/obj/machinery/hydroponics/proc/radioactive_exposure(modifier = 1)
	if(isnull(myseed))
		return

	if(prob(min(75, 25 * modifier)))
		myseed.adjust_instability(round(2 * modifier))
		adjust_toxic(round(1.5 * modifier)) // It is still toxic, mind you
		return

	switch(rand(0, 50))
		if(41 to 50)
			adjust_plant_health(round(-5 * modifier))
			visible_message(span_warning("\The [myseed.plantname] starts to wilt and burn!"))

		if(21 to 40)
			visible_message(span_notice("\The [myseed.plantname] appears unusually reactive..."))

		if(11 to 20)
			if(modifier >= 0.5)
				mutateweed()
			else
				adjust_weedlevel(max(1, round(modifier)))

		if(0 to 10)
			if(modifier >= 0.5)
				mutatepest()
			else
				adjust_pestlevel(max(1, round(modifier)))
