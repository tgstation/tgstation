/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magpulse = 0
//	flags = NOSLIP //disabled by default
	action_button_name = "Toggle Magboots"


	verb/toggle()
		set name = "Toggle Magboots"
		set category = "Object"
		set src in usr
		attack_self(usr)

	attack_self(mob/user)
		if(src.magpulse)
			src.flags &= ~NOSLIP
			src.slowdown = SHOES_SLOWDOWN
			src.magpulse = 0
			icon_state = "magboots0"
			user << "You disable the mag-pulse traction system."
		else
			src.flags |= NOSLIP
			src.slowdown = 2
			src.magpulse = 1
			icon_state = "magboots1"
			user << "You enable the mag-pulse traction system."
		user.update_inv_shoes(0)	//so our mob-overlays update

	examine()
		set src in view()
		..()
		var/state = "disabled"
		if(src.flags&NOSLIP)
			state = "enabled"
		usr << "Its mag-pulse traction system appears to be [state]."