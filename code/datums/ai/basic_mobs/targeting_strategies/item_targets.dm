
/// Subtype that allows items as valid targets.
/datum/targeting_strategy/basic/allow_items

/datum/targeting_strategy/basic/allow_items/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(isitem(the_target))
		// trust fall exercise, ai needs to handle targetting items that matter to the mob
		return TRUE

/// Parent means the pawn is interested in items
/// if the pawn wants items more than fighting, this will prevent hostile mobs from attacking targets holding what they want.
/datum/targeting_strategy/basic/allow_items/friendly_for_items
	/// if this pawn considers some mobs as enemies it wouldn't stop fighting, this key points to that list of enemies
	var/enemy_list_key = BB_FOES
	/// types of items the mob is interested in, not attacking
	var/wanted_items_key = BB_WANTED_ITEMS

/datum/targeting_strategy/basic/allow_items/friendly_for_items/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(!.)
		return FALSE

	var/datum/ai_controller/controller = living_mob.ai_controller
	var/list/enemy_list = list()
	var/list/wanted_items = controller.blackboard[wanted_items_key]
	if(controller.blackboard_key_exists(enemy_list_key))
		enemy_list = controller.blackboard[enemy_list_key]
	if(isliving(the_target) && !(the_target in enemy_list))
		var/mob/living/living_target = the_target
		for(var/obj/item/held as anything in living_target.held_items)
			if(held in wanted_items)
				return FALSE //heyyy i like this thing! let's NOT fight

///subtype that uses a generic food key instead
/datum/targeting_strategy/basic/allow_items/friendly_for_items/food
	wanted_items_key = BB_BASIC_FOODS
