///A lizards spines (those things on their back), but also including tail spines (gasp)
/obj/item/organ/external/spines
	name = "lizard spines"
	desc = "Not an actual spine, obviously."
	icon_state = "spines"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_SPINES

	preference = "feature_lizard_spines"

	dna_block = DNA_SPINES_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/spines

	///A two-way reference between the tail and the spines because of wagging sprites. Bruh.
	var/obj/item/organ/external/tail/lizard/paired_tail

/obj/item/organ/external/spines/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(.)
		paired_tail = locate(/obj/item/organ/external/tail/lizard) in receiver.organs //We want specifically a lizard tail, so we don't use the slot.

/obj/item/organ/external/spines/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	if(paired_tail)
		paired_tail.paired_spines = null
		paired_tail = null

///Bodypart overlay for spines (wagging gets updated by tail)
/datum/bodypart_overlay/mutant/spines
	layers = EXTERNAL_ADJACENT|EXTERNAL_BEHIND
	feature_key = "spines"
	///Spines moth with the tail, so track it
	var/wagging = FALSE

/datum/bodypart_overlay/mutant/spines/get_global_feature_list()
	return GLOB.spines_list

/datum/bodypart_overlay/mutant/spines/get_base_icon_state()
	return (wagging ? "wagging" : "") + sprite_datum.icon_state //add the wagging tag if we be wagging

/datum/bodypart_overlay/mutant/spines/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE

