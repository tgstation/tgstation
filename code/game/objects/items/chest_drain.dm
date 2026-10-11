/obj/item/chest_drain
	name = "chest drain"
	desc = "A medical device used to drain blood pooling around the lungs and heart."
	// icon = 'icons/obj/medical/firstaid.dmi'
	// icon_state = "chest_drain"
	// BEAKER STUFF BELOW - TEMPORARY
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "beaker"
	inhand_icon_state = "beaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	worn_icon_state = "beaker"
	// END BEAKER STUFF
	w_class = WEIGHT_CLASS_SMALL
	custom_premium_price = PAYCHECK_CREW * 2
	fill_icon_thresholds = /obj/item/reagent_containers/cup/beaker/large::fill_icon_thresholds
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/iron = SMALL_MATERIAL_AMOUNT)
	resistance_flags = ACID_PROOF

/obj/item/chest_drain/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return ..()
	var/mob/living/carbon/human/target = interacting_with
	if(!do_after(user, 3 SECONDS, target))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING


