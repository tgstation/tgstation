/mob/living/carbon/has_mouth()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(head && head.mouth)
		return TRUE
