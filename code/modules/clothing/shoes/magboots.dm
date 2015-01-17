/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magpulse = 0
//	flags = NOSLIP //disabled by default
	action_button_name = "Toggle Magboots"
	species_fit = list("Vox")

/obj/item/clothing/shoes/magboots/verb/toggle()
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

/obj/item/clothing/shoes/magboots/attack_self()
	src.toggle()
	..()
	return

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	user << "<span class='info'>Its mag-pulse traction system appears to be [state].</span>"

//CE
/obj/item/clothing/shoes/magboots/elite
	desc = "Advanced magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "advanced magboots"
	icon_state = "CE-magboots0"

/obj/item/clothing/shoes/magboots/elite/toggle()
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

//Death squad
/obj/item/clothing/shoes/magboots/deathsquad
	desc = "Very expensive and advanced magnetic boots, used only by the elite during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "deathsquad magboots"
	icon_state = "DS-magboots0"

/obj/item/clothing/shoes/magboots/deathsquad/toggle()
	if(usr.stat)
		return
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "DS-magboots0"
		usr << "You disable the mag-pulse traction system."
	else
		src.flags |= NOSLIP
		src.slowdown = 0
		src.magpulse = 1
		icon_state = "DS-magboots1"
		usr << "You enable the mag-pulse traction system."
	usr.update_inv_shoes()	//so our mob-overlays update