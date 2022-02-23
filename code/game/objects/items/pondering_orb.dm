/obj/item/pondering_orb
	name = "Pondering Orb"
	icon = 'icons/obj/pondering_orb.dmi'
	icon_state = "orb_of_ponders"
	desc = "Born to ponder."

/obj/item/pondering_orb/attack_hand(mob/user, list/modifiers)
	balloon_alert(user, "You start pondering the orb...")
	balloon_alert_to_viewers("[user.name] starts to ponder the orb...")
	if(do_after(user, 1 MINUTES, src))
		balloon_alert(
			user,
			pick(list(
				"born to ponder",
				"pondered",
				"ponder complete",
				"it does not ponder",
				"out of ponders",
				"yes",
				"no",
				"maybe",
				"keep pondering",
				"ready once more"
			))
		)
		balloon_alert_to_viewers("[user.name] ponders about pondering the ponder orb")
