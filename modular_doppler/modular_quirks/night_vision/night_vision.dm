/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	icon = FA_ICON_MOON
	value = 4
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = span_notice("The shadows seem a little less dark.")
	lose_text = span_danger("Everything seems a little darker.")
	medical_record_text = "Patient's eyes show above-average acclimation to darkness."
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/night_vision/add(client/client_source)
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/remove()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/proc/refresh_quirk_holder_eyes()
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/eyes/eyes = human_quirk_holder.get_organ_by_type(/obj/item/organ/eyes)
	if(!eyes)
		return
	// We've either added or removed TRAIT_NIGHT_VISION before calling this proc. Just refresh the eyes.
	eyes.refresh()

// This NV quirk variant applies color_offsets night vision to a mob based on its chosen eye color.
// Some eye colors will produce very slightly stronger mechanical night vision effects just by virtue of their RGB values being scaled higher (typically lighter colours).

/datum/quirk/night_vision
	desc = "You can see a little better in darkness than most ordinary humanoids. If your eyes are naturally more sensitive to light through other means (such as being photophobic or a mothperson), this effect is significantly stronger."
	medical_record_text = "Patient's visual sensory organs demonstrate non-standard performance in low-light conditions."
	var/nv_color = null /// Holds the player's selected night vision colour
	var/list/nv_color_cutoffs = null /// Contains the color_cutoffs applied to the user's eyes w/ our custom hue (once built)

/datum/quirk/night_vision/add_unique(client/client_source)
	. = ..()
	nv_color = client_source?.prefs.read_preference(/datum/preference/color/nv_color)
	if (isnull(nv_color))
		var/mob/living/carbon/human/human_holder = quirk_holder
		nv_color = process_chat_color(human_holder.eye_color_left)
	nv_color_cutoffs = calculate_color_cutoffs(nv_color)
	refresh_quirk_holder_eyes() // make double triple dog sure we apply the overlay

/// Calculate eye organ color_cutoffs used in tinted night vision with a supplied hexcode colour, clamping and scaling appropriately.
/datum/quirk/night_vision/proc/calculate_color_cutoffs(color)
	var/mob/living/carbon/human/target = quirk_holder

	// if we have more sensitive eyes, increase the power
	var/obj/item/organ/eyes/target_eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	if (!istype(target_eyes))
		return
	var/infravision_multiplier = max(0, (-(target_eyes.flash_protect) * DOPPLER_NIGHT_VISION_SENSITIVITY_MULT)) + 1

	var/list/new_rgb_cutoffs = new /list(3)
	for(var/i in 1 to 3)
		var/base_color = hex2num(copytext(color, (i*2), (i*2)+2)) //convert their supplied hex colour value to RGB
		var/adjusted_color = max(((base_color / 255) * (DOPPLER_NIGHT_VISION_POWER_MAX * infravision_multiplier)), (DOPPLER_NIGHT_VISION_POWER_MIN * infravision_multiplier)) //linear convert their eye color into a color_cutoff range, ensuring it is clamped
		new_rgb_cutoffs[i] = adjusted_color

	return new_rgb_cutoffs

/datum/quirk_constant_data/night_vision
	associated_typepath = /datum/quirk/night_vision
	customization_options = list(/datum/preference/color/nv_color)

// Client preference for night vision colour
/datum/preference/color/nv_color
	savefile_key = "nv_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED

/datum/preference/color/nv_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Night Vision" in preferences.all_quirks

/datum/preference/color/nv_color/apply_to_human(mob/living/carbon/human/target, value)
	return

// run the Blessed Runechat Proc since it does most of what we want regarding luminance clamping anyway. could it be better? probably. is it more work? yes, it's a LOT of work.
/datum/preference/color/nv_color/deserialize(input, datum/preferences/preferences)
	return process_chat_color(sanitize_hexcolor(input))

/datum/preference/color/nv_color/serialize(input)
	return process_chat_color(sanitize_hexcolor(input))

/datum/preference/color/nv_color/create_default_value()
	return process_chat_color("#[random_color()]")

/datum/quirk/photophobia
	desc = "Bright lights are uncomfortable and upsetting to you for whatever reason. Your eyes are also more sensitive to light in general. This shares a unique interaction with Night Vision."
	/// how much of a flash_protect deficit the quirk inflicts
	var/severity = 1

/datum/quirk/photophobia/add_unique(client/client_source)
	var/sensitivity = client_source?.prefs.read_preference(/datum/preference/choiced/photophobia_severity)
	switch (sensitivity)
		if ("Hypersensitive")
			severity = 2
		if ("Sensitive")
			severity = 1
	var/obj/item/organ/eyes/holder_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	restore_eyes(holder_eyes) // add_unique() happens after add() so we need to jank reset this to ensure sensitivity is properly applied at roundstart
	check_eyes(holder_eyes)

/datum/quirk_constant_data/photophobia
	associated_typepath = /datum/quirk/photophobia
	customization_options = list(/datum/preference/choiced/photophobia_severity)

/datum/preference/choiced/photophobia_severity
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "photophobia_severity"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/photophobia_severity/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Photophobia" in preferences.all_quirks

/datum/preference/choiced/photophobia_severity/init_possible_values()
	var/list/values = list("Sensitive", "Hypersensitive")
	return values

/datum/preference/choiced/photophobia_severity/apply_to_human(mob/living/carbon/human/target, value)
	return
