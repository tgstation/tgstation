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

/datum/reagent/toxin/bone_hurting_juice/on_mob_life(mob/living/carbon/M)
	if(prob(20))
		M.say(pick("Oof!", "OUCH!", "Owie!"))

	if(prob(10))
		to_chat(M, "<span class='danger'> Your bones hurt!</span>")

	if(prob(3))
		M.adjustBruteLoss(rand(1,5), 0)//we wanna hurt them, not kill them.
		to_chat(M, "<span class='userdanger'> Your bones really hurt!</span>")

	if(M.dna.species.id == "spookyskeleton")
		if(prob(5))
			M.visible_message("<span class='danger'>[M] rubs their bones, they appear to be hurting!</span>", "<span class='danger'>Your bones are starting to hurt a lot.</span>")
		if(prob(3))
			M.say(pick("This rattles me bones!", "My bones hurt!", "Oof OUCH Owie!"))

	if(M.dna.species.id == "skeleton")
		if(prob(5))
			M.visible_message("<span class='danger'>[M] rubs their bones, they appear to be hurting!</span>", "<span class='danger'>Your bones are starting to hurt a lot.</span>")
			M.adjustBruteLoss(rand(2,8), 0)
		if(prob(3))
			M.say(pick("This rattles me bones!!", "My bones hurt!!", "Oof OUCH Owie!!")) //Something neat, if I put two exclamation points here the mob will yell these lines instead of just saying them. A proper skeleton yells because their bones hurt more.
			M.adjustBruteLoss(rand(5,10), 0)
		if(prob(2))
			M.visible_message("<span class='danger'>[M] bones twist and warp! It looks like it really really hurts!</span>", "<span class='userdanger'>Your bones hurt so much!</span>")
			M.emote("scream")
			M.adjustBruteLoss(rand(10,20), 0)
