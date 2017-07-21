/datum/reagent/toxin/mutagen/reaction_mob(mob/living/W, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(W, /mob/living/carbon))
		return FALSE
	var/mob/living/carbon/M = W
	if(!M.has_dna())
		return FALSE
	if(method==VAPOR)
		if(M.reagents)
			var/modifier = Clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(id, amount)
		if(prob(min(33, reac_volume)))
			M.randmuti()
			if(prob(98))
				M.randmutb()
			else
				M.randmutvg()
			M.updateappearance()
			M.domutcheck()
	else
		M.randmuti()
		if(prob(98))
			M.randmutb()
		else
			M.randmutvg()
		M.updateappearance()
		M.domutcheck()
	return TRUE

/datum/reagent/toxin/bone_hurting_juice
	name = "Bone Hurting Juice"
	id =  "bone_hurting_juice"
	description = "A corrupted form of calcium that reacts horribly with more calcium."
	reagent_state = LIQUID
	color = "#DEDEDE" // a horrible shade of off-white grey, also FUG!!!
	toxpwr = 0 //It only hurts your bones

/datum/reagent/toxin/bone_hurting_juice/on_mob_life(mob/living/M)
	if (prob(20))
		M.say(pick("Oof!", "OUCH!!", "Owie!"))

	if  (prob(10))
		to_chat(M, "<span class='danger'> Your bones ache!")

	if (prob(3))
		M.adjustBruteLoss(rand(1,5), 0)//we wanna hurt them, not kill them.
		to_chat(M, "<span class='userdanger'> Your bones really hurt!")