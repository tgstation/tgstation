/datum/component/organ_corruption/stomach
	corruptable_organ_type = /obj/item/organ/stomach
	corrupted_icon_state = "stomach"


/datum/component/organ_corruption/stomach/corrupt_organ(obj/item/organ/corruption_target)
	. = ..()

	if(!.)
		return

	RegisterSignal(corruption_target, COMSIG_STOMACH_AFTER_EAT, PROC_REF(on_stomach_after_eat))


/datum/component/organ_corruption/stomach/UnregisterFromParent()
	. = ..()

	UnregisterSignal(parent, COMSIG_STOMACH_AFTER_EAT)


/datum/component/organ_corruption/stomach/proc/on_stomach_after_eat(obj/item/organ/stomach/tummy, atom/edible)
	SIGNAL_HANDLER

	if(!istype(edible, /obj/item/food))
		return

	var/obj/item/food/eaten = edible

	if(BLOODY & eaten.foodtypes) // They're good if it's BLOODY food, they're less good if it isn't.
		return

	var/obj/item/organ/parent_organ = parent

	if(parent_organ.owner && HAS_TRAIT(parent_organ.owner, TRAIT_AGEUSIA)) // They don't taste anything, their body shouldn't react strongly to the taste of that stuff.
		return

	var/mob/living/carbon/body = parent_organ.owner
	ASSERT(istype(body))

	body.set_disgust(max(body.disgust, TUMOR_DISLIKED_FOOD_DISGUST))

	to_chat(body, span_warning("That tasted awful..."))

	// We don't lose nutrition because we don't even use nutrition as hemopahges. It WILL however purge nearly all of what's in their stomach.
	body.vomit(vomit_flags = HEMOPHAGE_VOMIT_FLAGS, lost_nutrition = 0, distance = 1, purge_ratio = HEMOPHAGE_VOMIT_PURGE_RATIO)
