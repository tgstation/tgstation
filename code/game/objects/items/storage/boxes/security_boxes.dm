// This file contains everything used by security, or in other combat applications.

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/flashbangs/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/grenade/flashbang

/obj/item/storage/box/stingbangs
	name = "box of stingbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause severe injuries or death in repeated use.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/stingbangs/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/grenade/stingbang

/obj/item/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "secbox"
	illustration = "flash"

/obj/item/storage/box/flashes/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/assembly/flash/handheld

/obj/item/storage/box/wall_flash
	name = "wall-mounted flash kit"
	desc = "This box contains everything necessary to build a wall-mounted flash. <B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "secbox"
	illustration = "flash"

/obj/item/storage/box/wall_flash/PopulateContents()
	var/id = rand(1000, 9999)
	// FIXME what if this conflicts with an existing one?

	var/obj/item/assembly/control/flasher/remote = new(null)
	remote.id = id
	var/obj/item/wallframe/flasher/frame = new(null)
	frame.id = id

	return list(
		/obj/item/wallframe/button,
		/obj/item/electronics/airlock,
		/obj/item/assembly/flash/handheld,
		/obj/item/screwdriver,
		remote,
		frame,
	)

/obj/item/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "secbox"
	illustration = "grenade"

/obj/item/storage/box/teargas/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/grenade/chem_grenade/teargas

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	illustration = "emp"

/obj/item/storage/box/emps/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/grenade/empgrenade

/obj/item/storage/box/prisoner
	name = "box of prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "secbox"
	illustration = "id"

/obj/item/storage/box/prisoner/PopulateContents()
	return list(
		/obj/item/card/id/advanced/prisoner/one,
		/obj/item/card/id/advanced/prisoner/two,
		/obj/item/card/id/advanced/prisoner/three,
		/obj/item/card/id/advanced/prisoner/four,
		/obj/item/card/id/advanced/prisoner/five,
		/obj/item/card/id/advanced/prisoner/six,
		/obj/item/card/id/advanced/prisoner/seven,
	)

/obj/item/storage/box/seccarts
	name = "box of PDA security cartridges"
	desc = "A box full of PDA cartridges used by Security."
	icon_state = "secbox"
	illustration = "pda"

/obj/item/storage/box/seccarts/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/computer_disk/security

/obj/item/storage/box/firingpins
	name = "box of standard firing pins"
	desc = "A box full of standard firing pins, to allow newly-developed firearms to operate."
	icon_state = "secbox"
	illustration = "firingpin"

/obj/item/storage/box/firingpins/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/firing_pin

/obj/item/storage/box/firingpins/paywall
	name = "box of paywall firing pins"
	desc = "A box full of paywall firing pins, to allow newly-developed firearms to operate behind a custom-set paywall."
	illustration = "firingpin"

/obj/item/storage/box/firingpins/paywall/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/firing_pin/paywall

/obj/item/storage/box/lasertagpins
	name = "box of laser tag firing pins"
	desc = "A box full of laser tag firing pins, to allow newly-developed firearms to require wearing brightly coloured plastic armor before being able to be used."
	illustration = "firingpin"

/obj/item/storage/box/lasertagpins/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/firing_pin/tag/red
		. += /obj/item/firing_pin/tag/blue

/obj/item/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/handcuffs/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/restraints/handcuffs

/obj/item/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/zipties/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/restraints/handcuffs/cable/zipties

/obj/item/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienbox"
	illustration = "handcuff"

/obj/item/storage/box/alienhandcuffs/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/restraints/handcuffs/alien

/obj/item/storage/box/rubbershot
	name = "box of shotgun shells (Less Lethal - Rubber Shot)"
	desc = "A box full of rubber shot shotgun shells, designed for shotguns."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/rubbershot/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/storage/box/lethalshot
	name = "box of shotgun shells (Lethal)"
	desc = "A box full of lethal shotgun shells, designed for shotguns."
	icon_state = "lethalshot_box"
	illustration = null

/obj/item/storage/box/lethalshot/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_casing/shotgun/buckshot

/obj/item/storage/box/lethalshot/old

/obj/item/storage/box/lethalshot/old/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_casing/shotgun/buckshot/old

/obj/item/storage/box/slugs
	name = "box of shotgun shells (Lethal - Slugs)"
	desc = "A box full of lethal shotgun slugs, designed for shotguns."
	icon_state = "breacher_box"
	illustration = null

/obj/item/storage/box/slugs/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_casing/shotgun

/obj/item/storage/box/beanbag
	name = "box of shotgun shells (Less Lethal - Beanbag)"
	desc = "A box full of beanbag shotgun shells, designed for shotguns."
	icon_state = "beanbagshot_box"
	illustration = null

/obj/item/storage/box/beanbag/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/ammo_casing/shotgun/beanbag

/obj/item/storage/box/breacherslug
	name = "box of breaching shotgun shells"
	desc = "A box full of breaching slugs, designed for rapid entry, not very effective against anything else."
	icon_state = "breacher_box"
	illustration = null

/obj/item/storage/box/breacherslug/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_casing/shotgun/breacher

/obj/item/storage/box/large_dart
	name = "box of XL shotgun darts"
	name = "A box full of shotgun darts with increased chemical storage capacity."
	icon_state = "shotdart_box"
	illustration = null

/obj/item/storage/box/large_dart/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_casing/shotgun/dart/large

/obj/item/storage/box/emptysandbags
	name = "box of empty sandbags"
	illustration = "sandbag"

/obj/item/storage/box/emptysandbags/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/emptysandbag

/obj/item/storage/box/holy_grenades
	name = "box of holy hand grenades"
	desc = "Contains several grenades used to rapidly purge heresy."
	illustration = "grenade"

/obj/item/storage/box/holy_grenades/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/grenade/chem_grenade/holy

/obj/item/storage/box/fireworks
	name = "box of fireworks"
	desc = "Contains an assortment of fireworks."
	illustration = "sparkler"

/obj/item/storage/box/fireworks/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/sparkler = 3,
		/obj/item/grenade/firecracker = 3,
		/obj/item/toy/snappop = 1,
	))

/obj/item/storage/box/fireworks/dangerous
	desc = "This box has a small label on it stating that it's from the Gorlex Marauders. Contains an assortment of \"fireworks\"."

/obj/item/storage/box/fireworks/dangerous/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/sparkler
		. += /obj/item/grenade/firecracker

	if(prob(20))
		. += /obj/item/grenade/frag
	else
		. += /obj/item/toy/snappop

/obj/item/storage/box/firecrackers
	name = "box of firecrackers"
	desc = "A box filled with illegal firecrackers. You wonder who still makes these."
	icon_state = "syndiebox"
	illustration = "firecracker"

/obj/item/storage/box/firecrackers/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/grenade/firecracker

/obj/item/storage/box/sparklers
	name = "box of sparklers"
	desc = "A box of Nanotrasen brand sparklers, burns hot even in the cold of space-winter."
	illustration = "sparkler"

/obj/item/storage/box/sparklers/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/sparkler
