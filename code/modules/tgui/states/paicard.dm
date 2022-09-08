/**
 * tgui state: paicard_state
 *
 * Checks that the paicard is in the user's top-level
 * (hand, ear, pocket, belt, etc) inventory OR
 *  if the paicard has been slotted into a PDA which
 * is also on the user's person.
 *
 */

GLOBAL_DATUM_INIT(paicard_state, /datum/ui_state/paicard_state, new)

/datum/ui_state/paicard_state/can_use_topic(obj/item/paicard/paicard, mob/user)
	/// paicard is in the user's closest inventory
	if(!paicard.slotted && (paicard in user))
		return user.shared_ui_interaction(paicard)
	/// paicard is in a pda slot which is in the user's closest inventory
	if(paicard.slotted && (paicard.loc in user))
		return user.shared_ui_interaction(paicard)
	return UI_CLOSE
