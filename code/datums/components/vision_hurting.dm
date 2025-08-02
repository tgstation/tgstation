/// A component that damages eyes that look at the owner
/datum/component/vision_hurting
	var/damage_per_second
	var/message
	/// Do people looking at us make a fuss?
	var/silent

/datum/component/vision_hurting/Initialize(damage_per_second=1, message="Your eyes burn as you look at", silent = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.damage_per_second = damage_per_second
	src.message = message
	src.silent = silent

	START_PROCESSING(SSdcs, src)

/datum/component/vision_hurting/process(seconds_per_tick)
	for(var/mob/living/carbon/viewer in viewers(parent))
		if(viewer.is_blind() || viewer.get_eye_protection() >= damage_per_second)
			continue
		var/obj/item/organ/eyes/burning_orbs = locate() in viewer.organs
		if(!burning_orbs)
			continue
		burning_orbs.apply_organ_damage(damage_per_second * seconds_per_tick)
		if(silent)
			return
		if(SPT_PROB(50, seconds_per_tick))
			to_chat(viewer, span_userdanger("[message] [parent]!"))
		if(SPT_PROB(20, seconds_per_tick))
			viewer.emote("scream")
