// TODO move to components folder //
/datum/component/living_heart
	var/datum/action/item_action/organ_action/track_target/action

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	if(organ_parent.status != ORGAN_ORGANIC)
		return COMPONENT_INCOMPATIBLE

	if(!IS_HERETIC(organ_parent.owner))
		return COMPONENT_INCOMPATIBLE

	action = new(organ_parent)
	action.Grant(organ_parent.owner)

	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/datum/component/living_heart/Destroy(force, silent)
	QDEL_NULL(action)
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, COMSIG_ORGAN_REMOVED)
	return ..()

/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	to_chat(old_owner, span_userdanger("As your living [source.name] leaves your body, you feel less connected to the Mansus!"))
	qdel(src)

// The associated action
/datum/action/item_action/organ_action/track_target
	name = "Living Heartbeat"
	desc = "Track your targets."
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/track_target/Grant(mob/granted)
	if(!IS_HERETIC(granted))
		return

	return ..()

/datum/action/item_action/organ_action/track_target/IsAvailable()
	if(!IS_HERETIC(owner))
		return
	if(!isorgan(target))
		return
	if(!HAS_TRAIT(target, TRAIT_LIVING_HEART))
		return

	return ..()

/datum/action/item_action/organ_action/track_target/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/antagonist/heretic/heretic_datum = owner.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/living_heart_sacrificing/knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/living_heart_sacrificing)
	if(!knowledge)
		return FALSE

	if(!LAZYLEN(knowledge.sac_targets))
		to_chat(owner, span_danger("You have no targets. Visit a transmutation rune to aquire targets!"))
		return TRUE

	var/list/mob/living/carbon/human/human_targets = list()
	for(var/datum/weakref/target_ref as anything in knowledge.sac_targets)
		var/mob/living/carbon/human/real_target = target_ref?.resolve()
		if(!QDELETED(real_target))
			human_targets += real_target

	playsound(owner, 'sound/effects/singlebeat.ogg', 40, TRUE)
	for(var/mob/living/carbon/human/mob_target as anything in human_targets)
		var/dist = get_dist(get_turf(owner), get_turf(mob_target))
		var/dir = get_dir(get_turf(owner), get_turf(mob_target))

		if(isturf(mob_target.loc) && owner.z != mob_target.z)
			to_chat(owner, span_warning("[mob_target.real_name] is on another plane of existence!"))
		else
			switch(dist)
				if(0 to 15)
					to_chat(owner, span_warning("[mob_target.real_name] is near you. They are to the [dir2text(dir)] of you!"))
				if(16 to 31)
					to_chat(owner, span_warning("[mob_target.real_name] is somewhere in your vicinity. They are to the [dir2text(dir)] of you!"))
				if(32 to 127)
					to_chat(owner, span_warning("[mob_target.real_name] is far away from you. They are to the [dir2text(dir)] of you!"))
				else
					to_chat(owner, span_warning("[mob_target.real_name] is beyond our reach."))

		if(mob_target.stat == DEAD)
			to_chat(owner, span_warning("[mob_target.real_name] is dead. Bring them to a transmutation rune!"))
