/obj/item/device/aicard
	name = "inteliCard"
	icon = 'pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | ONBELT
	var/flush = null
	origin_tech = "programming=4"


	attack(mob/living/silicon/ai/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/silicon/ai))//If target is not an AI.
			return ..()

		M.attack_log += text("<font color='orange'>[world.time] - has been carded with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("<font color='red'>[world.time] - has used the [src.name] to card [M.name] ([M.ckey])</font>")

		transfer_ai("AICORE", "AICARD", M, user)
		return

	attack(mob/living/silicon/decoy/M as mob, mob/user as mob)
		if (!istype (M, /mob/living/silicon/decoy))
			return ..()
		else
			M.death()
			user << "<b>ERROR ERROR ERROR</b>"

	attack_self(mob/user)
		if (!in_range(src, user))
			return
		user.machine = src
		var/dat = "<TT><B>Intelicard</B><BR>"
		var/laws
		for(var/mob/living/silicon/ai/A in src)
			dat += "Stored AI: [A.name]<br>System integrity: [(A.health+100)/2]%<br>"

			for (var/index = 1, index <= A.laws_object.ion.len, index++)
				var/law = A.laws_object.ion[index]
				if (length(law) > 0)
					var/num = ionnum()
					laws += "[num]. [law]"

			if (A.laws_object.zeroth)
				laws += "0: [A.laws_object.zeroth]<BR>"

			var/number = 1
			for (var/index = 1, index <= A.laws_object.inherent.len, index++)
				var/law = A.laws_object.inherent[index]
				if (length(law) > 0)
					laws += "[number]: [law]<BR>"
					number++

			for (var/index = 1, index <= A.laws_object.supplied.len, index++)
				var/law = A.laws_object.supplied[index]
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
				dat += {"<a href='byond://?src=\ref[src];choice=Wireless'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</a>"}
				dat += "<br>"
				dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}
		user << browse(dat, "window=aicard")
		onclose(user, "aicard")
		return

	Topic(href, href_list)
		switch(href_list["choice"])
			if ("Close")
				usr << browse(null, "window=aicard")
				usr.machine = null
				return

			if ("Wipe")
				var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
				if(confirm == "Yes")
					flush = 1
					for(var/mob/living/silicon/ai/A in src)
						A.suiciding = 1
						A << "Your core files are being wiped!"
						while (A.stat != 2)
							A.oxyloss += 2
							A.updatehealth()
							sleep(10)
						flush = 0

			if ("Wireless")
				for(var/mob/living/silicon/ai/A in src)
					A.control_disabled = !A.control_disabled
					A << "The intelicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!"
					if (A.control_disabled)
						overlays -= image('pda.dmi', "aicard-on")
					else
						overlays += image('pda.dmi', "aicard-on")
		attack_self(usr)





