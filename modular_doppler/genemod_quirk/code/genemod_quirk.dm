/datum/quirk/genemodded
	name = "Genemodded"
	desc = "Some aspect of your physiology has been modified from your race's ordinary baseline, granting you a mutation of your choice."
	gain_text = span_notice("Your body feels unusual...")
	lose_text = span_notice("Normality returns in a flash.")
	medical_record_text = "Subject has innately modified genetic information."
	value = 10
	icon = FA_ICON_FLASK
	var/datum/mutation/human/added_mutation = NONE

/datum/quirk/genemodded/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/desired_mutation = client_source?.prefs.read_preference(/datum/preference/choiced/genemodded_dna)

	if (desired_mutation)
		added_mutation = GLOB.possible_genemods_for_quirk[desired_mutation]
		if (!human_holder.dna.activate_mutation(added_mutation))
			human_holder.dna.add_mutation(added_mutation, MUT_EXTRA)

/datum/quirk/genemodded/remove()
	if (added_mutation)
		var/mob/living/carbon/human/human_holder = quirk_holder
		human_holder.dna.remove_mutation(added_mutation)
		added_mutation = null

/datum/quirk_constant_data/genemodded
	associated_typepath = /datum/quirk/genemodded
	customization_options = list(/datum/preference/choiced/genemodded_dna)

/datum/preference/choiced/genemodded_dna
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "genemodded_dna"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/proc/generate_genemod_quirk_list()
	var/list/stuff_we_dont_want = list(/datum/mutation/human/self_amputation, /datum/mutation/human/hulk, /datum/mutation/human/clever, /datum/mutation/human/blind, /datum/mutation/human/thermal, /datum/mutation/human/telepathy, /datum/mutation/human/void, /datum/mutation/human/badblink, /datum/mutation/human/acidflesh)

	var/list/genemods = list()
	for (var/datum/mutation/human/mut as anything in subtypesof(/datum/mutation/human))
		if (!mut.locked && !(mut in stuff_we_dont_want))
			genemods[mut.name] = mut

	return genemods

GLOBAL_LIST_INIT(possible_genemods_for_quirk, generate_genemod_quirk_list())

/datum/preference/choiced/genemodded_dna/init_possible_values()
	return assoc_to_keys(GLOB.possible_genemods_for_quirk)

/datum/preference/choiced/genemodded_dna/create_default_value()
	return pick(assoc_to_keys(GLOB.possible_genemods_for_quirk))

/datum/preference/choiced/genemodded_dna/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Genemodded" in preferences.all_quirks

/datum/preference/choiced/genemodded_dna/apply_to_human(mob/living/carbon/human/target, value)
	return

