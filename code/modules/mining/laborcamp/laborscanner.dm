/obj/machinery/door_control/labor_button
	name = "Prisoner ID Scanner"
/*	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"

/obj/machinery/door_control/labor_button/allowed( mob/M as mob )
	if(ishuman(M) || ismonkey(M))
		message_admins("[M] is human or monkey")
		var/obj/item/weapon/card/id/prisoner/I = M.get_active_hand()
		message_admins("[M] is holding [I]")
		if(istype(I,/obj/item/weapon/card/id/prisoner))
			message_admins("[I] is a prisoner ID.")
			if(I.points >= I.goal)
				message_admins("[I] has enough points.")
				M << "Access granted."
				return 1;
			else
				M << "/red Insufficient mining points."
		else
			message_admins("[I] is not a prisoner ID.  Moving to normal access code.")
	..()
*/