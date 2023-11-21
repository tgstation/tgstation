/// This component will intercept bare-handed attacks by the owner on critically injured carbons and amputate random limbs instead
/datum/element/amputating_limbs
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// How long does it take?
	var/surgery_time
	/// What is the means by which we describe the act of amputation?
	var/surgery_verb
	/// The types of limb we can remove
	var/list/target_zones

/datum/element/amputating_limbs/Attach(
	datum/target,
	surgery_time = 5 SECONDS,
	surgery_verb = "prying",
	list/target_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG),
)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if (!length(target_zones))
		CRASH("[src] for [target] was not provided a valid list of body zones to target.")

	src.surgery_time = surgery_time
	src.surgery_verb = surgery_verb
	src.target_zones = target_zones
	RegisterSignals(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET), PROC_REF(try_amputate))

/datum/element/amputating_limbs/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/// Called when you click on literally anything with your hands, see if it is an injured carbon and then try to cut it up
/datum/element/amputating_limbs/proc/try_amputate(mob/living/surgeon, atom/victim)
	SIGNAL_HANDLER
	if (!iscarbon(victim) || HAS_TRAIT(victim, TRAIT_NODISMEMBER))
		return

	var/mob/living/carbon/limbed_victim = victim
	if (limbed_victim.stat == CONSCIOUS)
		return

	if (DOING_INTERACTION_WITH_TARGET(surgeon, victim))
		surgeon.balloon_alert(surgeon, "already busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	var/list/valid_targets = list()
	for (var/obj/item/bodypart/possible_target as anything in limbed_victim.bodyparts)
		if (possible_target.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		if (!(possible_target.body_zone in target_zones))
			continue
		valid_targets += possible_target

	if (!length(valid_targets))
		return

	INVOKE_ASYNC(src, PROC_REF(amputate), surgeon, victim, pick(valid_targets))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Chop one off
/datum/element/amputating_limbs/proc/amputate(mob/living/surgeon, mob/living/carbon/victim, obj/item/bodypart/to_remove)
	surgeon.visible_message(span_warning("[surgeon] begins [surgery_verb] [to_remove] off of [victim]!"))
	if (!do_after(surgeon, delay = surgery_time, target = victim))
		return
	to_remove.dismember()
