<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/upload
	var/mob/living/silicon/current = null //The target of future law uploads
	icon_screen = "command"

/obj/machinery/computer/upload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/aiModule))
		var/obj/item/weapon/aiModule/M = O
		if(src.stat & (NOPOWER|BROKEN|MAINT))
			return
		if(!current)
			user << "<span class='caution'>You haven't selected anything to transmit laws to!</span>"
			return
		if(!can_upload_to(current))
			user << "<span class='caution'>Upload failed!</span> Check to make sure [current.name] is functioning properly."
			current = null
			return
		var/turf/currentloc = get_turf(current)
		if(currentloc && user.z != currentloc.z)
			user << "<span class='caution'>Upload failed!</span> Unable to establish a connection to [current.name]. You're too far away!"
			current = null
			return
		M.install(current.laws, user)
	else
		return ..()

/obj/machinery/computer/upload/proc/can_upload_to(mob/living/silicon/S)
	if(S.stat == DEAD || S.syndicate)
		return 0
	return 1

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	circuit = /obj/item/weapon/circuitboard/computer/aiupload

/obj/machinery/computer/upload/ai/attack_hand(mob/user)
	if(..())
		return

	src.current = select_active_ai(user)

	if (!src.current)
		user << "<span class='caution'>No active AIs detected!</span>"
	else
		user << "[src.current.name] selected for law changes."

/obj/machinery/computer/upload/ai/can_upload_to(mob/living/silicon/ai/A)
	if(!A || !isAI(A))
		return 0
	if(A.control_disabled)
		return 0
	return ..()


/obj/machinery/computer/upload/borg
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	circuit = /obj/item/weapon/circuitboard/computer/borgupload

/obj/machinery/computer/upload/borg/attack_hand(mob/user)
	if(..())
		return

	src.current = select_active_free_borg(user)

	if(!src.current)
		user << "<span class='caution'>No active unslaved cyborgs detected!</span>"
	else
		user << "[src.current.name] selected for law changes."

