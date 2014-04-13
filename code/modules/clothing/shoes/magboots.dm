/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_off = 2
	action_button_name = "Toggle Magboots"


/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	attack_self(usr)
	

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "[magboot_state]0"
		user << "You disable the mag-pulse traction system."
	else
		src.flags |= NOSLIP
		src.slowdown = slowdown_off
		src.magpulse = 1
		icon_state = "[magboot_state]1"
		user << "You enable the mag-pulse traction system."
	user.update_inv_shoes(0)	//so our mob-overlays update
	

/obj/item/clothing/shoes/magboots/examine()
	set src in view()
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	usr << "Its mag-pulse traction system appears to be [state]."
	

/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_off = SHOES_SLOWDOWN
