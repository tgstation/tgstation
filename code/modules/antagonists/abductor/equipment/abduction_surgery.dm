/datum/surgery/organ_extraction
	name = "experimental dissection"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/extract_organ, /datum/surgery_step/gland_insert)
	possible_locs = list("chest")
	ignore_clothes = 1

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	if(H.dna.species.id == "abductor")
		return 1
	for(var/obj/item/implant/abductor/A in H.implants)
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
	user.visible_message("[user] starts to remove [target]'s organs.", "<span class='notice'>You start to remove [target]'s organs...</span>")

/datum/surgery_step/extract_organ/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		user.put_in_hands(IC)
		IC.Remove(target)
		return 1
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")
		return 1

/datum/surgery_step/gland_insert
	name = "insert gland"
	implements = list(/obj/item/organ/heart/gland = 100)
	time = 32

/datum/surgery_step/gland_insert/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts to insert [tool] into [target].", "<span class ='notice'>You start to insert [tool] into [target]...</span>")

/datum/surgery_step/gland_insert/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] inserts [tool] into [target].", "<span class ='notice'>You insert [tool] into [target].</span>")
	user.temporarilyRemoveItemFromInventory(tool, TRUE)
	var/obj/item/organ/heart/gland/gland = tool
	gland.Insert(target, 2)
	return 1

/datum/surgery/pacify
	name = "violence neutralization"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/saw,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/pacify,
				/datum/surgery_step/close)

	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("head")
	requires_bodypart_type = 0

/datum/surgery/pacify/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	. = FALSE
	if(!(H.dna.species.id == "abductor"))
		. = TRUE
	for(var/obj/item/implant/abductor/A in H.implants)
		. = TRUE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		to_chat(user, "<span class='warning'>It's hard to do surgery on someone's brain when they don't have one.</span>")
		return FALSE

/datum/surgery_step/pacify
	name = "rewire brain"
	implements = list(/obj/item/hemostat = 100, /obj/item/screwdriver = 35, /obj/item/pen = 15)
	time = 40

/datum/surgery_step/pacify/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to reshape [target]'s brain.", "<span class='notice'>You begin to reshape [target]'s brain...</span>")

/datum/surgery_step/pacify/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully reshapes [target]'s brain!", "<span class='notice'>You succeed in reshaping [target]'s brain.</span>")
	target.gain_trauma(/datum/brain_trauma/severe/pacifism)
	return TRUE

/datum/surgery_step/pacify/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully reshapes [target]'s brain!", "<span class='notice'>You screwed up, and rewired [target]'s brain the wrong way around...</span>")
	target.gain_trauma_type(BRAIN_TRAUMA_SEVERE)
	return FALSE