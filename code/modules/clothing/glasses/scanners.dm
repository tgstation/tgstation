/obj/item/clothing/glasses/scanner
	item_state = "glasses"
	var/on = TRUE

/obj/item/clothing/glasses/scanner/attack_self()
	toggle()

/obj/item/clothing/glasses/scanner/verb/toggle()
	set category = "Object"
	set name = "Toggle"
	set src in usr

	var/mob/C = usr
	if (!usr)
		if (!ismob(loc))
			return
		C = loc

	if (C.incapacitated())
		return

	if (on)
		disable(C)

	else
		enable(C)

	update_icon()
	C.update_inv_glasses()

/obj/item/clothing/glasses/scanner/proc/enable(var/mob/C)
	on = TRUE
	to_chat(C, "You turn \the [src] on.")

/obj/item/clothing/glasses/scanner/proc/disable(var/mob/C)
	on = FALSE
	to_chat(C, "You turn \the [src] off.")

/obj/item/clothing/glasses/scanner/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = "magnets=2;engineering=2"
	vision_flags = SEE_TURFS
	eyeprot = -1
	see_invisible = SEE_INVISIBLE_MINIMUM
	action_button_name = "Toggle Meson Scanner"

/obj/item/clothing/glasses/scanner/meson/enable(var/mob/C)
	eyeprot = 2
	vision_flags |= SEE_TURFS
	see_invisible |= SEE_INVISIBLE_MINIMUM
//	body_parts_covered |= EYES
	..()

/obj/item/clothing/glasses/scanner/meson/disable(var/mob/C)
	eyeprot = 0
//	body_parts_covered &= ~EYES
	vision_flags &= ~SEE_TURFS
	see_invisible &= ~SEE_INVISIBLE_MINIMUM
	..()

/obj/item/clothing/glasses/scanner/meson/update_icon()
	icon_state = initial(icon_state)

	if (!on)
		icon_state += "off"

/obj/item/clothing/glasses/scanner/material
	name = "optical material scanner"
	desc = "Allows one to see the original layout of the pipe and cable network."
	icon_state = "material"
	origin_tech = "magnets=3;engineering=3"
	action_button_name = "Toggle Material Scanner"
	// vision_flags = SEE_OBJS

	var/list/image/showing = list()
	var/mob/viewing

/obj/item/clothing/glasses/scanner/material/enable()
	update_mob(viewing)
	..()

/obj/item/clothing/glasses/scanner/material/disable()
	update_mob(viewing)
	..()

/obj/item/clothing/glasses/scanner/material/update_icon()
	if (!on)
		icon_state = "mesonoff"

	else
		icon_state = initial(icon_state)

/obj/item/clothing/glasses/scanner/material/dropped(var/mob/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/material/unequipped(var/mob/M)
	update_mob()

/obj/item/clothing/glasses/scanner/material/equipped(var/mob/M)
	update_mob(M)

/obj/item/clothing/glasses/scanner/material/OnMobLife(var/mob/living/carbon/human/M)
	update_mob(M.glasses == src ? M : null)

/obj/item/clothing/glasses/scanner/material/proc/clear()
	if (!showing.len)
		return

	if (viewing && viewing.client)
		viewing.client.images -= showing

	showing.Cut()

/obj/item/clothing/glasses/scanner/material/proc/apply()
	if (!viewing || !viewing.client || !on)
		return

	showing = get_images(get_turf(viewing), viewing.client.view)
	viewing.client.images += showing

/obj/item/clothing/glasses/scanner/material/proc/update_mob(var/mob/new_mob)
	if (new_mob == viewing)
		clear()
		apply()
		return

	if (new_mob != viewing)
		clear()

		if (viewing)
			viewing.on_logout.Remove("\ref[src]:mob_logout")
			viewing = null

		if (new_mob)
			new_mob.on_logout.Add(src, "mob_logout")
			viewing = new_mob

/obj/item/clothing/glasses/scanner/material/proc/mob_logout(var/list/args, var/mob/M)
	if (M != viewing)
		return

	clear()
	viewing.on_logout.Remove("\ref[src]:mob_logout")
	viewing = null

/obj/item/clothing/glasses/scanner/material/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data
