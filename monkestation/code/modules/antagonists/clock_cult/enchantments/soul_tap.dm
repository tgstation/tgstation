/datum/component/enchantment/soul_tap
	examine_description = "It has been blessed with the power of ripping the energy from target's souls and will heal the wielder when a target is struck."
	max_level = 3

/datum/component/enchantment/soul_tap/Destroy()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	return ..()

/datum/component/enchantment/soul_tap/apply_effect(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(tap_soul))

/datum/component/enchantment/soul_tap/proc/tap_soul(datum/source, mob/living/target, mob/living/user)
	if(!istype(target) || target.stat != CONSCIOUS)
		return
	var/obj/item/parentItem = parent
	var/health_back = CEILING(level * parentItem.force * 0.1, 1)
	user.heal_overall_damage(health_back, health_back)
	new /obj/effect/temp_visual/heal(get_turf(user), "#eeba6b")
