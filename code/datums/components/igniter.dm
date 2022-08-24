/datum/component/igniter
	var/fire_stacks
	var/fire_type

/datum/component/igniter/Initialize(fire_stacks = 1, fire_type = /datum/status_effect/fire_handler/fire_stacks)
	if(!isitem(parent) && !ishostile(parent) && !isgun(parent) && !ismachinery(parent) && !isstructure(parent) && !isprojectilespell(parent))
		return COMPONENT_INCOMPATIBLE

	src.fire_stacks = fire_stacks
	src.fire_type = fire_type

/datum/component/igniter/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent)) // turrets, etc
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, .proc/hostile_attackingtarget)

/datum/component/igniter/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET, COMSIG_PROJECTILE_ON_HIT))

/datum/component/igniter/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	do_igniter(target)

/datum/component/igniter/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	do_igniter(target)

/datum/component/igniter/proc/projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	do_igniter(target)

/datum/component/igniter/proc/do_igniter(atom/target)
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_fire_stacks(fire_stacks, fire_type)
		L.ignite_mob()
