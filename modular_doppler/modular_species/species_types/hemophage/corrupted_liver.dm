/// The minimum ratio of reagents that need to have the `REAGENT_BLOOD_REGENERATING` chemical_flags for the Hemophage not to violently vomit upon consumption.
#define MINIMUM_BLOOD_REGENING_REAGENT_RATIO 0.75

/datum/component/organ_corruption/liver
	corruptable_organ_type = /obj/item/organ/liver
	corrupted_icon_state = "liver"


/datum/component/organ_corruption/liver/register_signals_on_organ_owner(obj/item/organ/implanted_organ, mob/living/carbon/receiver)
	if(!..())
		return

	RegisterSignal(receiver, COMSIG_GLASS_DRANK, PROC_REF(handle_drink))


/datum/component/organ_corruption/liver/unregister_signals_from_organ_loser(obj/item/organ/target, mob/living/carbon/loser)
	if(!..())
		return

	UnregisterSignal(loser, COMSIG_GLASS_DRANK)


/datum/component/organ_corruption/liver/UnregisterFromParent()
	. = ..()

	var/obj/item/organ/liver/parent_liver = parent

	if(parent_liver.owner)
		UnregisterSignal(parent_liver.owner, COMSIG_GLASS_DRANK)


/**
 * Handles reacting to drinks based on their content, to see if the tumor likes what's in it or not.
 */
/datum/component/organ_corruption/liver/proc/handle_drink(mob/living/target_mob, obj/item/reagent_containers/cup/container, mob/living/user)
	SIGNAL_HANDLER

	if(HAS_TRAIT(target_mob, TRAIT_AGEUSIA)) // They don't taste anything, their body shouldn't react strongly to the taste of that stuff.
		return

	if(container.reagents.has_chemical_flag_doppler(REAGENT_BLOOD_REGENERATING, container.reagents.total_volume * MINIMUM_BLOOD_REGENING_REAGENT_RATIO)) // At least 75% of the content of the cup needs to be something that's counting as blood-regenerating for the tumor not to freak out.
		return

	var/mob/living/carbon/body = target_mob
	ASSERT(istype(body))

	body.set_disgust(max(body.disgust, TUMOR_DISLIKED_FOOD_DISGUST))

	to_chat(body, span_warning("That tasted awful..."))

	// We don't lose nutrition because we don't even use nutrition as Hemopahges. It WILL however purge nearly all of what's in their stomach.
	body.vomit(vomit_flags = HEMOPHAGE_VOMIT_FLAGS, lost_nutrition = 0, distance = 1, purge_ratio = HEMOPHAGE_VOMIT_PURGE_RATIO)


#undef MINIMUM_BLOOD_REGENING_REAGENT_RATIO
