/// A component that damages eyes that look at the owner
/datum/component/vision_hurting
	var/damage_per_second
	var/message

/datum/component/vision_hurting/Initialize(damage_per_second=1, message="Your eyes burn as you look at")
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.damage_per_second = damage_per_second
	src.message = message

	START_PROCESSING(SSdcs, src)

/datum/component/vision_hurting/process(seconds_per_tick)
	var/damage = damage_per_second * seconds_per_tick
	for(var/mob/living/carbon/viewer in viewers(parent))
		if(viewer.is_blind() || viewer.get_eye_protection() >= damage_per_second)
			continue
		var/obj/item/organ/internal/eyes/burning_orbs = locate() in viewer.organs
		if(!burning_orbs)
			continue
		burning_orbs.apply_organ_damage(damage)
		if(prob(max(5, 100 - (50 / seconds_per_tick)))) // Roughly 50% chance per second
			to_chat(viewer, span_userdanger("[message] [parent]!"))
		if(prob(max(5, 100 - (80 / seconds_per_tick)))) // Roughly 20% chance per second
			viewer.emote("scream")
