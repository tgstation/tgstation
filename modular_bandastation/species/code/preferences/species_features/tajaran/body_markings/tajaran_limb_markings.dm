/datum/preference/choiced/species_feature/tajaran_limb_markings
	savefile_key = "feature_tajaran_limb_markings"
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Узор меха: конечности"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/tajaran_limb

/datum/preference/choiced/species_feature/tajaran_limb_markings/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_TAJARAN_LIMB_MARKINGS]

/datum/preference/choiced/species_feature/tajaran_limb_markings/icon_for(value)
	var/static/list/limb_types = list(
		/obj/item/bodypart/arm/left/tajaran,
		/obj/item/bodypart/arm/right/tajaran,
		/obj/item/bodypart/leg/left/digitigrade/tajaran,
		/obj/item/bodypart/leg/right/digitigrade/tajaran,
	)

	var/static/datum/universal_icon/body
	if(isnull(body))
		body = uni_icon('icons/blanks/32x32.dmi', "nothing")
		for(var/obj/item/bodypart/limb_type as anything in limb_types)
			body.blend_icon(
				uni_icon(\
					'icons/bandastation/mob/species/tajaran/bodyparts.dmi',\
					"[limb_type::limb_id]_[limb_type::body_zone]"\
				),
				ICON_OVERLAY
			)

			if(limb_type::aux_zone)
				body.blend_icon(
					uni_icon('icons/bandastation/mob/species/tajaran/bodyparts.dmi',
					"[limb_type::limb_id]_[limb_type::aux_zone]"),
					ICON_OVERLAY
				)

		body.blend_icon(
			uni_icon(\
				'icons/bandastation/mob/species/tajaran/bodyparts.dmi',\
				"[/obj/item/bodypart/chest/tajaran::limb_id]_[/obj/item/bodypart/chest/tajaran::body_zone]_m"\
			),
			ICON_OVERLAY
		)

		body.blend_color(COLOR_ASSISTANT_GRAY, ICON_MULTIPLY)

	var/datum/universal_icon/final_icon = body.copy()
	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/body_markings = get_accessory_for_value(value)
		for(var/obj/item/bodypart/limb_type as anything in limb_types)
			var/datum/universal_icon/body_marking_icon = uni_icon(body_markings.icon, "[body_markings.icon_state]_[limb_type::body_zone]")
			body_marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
			final_icon.blend_icon(body_marking_icon, ICON_OVERLAY)

	final_icon.crop(8, 1, 24, 22)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/species_feature/tajaran_limb_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAJARAN_LIMB_MARKINGS] = value

/datum/preference/choiced/species_feature/tajaran_limb_markings/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/tajaran_body_markings_color::savefile_key
	return data
