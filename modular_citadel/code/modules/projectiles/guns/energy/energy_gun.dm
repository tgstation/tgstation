/obj/item/gun/energy/e_gun
	name = "blaster carbine"
	desc = "A high powered particle blaster carbine with varitable setting for stunning or lethal applications."
	icon = 'modular_citadel/icons/obj/guns/OVERRIDE_energy.dmi'
	lefthand_file = 'modular_citadel/icons/mob/inhands/OVERRIDE_guns_lefthand.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/OVERRIDE_guns_righthand.dmi'
	ammo_x_offset = 2
	flight_x_offset = 17
	flight_y_offset = 11
	

/*/////////////////////////////////////////////////////////////////////////////////////////////
							The Recolourable Energy Gun
*//////////////////////////////////////////////////////////////////////////////////////////////

obj/item/gun/energy/e_gun/cx
	name = "\improper CX Model D Energy Gun"
	desc = "An overpriced hybrid energy gun with two settings: disable, and kill. Manufactured by CX Armories. Has a polychromic coating."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "cxe"
	lefthand_file = 'modular_citadel/icons/mob/citadel/guns_lefthand.dmi'
	righthand_file = 'modular_citadel/icons/mob/citadel/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	flight_x_offset = 15
	flight_y_offset = 10
	var/body_color = "#252528"

obj/item/gun/energy/e_gun/cx/update_icon()
	..()
	var/mutable_appearance/body_overlay = mutable_appearance('modular_citadel/icons/obj/guns/cit_guns.dmi', "cxegun_body")
	if(body_color)
		body_overlay.color = body_color
	add_overlay(body_overlay)

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

obj/item/gun/energy/e_gun/cx/AltClick(mob/living/user)
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(alert("Are you sure you want to repaint your gun?", "Confirm Repaint", "Yes", "No") == "Yes")
		var/body_color_input = input(usr,"","Choose Body Color",body_color) as color|null
		if(body_color_input)
			body_color = sanitize_hexcolor(body_color_input, desired_format=6, include_crunch=1)
		update_icon()

obj/item/gun/energy/e_gun/cx/worn_overlays(isinhands, icon_file)
	. = ..()
	if(isinhands)
		var/mutable_appearance/body_inhand = mutable_appearance(icon_file, "cxe_body")
		body_inhand.color = body_color
		. += body_inhand
