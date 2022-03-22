/// Simple datum that holds the basic information associated with an ID card trim.
/datum/id_trim
	/// Icon file for this trim.
	var/trim_icon = 'icons/obj/card.dmi'
	/// Icon state for this trim. Overlayed on advanced ID cards.
	var/trim_state
	/// Job/assignment associated with this trim. Can be transferred to ID cards holding this trim.
	var/assignment
	/// The name of the job for interns. If unset it will default to "[assignment] (Intern)".
	var/intern_alt_name = null
	/// The icon_state associated with this trim, as it will show on the security HUD.
	var/sechud_icon_state = SECHUD_UNKNOWN

	/// Accesses that this trim unlocks on a card it is imprinted on. These accesses never take wildcard slots and can be added and removed at will.
	var/list/access = list()
	/// Accesses that this trim unlocks on a card that require wildcard slots to apply. If a card cannot accept all a trim's wildcard accesses, the card is incompatible with the trim.
	var/list/wildcard_access = list()
