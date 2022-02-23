/obj/item/pondering_orb
	name = "Pondering Orb"
	icon = 'icons/obj/pondering_orb.dmi'
	icon_state = "orb_of_ponders"
	desc = "Born to ponder."

/obj/item/pondering_orb/attack_hand(mob/user, list/modifiers)
	balloon_alert(user, "You start pondering the orb...")
	if(do_after(user, 1 MINUTES, src))
		balloon_alert(
			user,
			pick(list(
				"Born to ponder.",
				"Pondered.",
				"Ponder complete.",
				"It does not ponder.",
				"Out of ponders.",
				"Yes.",
				"No.",
				"Maybe.",
				"Keep pondering.",
				"Ready once more."
			))
		)
