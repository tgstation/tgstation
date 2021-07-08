// These will be shown in the sidebar, but at the bottom.
#define PREFERENCE_CATEGORY_FEATURES "features"

/datum/preference/choiced/moth_wings
	savefile_key = "feature_moth_wings"
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE

/datum/preference/choiced/moth_wings/init_possible_values()
	return possible_values_for_sprite_accessory_list(GLOB.moth_wings_list)

/datum/preference/choiced/moth_wings/apply(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value

#undef PREFERENCE_CATEGORY_FEATURES
