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

	attack(mob/living/silicon/decoy/M as mob, mob/user as mob)
		M.death()
		user << "<b>ERROR ERROR ERROR</b>"