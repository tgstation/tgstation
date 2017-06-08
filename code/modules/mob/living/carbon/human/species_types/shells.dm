//°*°*° LORE °*°*°
/*
   Human cloning is not a perfect process, and with each replica some genetic information is lost or damaged.
   This is usually not noticeable, but some people in dangerous professions accumulated enough errors to cause
   extreme decay, which caused a feedback loop of faster death, more frequent cloning, and worse health.

   Eventually, a new treatment came along to revive the human body at its original levels of functionality, through
   a combination of experimental genetic and bionic treatments. Some of the malformed were rich enough to afford it,
   others had to loan their future life to huge companies, such as NT, willing to foot the bill in exchange for very
   experienced workers.

   This treatment has a further cost. The reanimated bodies' genetic structure is so frayed and unstable that cloning
   is effectively impossible. The shells, as they've been named, are usually extremely cautious and at times paranoid;
   they've learned a lot of ways to lose their life, and those that are still around got there by avoiding death at all
   costs.

   Through a combination of bionic enhancements, odd genetics, and spite, shells can endure extreme amounts of pain and
   recover from the worst wounds on their own as long as they have a single spark of life left in them.
*/


/datum/species/shell
	name = "Shell"
	id = "shell"
	limbs_id = "shell"
	sexes = FALSE
	species_traits = list(EYECOLOR,LIPS,NO_UNDERWEAR,NOTRANSSTING,NOCRITDAMAGE)
	mutant_organs = list(/obj/item/organ/brain/shell)
	blacklisted = TRUE
	dangerous_existence = TRUE
	exotic_blood = "shellblood" //blood is mildly poisonous to others

/datum/species/shell/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	C.disabilities |= NOCLONE

/datum/species/shell/on_species_loss(mob/living/carbon/C, datum/species/old_species)
	..()
	C.disabilities &= ~NOCLONE

/datum/species/shell/qualifies_for_rank(rank, list/features)
	return TRUE	//Legally human, and usually ancient rich people

/datum/species/shell/spec_life(mob/living/carbon/human/H)
	..()
	if(H.stat != DEAD && H.health < 0)
		H.adjustToxLoss(-1)
		H.adjustBruteLoss(-1)
		H.adjustFireLoss(-1)
		H.adjustOxyLoss(-1)

/datum/species/shell/spec_mutation(mob/living/carbon/human/H)
	to_chat(H, "<span class='userdanger'>Your unstable genes collapse while mutating! Your flesh is [pick("melting","falling off","withering","rotting")]!</span>")
	H.adjustCloneLoss(25)
	return TRUE //no mutation
