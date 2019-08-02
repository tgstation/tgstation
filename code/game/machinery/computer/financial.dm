/obj/machinery/computer/finances
	name = "Financial Computer"
	desc = "A computer used to manage the stations budget."
	icon_screen = "finances"
	icon_keyboard = "generic_key"
	req_access = list(ACCESS_FINANCE)
	circuit = /obj/item/circuitboard/computer/card/finances

/obj/machinery/computer/finances/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/card/id))
		id_insert(user, I, inserted_scan_id)
		inserted_scan_id = I
	else
		return ..()

/obj/machinery/computer/finances/ui_interact(mob/user)
	. = ..()
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	var/dat
	
	
