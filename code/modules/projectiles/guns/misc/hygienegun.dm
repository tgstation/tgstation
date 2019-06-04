/obj/item/gun/hygienegun
	name = "Stink Removal Device"
	desc = "Cleans the stink right off any crew member."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "hygienegun"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/pressurizedsoap/ammo

/obj/item/gun/hygienegun/Initialize()
	. = ..()
	chambered = new /obj/item/ammo_casing/caseless/hygienepellet(src)

/obj/item/gun/hygienegun/can_shoot()
	return ammo.charges

/obj/item/gun/hygienegun/process_chamber()
	if(!ammo.charges)
		return FALSE
	if(chambered && !chambered.BB)
		chambered.newshot()
		ammo.charges--

/obj/item/gun/hygienegun/update_icon()
	if(ammo.charges)
		add_overlay("hygienegun_clean")
	else
		cut_overlays()
	

/obj/item/gun/hygienegun/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(istype(A, /obj/item/pressurizedsoap))
		if(ammo)
			ammo.forceMove(get_turf(drop_location()))
		to_chat(user, "<span class='notice'>You load the [A] into [src].</span>")
		ammo = A
		A.forceMove(src)
		process_chamber()
		update_icon()

/obj/item/gun/hygienegun/attack_self(mob/living/user)
	if(!ammo)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return FALSE

	user.put_in_hands(ammo)
	to_chat(user, "<span class='notice'>You unload [ammo] from \the [src].</span>")
	ammo = null

	return TRUE

/obj/item/pressurizedsoap
	name = "SRD Chemical Container"
	desc = "A container with a variety of highly condensed cleaning chemicals which make it perfect for use in the stink removal device."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "srd"
	var/charges = 8
