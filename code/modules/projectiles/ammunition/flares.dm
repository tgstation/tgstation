/* Basic ammo for the flare gun. Does a nice amount of burn damage (15), and if it's shot from the syndicate flare gun will set people on fire
   Can also be fired from shotguns, but only to the same effect as being fired from a regular flare gun */

/obj/item/ammo_casing/shotgun/flare
	name = "flare shell"
	desc = "Flare shell, shot by flare guns. Contains a flare and little else."
	icon_state = "flareshell"
	caliber = "flare"
	projectile_type = "/obj/item/projectile/flare"
	m_amt = 1000
	w_type = RECYK_METAL
	w_class = 1.0
	var/obj/item/device/flashlight/flare/stored_flare = null

/obj/item/ammo_casing/shotgun/flare/New()
	..()
	stored_flare = new(src)

/obj/item/ammo_casing/shotgun/flare/attack_self()
	usr <<"You disassemble the flare shell."
	stored_flare.loc = usr.loc
	new/obj/item/ammo_casing/shotgun/empty(usr.loc)
	qdel(src)