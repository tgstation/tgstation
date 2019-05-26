/datum/component/knockback
	var/throw_distance
	var/reverse

/datum/component/knockback/Initialize(throw_distance=1, reverse=FALSE)
	if(!isitem(parent) && !ishostile(parent) && !isgun(parent) && !isprojectile(parent))
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
	else if(isprojectile(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/hostile_attackingtarget)

/datum/component/knockback/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_ATTACKINGTARGET, COMSIG_PROJECTILE_ON_HIT, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))

/datum/component/knockback/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_PROJECTILE_BEFORE_FIRE, .proc/projectile_modify)

/datum/component/knockback/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_PROJECTILE_BEFORE_FIRE)

/datum/component/knockback/proc/projectile_modify(atom/movable/firer, obj/item/projectile/fired, atom/original_target)
	// the projectile needs to store the knockback in case we get deleted before it hits
	fired.AddComponent(/datum/component/knockback, throw_distance, reverse)

/datum/component/knockback/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	do_knockback(source, target, user)

/datum/component/knockback/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/source, atom/target)
	do_knockback(source, target, source)

/datum/component/knockback/proc/projectile_hit(obj/item/projectile/source, atom/target, Angle, blocked)
	do_knockback(source, target, null, angle2dir(Angle))

/datum/component/knockback/proc/do_knockback(atom/source, atom/target, mob/thrower, override_dir)
	if(!ismovableatom(target))
		return
	var/atom/movable/throwee = target
	var/throw_dir = override_dir ? override_dir : get_dir(source, throwee)
	if(reverse)
		throw_dir = turn(throw_dir, 180)
	var/atom/throw_target = get_edge_target_turf(throwee, throw_dir)
	throwee.safe_throw_at(throw_target, throw_distance, 1, thrower)