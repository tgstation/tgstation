/// Accepts visible items that aren't anchored or already being pulled.
/datum/targeting_strategy/pickup_item/stealable_item

/datum/targeting_strategy/pickup_item/stealable_item/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/candidate = target
	if(!isitem(candidate) || candidate.anchored || candidate.pulledby)
		return FALSE
	return can_see(living_mob, candidate, vision_range)

/// Accepts ordinary ground loot plus items visibly accessible in hands or a human's ID slot.
/datum/targeting_strategy/pickup_item/stealable_item/stoat

/datum/targeting_strategy/pickup_item/stealable_item/stoat/is_valid_target(
	mob/living/living_mob,
	atom/target,
	vision_range,
	datum/ai_controller/controller = null,
)
	if(QDELETED(target))
		return FALSE
	var/obj/item/candidate = target
	if(!isitem(candidate) || candidate.anchored || candidate.pulledby)
		return FALSE
	if(isturf(candidate.loc))
		return can_see(living_mob, candidate, vision_range)
	var/mob/living/item_holder = candidate.loc
	if(!istype(item_holder) || !can_see(living_mob, item_holder, vision_range))
		return FALSE
	if(candidate in item_holder.held_items)
		return TRUE
	if(ishuman(item_holder))
		var/mob/living/carbon/human/human_holder = item_holder
		return human_holder.wear_id == candidate
	return FALSE

/datum/targeting_strategy/pickup_item/stealable_item/stoat/can_keep_target(
	mob/living/living_mob,
	atom/target,
	range,
	datum/ai_controller/controller = null,
)
	return is_valid_target(living_mob, target, range, controller)
