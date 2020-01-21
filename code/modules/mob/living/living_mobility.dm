/*
MOBILITY TRAITS
*/

/mob/living/proc/set_up_mobility()
	if(mobility_flags & MOBILITY_MOVE)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_IMMOBILE), .proc/on_immobile_trait_change)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_GROUND_IMMOBILE), .proc/on_ground_immobile_trait_change)
	if(mobility_flags & MOBILITY_STAND)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_STANDINGBLOCKED), .proc/on_standingblocked_trait_change)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_GROUND_STANDINGBLOCKED), .proc/on_ground_standingblocked_trait_change)
	if(mobility_flags & MOBILITY_HANDS_USE)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_HANDSBLOCKED), .proc/on_handsblocked_trait_change)
	if(mobility_flags & MOBILITY_PICKUP)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_PICKUPBLOCKED), .proc/on_pickupblocked_trait_change)
	if(mobility_flags & MOBILITY_UI)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_UIBLOCKED), .proc/on_uiblocked_trait_change)
	if(mobility_flags & MOBILITY_STORAGE)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_STORAGEBLOCKED), .proc/on_storageblocked_trait_change)
	if(mobility_flags & MOBILITY_PULL)
		RegisterSignal(src, SIGNAL_TRAIT(TRAIT_PULLBLOCKED), .proc/on_pullblocked_trait_change)

/mob/living/proc/unset_mobility()
	if(!(mobility_flags & MOBILITY_MOVE))
		UnregisterSignal(src, list(SIGNAL_TRAIT(TRAIT_IMMOBILE), SIGNAL_TRAIT(TRAIT_GROUND_IMMOBILE)))
	if(!(mobility_flags & MOBILITY_STAND))
		UnregisterSignal(src, list(SIGNAL_TRAIT(TRAIT_STANDINGBLOCKED), SIGNAL_TRAIT(TRAIT_GROUND_STANDINGBLOCKED)))
	if(!(mobility_flags & MOBILITY_HANDS_USE))
		UnregisterSignal(src, SIGNAL_TRAIT(TRAIT_HANDSBLOCKED))
	if(!(mobility_flags & MOBILITY_PICKUP))
		UnregisterSignal(src, SIGNAL_TRAIT(TRAIT_PICKUPBLOCKED))
	if(!(mobility_flags & MOBILITY_UI))
		UnregisterSignal(src, SIGNAL_TRAIT(TRAIT_UIBLOCKED))
	if(!(mobility_flags & MOBILITY_STORAGE))
		UnregisterSignal(src, SIGNAL_TRAIT(TRAIT_STORAGEBLOCKED))
	if(!(mobility_flags & MOBILITY_PULL))
		UnregisterSignal(src, SIGNAL_TRAIT(TRAIT_PULLBLOCKED))

/mob/living/proc/on_ground_immobile_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_MOVE)
			on_ground_mobility_loss()
	else if(mobility_flags & MOBILITY_MOVE)
		on_ground_mobility_gain()

/mob/living/proc/on_ground_mobility_loss()
	if(movement_type & (FLYING|FLOATING))
		return
	ADD_TRAIT(src, TRAIT_IMMOBILE, TRAIT_GROUND_IMMOBILE)

/mob/living/proc/on_ground_mobility_gain()
	if(movement_type & (FLYING|FLOATING))
		return
	REMOVE_TRAIT(src, TRAIT_IMMOBILE, TRAIT_GROUND_IMMOBILE)

/mob/living/proc/on_immobile_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_MOVE)
			on_mobility_loss()
	else if(mobility_flags & MOBILITY_MOVE)
		on_mobility_gain()

/mob/living/proc/on_mobility_loss()

/mob/living/proc/on_mobility_gain()

/mob/living/proc/on_ground_standingblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_STAND)
			on_ground_standing_ability_loss()
	else if(mobility_flags & MOBILITY_STAND)
		on_ground_standing_ability_gain()

/mob/living/proc/on_ground_standing_ability_loss()
	if(movement_type & (FLYING|FLOATING))
		return
	ADD_TRAIT(src, TRAIT_STANDINGBLOCKED, TRAIT_GROUND_STANDINGBLOCKED)

/mob/living/proc/on_ground_standing_ability_gain()
	if(movement_type & (FLYING|FLOATING))
		return
	REMOVE_TRAIT(src, TRAIT_STANDINGBLOCKED, TRAIT_GROUND_STANDINGBLOCKED)

/mob/living/proc/on_standingblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_STAND)
			on_standing_ability_loss()
	else if(mobility_flags & MOBILITY_STAND)
		on_standing_ability_gain()

/mob/living/proc/on_standing_ability_loss()
	if(!IS_PRONE(src) && !buckled) //force them on the ground
		lay_down()

/mob/living/proc/on_standing_ability_gain()
	if(!resting && !buckled)
		get_up()

/mob/living/proc/on_handsblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_HANDS_USE)
			on_hands_use_loss()
	else
		if(mobility_flags & MOBILITY_HANDS_USE)
			on_hands_use_gain()

/mob/living/proc/on_hands_use_loss()
	drop_all_held_items()
	ADD_TRAIT(src, TRAIT_PULLBLOCKED, TRAIT_HANDSBLOCKED)
	ADD_TRAIT(src, TRAIT_UIBLOCKED, TRAIT_HANDSBLOCKED)
	ADD_TRAIT(src, TRAIT_PICKUPBLOCKED, TRAIT_HANDSBLOCKED)
	ADD_TRAIT(src, TRAIT_STORAGEBLOCKED, TRAIT_HANDSBLOCKED)

