/obj/machinery/computer/camera_advanced/xenobio
	max_slimes = 1
	var/upgradetier = 0

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/xenobio_console_upgrade))
		var/obj/item/disk/xenobio_console_upgrade/diskthing = O
		var/successfulupgrade = FALSE
		for(var/I in diskthing.upgradetypes)
			if(upgradetier & I)
				continue
			else
				upgradetier |= I
				successfulupgrade = TRUE
			if(I == XENOBIO_UPGRADE_SLIMEADV)
				max_slimes = 10
		if(successfulupgrade)
			to_chat(user, "<span class='notice'>You have successfully upgraded [src] with [O].</span>")
		else
			to_chat(user, "<span class='warning'>[src] already has the contents of [O] installed!</span>")
		return
	. = ..()

/obj/item/disk/xenobio_console_upgrade
	name = "Xenobiology console upgrade disk"
	desc = "Allan please add detail."
	icon_state = "datadisk5"
	var/list/upgradetypes = list()

/obj/item/disk/xenobio_console_upgrade/admin
	name = "Xenobio all access thing"
	desc = "'the consoles are literally useless!!!!!!!!!!!!!!!'"
	upgradetypes = list(XENOBIO_UPGRADE_SLIMEBASIC, XENOBIO_UPGRADE_SLIMEADV, XENOBIO_UPGRADE_MONKEYS)

/obj/item/disk/xenobio_console_upgrade/monkey
	name = "Xenobiology console monkey upgrade disk"
	desc = "This disk will add the ability to remotely recycle monkeys via the Xenobiology console."
	upgradetypes = list(XENOBIO_UPGRADE_MONKEYS)

/obj/item/disk/xenobio_console_upgrade/slimebasic
	name = "Xenobiology console basic slime upgrade disk"
	desc = "This disk will add the ability to remotely manipulate slimes via the Xenobiology console."
	upgradetypes = list(XENOBIO_UPGRADE_SLIMEBASIC)

/obj/item/disk/xenobio_console_upgrade/slimeadv
	name = "Xenobiology console advanced slime upgrade disk"
	desc = "This disk will add the ability to remotely feed slimes potions via the Xenobiology console, and lift the restrictions on the number of slimes that can be stored inside the Xenobiology console. This includes the contents of the basic slime upgrade disk."
	upgradetypes = list(XENOBIO_UPGRADE_SLIMEBASIC, XENOBIO_UPGRADE_SLIMEADV)
