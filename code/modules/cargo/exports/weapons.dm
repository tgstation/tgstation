// Weapon exports. Stun batons, disablers, etc.

/datum/export/weapon
	include_subtypes = FALSE

/datum/export/weapon/baton
	cost = 100
	unit_name = "stun baton"
	export_types = list(/obj/item/melee/baton)
	exclude_types = list(/obj/item/melee/baton/cattleprod)
	include_subtypes = TRUE

/datum/export/weapon/knife
	cost = 750
	unit_name = "combat knife"
	export_types = list(/obj/item/kitchen/knife/combat)


/datum/export/weapon/taser
	cost = 250
	unit_name = "advanced taser"
	export_types = list(/obj/item/gun/energy/e_gun/advtaser)

/datum/export/weapon/laser
	cost = 250
	unit_name = "laser gun"
	export_types = list(/obj/item/gun/energy/laser)

/datum/export/weapon/disabler
	cost = 100
	unit_name = "disabler"
	export_types = list(/obj/item/gun/energy/disabler)

/datum/export/weapon/energy_gun
	cost = 900
	unit_name = "energy gun"
	export_types = list(/obj/item/gun/energy/e_gun)


/datum/export/weapon/wt550
	cost = 1400
	unit_name = "WT-550 automatic rifle"
	export_types = list(/obj/item/gun/ballistic/automatic/wt550)

/datum/export/weapon/shotgun
	cost = 350
	unit_name = "combat shotgun"
	export_types = list(/obj/item/gun/ballistic/shotgun/automatic/combat)


/datum/export/weapon/flashbang
	cost = 15
	unit_name = "flashbang grenade"
	export_types = list(/obj/item/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 15
	unit_name = "tear gas grenade"
	export_types = list(/obj/item/grenade/chem_grenade/teargas)


/datum/export/weapon/flash
	cost = 10
	unit_name = "handheld flash"
	export_types = list(/obj/item/device/assembly/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 3
	unit_name = "pair"
	message = "of handcuffs"
	export_types = list(/obj/item/restraints/handcuffs)
	
// relics of lavaland

/datum/export/weapon/hierophant
	cost = 40000
	unit_name = "Hierophant Club"
	export_types = list(/obj/item/hierophant_club)
	
/datum/export/weapon/lava
	cost = 40000
	unit_name = "Lava Staff"
	export_types = list(/obj/item/lava_staff)
	
/datum/export/weapon/cleaving_saw
	cost = 40000
	unit_name = "Cleaving Saw"
	export_types = list(/obj/item/melee/transforming/cleaving_saw)
	
/datum/export/weapon/mayhem
	cost = 40000
	unit_name = "Mayhem in a bottle"
	export_types = list(/obj/item/mayhem)
	
/datum/export/weapon/blood_contract
	cost = 40000
	unit_name = "Blood Contract"
	export_types = list(/obj/item/blood_contract)
	
//Artifacts of lavaland

/datum/export/weapon/immortality_talisman
	cost = 10000
	unit_name = "Immortality Talisman"
	export_types = list(/obj/item/device/immortality_talisman)
	
/datum/export/weapon/babel
	cost = 10000
	unit_name = "Book of Babel"
	export_types = list(/obj/item/book_of_babel)
	
/datum/export/weapon/lifesteal //Only the disk if somoene removes it from rnd they cant get it back anymore
	cost = 10000
	unit_name = "Lifesteal mod disk"
	export_types = list(/obj/item/borg/upgrade/modkit/lifesteal)
	
/datum/export/weapon/Inferno
	cost = 10000
	unit_name = "Inferno"
	export_types = list(/obj/item/grenade/clusterbuster/inferno)
	
/datum/export/weapon/hook
	cost = 10000
	unit_name = "Meat hook"
	export_types = list(/obj/item/gun/magic/hook)
	
/datum/export/weapon/red_cube // first half
	cost = 5000
	unit_name = "Red cube"
	export_types = list(/obj/item/device/warp_cube/red)
	
/datum/export/weapon/blue_cube // second half
	cost = 5000
	unit_name = "Blue cube"
	export_types = list(/obj/item/device/warp_cube)
	
/datum/export/weapon/shipbottle
	cost = 10000
	unit_name = "Ship in a bottle"
	export_types = list(/obj/item/ship_in_a_bottle)
	
/datum/export/weapon/beserker
	cost = 10000
	unit_name = "Beserker suit"
	export_types = list(/obj/item/clothing/suit/space/hardsuit/ert/paranormal/beserker)
	
/datum/export/weapon/tarotcards
	cost = 20000
	unit_name = "Tarot cards"
	export_types = list(/obj/item/guardiancreator)
	
/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	cost = 10000
	unit_name = "Inquisitor hardsuit"
	export_types = list(/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor)
	
	
