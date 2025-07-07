	/* A couple of brain tumor stats for anyone curious / looking at this quirk for balancing:
	 * - It takes less 16 minute 40 seconds to die from brain death due to a brain tumor.
	 * - It takes 1 minutes 40 seconds to take 10% (20 organ damage) brain damage.
	 * - 5u mannitol will heal 12.5% (25 organ damage) brain damage
	 */
/datum/quirk/item_quirk/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Better bring some mannitol!"
	icon = FA_ICON_BRAIN
	value = -12
	gain_text = span_danger("You feel smooth.")
	lose_text = span_notice("You feel wrinkled again.")
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	hardcore_value = 12
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/storage/pill_bottle/mannitol/braintumor)
	no_process_traits = list(TRAIT_TUMOR_SUPPRESSED)

/datum/quirk/item_quirk/brainproblems/add_unique(client/client_source)
	give_item_to_holder(
		/obj/item/storage/pill_bottle/mannitol/braintumor,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		),
		flavour_text = "These will keep you alive until you can secure a supply of medication. Don't rely on them too much!",
		notify_player = TRUE,
	)

/datum/quirk/item_quirk/brainproblems/process(seconds_per_tick)
	quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * seconds_per_tick)
