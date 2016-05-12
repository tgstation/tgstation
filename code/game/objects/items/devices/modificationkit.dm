/obj/item/modkit
	name = "modification kit"
	desc = "A one-use kit, which enables kinetic accelerators to be fired with only one hand, as well as allowing less dextrous races to use the tool."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	var/uses = 1

/obj/item/modkit/afterattack(obj/item/weapon/gun/energy/kinetic_accelerator/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		user << "<span class='warning'>This kit can only modify kinetic accelerators!</span>"
		return ..()
	user <<"<span class='notice'>You modify the [C], making it less unwieldy.</span>"
	C.name = "compact [C.name]"
	C.weapon_weight = WEAPON_LIGHT
	C.trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	uses --
	if(!uses)
		qdel(src)