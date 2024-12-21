/datum/computer_file/program/maintenance/modsuit_control/tap(atom/tapped_atom, mob/living/user, params)
	. = ..()

	if(!ishuman(tapped_atom))
		return
	var/mob/living/carbon/human/john_modsuit = tapped_atom
	for(var/obj/item/mod/control/target_suit in john_modsuit.contents)
		if(!do_after(user, 5 SECONDS, john_modsuit))
			return
		var/response = tgui_alert(
			john_modsuit,
			"[user] is attempting to link their PDA to your MOD, [target_suit]. This gives them TOTAL control of your suit, do you let them?",
			"Connection Attempt",
			list(
				"Connect",
				"Refuse",
			),
		)
		if(response == "Connect")
			sync_modsuit(target_suit, user)
			playsound(target_suit, 'sound/effects/industrial_scan/industrial_scan2.ogg', 50, TRUE)
		else
			return
