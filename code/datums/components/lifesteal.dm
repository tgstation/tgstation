/datum/component/lifesteal
	var/flat_heal // heals a constant amount every time a hit occurs
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/datum/component/lifesteal/Initialize(flat_heal=0)
	if(!isitem(parent) && !ishostile(parent) && !isgun(parent))
		return COMPONENT_INCOMPATIBLE

	src.flat_heal = flat_heal

/datum/component/lifesteal/RegisterWithParent()
	if(isgun(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
		var/obj/item/parentgun = parent
		if(ismob(parentgun.loc))
			// call that we equipped the gun if it was modified in our hands
			on_equip(null, parentgun.loc, null)
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/hostile_attackingtarget)

/datum/component/lifesteal/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_ATTACKINGTARGET, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))

/datum/component/lifesteal/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)

/datum/component/lifesteal/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_PROJECTILE_ON_HIT)

/datum/component/lifesteal/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	do_lifesteal(user, target)

/datum/component/lifesteal/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target)
	do_lifesteal(attacker, target)

/datum/component/lifesteal/proc/projectile_hit(atom/movable/firer, atom/target, Angle)
	do_lifesteal(firer, target)

/datum/component/lifesteal/proc/do_lifesteal(atom/heal_target, atom/damage_target)
	if(isliving(heal_target) && isliving(damage_target))
		var/mob/living/healing = heal_target
		var/mob/living/damaging = damage_target
		if(damage_target.stat != DEAD)
			heal_target.heal_ordered_damage(flat_heal, damage_heal_order)