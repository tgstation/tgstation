/datum/surgery/organ_extraction
	name = "experimental dissection"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin,/datum/surgery_step/incise, /datum/surgery_step/extract_organ ,/datum/surgery_step/gland_insert)
	possible_locs = list("chest")
	ignore_clothes = 1

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	if(H.dna.species.id == "abductor")
		return 1
	for(var/obj/item/weapon/implant/abductor/A in H.implants)
		return 1
	return 0


/datum/surgery_step/extract_organ
	name = "remove heart"
	accept_hand = 1
	time = 32
	var/obj/item/organ/IC = null
	var/list/organ_types = list(/obj/item/organ/heart)

/datum/surgery_step/extract_organ/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/atom/A in target.internal_organs)
		if(A.type in organ_types)
			IC = A
			break
	user.visible_message("[IDENTITY_SUBJECT(1)] starts to remove [IDENTITY_SUBJECT(2)]'s organs.", "<span class='notice'>You start to remove [IDENTITY_SUBJECT(2)]'s organs...</span>", subjects=list(user, target))

/datum/surgery_step/extract_organ/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(IC)
		user.visible_message("[IDENTITY_SUBJECT(1)] pulls [IC] out of [IDENTITY_SUBJECT(2)]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [IDENTITY_SUBJECT(2)]'s [target_zone].</span>", subjects=list(user, target))
		user.put_in_hands(IC)
		IC.Remove(target)
		return 1
	else
		to_chat(user, "<span class='warning'>You don't find anything in [IDENTITY_SUBJECT(1)]'s [target_zone]!</span>", list(target))
		return 1

/datum/surgery_step/gland_insert
	name = "insert gland"
	implements = list(/obj/item/organ/heart/gland = 100)
	time = 32

/datum/surgery_step/gland_insert/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[IDENTITY_SUBJECT(1)] starts to insert [tool] into [IDENTITY_SUBJECT(2)].", "<span class ='notice'>You start to insert [tool] into [target]...</span>", subjects=list(user, target))

/datum/surgery_step/gland_insert/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[IDENTITY_SUBJECT(1)] inserts [tool] into [IDENTITY_SUBJECT(2)].", "<span class ='notice'>You insert [tool] into [IDENTITY_SUBJECT(2)].</span>", subjects=list(user, target))
	user.drop_item()
	var/obj/item/organ/heart/gland/gland = tool
	gland.Insert(target, 2)
	return 1
