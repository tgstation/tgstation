/datum/surgery/organ_extraction
	name = "experimental dissection"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin,/datum/surgery_step/incise, /datum/surgery_step/extract_organ ,/datum/surgery_step/gland_insert)
	species = list(/mob/living/carbon/human)
	location = "chest"
	user_species_restricted = 1
	user_species_ids = list("abductor")
	ignore_clothes = 1

/datum/surgery_step/extract_organ
	accept_hand = 1
	time = 32
	var/obj/item/IC = null
	var/list/organ_types = list(/obj/item/organ/heart)

/datum/surgery_step/extract_organ/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/I in target.internal_organs)
		if(I.type in organ_types)
			IC = I
			break
	user.visible_message("[user] starts to remove [target]'s organs.", "<span class='notice'>You start to remove [target]'s organs...</span>")

/datum/surgery_step/extract_organ/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		user.put_in_hands(IC)
		target.internal_organs -= IC
		return 1
	else
		user << "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>"
		return 0

/datum/surgery_step/gland_insert
	implements = list(/obj/item/gland = 100)
	time = 32

/datum/surgery_step/gland_insert/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts to insert [tool] into [target].", "<span class ='notice'>You start to insert [tool] into [target]...</span>")

/datum/surgery_step/gland_insert/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] inserts [tool] into [target].", "<span class ='notice'>You insert [tool] into [target].</span>")
	user.drop_item()
	var/obj/item/gland/gland = tool
	gland.Inject(target)
	return 1


