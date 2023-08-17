/datum/component/enchantment/electricution
	max_level = 3
	examine_description = "It has been blessed with the power of electricity and will shock targets."

/datum/component/enchantment/electricution/Destroy()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	return ..()

/datum/component/enchantment/electricution/apply_effect(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(shock_target))

/datum/component/enchantment/electricution/proc/shock_target(datum/source, atom/movable/target, mob/living/user)
	user.Beam(target, icon_state = "lightning[rand(1,12)]", time = 2, maxdistance = 32)
	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	if(carbon_target.electrocute_act(level * 3, user, 1, SHOCK_NOSTUN))
		carbon_target.visible_message(span_danger("[user] electrocutes [target]!"), span_userdanger("[user] electrocutes you!"))
