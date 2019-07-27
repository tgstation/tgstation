

/obj/machinery/computer/upload
	var/mob/living/silicon/current = null //The target of future law uploads
	icon_screen = "command"
	var/obj/item/gps/internal/ai_upload/embedded_gps
	var/obj/item/gps/internal/ai_upload/embedded_gps_type = /obj/item/gps/internal/ai_upload
	time_to_scewdrive = 60

/obj/item/gps/internal/ai_upload
	icon_state = null
	gpstag = "Encrypted Upload Signal"
	desc = "Signal used to connect remotely with silicons."
	invisibility = 100

/obj/machinery/computer/upload/Initialize()
	embedded_gps = new embedded_gps_type(src)
	return ..()

/obj/machinery/computer/upload/Destroy()
	QDEL_NULL(embedded_gps)
	return ..()

/obj/machinery/computer/upload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/aiModule))
		var/obj/item/aiModule/M = O
		if(stat & (NOPOWER|BROKEN|MAINT))
			return
		if(!current)
			to_chat(user, "<span class='caution'>You haven't selected anything to transmit laws to!</span>")
			return
		if(!can_upload_to(current))
			to_chat(user, "<span class='caution'>Upload failed!</span> Check to make sure [current.name] is functioning properly.")
			current = null
			return
		var/turf/currentloc = get_turf(current)
		if(currentloc && user.z != currentloc.z)
			to_chat(user, "<span class='caution'>Upload failed!</span> Unable to establish a connection to [current.name]. You're too far away!")
			current = null
			return
		M.install(current.laws, user)
	else
		return ..()

/obj/machinery/computer/upload/proc/can_upload_to(mob/living/silicon/S)
	if(S.stat == DEAD)
		return FALSE
	return TRUE

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	circuit = /obj/item/circuitboard/computer/aiupload

/obj/machinery/computer/upload/ai/interact(mob/user)
	current = select_active_ai(user)

	if (!current)
		to_chat(user, "<span class='caution'>No active AIs detected!</span>")
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/upload/ai/can_upload_to(mob/living/silicon/ai/A)
	if(!A || !isAI(A))
		return FALSE
	if(A.control_disabled)
		return FALSE
	return ..()


/obj/machinery/computer/upload/borg
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	circuit = /obj/item/circuitboard/computer/borgupload

/obj/machinery/computer/upload/borg/interact(mob/user)
	current = select_active_free_borg(user)

	if(!current)
		to_chat(user, "<span class='caution'>No active unslaved cyborgs detected!</span>")
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/upload/borg/can_upload_to(mob/living/silicon/robot/B)
	if(!B || !iscyborg(B))
		return FALSE
	if(B.scrambledcodes || B.emagged)
		return FALSE
	return ..()
