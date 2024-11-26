/// This component will intercept bare-handed attacks by the owner on sufficiently injured carbons and amputate random limbs instead
/datum/component/amputating_limbs
	/// How long does it take?
	var/surgery_time
	/// What is the means by which we describe the act of amputation?
	var/surgery_verb
	/// How awake must our target be?
	var/minimum_stat
	/// How likely are we to perform this action?
	var/snip_chance
	/// The types of limb we can remove
	var/list/target_zones
	/// Callback for a proc right before confirming the attack. If it returns FALSE, cancel
	var/datum/callback/pre_hit_callback

/datum/component/amputating_limbs/Initialize(
	surgery_time = 5 SECONDS,
	surgery_verb = "prying",
	minimum_stat = SOFT_CRIT,
	snip_chance = 100,
	list/target_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG),
	datum/callback/pre_hit_callback,
)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if (!length(target_zones))
		CRASH("[src] for [parent] was not provided a valid list of body zones to target.")

	src.surgery_time = surgery_time
	src.surgery_verb = surgery_verb
	src.minimum_stat = minimum_stat
	src.snip_chance = snip_chance
	src.target_zones = target_zones
	src.pre_hit_callback = pre_hit_callback

/datum/component/amputating_limbs/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET), PROC_REF(try_amputate))

/datum/component/amputating_limbs/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))

/// Called when you click on literally anything with your hands, see if it is an injured carbon and then try to cut it up
/datum/component/amputating_limbs/proc/try_amputate(mob/living/surgeon, atom/victim, proximity, modifiers)
	SIGNAL_HANDLER
	if (!proximity || !iscarbon(victim) || HAS_TRAIT(victim, TRAIT_NODISMEMBER) || !prob(snip_chance))
		return

	var/mob/living/carbon/limbed_victim = victim
	if (limbed_victim.stat < minimum_stat)
		return

	if (DOING_INTERACTION_WITH_TARGET(surgeon, victim))
		surgeon.balloon_alert(surgeon, "already busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(pre_hit_callback && !pre_hit_callback.Invoke(victim))
		return

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
/datum/component/amputating_limbs/proc/amputate(mob/living/surgeon, mob/living/carbon/victim, obj/item/bodypart/to_remove)
	if(surgery_time > 0 SECONDS)
		surgeon.visible_message(span_warning("[surgeon] is [surgery_verb] the [to_remove] off of [victim]!"))
	if (surgery_time > 0 && !do_after(surgeon, delay = surgery_time, target = victim))
		return
	to_remove.dismember()
