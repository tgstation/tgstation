/obj/machinery/computer/upload
	var/mob/living/silicon/current = null //The target of future law uploads
	icon_screen = "command"

/obj/machinery/computer/upload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/aiModule))
		var/obj/item/aiModule/M = O
		if(src.stat & (NOPOWER|BROKEN|MAINT))
			return
		if(!current)
			to_chat(user, "<span class='caution'>You haven't selected anything to transmit laws to!</span>")
			return
		if(!can_upload_to(current))
			current = null
			return
		M.install(current.laws, user)
	else
		return ..()

/obj/machinery/computer/upload/proc/can_upload_to(mob/living/silicon/S, mob/user, silent=FALSE)
	var/turf/currentloc = get_turf(current)

	. = TRUE
	if(S.stat == DEAD)
		if(user && !silent)
			to_chat(user, "<span class='caution'>Upload failed!</span> Check to make sure [current.name] is functioning properly.")
		. = FALSE
	else if(S.has_trait(TRAIT_NO_LAW_CHANGE))
		if(user && !silent)
			to_chat(user, "<span class='caution'>Upload failed, [current.name] is not responding to law change signals.")
		. = FALSE
	else if(currentloc && user.z != currentloc.z)
		. = FALSE
		if(user && !silent)
			to_chat(user, "<span class='caution'>Upload failed!</span> Unable to establish a connection to [current.name]. You're too far away!")

/obj/machinery/computer/upload/ai
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	circuit = /obj/item/circuitboard/computer/aiupload

/obj/machinery/computer/upload/ai/interact(mob/user)
	src.current = select_active_ai(user)

	if (!src.current)
		to_chat(user, "<span class='caution'>No active AIs detected!</span>")
	else
		to_chat(user, "[src.current.name] selected for law changes.")

/obj/machinery/computer/upload/ai/can_upload_to(mob/living/silicon/ai/A)
	if(!A || !isAI(A))
		return 0
	if(A.control_disabled) // aka: in an intellicard.
		return 0
	return ..()


/obj/machinery/computer/upload/borg
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	circuit = /obj/item/circuitboard/computer/borgupload

/obj/machinery/computer/upload/borg/interact(mob/user)
	src.current = select_active_free_borg(user)

	if(!src.current)
		to_chat(user, "<span class='caution'>No active unslaved cyborgs detected!</span>")
	else
		to_chat(user, "[src.current.name] selected for law changes.")

/obj/machinery/computer/upload/borg/can_upload_to(mob/living/silicon/robot/B)
	if(!B || !iscyborg(B))
		return 0
	if(B.scrambledcodes || B.emagged)
		return 0
	return ..()
