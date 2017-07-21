/datum/species/skeleton/playable
	name = "Spooky Scary Skeleton"
	id = "spookyskeleton"
	say_mod = "rattles"
	blacklisted = 0
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	mutant_organs = list(/obj/item/organ/tongue/bone)
	damage_overlay_type = ""
	species_traits = list(LIPS)
	limbs_id = "skeleton"


/datum/species/skeleton/playable/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "bone_hurting_juice")
		if (prob(5))
			H.visible_message("<span class='danger'>[H] rubs their bones, they appear to be hurting!</span>", "<span class='danger'>Your bones are starting to hurt a lot.</span>")
		if(prob(3))
			H.say(pick("This rattles me bones!", "My bones hurt!", "Oof OUCH Owie!"))

/datum/species/skeleton/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H) //The counter to necrolitches... except not really because its hard to get this chem into their system.
	if(chem.id == "bone_hurting_juice")
		if (prob(5))
			H.visible_message("<span class='danger'>[H] rubs their bones, they appear to be hurting!</span>", "<span class='danger'>Your bones are starting to hurt a lot.</span>")
			H.adjustBruteLoss(rand(2,8), 0)
		if(prob(3))
			H.say(pick("This rattles me bones!", "My bones hurt!", "Oof OUCH Owie!"))
			H.adjustBruteLoss(rand(5,10), 0)
		if(prob(2))
			H.visible_message("<span class='danger'>[H] bones twist and warp, it looks like it really really hurts!</span>", "<span class='userdanger'>Your bones hurt so much!</span>")
			H.emote("scream")
			H.adjustBruteLoss(rand(10,20), 0)