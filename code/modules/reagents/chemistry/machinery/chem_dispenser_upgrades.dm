/obj/item/device/chem_dispenser_addin_board
	name = "chem dispenser add-in board"
	desc = "An add-in board containing supplementary recipes for the chem dispenser."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'

/obj/item/device/chem_dispenser_auth_board
	name = "chem dispenser dangerous recipes authorization board"
	desc = "An authorization board that disengages the safeties on a chem dispenser, allowing it to dispense toxic materials."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	req_access = list(ACCESS_HOS, ACCESS_CAPTAIN)
	var/authorized = FALSE

/obj/item/device/chem_dispenser_auth_board/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/card/id) && check_access(I))
		to_chat(user, "You authorize the use of this board.")
		authorized = TRUE
		return

	return ..()


/obj/item/device/chem_dispenser_auth_board/examine(user)
	..()
	if (authorized)
		to_chat(user, "The use of this board has been authorized by station management.")

/obj/item/device/chem_dispenser_auth_board/proc/isAuthorized()
	return authorized