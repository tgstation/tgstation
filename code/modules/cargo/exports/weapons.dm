// Weapon exports. Stun batons, disablers, etc.

/datum/export/weapon
	include_subtypes = FALSE

/datum/export/weapon/baton
	cost = 100
	unit_name = "stun baton"
	export_types = list(/obj/item/weapon/melee/baton)
	exclude_types = list(/obj/item/weapon/melee/baton/cattleprod)
	include_subtypes = TRUE

/datum/export/weapon/knife
	cost = 750
	unit_name = "combat knife"
	export_types = list(/obj/item/weapon/kitchen/knife/combat)


/datum/export/weapon/taser
	cost = 250
	unit_name = "advanced taser"
	export_types = list(/obj/item/weapon/gun/energy/e_gun/advtaser)

/datum/export/weapon/laser
	cost = 250
	unit_name = "laser gun"
	export_types = list(/obj/item/weapon/gun/energy/laser)

/datum/export/weapon/disabler
	cost = 100
	unit_name = "disabler"
	export_types = list(/obj/item/weapon/gun/energy/disabler)

/datum/export/weapon/energy_gun
	cost = 900
	unit_name = "energy gun"
	export_types = list(/obj/item/weapon/gun/energy/e_gun)


/datum/export/weapon/wt550
	cost = 1400
	unit_name = "WT-550 automatic rifle"
	export_types = list(/obj/item/weapon/gun/ballistic/automatic/wt550)

/datum/export/weapon/shotgun
	cost = 350
	unit_name = "combat shotgun"
	export_types = list(/obj/item/weapon/gun/ballistic/shotgun/automatic/combat)


/datum/export/weapon/flashbang
	cost = 15
	unit_name = "flashbang grenade"
	export_types = list(/obj/item/weapon/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 15
	unit_name = "tear gas grenade"
	export_types = list(/obj/item/weapon/grenade/chem_grenade/teargas)


/datum/export/weapon/flash
	cost = 10
	unit_name = "handheld flash"
	export_types = list(/obj/item/device/assembly/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 3
	unit_name = "pair"
	message = "of handcuffs"
	export_types = list(/obj/item/weapon/restraints/handcuffs)