/obj/machinery/computer/upload/borg/can_upload_to(mob/living/silicon/robot/B)
	if(!B || !isrobot(B))
		return 0
	if(B.scrambledcodes || B.emagged)
		return 0
	return ..()
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0

	light_color = "#555555"


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.isUnconscious() || istype(usr, /mob/living/silicon))
			return

		opened = !opened
		if(opened)
			to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
		else
			to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")
		return

	proc/install_module(var/obj/item/weapon/aiModule/O, var/mob/user)
		if(stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return 0
		if(stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return 0
		if (!current)
			to_chat(usr, "You haven't selected an AI to transmit laws to!")
			return 0

		if(ticker && ticker.mode && ticker.mode.name == "blob")
			to_chat(usr, "Law uploads have been disabled by Nanotrasen!")
			return 0

		if (current.stat == 2 || current.control_disabled == 1)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else if (current.aiRestorePowerRoutine)
			to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
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
		to_chat(current, "These are your laws now:")
		current.show_laws()
		for(var/mob/living/silicon/robot/R in mob_list)
			if(R.lawupdate && (R.connected_ai == current))
				to_chat(R, "These are your laws now:")
				R.show_laws()
		to_chat(user, "<span class='notice'>Upload complete. The AI's laws have been modified.</span>")

	attackby(obj/item/weapon/O as obj, mob/user as mob)
		if (user.z > 6)
			to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
			return
		if(istype(O, /obj/item/weapon/aiModule))
			if(install_module(O,user))
				announce_law_changes(user)
		else if(istype(O, /obj/item/weapon/planning_frame))
			if(stat & NOPOWER)
				to_chat(usr, "The upload computer has no power!")
				return
			if(stat & BROKEN)
				to_chat(usr, "The upload computer is broken!")
				return
			if (!current)
				to_chat(usr, "You haven't selected an AI to transmit laws to!")
				return

			if(ticker && ticker.mode && ticker.mode.name == "blob")
				to_chat(usr, "Law uploads have been disabled by Nanotrasen!")
				return

			if (current.stat == 2 || current.control_disabled == 1)
				to_chat(usr, "Upload failed. No signal is being detected from the AI.")
			else if (current.aiRestorePowerRoutine)
				to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
			else
				var/obj/item/weapon/planning_frame/frame=O
				if(frame.modules.len>0)
					to_chat(user, "<span class='notice'>You begin to load \the [frame] into \the [src]...</span>")
					if(do_after(user, src,50))
						var/failed=0
						for(var/i=1;i<=frame.modules.len;i++)
							var/obj/item/weapon/aiModule/M = frame.modules[i]
							to_chat(user, "<span class='notice'>Running [M]...</span>")
							if(!install_module(M,user))
								failed=1
								break
						if(!failed)
							announce_law_changes(user)
				else
					to_chat(user, "<span class='warning'>It's empty, doofus.</span>")
		else
			..()


	attack_hand(var/mob/user as mob)
		if(istype(user,/mob/dead))
			to_chat(usr, "<span class='rose'>Your ghostly hand goes right through!</span>")
			return
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = select_active_ai(user)

		if (!src.current)
			to_chat(usr, "No active AIs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return



/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/borgupload"
	var/mob/living/silicon/robot/current = null

	light_color = "#555555"

	proc/announce_law_changes()
		to_chat(current, "These are your laws now:")
		current.show_laws()
		to_chat(usr, "<span class='notice'>Upload complete. The robot's laws have been modified.</span>")

	proc/install_module(var/obj/item/weapon/aiModule/M,var/mob/user)
		if(stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return 0
		if(stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return 0
		if (!current)
			to_chat(usr, "You haven't selected a robot to transmit laws to!")
			return 0

		if (current.stat == 2 || current.emagged)
			to_chat(usr, "Upload failed. No signal is being detected from the robot.")
			return 0
		if (istype(current, /mob/living/silicon/robot/mommi))
			var/mob/living/silicon/robot/mommi/mommi = current
			if(mommi.keeper)
				to_chat(usr, "Upload failed. No signal is being detected from the cyborg.")
				return 0
		else if (current.connected_ai)
			to_chat(usr, "Upload failed. The robot is slaved to an AI.")
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
					to_chat(user, "<span class='warning'>[src.current] is operating in KEEPER mode and cannot be accessed via control signals.</span>")
					return ..()
			install_module(W,user)
		else if(istype(W, /obj/item/weapon/planning_frame))
			if(stat & NOPOWER)
				to_chat(user, "The upload computer has no power!")
				return
			if(stat & BROKEN)
				to_chat(user, "The upload computer is broken!")
				return
			if (!current)
				to_chat(user, "You haven't selected a robot to transmit laws to!")
				return

			if (current.stat == 2 || current.emagged)
				to_chat(user, "Upload failed. No signal is being detected from the robot.")
				return
			if (istype(current, /mob/living/silicon/robot/mommi))
				var/mob/living/silicon/robot/mommi/mommi = current
				if(mommi.keeper)
					to_chat(user, "Upload failed. No signal is being detected from the cyborg.")
					return
			else if (current.connected_ai)
				to_chat(user, "Upload failed. The robot is slaved to an AI.")
			else
				var/obj/item/weapon/planning_frame/frame=W
				if(frame.modules.len>0)
					to_chat(user, "<span class='notice'>You begin to load \the [frame] into \the [src]...</span>")
					if(do_after(user, src,50))
						var/failed=0
						for(var/i=1;i<=frame.modules.len;i++)
							var/obj/item/weapon/aiModule/M = frame.modules[i]
							to_chat(user, "<span class='notice'>Running [M]...</span>")
							if(!install_module(M,user))
								failed=1
								break
						if(!failed)
							announce_law_changes()
				else
					to_chat(user, "<span class='warning'>It's empty, doofus.</span>")
		else
			return ..()


	attack_hand(var/mob/user as mob)
		if(istype(user,/mob/dead))
			to_chat(usr, "<span class='rose'>Your ghostly hand goes right through!</span>")
			return
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = freeborg()

		if (!src.current)
			to_chat(usr, "No free cyborgs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
