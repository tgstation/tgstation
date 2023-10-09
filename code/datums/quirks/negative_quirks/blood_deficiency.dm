/datum/quirk/item_quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	icon = FA_ICON_TINT
	value = -8
	mob_trait = TRAIT_BLOOD_DEFICIENCY
	gain_text = span_danger("You feel your vigor slowly fading away.")
	lose_text = span_notice("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	hardcore_value = 8
	mail_goodies = list(/obj/item/reagent_containers/blood/o_minus) // universal blood type that is safe for all

/datum/quirk/item_quirk/blooddeficiency/post_add()
	if(!ishuman(quirk_holder))
		return

	// for making sure the roundstart species has the right blood pack sent to them
	var/mob/living/carbon/human/carbon_target = quirk_holder
	carbon_target.dna.species.update_quirk_mail_goodies(carbon_target, src)

/datum/quirk/item_quirk/blooddeficiency/add_unique(client/client_source)
	give_item_to_holder(
		/obj/item/storage/pill_bottle/iron,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = "You made sure to bring some iron pills with you to combat your blood problem.",
	)

/**
 * Makes the mob lose blood from having the blood deficiency quirk, if possible
 *
 * Arguments:
 * * seconds_per_tick
 */
/datum/quirk/item_quirk/blooddeficiency/proc/lose_blood(seconds_per_tick)
	if(quirk_holder.stat == DEAD)
		return

	var/mob/living/carbon/human/carbon_target = quirk_holder
	if(HAS_TRAIT(carbon_target, TRAIT_NOBLOOD) && isnull(carbon_target.dna.species.exotic_blood)) //can't lose blood if your species doesn't have any
		return

	if (carbon_target.blood_volume <= 0)
		return

	// drain da blood
	carbon_target.blood_volume = max(0, carbon_target.blood_volume - carbon_target.dna.species.blood_deficiency_drain_rate * seconds_per_tick)
