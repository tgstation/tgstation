/obj/item/modkit
	name = "modification kit"
	desc = "A one-use kit, which allows less \
		dextrous races to use the tool."
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
		user << "<span class='warning'>This kit can only modify kinetic \
			accelerators!</span>"
		return ..()
	// RIP the 'improved improved improved improved kinetic accelerator
	if(C.trigger_guard == TRIGGER_GUARD_ALLOW_ALL)
		user << "<span class='warning'>This kinetic accelerator already has \
			been modified.</span>"
		return ..()
	user <<"<span class='notice'>You modify the [C], adjusting the trigger \
		guard.</span>"
	C.name = "modified [C.name]"
	C.trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	uses--
	if(!uses)
		qdel(src)
