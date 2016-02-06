/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "secure crate"
	icon_crate = "securecrate"
	icon_state = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	locked = 1
	health = 1000

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_crate = "weaponcrate"
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_crate = "plasmacrate"
	icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_crate = "secgearcrate"
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_crate = "hydrosecurecrate"
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/update_icon()
	..()
	if(locked)
		overlays += redlight
	else if(broken)
		overlays += emag
	else
		overlays += greenlight

/obj/structure/closet/crate/secure/attack_hand(mob/user)
	if(manifest)
		tear_manifest(user)
		return
	if(locked && !broken)
		if (allowed(user))
			user << "<span class='notice'>You unlock [src].</span>"
			src.locked = 0
			update_icon()
			add_fingerprint(user)
			return
		else
			user << "<span class='notice'>[src] is locked.</span>"
			return
	else
		..()

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/card) && src.allowed(user) && !locked && !opened && !broken)
		user << "<span class='notice'>You lock \the [src].</span>"
		src.locked = 1
		update_icon()
		add_fingerprint(user)
		return

	return ..()

/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(locked && !broken)
		src.locked = 0
		src.broken = 1
		update_icon()
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 60, 1)
		user << "<span class='notice'>You unlock \the [src].</span>"
		add_fingerprint(user)

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			update_icon()
		else
			src.locked = 0
			src.broken = 1
			update_icon()
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()

