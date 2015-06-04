//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/upload
	var/mob/living/silicon/current = null //The target of future law uploads
	icon_state = null //To make sure mappers understand THIS ISN'T A VALID TYPE

/obj/machinery/computer/upload/attackby(obj/item/O as obj, mob/user as mob, params)
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
		M.install(current, user)
	else
		..()

/obj/machinery/computer/upload/proc/can_upload_to(var/mob/living/silicon/S as mob)
	if(S.stat == DEAD || S.syndicate)
		return 0
	return 1

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = /obj/item/weapon/circuitboard/aiupload

/obj/machinery/computer/upload/ai/attack_hand(var/mob/user as mob)
	if(..())
		return

	src.current = select_active_ai(user)

	if (!src.current)
		user << "<span class='caution'>No active AIs detected!</span>"
	else
		user << "[src.current.name] selected for law changes."

/obj/machinery/computer/upload/ai/can_upload_to(var/mob/living/silicon/ai/A as mob)
	if(!A || !isAI(A))
		return 0
	if(A.control_disabled)
		return 0
	return ..()


/obj/machinery/computer/upload/borg
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = /obj/item/weapon/circuitboard/borgupload

/obj/machinery/computer/upload/borg/attack_hand(var/mob/user as mob)
	if(..())
		return

	src.current = select_active_free_borg(user)

	if(!src.current)
		user << "<span class='caution'>No active unslaved cyborgs detected!</span>"
	else
		user << "[src.current.name] selected for law changes."

/obj/machinery/computer/upload/borg/can_upload_to(var/mob/living/silicon/robot/B as mob)
	if(!B || !isrobot(B))
		return 0
	if(B.scrambledcodes || B.emagged)
		return 0
	return ..()