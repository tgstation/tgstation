/obj/machinery/computer/accounting
	name = "station accounting console"
	desc = "You can use this to manage the distribution of credits on the station's departments."
	icon_screen = "money"
	icon_keyboard = "money_key"
	req_access = list(ACCESS_HOP)
	circuit = /obj/item/circuitboard/computer/accounting
	var/obj/item/card/id/id = null
	light_color = LIGHT_COLOR_BLUE
	
/obj/machinery/computer/accounting/examine(mob/user)
	..()
	if(id)
		to_chat(user, "<span class='notice'>Alt-click to eject the ID card.</span>")
		
/obj/machinery/computer/accounting/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || !is_operational())
		return
	if(id)
		eject_id(user)
		
/obj/machinery/computer/accounting/proc/eject_id(mob/user)
	if(id)
		id.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(id)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		id = null
		
/obj/machinery/computer/accounting/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/idcard = O
		if(check_access(idcard))
			if(!id)
				if(!user.transferItemToLoc(idcard,src))
					return
				id = idcard
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else
		return ..()