/datum/design/xenobio_upgrade
	name = "owo"
	desc = "someone's bussin"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/xenobio_upgrade/xenobiomonkeys
	name = "Xenobiology console monkey upgrade disk"
	desc = "This disk will add the ability to remotely recycle monkeys via the Xenobiology console."
	id = "xenobio_monkeys"
	build_path = /obj/item/disk/xenobio_console_upgrade/monkey

/datum/design/xenobio_upgrade/xenobioslimebasic
	name = "Xenobiology console basic slime upgrade disk"
	desc = "This disk will add the ability to remotely manipulate slimes via the Xenobiology console."
	id = "xenobio_slimebasic"
	build_path = /obj/item/disk/xenobio_console_upgrade/slimebasic

/datum/design/xenobio_upgrade/xenobioslimeadv
	name = "Xenobiology console advanced slime upgrade disk"
	desc = "This disk will add the ability to remotely feed slimes potions via the Xenobiology console, and lift the restrictions on the number of slimes that can be stored inside the Xenobiology console. This includes the contents of the basic slime upgrade disk."
	id = "xenobio_slimeadv"
	build_path = /obj/item/disk/xenobio_console_upgrade/slimeadv
