/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return FALSE

	for(var/datum/action/item_action/chameleon/change/to_randomize in owner.actions)
		to_randomize.random_look()
	return TRUE

/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New()
	. = ..()

	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return

	// No point making the code more complicated if no non-drone
	// is ever going to use one of these

	var/mob/living/simple_animal/drone/D

	if(isdrone(owner))
		D = owner
	else
		return

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone()
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone()
	else
		to_chat(owner, span_warning("You shouldn't be able to toggle a camogear helmetmask if you're not wearing it."))
	if(new_headgear)
		// Force drop the item in the headslot, even though
		// it's has TRAIT_NODROP
		D.dropItemToGround(target, TRUE)
		qdel(old_headgear)
		// where is `ITEM_SLOT_HEAD` defined? WHO KNOWS
		D.equip_to_slot(new_headgear, ITEM_SLOT_HEAD)
	return 1
