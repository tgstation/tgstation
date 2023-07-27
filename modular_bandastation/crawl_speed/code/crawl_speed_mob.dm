/mob/living/update_move_intent_slowdown()
	if(HAS_TRAIT(src, TRAIT_FORCE_WALK_SPEED))
		add_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/walk)
		return
	. = ..()

/mob/living/carbon/set_body_position(new_value)
	. = ..()
	if(isnull(.))
		return
	if(new_value == LYING_DOWN)
		AddComponent(/datum/component/crawl_speed)
