/datum/disease/revblight
	name = "Unnatural Wasting"
	max_stages = 5
	stage_prob = 5
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	cure_text = "Holy water or extensive rest."
	spread_text = "A burst of unholy energy"
	cures = list(/datum/reagent/water/holywater)
	cure_chance = 30 //higher chance to cure, because revenants are assholes
	agent = "Unholy Forces"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CURABLE
	permeability_mod = 1
	severity = DISEASE_SEVERITY_HARMFUL
	var/stagedamage = 0 //Highest stage reached.
	var/finalstage = 0 //Because we're spawning off the cure in the final stage, we need to check if we've done the final stage's effects.

/datum/disease/revblight/cure()
	if(affected_mob)
		affected_mob.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#1d2953")
		if(affected_mob.dna && affected_mob.dna.species)
			affected_mob.dna.species.handle_mutant_bodyparts(affected_mob)
			affected_mob.dna.species.handle_hair(affected_mob)
		to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
	..()


/datum/disease/revblight/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	if(!finalstage)
		if(affected_mob.body_position == LYING_DOWN && DT_PROB(3 * stage, delta_time))
			cure()
			return FALSE
		if(DT_PROB(1.5 * stage, delta_time))
			to_chat(affected_mob, "<span class='revennotice'>You suddenly feel [pick("sick and tired", "disoriented", "tired and confused", "nauseated", "faint", "dizzy")]...</span>")
			affected_mob.add_confusion(8)
			affected_mob.adjustStaminaLoss(20, FALSE)
			new /obj/effect/temp_visual/revenant(affected_mob.loc)
		if(stagedamage < stage)
			stagedamage++
			affected_mob.adjustToxLoss(1 * stage * delta_time, FALSE) //should, normally, do about 30 toxin damage.
			new /obj/effect/temp_visual/revenant(affected_mob.loc)
		if(DT_PROB(25, delta_time))
			affected_mob.adjustStaminaLoss(stage, FALSE)

	switch(stage)
		if(2)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("pale")
		if(3)
			if(DT_PROB(5, delta_time))
				affected_mob.emote(pick("pale","shiver"))
		if(4)
			if(DT_PROB(7.5, delta_time))
				affected_mob.emote(pick("pale","shiver","cries"))
		if(5)
			if(!finalstage)
				finalstage = TRUE
				to_chat(affected_mob, "<span class='revenbignotice'>You feel like [pick("nothing's worth it anymore", "nobody ever needed your help", "nothing you did mattered", "everything you tried to do was worthless")].</span>")
				affected_mob.adjustStaminaLoss(22.5 * delta_time, FALSE)
				new /obj/effect/temp_visual/revenant(affected_mob.loc)
				if(affected_mob.dna && affected_mob.dna.species)
					affected_mob.dna.species.handle_mutant_bodyparts(affected_mob,"#1d2953")
					affected_mob.dna.species.handle_hair(affected_mob,"#1d2953")
				affected_mob.visible_message("<span class='warning'>[affected_mob] looks terrifyingly gaunt...</span>", "<span class='revennotice'>You suddenly feel like your skin is <i>wrong</i>...</span>")
				affected_mob.add_atom_colour("#1d2953", TEMPORARY_COLOUR_PRIORITY)
				addtimer(CALLBACK(src, .proc/cure), 10 SECONDS)
