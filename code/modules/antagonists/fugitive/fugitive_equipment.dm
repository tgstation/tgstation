/datum/action/item_action/camouflage
	name = "Activate Camouflage"
	desc = "Activate your camouflage suit, and blend into your surroundings..."
	button_icon_state = "alien_sneak"
	/// The alpha we move to when activating this action.
	var/camouflage_alpha = 75
	/// Are we currently cloaking ourself?
	var/cloaking = FALSE

/datum/action/item_action/camouflage/Remove(mob/living/remove_from)
	remove_cloaking()

	return ..()

/datum/action/item_action/camouflage/Trigger(trigger_flags)
	. = ..()

	if(cloaking)
		remove_cloaking()
	else
		owner.alpha = camouflage_alpha
		to_chat(owner, span_notice("You activate the [name] and blend into your surroundings..."))
		cloaking = TRUE

	return TRUE

/**
 * Returns the owner's alpha value to its initial value,
 *
 * Disables cloaking and flashes sparks. Used when toggling the ability, as well as to
 * make sure the action properly resets its owner when removed.
 */

/datum/action/item_action/camouflage/proc/remove_cloaking()
	do_sparks(2, FALSE, owner)
	owner.alpha = initial(owner.alpha)
	to_chat(owner, span_notice("You disable the [name], and become visible once again."))
	cloaking = FALSE

/obj/item/clothing/under/camouflage_suit
	name = "experimental camouflage suit"
	desc = "A fancy-looking camouflage undersuit. It can be activated to make the wearer blend in with their surroundings."
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "abductor"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	actions_types = list(/datum/action/item_action/camouflage)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/under/camouflage_suit/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/clothing/under/camouflage_suit/dropped(mob/user)
	. = ..()

/obj/item/clothing/under/camouflage_suit/emp_act(severity)
	. = ..()

	if(prob(15 * severity))
		visible_message(span_warning("The cloaking systems on the [name] begin to overload."), blind_message = audible_message("You hear a fizzle, and the snapping of sparks."))
		do_sparks(2, FALSE, src)
		burn()

/obj/item/reagent_containers/hypospray/medipen/invisibility
	name = "invisibility autoinjector"
	desc = "An autoinjector containing a stabilized SaturnX compound. Produced for use in tactical stealth operations, by operatives were presumably comfortable with nudity."
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list(/datum/reagent/drug/saturnx = 20)
	label_examine = FALSE
