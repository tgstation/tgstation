/datum/quirk/feline_aspect
	name = "Feline Traits"
	desc = "You happen to act like a feline, for whatever reason. This will replace most other tongue-based speech quirks."
	gain_text = span_notice("Nya could go for some catnip right about now...")
	lose_text = span_notice("You feel less attracted to lasers.")
	medical_record_text = "Patient seems to possess behavior much like a feline."
	mob_trait = TRAIT_FELINE
	icon = FA_ICON_CAT

/datum/quirk/feline_aspect/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/internal/tongue/cat/new_tongue = new(get_turf(human_holder))

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/feline_aspect/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/internal/tongue/new_tongue = new human_holder.dna.species.mutanttongue

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE))
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)
