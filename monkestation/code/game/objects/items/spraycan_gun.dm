/obj/item/toy/crayon/spraycan/use_on(atom/target, mob/user, params)
	if(istype(target, /obj/item/toy/crayon/spraycan/gun))
		var/obj/item/toy/crayon/spraycan/gun/gun = target
		if(gun.contained_spraycan)
			gun.unload_spraycan()
		gun.load_spraycan(src)
		return FALSE

	return ..()

/obj/item/toy/crayon/spraycan/gun
	name = "Spraycan gun"
	desc = "used for carefull painting of various surfaces"
	icon = 'monkestation/icons/obj/misc.dmi'
	// this actually gets overridden by icon_uncapped because of shitcode in spraycans, use it as a R&D design icon var instead
	icon_state = "spraycan_gun_filled"
	icon_uncapped = "spraycan_gun_empty"

	charges = 0
	has_cap = FALSE
	is_capped = FALSE
	overlay_paint_colour = FALSE

	var/obj/item/toy/crayon/spraycan/contained_spraycan

/obj/item/toy/crayon/spraycan/gun/examine()
	. = ..()
	if(contained_spraycan)
		. += span_notice("It's spraycan slot is full, you can alt+click it to release the can or use another can onto it to replace it.")
	else
		. += span_notice("It's spraycan slot is empty, you can slot a spraycan into it by clicking the gun with the spraycan")

/obj/item/toy/crayon/spraycan/gun/set_painting_tool_color(chosen_color)
	. = ..()
	icon_state = contained_spraycan ? "spraycan_gun_filled" : icon_uncapped

/obj/item/toy/crayon/spraycan/gun/AltClick(mob/user)
	if(contained_spraycan)
		unload_spraycan()

/obj/item/toy/crayon/spraycan/gun/refill()
	if(!charges)
		return charges_left = charges

	return ..()

/obj/item/toy/crayon/spraycan/gun/use_charges(mob/user, amount = 1, requires_full = TRUE)
	if(contained_spraycan?.charges == -1) // What's the point?
		. = amount
		return refill()

	if(check_empty(user, amount, requires_full))
		return FALSE
	else
		. = min(contained_spraycan.charges_left, amount)
		contained_spraycan.charges_left -= .
		charges_left -= .

/obj/item/toy/crayon/spraycan/gun/check_empty(mob/user, amount = 1, requires_full = TRUE)
	if(!contained_spraycan)
		balloon_alert(user, "no spraycan!")
		return TRUE
	if(contained_spraycan.charges == -1)
		return FALSE
	if(!contained_spraycan.charges_left)
		balloon_alert(user, "tank empty!")
		return TRUE
	if(contained_spraycan.charges_left < amount && requires_full)
		balloon_alert(user, "not enough left!")
		return TRUE

	return FALSE

/obj/item/toy/crayon/spraycan/gun/proc/load_spraycan(obj/item/toy/crayon/spraycan/wanted_spraycan)
	wanted_spraycan.forceMove(src)
	contained_spraycan = wanted_spraycan
	charges = contained_spraycan.charges_left
	refill()
	icon_state = "spraycan_gun_filled"

/obj/item/toy/crayon/spraycan/gun/proc/unload_spraycan()
	contained_spraycan.forceMove(drop_location(src))
	contained_spraycan = null
	charges = 0
	refill()
	icon_state = icon_uncapped
