GLOBAL_LIST_INIT(possible_quirk_atypical_tastes, list(
	"Lizardperson" = /obj/item/organ/tongue/lizard,
	"Feline" = /obj/item/organ/tongue/cat,
	"Mothman" = /obj/item/organ/tongue/moth,
	"Snail" = /obj/item/organ/tongue/snail,
	"Hemophage" = /obj/item/organ/tongue/hemophage,
	"Ramatan" = /obj/item/organ/tongue/ramatan,
))

/datum/quirk/atypical_tastes
	name = "Atypical Tastes"
	desc = "For one reason or another, your tastes in food are similar to that of another species."
	value = 0
	mob_trait = TRAIT_ATYPICAL_TASTER
	icon = FA_ICON_PLATE_WHEAT

/datum/quirk_constant_data/atypical_taster
	associated_typepath = /datum/quirk/atypical_tastes
	customization_options = list(/datum/preference/choiced/atypical_tastes)

/datum/quirk/atypical_tastes/add_unique(client/client_source)
	var/obj/item/organ/tongue/desired_taste_copier = GLOB.possible_quirk_atypical_tastes[client_source?.prefs?.read_preference(/datum/preference/choiced/atypical_tastes)]
	if(isnull(desired_taste_copier)) // I mean I'm not going to stop you from randomizing your tastes every round. Go ahead.
		desired_taste_copier = GLOB.possible_quirk_atypical_tastes[pick(GLOB.possible_quirk_atypical_tastes)]

	var/mob/living/carbon/human/human_holder = quirk_holder
	if(human_holder.dna.species.type in GLOB.species_blacklist_no_humanoid)
		to_chat(human_holder, span_warning("Due to your species type, the [name] quirk has been disabled."))
		return

	var/obj/item/organ/tongue/holder_tongue = human_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!holder_tongue)
		to_chat(human_holder, span_warning("As you seem to lack a tongue and thus ability to taste food, the [name] quirk has been disabled."))
		return

	holder_tongue.liked_foodtypes = desired_taste_copier.liked_foodtypes
	holder_tongue.disliked_foodtypes = desired_taste_copier.disliked_foodtypes
	holder_tongue.toxic_foodtypes = desired_taste_copier.toxic_foodtypes
	holder_tongue.sense_of_taste = desired_taste_copier.sense_of_taste
	medical_record_text = "Patient exhibits atypical mutation in taste receptors."
