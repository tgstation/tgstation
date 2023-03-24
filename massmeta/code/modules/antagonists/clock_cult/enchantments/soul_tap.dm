/datum/component/enchantment/soul_tap
	max_level = 3

/datum/component/enchantment/soul_tap/apply_effect(obj/item/target)
	examine_description = "Он был благословлен силой вырывать энергию из души цели и исцелять владельца, когда цель поражена."
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(tap_soul))

/datum/component/enchantment/soul_tap/proc/tap_soul(datum/source, mob/living/target, mob/living/user)
	if(!istype(target) || target.stat != CONSCIOUS)
		return
	var/obj/item/parentItem = parent
	var/health_back = CEILING(level * parentItem.force * 0.1, 1)
	user.heal_overall_damage(health_back, health_back)
	new /obj/effect/temp_visual/heal(get_turf(user), "#eeba6b")
