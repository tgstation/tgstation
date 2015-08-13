/obj/item/device/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2.0
	slot_flags = SLOT_BELT
	flags = NOBLUDGEON
	var/flush = null
	origin_tech = "programming=4;materials=4"


/obj/item/device/aicard/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src
	if(AI) //AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		add_logs(user, AI, "carded", src)
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	update_state() //Whatever happened, update the card's state (icon, name) to match.


/obj/item/device/aicard/proc/update_state()
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src //AI is inside.
	if(AI)
		name = "intelliCard - [AI.name]"
		if (AI.stat == DEAD)
			icon_state = "aicard-404"
		else
			icon_state = "aicard-full"
		AI.cancel_camera() //AI are forced to move when transferred, so do this whenver one is downloaded.
	else
		icon_state = "aicard"
		name = "intelliCard"
		overlays.Cut()

/obj/item/device/aicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Intellicard</B><BR>"
	var/laws
	for(var/mob/living/silicon/ai/A in src)
		dat += "Stored AI: [A.name]<br>System integrity: [(A.health+100)/2]%<br>"

		if (A.laws.zeroth)
			laws += "0: [A.laws.zeroth]<BR>"

		for (var/index = 1, index <= A.laws.ion.len, index++)
			var/law = A.laws.ion[index]
			if (length(law) > 0)
				var/num = ionnum()
				laws += "[num]. [law]<BR>"


		var/number = 1
		for (var/index = 1, index <= A.laws.inherent.len, index++)
			var/law = A.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= A.laws.supplied.len, index++)
			var/law = A.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (A.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			if (!src.flush)
				dat += {"<A href='byond://?src=\ref[src];choice=Wipe'>Wipe AI</A>"}
			else
				dat += "<b>Wipe in progress</b>"
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Wireless'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</a>"}
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Radio'>[A.radio_enabled ? "Disable" : "Enable"] Subspace Radio</a>"}
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Close'>Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return

/obj/item/device/aicard/Topic(href, href_list)
	var/mob/U = usr
	if (!in_range(src, U)||U.machine!=src)//If they are not in range of 1 or less or their machine is not the card (ie, clicked on something else).
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if ("Wipe")
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes")
				if(isnull(src)||!in_range(src, U)||U.machine!=src)
					U << browse(null, "window=aicard")
					U.unset_machine()
					return
				else
					flush = 1
					for(var/mob/living/silicon/ai/A in src)
						A.suiciding = 1
						A << "Your core files are being wiped!"
						while (A.stat != 2)
							A.adjustOxyLoss(2)
							A.updatehealth()
							sleep(10)
						flush = 0

		if ("Wireless")
			for(var/mob/living/silicon/ai/A in src)
				A.control_disabled = !A.control_disabled
				A << "The intellicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!"
				if (A.control_disabled)
					overlays -= image('icons/obj/aicards.dmi', "aicard-on")
				else
					overlays += image('icons/obj/aicards.dmi', "aicard-on")

		if ("Radio")
			for(var/mob/living/silicon/ai/A in src)
				A.radio_enabled = !A.radio_enabled
				A << "Your Subspace Transceiver has been [A.radio_enabled ? "enabled" : "disabled"]!"
	attack_self(U)
