/obj/structure/sign/eyechart
	icon_state = "eyechart"
	name = "eye chart"
	desc = "A poster with a series of colored bars and letters of different sizes, \
		used to test color vision and blindness - I mean, visual acuity."
	is_editable = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/eyechart, 32)

/obj/structure/sign/eyechart/examine(mob/user)
	. = ..()
	if(isobserver(user))
		return

	if(!user.can_read(src, READING_CHECK_LITERACY, silent = TRUE) || !user.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE))
		if(!user.is_blind())
			. += "<hr>You gaze at the wall of symbols, trying to make sense of them..."
			. += span_warning("...But you don't actually know what any of them mean.")
		return

	if(user.is_blind())
		. += "<hr>You feel the poster."
		. += span_notice("Yes, feels like... \"E, P, D...\" Good thing this chart has braille!")
		return

	if(!user.can_read(src, READING_CHECK_LIGHT, silent = TRUE))
		. += "<hr>You squint at the chart."
		. += span_warning("...But it's too dark to make out anything.")
		return

	var/colorblind = FALSE
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		colorblind = !!carbon_user.has_trauma_type(/datum/brain_trauma/mild/color_blindness)
	else if(isdog(user) || iscat(user))
		colorblind = TRUE // i know these pets are not colorblind in the conventional sense, but it's an easter egg, ok?

	var/obj/item/organ/eyes/eye = user.get_organ_slot(ORGAN_SLOT_EYES)
	// eye null checks here are for mobs without eyes.
	// humans missing eyes will be caught by the is_blind check above.
	var/eye_goodness = isnull(eye) ? 0 : eye.damage
	var/little_bad = isnull(eye) ? 20 : eye.low_threshold
	var/very_bad = isnull(eye) ? 30 : eye.high_threshold

	if(user.has_status_effect(/datum/status_effect/eye_blur))
		eye_goodness = max(eye_goodness, very_bad + 1)
	if(user.is_nearsighted_currently())
		eye_goodness = max(eye_goodness, little_bad + 1)
	eye_goodness += ((get_dist(user, src) - 2) * 5) // add a modifier based on distance, so closer = "better", further = "worse"

	. += "<hr>You read through the chart, for old time's sake."
	if(eye_goodness <= 0)
		. += span_notice("\"E, F, P...\" Yep, you can read down to the [colorblind ? "brown - wait, isn't it supposed to be red? -" : "red"] line.")
	else if(eye_goodness < little_bad)
		. += span_notice("\"E, F, P...\" You can make out most of the letters, but it gets a bit difficult past the [colorblind ? "grey - wait, isn't it supposed to be green? -" : "green"] line.")
	else if(eye_goodness < very_bad)
		. += span_warning("\"E, F, P..?\" You can make out the big letters, but the smaller ones are a bit of a blur.")
	else
		. += span_warning("\"E, P, D..?\" You can hardly make out the big letters, let alone the smaller ones.")
