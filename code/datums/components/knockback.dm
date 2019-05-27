/datum/component/knockback
	var/throw_distance
	var/reverse

/datum/component/knockback/Initialize(throw_distance=1, reverse=FALSE)
	if(!isitem(parent) && !ishostile(parent) && !isgun(parent))
		return COMPONENT_INCOMPATIBLE

	src.throw_distance = throw_distance
	src.reverse = reverse

/datum/component/knockback/RegisterWithParent()
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

/datum/component/knockback/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_ATTACKINGTARGET, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))

/datum/component/knockback/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)

/datum/component/knockback/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_PROJECTILE_ON_HIT)

/datum/component/knockback/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	do_knockback(target, user, get_dir(source, target))

/datum/component/knockback/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target)
	do_knockback(target, attacker, get_dir(attacker, target))

/datum/component/knockback/proc/projectile_hit(atom/movable/firer, atom/target, Angle)
	do_knockback(target, null, angle2dir(Angle))

/datum/component/knockback/proc/do_knockback(atom/target, mob/thrower, throw_dir)
	if(!ismovableatom(target) || throw_dir == null)
		return
	var/atom/movable/throwee = target
	if(reverse)
		throw_dir = turn(throw_dir, 180)
	var/atom/throw_target = get_edge_target_turf(throwee, throw_dir)
	throwee.safe_throw_at(throw_target, throw_distance, 1, thrower)