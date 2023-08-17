/datum/component/enchantment/blinding
	examine_description = "It has been blessed with the power to emit a blinding light when striking a target."
	max_level = 1

/datum/component/enchantment/blinding/Destroy()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	return ..()

/datum/component/enchantment/blinding/apply_effect(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(flash_target))

/datum/component/enchantment/blinding/proc/flash_target(datum/source, mob/living/target, mob/living/user)
	if(!istype(target))
		return
	var/obj/item/parent_item = parent
	parent_item.visible_message(span_danger("\The [parent_item] emits a blinding light!"))
	target.flash_act(2, affect_silicon = TRUE, length = 3 SECONDS) //might want to make this not effect borgs
