/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	if(iscultist(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.adjustToxLoss(-3, 0)
		M.adjustOxyLoss(-3, 0)
		M.adjustBruteLoss(-3, 0)
		M.adjustFireLoss(-3, 0)
		M.adjustCloneLoss(-5, 0)
		M.adjustBrainLoss(-3, 0)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.blood_volume < BLOOD_VOLUME_NORMAL)
				C.blood_volume += 5
	else
		M.adjustBrainLoss(3)
		M.adjustToxLoss(1, 0)
		M.adjustFireLoss(2, 0)
		M.adjustOxyLoss(2, 0)
		M.adjustBruteLoss(2, 0)
	holder.remove_reagent(src.id, 1)
	return FINISHONMOBLIFE(M)

/datum/reagent/shadowling_blindness_smoke
	name = "odd black liquid"
	id = "blindness_smoke"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 100 //lel

/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	if(!is_shadow_or_thrall(M))
		to_chat(M, "<span class='warning'><b>You breathe in the black smoke, and your eyes burn horribly!</b></span>")
		M.blind_eyes(5)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3, 0)
			. = 1
	else
		to_chat(M, "<span class='notice'><b>You breathe in the black smoke, and you feel revitalized!</b></span>")
		M.adjustOxyLoss(-2, 0)
		M.adjustToxLoss(-2, 0)
		. = 1
	return ..() || .

/datum/reagent/water/reaction_turf(turf/open/T, reac_volume)
	. = ..()
	for(var/mob/living/simple_animal/hostile/gremlin/G in src)
		G.divide()

/datum/reagent/water/on_mob_life(mob/living/M)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 1*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.drunkenness = max(H.drunkenness - 2, 0)
	..()
	. = 1

/datum/reagent/holywater/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M) && is_vampire(M) && prob(80))
		var/datum/antagonist/vampire/V = M.mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
		if(!V.get_ability(/datum/vampire_passive/full))
			switch(current_cycle)
				if(1 to 4)
					to_chat(M, "<span class='warning'>Something sizzles in your veins!</span>")
					M.adjustFireLoss(0.5)
				if(5 to 12)
					to_chat(M, "<span class='danger'>You feel an intense burning inside of you!</span>")
					M.adjustFireLoss(1)
				if(13 to INFINITY)
					M.visible_message("<span class='danger'>[M] suddenly bursts into flames!<span>", "<span class='userdanger'>You suddenly ignite in a holy fire!</span>")
					M.adjust_fire_stacks(3)
					M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					M.adjustFireLoss(3)		//Hence the other damages... ain't I a bastard?
