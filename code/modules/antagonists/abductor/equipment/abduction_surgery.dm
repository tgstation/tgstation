/datum/surgery/organ_extraction
	name = "Experimental organ replacement"
	possible_locs = list(BODY_ZONE_CHEST)
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/extract_organ,
		/datum/surgery_step/gland_insert,
	)

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(user))
		return FALSE
	if(!..())
		return FALSE
	if(isabductor(user))
		return TRUE
	var/mob/living/non_abductor = user
	if(locate(/obj/item/implant/abductor) in non_abductor.implants)
		return TRUE
	return FALSE


/datum/surgery_step/extract_organ
	name = "remove heart"
	accept_hand = 1
	time = 3.2 SECONDS
	var/obj/item/organ/IC = null
	var/list/organ_types = list(/obj/item/organ/heart)

/datum/surgery_step/extract_organ/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/atom/A in target.organs)
		if(A.type in organ_types)
			IC = A
			break
	user.visible_message(span_notice("[user] starts to remove [target]'s organs."), span_notice("You start to remove [target]'s organs..."))

/datum/surgery_step/extract_organ/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(IC)
		user.visible_message(span_notice("[user] pulls [IC] out of [target]'s [target_zone]!"), span_notice("You pull [IC] out of [target]'s [target_zone]."))
		user.put_in_hands(IC)
		IC.Remove(target)
		return 1
	else
		to_chat(user, span_warning("You don't find anything in [target]'s [target_zone]!"))
		return 1

/datum/surgery_step/gland_insert
	name = "insert gland"
	implements = list(/obj/item/organ/heart/gland = 100)
	time = 3.2 SECONDS

/datum/surgery_step/gland_insert/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(span_notice("[user] starts to insert [tool] into [target]."), span_notice("You start to insert [tool] into [target]..."))

/datum/surgery_step/gland_insert/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(span_notice("[user] inserts [tool] into [target]."), span_notice("You insert [tool] into [target]."))
	user.temporarilyRemoveItemFromInventory(tool, TRUE)
	var/obj/item/organ/heart/gland/gland = tool
	gland.Insert(target, special = TRUE, movement_flags = FROM_ABDUCTOR_SURGERY)
	return TRUE
