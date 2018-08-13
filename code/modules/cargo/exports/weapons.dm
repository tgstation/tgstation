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
	cost = 100
	unit_name = "combat knife"
	export_types = list(/obj/item/kitchen/knife/combat)


/datum/export/weapon/taser
	cost = 200
	unit_name = "advanced taser"
	export_types = list(/obj/item/gun/energy/e_gun/advtaser)

/datum/export/weapon/laser
	cost = 200
	unit_name = "laser gun"
	export_types = list(/obj/item/gun/energy/laser)

/datum/export/weapon/disabler
	cost = 100
	unit_name = "disabler"
	export_types = list(/obj/item/gun/energy/disabler)

/datum/export/weapon/energy_gun
	cost = 300
	unit_name = "energy gun"
	export_types = list(/obj/item/gun/energy/e_gun)

/datum/export/weapon/wt550
	cost = 300
	unit_name = "WT-550 automatic rifle"
	export_types = list(/obj/item/gun/ballistic/automatic/wt550)

/datum/export/weapon/shotgun
	cost = 300
	unit_name = "combat shotgun"
	export_types = list(/obj/item/gun/ballistic/shotgun/automatic/combat)


/datum/export/weapon/flashbang
	cost = 5
	unit_name = "flashbang grenade"
	export_types = list(/obj/item/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 5
	unit_name = "tear gas grenade"
	export_types = list(/obj/item/grenade/chem_grenade/teargas)


/datum/export/weapon/flash
	cost = 5
	unit_name = "handheld flash"
	export_types = list(/obj/item/assembly/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 3
	unit_name = "pair"
	message = "of handcuffs"
	export_types = list(/obj/item/restraints/handcuffs)

// relics of lavaland

/datum/export/weapon/hierophant_club
	cost = 40000
	unit_name = "Hierophant Club"
	export_types = list(/obj/item/hierophant_club)

/datum/export/weapon/legion_stormstaff
	cost = 40000
	unit_name = "Staff of Storms"
	export_types = list(/obj/item/staff/storm)

/datum/export/weapon/drake_lavastaff
	cost = 40000
	unit_name = "Lava Staff"
	export_types = list(/obj/item/lava_staff)

/datum/export/weapon/drake_blood
	cost = 40000
	unit_name = "Bottle of Dragon's Blood"
	export_types = list(/obj/item/dragons_blood)

/datum/export/weapon/blood_drunk_cleaving_saw
	cost = 40000
	unit_name = "Cleaving Saw"
	export_types = list(/obj/item/melee/transforming/cleaving_saw)

/datum/export/weapon/colossus_vocalcords
	cost = 40000
	unit_name = "Angelic Vocal Cords"
	export_types = list(/obj/item/organ/vocal_cords/colossus)

/datum/export/weapon/colossus_crystal
	cost = 40000
	unit_name = "Anomalous Crystal"
	export_types = list(/obj/machinery/anomalous_crystal)

/datum/export/weapon/bubblegum_mayhem
	cost = 40000
	unit_name = "Mayhem in a Bottle"
	export_types = list(/obj/item/mayhem)

/datum/export/weapon/bubblegum_blood_contract
	cost = 40000
	unit_name = "Blood Contract"
	export_types = list(/obj/item/blood_contract)

/datum/export/weapon/bubblegum_spellblade
	cost = 40000
	unit_name = "Spellblade"
	export_types = list(/obj/item/gun/magic/staff/spellblade)

/datum/export/weapon/bubblegum_hev_suit
	cost = 30000
	unit_name = "Hostile Environment Suit"
	export_types = list(/obj/item/clothing/suit/space/hostile_environment)

/datum/export/weapon/bubblegum_hev_helmet
	cost = 10000
	unit_name = "Hostile Environment Helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/hostile_environment)

//Artifacts of lavaland

/datum/export/weapon/immortality_talisman
	cost = 10000
	unit_name = "Immortality Talisman"
	export_types = list(/obj/item/immortality_talisman)

/datum/export/weapon/babel
	cost = 10000
	unit_name = "Book of Babel"
	export_types = list(/obj/item/book_of_babel)

/datum/export/weapon/hook
	cost = 10000
	unit_name = "Meat Hook"
	export_types = list(/obj/item/gun/magic/hook)

/datum/export/weapon/shipbottle //the price for not breaking the bottle.
	cost = 20000
	unit_name = "Ship in a Bottle"
	export_types = list(/obj/item/ship_in_a_bottle)

/datum/export/weapon/tarot //price for sacraficing a very profitiable ally
	cost = 20000
	unit_name = "Tarot Cards"
	export_types = list(/obj/item/guardiancreator)

/datum/export/weapon/wisplantern //thermals on lavaland
	cost = 10000
	unit_name = "Wisp Lantern"
	export_types = list(/obj/item/wisp_lantern)

/datum/export/weapon/flight //if xenobiology ever reaches the point to get these without shuttle being called they deserve it
	cost = 10000
	unit_name = "Strange Elixir"
	export_types = list(/obj/item/reagent_containers/glass/bottle/potion/flight)

/datum/export/weapon/cheart //is a very powerfull healing artifact in the robust hands
	cost = 10000
	unit_name = "Cursed Heart"
	export_types = list(/obj/item/organ/heart/cursed/wizard)

/datum/export/weapon/ckatana
	cost = 10000
	unit_name = "Katana"
	export_types = list(/obj/item/katana/cursed)

/datum/export/weapon/geye //xray
	cost = 10000
	unit_name = "Eye of God"
	export_types = list(/obj/item/clothing/glasses/godeye)

/datum/export/weapon/spectral
	cost = 10000
	unit_name = "Spectral Sword"
	export_types = list(/obj/item/melee/ghost_sword)

/datum/export/weapon/narnar_hardsuit
	cost = 10000
	unit_name = "Nar-Sien Hardened Armor"
	export_types = list(/obj/item/clothing/suit/space/hardsuit/cult)

/datum/export/weapon/asclepius_rod
	cost = 20000
	unit_name = "Rod of Asclepius"
	export_types = list(/obj/item/rod_of_asclepius)

/datum/export/weapon/cursed_heart
	cost = 5000 //you should be paying CentCom for this
	unit_name = "Cursed Heart"
	export_types = list(/obj/item/organ/heart/cursed/wizard)

/datum/export/weapon/paranormal_hardsuit 
	cost = 25000 //makes the narnar hardsuit look like a bathrobe
	unit_name = "Paranormal Hardsuit"
	export_types = list(/obj/item/clothing/suit/space/hardsuit/ert/paranormal) //covers berserker and inquisitor hardsuits

/datum/export/weapon/voodoo_doll
	cost = 10000
	unit_name = "Voodoo Doll"
	export_types = list(/obj/item/voodoo)

/datum/export/weapon/inferno_clusterbuster
	cost = 10000
	unit_name = "Inferno Pattern Clusterbuster Grenade"
	export_types = list(/obj/item/grenade/clusterbuster/inferno)

/datum/export/weapon/memento_mori
	cost = 10000
	unit_name = "Memento Mori"
	export_types = list(/obj/item/clothing/neck/necklace/memento_mori)
