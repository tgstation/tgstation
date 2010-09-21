/obj/item/device/aicard
	name = "inteliCard"
	icon = 'pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | ONBELT


	attack(mob/living/silicon/ai/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/silicon/ai))
			return ..()
												 // ** Bugfix for r74 **
		if(istype(M, /mob/living/silicon/decoy)) // Don't branch this out into a separate attack(), it overwrites the first definition.
			M.death()							 // We typecast in the function's arguments, but it doesn't actually typecheck
			user << "<b>ERROR ERROR ERROR</b>"	 // (beyond, I suspect, the big four ATOMs), typechecking for subtypes of one of the ATOMs needs
			return 0							 // to occur in the function itself. -- TLE

		if(src.contents.len > 0)
			// Already have an AI
			if(M.client)
				user << "<b>Transfer failed</b>: Existing daemon found on this terminal. Remove existing daemon to install a new one."
				return
			else if(M.stat == 2)
				user << "<b>Transfer failed</b>: Unable to establish connection."
				return
			else
				for(var/mob/living/silicon/ai/A in src)
					M.name = A.name
					M.real_name = A.real_name
					if(A.mind)
						A.mind.transfer_to(M)
					M.control_disabled = 0
					M.laws_object = A.laws_object
					M << "You have been uploaded to a stationary terminal. Remote device connection restored."
					user << "<b>Transfer succesful</b>: [M.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
					del(A)
					src.icon_state = "aicard"
					M.icon_state = "ai"
					src.name = "inteliCard"
					return
		else
			if (M.real_name != "Inactive AI" && M.stat != 2)
				var/mob/living/silicon/ai/O = new /mob/living/silicon/ai( src )
				O.invisibility = 0
				O.canmove = 0
				O.name = M.name
				O.real_name = M.real_name
				O.anchored = 1
				O.aiRestorePowerRoutine = 0
				O.control_disabled = 1 // Can't control things remotely if you're stuck in a card!
				O.laws_object = M.laws_object
				if(M.mind)
					M.mind.transfer_to(O)
				src.name = "inteliCard - [M.name]"
				M.name = "Inactive AI"
				M.real_name = "Inactive AI"
				M.icon_state = "ai-crash"
				src.icon_state = "aicard-full"
				O << "You have been downloaded to a mobile storage device. Remote device connection severed."
				user << "<b>Transfer succeeded</b>: [O.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."


	Topic(href, href_list)

		if (href_list["wipe"])
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes")
				for(var/mob/living/silicon/ai/A in src)
					A.suiciding = 1
					A << "Your core files are being wiped!"
					while (A.stat != 2)
						A.oxyloss += 2
						A.updatehealth()
						src.attack_self(usr)
						sleep(10)


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

			dat += {"<A href='byond://?src=\ref[src];wipe=1'>Wipe AI</A>"}
		user << browse(dat, "window=aicard")
		onclose(user, "aicard")
		return






