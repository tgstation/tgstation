/obj/item/device/aicard
	name = "inteliCard"
	icon = 'pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | ONBELT
	var/flush = null


	attack(mob/living/silicon/ai/M as mob, mob/user as mob)
		if (src.flush)
			return

		if(!istype(M, /mob/living/silicon/ai))
			return ..()

		if(src.contents.len > 0)
			for(var/mob/living/silicon/ai/A in src)

			// Already have an AI
				if(M.real_name != "Inactive AI")
					user << "<b>Transfer failed</b>: Existing AI found on this terminal. Remove existing AI to install a new one."
					return
//				else if(M.stat != A.stat)
//					user << "<b>Transfer failed</b>: Unable to establish connection."
//					return
				else
					M.name = A.name
					M.real_name = A.real_name
					if(A.mind)
						A.mind.transfer_to(M)
					M.control_disabled = 0
					M.laws_object = A.laws_object
					M.oxyloss = A.oxyloss
					M.fireloss = A.fireloss
					M.bruteloss = A.bruteloss
					M.toxloss = A.toxloss
					M.updatehealth()
					M << "You have been uploaded to a stationary terminal. Remote device connection restored."
					user << "<b>Transfer succesful</b>: [M.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
					del(A)
					if (!M.stat)
						M.icon_state = "ai"
					else
						M.icon_state = "ai-crash"
					src.icon_state = "aicard"
					src.name = "inteliCard"
					src.overlays = null
					return
		else
			if (M.real_name != "Inactive AI")
				var/mob/living/silicon/ai/O = new /mob/living/silicon/ai( src )
				O.invisibility = 0
				O.canmove = 0
				O.name = M.name
				O.real_name = M.real_name
				O.anchored = 1
				O.aiRestorePowerRoutine = 0
				O.control_disabled = 1 // Can't control things remotely if you're stuck in a card!
				O.laws_object = M.laws_object
				O.stat = M.stat
				O.oxyloss = M.oxyloss
				O.fireloss = M.fireloss
				O.bruteloss = M.bruteloss
				O.toxloss = M.toxloss
				O.updatehealth()
				if(M.mind)
					M.mind.transfer_to(O)
				src.name = "inteliCard - [M.name]"
				M.name = "Inactive AI"
				M.real_name = "Inactive AI"
				M.icon_state = "ai-empty"
				if (O.stat == 2)
					src.icon_state = "aicard-404"
				else
					src.icon_state = "aicard-full"
				O << "You have been downloaded to a mobile storage device. Remote device connection severed."
				user << "<b>Transfer succeeded</b>: [O.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
			else
				user << "There isn't an AI on this terminal."

	attack(mob/living/silicon/decoy/M as mob, mob/user as mob)
		if (!istype (M, /mob/living/silicon/decoy))
			return ..()
		else
			M.death()
			user << "<b>ERROR ERROR ERROR</b>"

	Topic(href, href_list)

		if (href_list["wipe"])
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes")
				src.flush = 1
				for(var/mob/living/silicon/ai/A in src)
					A.suiciding = 1
					A << "Your core files are being wiped!"
					while (A.stat != 2)
						A.oxyloss += 2
						A.updatehealth()
						src.attack_self(usr)
						sleep(10)
					src.flush = 0

		if (href_list["wireless"])
			for(var/mob/living/silicon/ai/A in src)
				A.control_disabled = !A.control_disabled
				A << "The intelicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!"
				if (A.control_disabled)
					src.overlays -= image('pda.dmi', "aicard-on")
				else
					src.overlays += image('pda.dmi', "aicard-on")
				src.attack_self(usr)


	attack_self(mob/user)
		user.machine = src
		var/dat = "<TT><B>Intelicard</B><BR>"
		var/laws
		for(var/mob/living/silicon/ai/A in src)
			dat += "Stored AI: [A.name]<br>System integrity: [(A.health+100)/2]%<br>"

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
					dat += {"<A href='byond://?src=\ref[src];wipe=1'>Wipe AI</A>"}
				else
					dat += "<b>Wipe in progress</b>"
				dat += {" <A href='byond://?src=\ref[src];wireless=1'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</A>"}
		user << browse(dat, "window=aicard")
		onclose(user, "aicard")
		return






