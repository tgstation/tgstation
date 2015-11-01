/datum/surgery/organ_extraction
	name = "experimental dissection"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin,/datum/surgery_step/incise, /datum/surgery_step/extract_organ ,/datum/surgery_step/gland_insert)
	possible_locs = list("chest")
	ignore_clothes = 1

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	if(H.dna && istype(H.dna.species, /datum/species/abductor))
		return ..()
	if((locate(/obj/item/weapon/implant/abductor) in H))
		return ..()
	return 0

/datum/surgery_step/extract_organ
	name = "remove heart"
	accept_hand = 1
	time = 32
	var/datum/organ/internal/IC = null
	var/list/organ_types = list("heart")

/datum/surgery_step/extract_organ/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/organname in organ_types)
		IC = target.getorgan(organname)
		if(IC && IC.exists())
			break
	user.visible_message("<span class='notice'>[user] starts to remove [target]'s organs.</span>")

/datum/surgery_step/extract_organ/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(IC && IC.exists())
		user.visible_message("<span class='notice'>[user] pulls [IC] out of [target]'s [target_zone]!</span>")
		IC.dismember(ORGAN_REMOVED, special = 1)
		user.put_in_hands(IC)
		return 1
	else
		user.visible_message("<span class='notice'>[user] doesn't find anything in [target]'s [target_zone].</span>")
		return 0

/datum/surgery_step/gland_insert
	name = "insert gland"
	implements = list(/obj/item/organ/internal/heart/gland = 100)
	time = 32

/datum/surgery_step/gland_insert/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] starts to insert [tool] into [target].</span>")

/datum/surgery_step/gland_insert/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] inserts [tool] into [target].</span>")
	var/obj/item/organ/internal/heart/gland/G = tool
	user.drop_item()
	G.Insert(target, 2)
	return 1


