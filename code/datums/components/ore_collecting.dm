/*
 * A component to allow us to collect ore
 */
/datum/component/ore_collecting
	///callback after collecting the ore
	var/datum/callback/post_collect

/datum/component/ore_collecting/Initialize(post_collect)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.post_collect = post_collect

/datum/component/ore_collecting/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(collect_ore))

/datum/component/ore_collecting/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)

/datum/component/ore_collecting/proc/collect_ore(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/item/stack/ore))
		return

	var/atom/movable/movable_target = target

	movable_target.forceMove(source)

	if(post_collect)
		post_collect.Invoke(target)
	return COMPONENT_HOSTILE_NO_ATTACK
