
/obj/structure/closet/extinguisher
	name = "extinguisher closet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon_state = "extinguisher10"
	icon_opened = "extinguisher11"
	icon_closed = "extinguisher10"
	opened = 1
	anchored = 1
	density = 0
	var/obj/item/weapon/extinguisher/EXTINGUISHER = new/obj/item/weapon/extinguisher
	var/localopened = 1

	open()
		return

	close()
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (isrobot(usr))
			return
		if (istype(O, /obj/item/weapon/extinguisher))
			if(!EXTINGUISHER)
				user.drop_item(O)
				src.contents += O
				EXTINGUISHER = O
				user << "\blue You place the extinguisher in the [src.name]."
			else
				localopened = !localopened
		else
			localopened = !localopened
		update_icon()

	attack_hand(mob/user as mob)
		if(localopened)
			if(EXTINGUISHER)
				user.put_in_hand(EXTINGUISHER)
				EXTINGUISHER = null
				user << "\blue You take the extinguisher from the [name]."
			else
				localopened = !localopened

		else
			localopened = !localopened
		update_icon()

	verb/toggle_openness() //nice name, huh? HUH?!
		set name = "Open/Close"
		set category = "Object"

		if (isrobot(usr))
			return

		localopened = !localopened
		update_icon()

	verb/remove_extinguisher()
		set name = "Remove Extinguisher"
		set category = "Object"

		if (isrobot(usr))
			return

		if (localopened)
			if(EXTINGUISHER)
				usr.put_in_hand(EXTINGUISHER)
				EXTINGUISHER = null
				usr << "\blue You take the extinguisher from the [name]."
			else
				usr << "\blue The [name] is empty."
		else
			usr << "\blue The [name] is closed."
		update_icon()

	attack_paw(mob/user as mob)
		attack_hand(user)
		return

	attack_ai(mob/user as mob)
		return

	update_icon()
		var/hasextinguisher = 0
		if(EXTINGUISHER)
			hasextinguisher = 1
		icon_state = text("extinguisher[][]",hasextinguisher,src.localopened)
