/// Accepts open turfs which aren't space, aren't blocked, and are within hoarding range. Used to pick a parrot's nest.
/datum/targeting_strategy/parrot_hoard_location

/datum/targeting_strategy/parrot_hoard_location/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/turf/open/candidate = target
	if(!istype(candidate) || is_space_or_openspace(candidate))
		return FALSE
	if(candidate.is_blocked_turf(source_atom = living_mob))
		return FALSE
	return TRUE

/// Accepts small items lying on a turf away from the nest, or non-ally humans holding a small valuable. Used to pick something to steal.
/datum/targeting_strategy/parrot_hoard_item

/datum/targeting_strategy/parrot_hoard_item/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(isnull(controller))
		return FALSE

	var/list/ignore_items = controller.blackboard[BB_IGNORE_ITEMS]
	if(is_type_in_typecache(target, ignore_items))
		return FALSE

	var/turf/nest_turf = controller.blackboard[BB_HOARD_LOCATION]
	if(target.loc == nest_turf)
		return FALSE

	if(isitem(target))
		var/obj/item/loose_item = target
		return loose_item.w_class <= WEIGHT_CLASS_SMALL

	if(!ishuman(target))
		return FALSE
	if(living_mob.has_ally(target)) // dont steal from friends
		return FALSE
	return holding_valuable(controller, target)

/datum/targeting_strategy/parrot_hoard_item/proc/holding_valuable(datum/ai_controller/controller, mob/living/human_target)
	var/list/ignore_items = controller.blackboard[BB_IGNORE_ITEMS]
	for(var/obj/item/potential_item in human_target.held_items)
		if(is_type_in_typecache(potential_item, ignore_items))
			continue
		if(potential_item.w_class <= WEIGHT_CLASS_SMALL)
			return TRUE
	return FALSE

/// Finds something for the parrot to steal. Temporarily ignores faction when eyeing a person's belongings.
/datum/bt_node/ai_behavior/acquire_target/parrot_hoard_item
	target_source = /datum/target_source/oview
	targeting_strategy = /datum/targeting_strategy/parrot_hoard_item
	time_between_perform = 5 SECONDS

/datum/bt_node/ai_behavior/acquire_target/parrot_hoard_item/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	if(ishuman(target))
		controller.set_blackboard_key(BB_ALWAYS_IGNORE_FACTION, TRUE)

/// Single-hit grab variant which resets the faction-ignore flag once we are done stealing.
/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/parrot

/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/parrot/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.set_blackboard_key(BB_ALWAYS_IGNORE_FACTION, FALSE)

/// Find a nest, carry loot home, then go steal more.
/datum/bt_node/subtree/parrot_hoard
	behavior_tree_json = "code/modules/mob/living/basic/pets/parrot/parrot_ai/parrot_hoard.bt.json"