/mob/living/proc/on_hands_use_gain()
	REMOVE_TRAIT(src, TRAIT_PULLBLOCKED, TRAIT_HANDSBLOCKED)
	REMOVE_TRAIT(src, TRAIT_UIBLOCKED, TRAIT_HANDSBLOCKED)
	REMOVE_TRAIT(src, TRAIT_PICKUPBLOCKED, TRAIT_HANDSBLOCKED)
	REMOVE_TRAIT(src, TRAIT_STORAGEBLOCKED, TRAIT_HANDSBLOCKED)

/mob/living/proc/on_pickupblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_PICKUP)
			on_pickup_ability_loss()
	else if(mobility_flags & MOBILITY_PICKUP)
		on_pickup_ability_gain()

/mob/living/proc/on_pickup_ability_loss()

/mob/living/proc/on_pickup_ability_gain()

/mob/living/proc/on_uiblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_UI)
			on_ui_use_loss()
	else if(mobility_flags & MOBILITY_UI)
		on_ui_use_gain()

/mob/living/proc/on_ui_use_loss()
	unset_machine()

/mob/living/proc/on_ui_use_gain()

/mob/living/proc/on_storageblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_STORAGE)
			on_storage_use_loss()
	else if(mobility_flags & MOBILITY_STORAGE)
		on_storage_use_gain()

/mob/living/proc/on_storage_use_loss() //Should close any open storage windows here.

/mob/living/proc/on_storage_use_gain()

/mob/living/proc/on_pullblocked_trait_change(datum/source, change_flag)
	if(change_flag == COMPONENT_ADD_TRAIT)
		if(mobility_flags & MOBILITY_PULL)
			on_pull_ability_loss()
	else if(mobility_flags & MOBILITY_PULL)
		on_pull_ability_gain()

/mob/living/proc/on_pull_ability_loss()
	if(pulling)
		stop_pulling()

/mob/living/proc/on_pull_ability_gain()

/*
MOBILITY FLAGS
Avoid changing these outside of mob definition or init.
If you have to use them, toggle them between NONE and their default setting for the mob. If you need to enable or disable specific flags, use traits instead.
They represent inherent potential, not a temporary change.
There's no footprint for the changes, no sources, so if two different things change them there's possible problems.
*/

/mob/living/proc/set_mobility_flags(flags_to_set)
	if(flags_to_set == mobility_flags)
		return
	. = mobility_flags
	var/unchanging_flags = flags_to_set & mobility_flags
	if(mobility_flags & unchanging_flags)
		remove_mobility_flags(mobility_flags & unchanging_flags)
	if(flags_to_set & unchanging_flags)
		add_mobility_flags(flags_to_set & unchanging_flags)

//Don't use this proc outside of set_mobility_flags. If you need to manipulate specific flags, use traits.
/mob/living/proc/remove_mobility_flags(flags_to_remove)
	if(!(mobility_flags & flags_to_remove))
		return //Nothing old to remove.
	. = mobility_flags
	mobility_flags &= ~flags_to_remove
	var/changed_flags = ~(. & flags_to_remove) & flags_to_remove
	if(changed_flags & MOBILITY_MOVE)
		on_mobility_loss()
	if(changed_flags & MOBILITY_STAND)
		on_standing_ability_loss()
	if(changed_flags & MOBILITY_HANDS_USE)
		on_hands_use_loss()
	if(changed_flags & MOBILITY_PICKUP)
		on_pickup_ability_loss()
	if(changed_flags & MOBILITY_UI)
		on_ui_use_loss()
	if(changed_flags & MOBILITY_STORAGE)
		on_storage_use_loss()
	if(changed_flags & MOBILITY_PULL)
		on_pull_ability_loss()
	unset_mobility()

//Don't use this proc outside of set_mobility_flags. If you need to manipulate specific flags, use traits.
/mob/living/proc/add_mobility_flags(flags_to_add)
	if(flags_to_add == (mobility_flags & flags_to_add))
		return //Nothing new to add.
	. = mobility_flags
	mobility_flags |= flags_to_add
	var/changed_flags = ~(. & flags_to_add) & flags_to_add
	if(changed_flags & MOBILITY_MOVE && !HAS_TRAIT(src, TRAIT_IMMOBILE))
		on_mobility_gain()
	if(changed_flags & MOBILITY_STAND && !HAS_TRAIT(src, TRAIT_STANDINGBLOCKED))
		on_standing_ability_gain()
	if(changed_flags & MOBILITY_HANDS_USE && !HAS_TRAIT(src, TRAIT_HANDSBLOCKED))
		on_hands_use_gain()
	if(changed_flags & MOBILITY_PICKUP && !HAS_TRAIT(src, TRAIT_PICKUPBLOCKED))
		on_pickup_ability_gain()
	if(changed_flags & MOBILITY_UI && !HAS_TRAIT(src, TRAIT_UIBLOCKED))
		on_ui_use_gain()
	if(changed_flags & MOBILITY_STORAGE && !HAS_TRAIT(src, TRAIT_STORAGEBLOCKED))
		on_storage_use_gain()
	if(changed_flags & MOBILITY_PULL && !HAS_TRAIT(src, TRAIT_PULLBLOCKED))
		on_pull_ability_gain()
	set_up_mobility()
