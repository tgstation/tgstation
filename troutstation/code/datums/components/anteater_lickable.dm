/// Add this to food items that should react differently to anteaters trying to lick them.
/// This hooks into the edible component (or rather it hooks into this), so adding this to random non-food items won't work for now.
/datum/component/anteater_lickable
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/result_item_type

/datum/component/anteater_lickable/Initialize(
	result_item_type,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.result_item_type = result_item_type

/datum/component/anteater_lickable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(OnExamine))

/datum/component/anteater_lickable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE))

/datum/component/anteater_lickable/proc/OnExamine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(HAS_TRAIT(user, TRAIT_TINY_SNOUT))
		examine_list += span_notice("It won't fit in your snout, but those ants...")
	else
		var/obj/item/organ/liver/liver = user.get_organ_slot(ORGAN_SLOT_LIVER)
		if(liver && HAS_TRAIT(liver, TRAIT_CULINARY_METABOLISM)) // goddamn liver traits
			examine_list += span_notice("Anteaters won't be able to eat <i>all</i> of this, but...")

/datum/component/anteater_lickable/proc/lick(mob/living/carbon/human/anteater)
	var/atom/food = parent

	anteater.visible_message("[anteater] licks all the ants off of [food].",
		"You lick all the ants off of [food].")
	var/num_ants = food.reagents.get_reagent_amount(/datum/reagent/ants)
	food.reagents.trans_to(anteater, amount = num_ants, target_id = /datum/reagent/ants, methods = INGEST, show_message = FALSE)

	// put the new food item in active hand or drop it if we can't
	var/atom/new_food = new result_item_type(food.drop_location())
	qdel(food)
	if(anteater.can_put_in_hand(new_food, anteater.active_hand_index))
		anteater.put_in_hands(new_food)




