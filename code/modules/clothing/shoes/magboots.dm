/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/base_state = "magboots"
	var/magpulse = 0
	var/mag_slow = 2
//	flags = NOSLIP //disabled by default
	action_button_name = "Toggle Magboots"
	species_fit = list("Vox")

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "[base_state]0"
		to_chat(usr, "You disable the mag-pulse traction system.")
	else
		src.flags |= NOSLIP
		src.slowdown = mag_slow
		src.magpulse = 1
		icon_state = "[base_state]1"
		to_chat(usr, "You enable the mag-pulse traction system.")
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
	to_chat(user, "<span class='info'>Its mag-pulse traction system appears to be [state].</span>")

//CE
/obj/item/clothing/shoes/magboots/elite
	desc = "Advanced magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "advanced magboots"
	icon_state = "CE-magboots0"
	base_state = "CE-magboots"
	mag_slow = 1

//Atmos techies die angry
/obj/item/clothing/shoes/magboots/atmos
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. These are painted in the colors of an atmospheric technician."
	name = "atmospherics magboots"
	icon_state = "atmosmagboots0"
	base_state = "atmosmagboots"

//Death squad
/obj/item/clothing/shoes/magboots/deathsquad
	desc = "Very expensive and advanced magnetic boots, used only by the elite during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "deathsquad magboots"
	icon_state = "DS-magboots0"
	base_state = "DS-magboots"
	mag_slow = 0