//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0

	l_color = "#FFFFFF"


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon) || (usr.status_flags & FAKEDEATH))
			return

		opened = !opened
		if(opened)
			usr << "<span class='notice'>The access panel is now open.</span>"
		else
			usr << "<span class='notice'>The access panel is now closed.</span>"
		return

	proc/install_module(var/obj/item/weapon/aiModule/O, var/mob/user)
		if(stat & NOPOWER)
			usr << "The upload computer has no power!"
			return 0
		if(stat & BROKEN)
			usr << "The upload computer is broken!"
			return 0
		if (!current)
			usr << "You haven't selected an AI to transmit laws to!"
			return 0

		if(ticker && ticker.mode && ticker.mode.name == "blob")
			usr << "Law uploads have been disabled by NanoTrasen!"
			return 0

		if (current.stat == 2 || current.control_disabled == 1)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (current.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			// Modules should throw their own errors.
			// Our responsibility is to prevent success messages.
			var/obj/item/weapon/aiModule/M = O
			if(!M.validate(current.laws,current,user))
				return 0
			if(!M.upload(current.laws,current,user))
				return 0
		return 1

	proc/announce_law_changes(var/mob/user)
		current << "These are your laws now:"
		current.show_laws()
		for(var/mob/living/silicon/robot/R in mob_list)
			if(R.lawupdate && (R.connected_ai == current))
				R << "These are your laws now:"
				R.show_laws()
		user << "<span class='notice'>Upload complete. The AI's laws have been modified.</span>"

	attackby(obj/item/weapon/O as obj, mob/user as mob)
		if (user.z > 6)
			user << "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!"
			return
		if(istype(O, /obj/item/weapon/aiModule))
			if(install_module(O,user))
				announce_law_changes(user)
		else if(istype(O, /obj/item/weapon/planning_frame))
			if(stat & NOPOWER)
				usr << "The upload computer has no power!"
				return
			if(stat & BROKEN)
				usr << "The upload computer is broken!"
				return
			if (!current)
				usr << "You haven't selected an AI to transmit laws to!"
				return

			if(ticker && ticker.mode && ticker.mode.name == "blob")
				usr << "Law uploads have been disabled by NanoTrasen!"
				return

			if (current.stat == 2 || current.control_disabled == 1)
				usr << "Upload failed. No signal is being detected from the AI."
			else if (current.see_in_dark == 0)
				usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
			else
				var/obj/item/weapon/planning_frame/frame=O
				if(frame.modules.len>0)
					user << "<span class='notice'>You load \the [frame] into \the [src]...</span>"
					if(do_after(user,50))
						var/failed=0
						for(var/i=1;i<=frame.modules.len;i++)
							var/obj/item/weapon/aiModule/M = frame.modules[i]
							user << "<span class='notice'>Running [M]...</span>"
							if(!install_module(M,user))
								failed=1
								break
						if(!failed)
							announce_law_changes(user)
				else
					user << "<span class='warning'>It's empty, doofus.</span>"
		else
			..()


	attack_hand(var/mob/user as mob)
		if(istype(user,/mob/dead))
			usr << "<span class='rose'>Your ghostly hand goes right through!</span>"
			return
		if(src.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(src.stat & BROKEN)
			usr << "The upload computer is broken!"
			return

		src.current = select_active_ai(user)

		if (!src.current)
			usr << "No active AIs detected."
		else
			usr << "[src.current.name] selected for law changes."
		return



/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/borgupload"
	var/mob/living/silicon/robot/current = null

	l_color = "#FFFFFF"

	proc/announce_law_changes()
		current << "These are your laws now:"
		current.show_laws()
		usr << "<span class='notice'>Upload complete. The robot's laws have been modified.</span>"

	proc/install_module(var/obj/item/weapon/aiModule/M,var/mob/user)
		if(stat & NOPOWER)
			usr << "The upload computer has no power!"
			return 0
		if(stat & BROKEN)
			usr << "The upload computer is broken!"
			return 0
		if (!current)
			usr << "You haven't selected a robot to transmit laws to!"
			return 0

		if (current.stat == 2 || current.emagged)
			usr << "Upload failed. No signal is being detected from the robot."
			return 0
		if (istype(current, /mob/living/silicon/robot/mommi))
			var/mob/living/silicon/robot/mommi/mommi = current
			if(mommi.keeper)
				usr << "Upload failed. No signal is being detected from the cyborg."
				return 0
		else if (current.connected_ai)
			usr << "Upload failed. The robot is slaved to an AI."
			return 0
		else
			// Modules should throw their own errors.
			// Our responsibility is to prevent success messages.
			if(!M.validate(current.laws,current,user))
				return 0
			if(!M.upload(current.laws,current,user))
				return 0
			announce_law_changes()
		return 1

	attackby(var/obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/aiModule))
			if(isMoMMI(src.current))
				var/mob/living/silicon/robot/mommi/mommi = src.current
				if(mommi.keeper)
					user << "<span class='warning'>[src.current] is operating in KEEPER mode and cannot be accessed via control signals.</span>"
					return ..()
			install_module(W,user)
		else if(istype(W, /obj/item/weapon/planning_frame))
			if(stat & NOPOWER)
				user << "The upload computer has no power!"
				return
			if(stat & BROKEN)
				user << "The upload computer is broken!"
				return
			if (!current)
				user << "You haven't selected a robot to transmit laws to!"
				return

			if (current.stat == 2 || current.emagged)
				user << "Upload failed. No signal is being detected from the robot."
				return
			if (istype(current, /mob/living/silicon/robot/mommi))
				var/mob/living/silicon/robot/mommi/mommi = current
				if(mommi.keeper)
					user << "Upload failed. No signal is being detected from the cyborg."
					return
			else if (current.connected_ai)
				user << "Upload failed. The robot is slaved to an AI."
			else
				var/obj/item/weapon/planning_frame/frame=W
				if(frame.modules.len>0)
					user << "<span class='notice'>You load \the [frame] into \the [src]...</span>"
					if(do_after(user,50))
						var/failed=0
						for(var/i=1;i<=frame.modules.len;i++)
							var/obj/item/weapon/aiModule/M = frame.modules[i]
							user << "<span class='notice'>Running [M]...</span>"
							if(!install_module(M,user))
								failed=1
								break
						if(!failed)
							announce_law_changes()
				else
					user << "<span class='warning'>It's empty, doofus.</span>"
		else
			return ..()


	attack_hand(var/mob/user as mob)
		if(istype(user,/mob/dead))
			usr << "<span class='rose'>Your ghostly hand goes right through!</span>"
			return
		if(src.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(src.stat & BROKEN)
			usr << "The upload computer is broken!"
			return

		src.current = freeborg()

		if (!src.current)
			usr << "No free cyborgs detected."
		else
			usr << "[src.current.name] selected for law changes."
		return

