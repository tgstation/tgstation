/datum/outfit/cultist
	name = "Cultist (Preview only)"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	head = /obj/item/clothing/head/hooded/cult_hoodie/alt
	shoes = /obj/item/clothing/shoes/cult/alt
	r_hand = /obj/item/melee/blood_magic/stun

/datum/outfit/cultist/post_equip(mob/living/carbon/human/equipped, visuals_only)
	equipped.eye_color_left = BLOODCULT_EYE
	equipped.eye_color_right = BLOODCULT_EYE
	equipped.update_body()

///Returns whether the given mob is convertable to the blood cult
/proc/is_convertable_to_cult(mob/living/target, datum/team/cult/specific_cult)
	if(!istype(target))
		return FALSE
	if(isnull(target.mind))
		return FALSE

// disables client checks if testing for easier debugging
#ifndef TESTING
	if(!GET_CLIENT(target))
		return FALSE
#endif

	if(ishuman(target) && target.mind.holy_role)
		return FALSE
	if(specific_cult?.is_sacrifice_target(target.mind))
		return FALSE
	var/mob/living/master = target.mind.enslaved_to?.resolve()
	if(master && !IS_CULTIST(master))
		return FALSE
	if(IS_HERETIC_OR_MONSTER(target))
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE) || issilicon(target) || isbot(target) || isdrone(target))
		return FALSE //can't convert machines, shielded, or braindead
	return TRUE
