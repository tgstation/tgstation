//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon))
			return

		opened = !opened
		if(opened)
			usr << "\blue The access panel is now open."
		else
			usr << "\blue The access panel is now closed."
		return


	attackby(obj/item/weapon/O as obj, mob/user as mob)
		if (user.z > 6)
			user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return
		if(istype(O, /obj/item/weapon/aiModule))
			var/obj/item/weapon/aiModule/M = O
			M.install(src)
		if(istype(O, /obj/item/weapon/planning_frame))
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
					user << "\blue You load \the [frame] into \the [src]..."
					if(do_after(user,50))
						for(var/i=1;i<=frame.modules.len;i++)
							var/obj/item/weapon/aiModule/M = frame.modules[i]
							user << "\blue Running [M]..."
							M.install(src)
				else
					user << "\red It's empty, doofus."
		else
			..()


	attack_hand(var/mob/user as mob)
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


	attackby(var/obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/aiModule))
			var/obj/item/weapon/aiModule/module=W
			if(isMoMMI(src.current))
				var/mob/living/silicon/robot/mommi/mommi = src.current
				if(mommi.keeper)
					user << "\red [src.current] is operating in KEEPER mode and cannot be accessed via control signals."
					return ..()
			module.install(src)
		else if(istype(W, /obj/item/weapon/planning_frame))
			if(stat & NOPOWER)
				usr << "The upload computer has no power!"
				return
			if(stat & BROKEN)
				usr << "The upload computer is broken!"
				return
			if (!current)
				usr << "You haven't selected a robot to transmit laws to!"
				return

			if (current.stat == 2 || current.emagged)
				usr << "Upload failed. No signal is being detected from the robot."
			if (istype(current, /mob/living/silicon/robot/mommi))
				var/mob/living/silicon/robot/mommi/mommi = current
				if(mommi.keeper)
					usr << "Upload failed. No signal is being detected from the cyborg."
					return
			else if (current.connected_ai)
				usr << "Upload failed. The robot is slaved to an AI."
			else
				var/obj/item/weapon/planning_frame/frame=W
				if(frame.modules.len>0)
					user << "\blue You load \the [frame] into \the [src]..."
					if(do_after(user,50))
						for(var/i=1;i<=frame.modules.len;i++)
							var/obj/item/weapon/aiModule/M = frame.modules[i]
							user << "\blue Running [M]..."
							M.install(src)
				else
					user << "\red It's empty, doofus."
		else
			return ..()


	attack_hand(var/mob/user as mob)
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
