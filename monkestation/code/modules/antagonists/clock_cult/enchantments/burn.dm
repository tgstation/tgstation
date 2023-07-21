/datum/component/enchantment/burn
	examine_description = "It has been blessed with the power of fire and will set struck targets on fire."
	max_level = 3

/datum/component/enchantment/burn/Destroy()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	return ..()

/datum/component/enchantment/burn/apply_effect(obj/item/target)
	target.damtype = BURN
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(burn_target))

/datum/component/enchantment/burn/proc/burn_target(datum/source, atom/movable/target, mob/living/user)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.adjust_fire_stacks(level)
	living_target.ignite_mob()
