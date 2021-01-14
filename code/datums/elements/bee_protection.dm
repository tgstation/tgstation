/**
 * Bee protection element, added to clothing that is THICKMATERIAL.
 */

/datum/element/bee_protection/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/clothing))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/on_change_of_clothes)

/* Signal handler for a mob equipping/dropping some bee protective clothing.
 *
 * Checks to see if the given mob has THICKMATERIAL suit clothing and head
 * clothing, grants TRAIT_BEE_FRIENDLY if so, removes it otherwise.
 */
/datum/element/bee_protection/proc/on_change_of_clothes(obj/item/clothing/clothing, mob/user)
	SIGNAL_HANDLER

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human = user

	REMOVE_TRAIT(human, TRAIT_BEE_FRIENDLY, ELEMENT_TRAIT)

	if(!istype(/obj/item/clothing, human.head) || !istype(/obj/item/clothing, human.wear_suit))
		return

	var/obj/item/clothing/hat = human.head
	var/obj/item/clothing/suit = human.wear_suit

	if(hat.clothing_flags & THICKMATERIAL && suit.clothing_flags & THICKMATERIAL)
		ADD_TRAIT(human, TRAIT_BEE_FRIENDLY, ELEMENT_TRAIT)
