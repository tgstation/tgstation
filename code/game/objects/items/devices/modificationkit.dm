/obj/item/modkit
	name = "modification kit"
	desc = "A one-use kit, which enables kinetic accelerators to retain their \
		charge when away from a bioelectric source, renders them immune to \
		interference with other accelerators, as well as allowing less \
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
	if(C.holds_charge && C.unique_frequency)
		user << "<span class='warning'>This kinetic accelerator already has \
			these upgrades.</span>"
		return ..()

	user <<"<span class='notice'>You modify the [C], adjusting the trigger \
		guard and internal capacitor.</span>"
	C.name = "improved [C.name]"
	C.holds_charge = TRUE
	C.unique_frequency = TRUE
	C.trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	uses--
	if(!uses)
		qdel(src)
