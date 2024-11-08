// To speed up the preference menu, we apply 1 filter to the entire mob
/mob/living/carbon/human/dummy/regenerate_icons()
	. = ..()
	apply_height_filters(src, TRUE)

/mob/living/carbon/human/dummy/apply_height_filters(mutable_appearance/appearance, only_apply_in_prefs = FALSE)
	if(only_apply_in_prefs)
		return ..()

// Not necessary with above
/mob/living/carbon/human/dummy/apply_height_offsets(mutable_appearance/appearance, upper_torso)
	return
