/datum/component/knockback
	var/throw_distance

/datum/component/knockback/Initialize(throw_distance=1)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.throw_distance = throw_distance

/datum/component/knockback/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/afterattack_react)

/datum/component/knockback/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/datum/component/knockback/proc/afterattack_react(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!ismovableatom(target) || !proximity_flag)
		return
	var/obj/item/master = parent
	var/atom/movable/throwee = target
	var/atom/throw_target = get_edge_target_turf(throwee, get_dir(master, throwee))
	throwee.safe_throw_at(throw_target, throw_distance, 1, user)