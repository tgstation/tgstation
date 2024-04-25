/// Quietly implants people with battle royale implants
/obj/item/royale_implanter
	name = "royale implanter"
	desc = "Subtly implants people with rumble royale implants, \
		preparing them to struggle for their life for the enjoyment of the Syndicate's paying audience. \
		Implants may cause irritation at site of implantation."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "nanite_hypo"
	w_class = WEIGHT_CLASS_SMALL
	/// Do we have a linked remote? Just to prevent headdesk moments
	var/linked = FALSE

/obj/item/royale_implanter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		if (!istype(interacting_with, /obj/item/royale_remote))
			return NONE
		var/obj/item/royale_remote/remote = interacting_with
		remote.link_implanter(src, user)
		return ITEM_INTERACT_SUCCESS
	if (!linked)
		balloon_alert(user, "no linked remote!")
		return ITEM_INTERACT_BLOCKING
	if (DOING_INTERACTION_WITH_TARGET(user, interacting_with))
		balloon_alert(user, "busy!")
		return ITEM_INTERACT_BLOCKING
	var/mob/living/potential_winner = interacting_with
	if (potential_winner.stat != CONSCIOUS)
		balloon_alert(user, "target unconscious!")
		return ITEM_INTERACT_BLOCKING
	if (!potential_winner.mind)
		balloon_alert(user, "target too boring!")
		return ITEM_INTERACT_BLOCKING
	log_combat(user, potential_winner, "tried to implant a battle royale implant into")
	if (!do_after(user, 1.5 SECONDS, potential_winner))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/implant/explosive/battle_royale/encouragement_implant = new
	if(!encouragement_implant.implant(potential_winner, user))
		qdel(encouragement_implant) // no balloon alert - feedback is usually provided by the implant
		return ITEM_INTERACT_BLOCKING

	potential_winner.balloon_alert(user, "implanted")
	SEND_SIGNAL(src, COMSIG_ROYALE_IMPLANTED, encouragement_implant)
	return ITEM_INTERACT_SUCCESS

/// Activates implants implanted by linked royale implanter
/obj/item/royale_remote
	name = "royale remote"
	desc = "A single use device which will activate any linked rumble royale implants, starting the show."
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "designator_syndicate"
	w_class = WEIGHT_CLASS_SMALL
	/// Minimum number of contestants we should have
	var/required_contestants = 6
	/// List of implanters we are linked to
	var/list/linked_implanters = list()
	/// List of implants of lucky contestants
	var/list/implanted_implants = list()

/obj/item/royale_remote/Destroy(force)
	linked_implanters = null
	implanted_implants = null
	return ..()

/obj/item/royale_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!istype(interacting_with, /obj/item/royale_implanter))
		return NONE
	link_implanter(interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/royale_remote/attack_self(mob/user, modifiers)
	. = ..()
	if (.)
		return
	var/contestant_count = length(implanted_implants)
	if (contestant_count < required_contestants)
		balloon_alert(user, "[required_contestants - contestant_count] contestants needed!")
		return

	DSbattle_royale.start_battle(implanted_implants)

	for (var/obj/implanter as anything in linked_implanters)
		do_sparks(3, cardinal_only = FALSE, source = implanter)
		qdel(implanter)
	do_sparks(3, cardinal_only = FALSE, source = src)
	qdel(src)

/// Link to an implanter
/obj/item/royale_remote/proc/link_implanter(obj/item/royale_implanter/implanter, mob/user)
	if (implanter in linked_implanters)
		if (user)
			balloon_alert(user, "already linked!")
		return

	if (user)
		balloon_alert(user, "link established")

	implanter.linked = TRUE
	linked_implanters += implanter
	RegisterSignal(implanter, COMSIG_ROYALE_IMPLANTED, PROC_REF(record_contestant))
	RegisterSignal(implanter, COMSIG_QDELETING, PROC_REF(implanter_destroyed))

/// Record that someone just got implanted
/obj/item/royale_remote/proc/record_contestant(obj/item/implanter, obj/item/implant)
	SIGNAL_HANDLER
	implanted_implants |= implant
	RegisterSignal(implant, COMSIG_QDELETING, PROC_REF(implant_destroyed))

/// A linked implanter was destroyed
/obj/item/royale_remote/proc/implanter_destroyed(obj/item/implanter)
	SIGNAL_HANDLER
	linked_implanters -= implanter

/obj/item/royale_remote/proc/implant_destroyed(obj/item/implant)
	SIGNAL_HANDLER
	implanted_implants -= implant
