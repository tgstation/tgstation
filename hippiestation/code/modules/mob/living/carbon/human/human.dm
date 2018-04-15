/mob/living/carbon/human/create_internal_organs()
  internal_organs += new /obj/item/organ/butt
  return ..()

/mob/living/carbon/human/canSuicide()
	var/datum/mutation/human/HM = GLOB.mutations_list[CLUWNEMUT]
	if(dna.species.id == "tarajan" || dna.species.id == "meeseeks" || HM in dna.mutations)
		return FALSE
	else
		return ..()

/mob/living/carbon/human/canSuccumb()
	var/datum/mutation/human/HM = GLOB.mutations_list[CLUWNEMUT]
	if(dna.species.id == "tarajan" || dna.species.id == "meeseeks" || HM in dna.mutations)
		return FALSE
	else
		return ..()

/mob/living/carbon/human/canGhost()
	var/datum/mutation/human/HM = GLOB.mutations_list[CLUWNEMUT]
	if(dna.species.id == "tarajan" || dna.species.id == "meeseeks" || HM in dna.mutations)
		return FALSE
	else
		return ..()

/mob/living/carbon/human/resist_restraints()
	if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit/nano))
		var/obj/item/clothing/suit/space/hardsuit/nano/NS = wear_suit
		if(NS.mode == "strength")
			changeNext_move(CLICK_CD_BREAKOUT)
			last_special = world.time + CLICK_CD_BREAKOUT
			cuff_resist(cuff_break = FAST_CUFFBREAK)
		else
			..()