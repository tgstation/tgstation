	/* A couple of brain tumor stats for anyone curious / looking at this quirk for balancing:
	 * - It takes less 16 minute 40 seconds to die from brain death due to a brain tumor.
	 * - It takes 1 minutes 40 seconds to take 10% (20 organ damage) brain damage.
	 * - 5u mannitol will heal 12.5% (25 organ damage) brain damage
	 */
/datum/quirk/item_quirk/brainproblems
	name = "Brain Tumor"
	desc = "У вас в мозгу есть маленький друг, который медленно разрушает его. Лучше взять с собой немного маннитола!"
	icon = FA_ICON_BRAIN
	value = -12
	gain_text = span_danger("Вы ощущаете тяжесть мышления.")
	lose_text = span_notice("Вы снова здраво мыслите.")
	medical_record_text = "У пациента опухоль в мозгу, которая медленно ведет его к смерти."
	hardcore_value = 12
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/storage/pill_bottle/mannitol/braintumor)
	no_process_traits = list(TRAIT_TUMOR_SUPPRESSED)
	/// Speed at which our brain will get damaged, per second
	var/degradation_speed = 0.2
	/// Type of item we get in our pocket to help with the quirk after joining
	var/obj/item/medicine_to_get = /obj/item/storage/pill_bottle/mannitol/braintumor

/datum/quirk/item_quirk/brainproblems/add_unique(client/client_source)
	give_item_to_holder(
		medicine_to_get,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		),
		flavour_text = "Они помогут вам выжить, пока вы не получите запас лекарств. Не полагайтесь на них слишком сильно!",
		notify_player = TRUE,
	)

/datum/quirk/item_quirk/brainproblems/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/dullahan))
		return FALSE
	return ..()

/datum/quirk/item_quirk/brainproblems/process(seconds_per_tick)
	quirk_holder.adjust_organ_loss(ORGAN_SLOT_BRAIN, degradation_speed * seconds_per_tick)
