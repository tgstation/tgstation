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

// Allows a drone to turn their hat into a mask
// This action's existence is very silly can be replaced with just, a hat with a chameleon action that can be both hats and masks.
/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_camogear_helm"

/datum/action/item_action/chameleon/drone/togglehatmask/New(Target)
	if (istype(Target, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(Target, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"
	return ..()

/datum/action/item_action/chameleon/drone/togglehatmask/IsAvailable(feedback)
	return ..() && isdrone(owner)

/datum/action/item_action/chameleon/drone/togglehatmask/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return FALSE

	var/mob/living/simple_animal/drone/droney = owner

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone(droney)
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone(droney)
	else
		to_chat(owner, span_warning("You shouldn't be able to toggle a camogear helmetmask if you're not wearing it."))
		return FALSE
	droney.dropItemToGround(target, force = TRUE)
	droney.equip_to_slot_or_del(new_headgear, ITEM_SLOT_HEAD)
	return TRUE
