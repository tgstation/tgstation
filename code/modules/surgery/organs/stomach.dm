/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = ORGAN_SLOT_STOMACH
	attack_verb = list("gored", "squished", "slapped", "digested")
	desc = "Onaka ga suite imasu."
	var/disgust_metabolism = 1

/obj/item/organ/stomach/on_life()
	var/mob/living/carbon/human/H = owner

	if(istype(H))
		H.dna.species.handle_digestion(H)
		handle_disgust(H)
		handle_nutrition(H) //This is nutrition in the "vitamins" sense, not the "fed" sense

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/H)
	if(H.disgust)
		var/pukeprob = 5 + 0.05 * H.disgust
		if(H.disgust >= DISGUST_LEVEL_GROSS)
			if(prob(10))
				H.stuttering += 1
				H.confused += 2
			if(prob(10) && !H.stat)
				to_chat(H, "<span class='warning'>You feel kind of iffy...</span>")
			H.jitteriness = max(H.jitteriness - 3, 0)
		if(H.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(prob(pukeprob)) //iT hAndLeS mOrE ThaN PukInG
				H.confused += 2.5
				H.stuttering += 1
				H.vomit(10, 0, 1, 0, 1, 0)
			H.Dizzy(5)
		if(H.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(prob(25))
				H.blur_eyes(3) //We need to add more shit down here

		H.adjust_disgust(-0.5 * disgust_metabolism)

	switch(H.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			H.clear_alert("disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			H.throw_alert("disgust", /obj/screen/alert/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			H.throw_alert("disgust", /obj/screen/alert/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			H.throw_alert("disgust", /obj/screen/alert/disgusted)

/obj/item/organ/stomach/proc/handle_nutrition(mob/living/carbon/human/H)
	//First, calculate the actual vitamin levels
	var/vitamin_decay_rate = H.vitamins * 0.001 //Vitamin levels will slowly decay towards neutral
	vitamin_decay_rate = Clamp(vitamin_decay_rate, -0.05, 0.05)
	H.vitamins -= vitamin_decay_rate //Yes, this works for negatives, don't ask me how
	H.vitamins = Clamp(H.vitamins, -VITAMIN_CLAMP, VITAMIN_CLAMP) //So we don't have 1000% vitamin level

	if(H.vitamins < VITAMIN_LEVEL_HYPERVITAMINITOSIS)
		//Then, our body heals depending on nutrition!
		H.adjustBruteLoss(-max(0, 0.01 + (H.vitamins * 0.0005))) //Natural healing remains very slow, but is faster for people who are well-nourished
		H.adjustFireLoss(-max(0, 0.01 + (H.vitamins * 0.0003))) //Burn wounds heal slightly more slowly

/obj/item/organ/stomach/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.clear_alert("disgust")

	..()

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/plasmaman
	name = "digestive crystal"
	icon_state = "pstomach"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."
