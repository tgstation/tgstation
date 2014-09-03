/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magpulse = 0
//	flags = NOSLIP //disabled by default
	action_button_name = "Toggle Magboots"
	species_fit = list("Vox")

	verb/toggle()
		set name = "Toggle Magboots"
		set category = "Object"
		set src in usr
		if(usr.stat)
			return
		if(src.magpulse)
			src.flags &= ~NOSLIP
			src.slowdown = SHOES_SLOWDOWN
			src.magpulse = 0
			icon_state = "magboots0"
			usr << "You disable the mag-pulse traction system."
		else
			src.flags |= NOSLIP
			src.slowdown = 2
			src.magpulse = 1
			icon_state = "magboots1"
			usr << "You enable the mag-pulse traction system."
		usr.update_inv_shoes()	//so our mob-overlays update

	attack_self()
		src.toggle()
		..()
		return

	examine()
		set src in view()
		..()
		var/state = "disabled"
		if(src.flags&NOSLIP)
			state = "enabled"
		usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/shoes/magboots/elite
	desc = "Advanced magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "advanced magboots"
	icon_state = "CE-magboots0"

	toggle()
		if(usr.stat)
			return
		if(src.magpulse)
			src.flags &= ~NOSLIP
			src.slowdown = SHOES_SLOWDOWN
			src.magpulse = 0
			icon_state = "CE-magboots0"
			usr << "You disable the mag-pulse traction system."
		else
			src.flags |= NOSLIP
			src.slowdown = 1
			src.magpulse = 1
			icon_state = "CE-magboots1"
			usr << "You enable the mag-pulse traction system."
		usr.update_inv_shoes()	//so our mob-overlays update