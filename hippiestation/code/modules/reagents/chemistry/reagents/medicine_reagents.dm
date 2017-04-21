/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Reduces drowsiness and hallucinations."
	color = "#FF00FF"

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Increases movement speed but causes you to lose weight fast, will also purge nutriment and vitamin from the body. Overdose deals toxin damage and inhibits breathing."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 45
	addiction_threshold = 30

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	if(M.reagents.has_reagent("nutriment"))
		M.reagents.remove_reagent("nutriment", 5)
	if(M.reagents.has_reagent("vitamin"))
		M.reagents.remove_reagent("vitamin", 5)
	if(prob(34))
		if(M.nutrition > 15)
			M.nutrition -= rand(5, 15) //Lose nutrition very rapidly.
		else
			if(M.nutrition > 0)//If you are nearly out of nutrition it slows down a bit but you could go all the way down. this prevents negatives.
				M.nutrition -= 1

	if(M.reagents.has_reagent("methamphetamine"))
		if(prob(15))
			M.adjust_fire_stacks(2)
			M.IgniteMob()
			to_chat(M, "<span class='boldwarning'>The Meth in your system reacts violently with the Ephedrine and you burst into flames!</span>")
	..()
	. = 1

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(0.5*REM, 0)
		M.losebreath++
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage1(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(2*REM, 0)
		M.losebreath += 2
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage2(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(3*REM, 0)
		M.losebreath += 3
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage3(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(4*REM, 0)
		M.losebreath += 4
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage4(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(5*REM, 0)
		M.losebreath += 5
		. = 1
	..()