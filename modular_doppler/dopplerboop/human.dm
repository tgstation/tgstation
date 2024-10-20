/mob/living/carbon/human
	var/voice_type

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dopplerboop)
