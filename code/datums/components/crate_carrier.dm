/**
 * Component for simplemobs and basicmobs that allow them to carry crates.
 */
/datum/component/crate_carrier
	/// The max number of crates we can carry
	var/crate_limit = 3
	/// Typecache of all the types we can pick up and carry
	var/list/carriable_cache
	/// A lazylist of all crates we are carrying
	var/list/atom/movable/crates_in_hand

/datum/component/crate_carrier/Initialize(crate_limit = 3, list/carriable_types)
	. = ..()
	if(!isanimal_or_basicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.crate_limit = crate_limit

	if(carriable_types)
		src.carriable_cache = typecacheof(carriable_types)

	else
		var/static/default_cache = typecacheof(list(/obj/structure/closet/crate))
		src.carriable_cache = default_cache

/datum/component/crate_carrier/Destroy(force, silent)
	LAZYCLEARLIST(crates_in_hand)
	return ..()

/datum/component/crate_carrier/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/component/crate_carrier/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_LIVING_DEATH, COMSIG_PARENT_EXAMINE))

/// Signal proc for [COMSIG_PARENT_EXAMINE] to show when we're carrying crates
/datum/component/crate_carrier/proc/on_examine(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	var/num_crates = LAZYLEN(crates_in_hand)
	if(num_crates > 0)
		examine_list += span_notice("[source.p_theyre(TRUE)] carrying [num_crates == 1 ? "a crate":"[num_crates] crates"].")

/// Signal proc for [COMSIG_LIVING_UNARMED_ATTACK] to allow mobs to pick up or drop crates
/datum/component/crate_carrier/proc/on_unarm_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(source.combat_mode)
		return

	if(is_type_in_typecache(target, carriable_cache))
		var/atom/movable/movable_target = target
		if(LAZYLEN(crates_in_hand) >= crate_limit)
			source.balloon_alert(source, "too many crates!")
			return COMPONENT_CANCEL_ATTACK_CHAIN

		for(var/mob/living/inside_mob in movable_target.get_all_contents())
			if(inside_mob.mob_size < MOB_SIZE_HUMAN)
				continue
			source.balloon_alert(source, "crate too heavy!")
			return COMPONENT_CANCEL_ATTACK_CHAIN

		LAZYADD(crates_in_hand, target)
		movable_target.forceMove(source)
		source.balloon_alert(source, "grabbed crate")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(isopenturf(target) && LAZYLEN(crates_in_hand))
		drop_all_crates(target)
		source.balloon_alert(source, "dropped crate")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// Signal proc for [COMSIG_LIVING_DEATH], so we drop crates on death or gib
/datum/component/crate_carrier/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	drop_all_crates(source.drop_location())

/// Drops all the crates in our crate list.
/datum/component/crate_carrier/proc/drop_all_crates(atom/drop_to)
	for(var/obj/structure/closet/crate/held_crate as anything in crates_in_hand)
		held_crate.forceMove(drop_to)
		LAZYREMOVE(crates_in_hand, held_crate)
