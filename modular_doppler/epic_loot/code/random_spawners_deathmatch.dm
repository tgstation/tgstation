/obj/effect/spawner/random/epic_loot/deathmatch_armor
	name = "deathmatch armor spawner"
	desc = "Automagically transforms into a set of armor."
	icon_state = "armor_random"
	loot = list(
		/obj/effect/spawner/random/lethalstation_armor_set = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/peacekeeper = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/peacekeeper_fake = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/hardened = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/archangel = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/koranda = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/kuroba = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/kuroba_super = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/val = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/sushi = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/filtre_light = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/filtre_heavy = 1,
	)

/obj/effect/spawner/random/lethalstation_armor_set
	name = "armor set spawner"
	icon_state = "lizard_boots"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/clothing/suit/armor/lethal_paper,
		/obj/item/clothing/head/helmet/sf_peacekeeper/debranded,
	)

/obj/effect/spawner/random/lethalstation_armor_set/peacekeeper
	loot = list(
		/obj/item/clothing/suit/armor/sf_peacekeeper,
		/obj/item/clothing/head/helmet/sf_peacekeeper,
	)

/obj/effect/spawner/random/lethalstation_armor_set/peacekeeper_fake
	loot = list(
		/obj/item/clothing/suit/armor/sf_peacekeeper/debranded,
		/obj/item/clothing/head/helmet/sf_peacekeeper/debranded,
	)

/obj/effect/spawner/random/lethalstation_armor_set/hardened
	loot = list(
		/obj/item/clothing/suit/armor/sf_hardened,
		/obj/item/clothing/head/helmet/toggleable/sf_hardened,
	)

/obj/effect/spawner/random/lethalstation_armor_set/archangel
	loot = list(
		/obj/item/clothing/suit/armor/sf_hardened/emt,
		/obj/item/clothing/head/helmet/toggleable/sf_hardened/emt,
	)

/obj/effect/spawner/random/lethalstation_armor_set/koranda
	loot = list(
		/obj/item/clothing/suit/armor/lethal_koranda,
		/obj/item/clothing/head/helmet/sf_peacekeeper,
	)

/obj/effect/spawner/random/lethalstation_armor_set/kuroba
	loot = list(
		/obj/item/clothing/suit/armor/lethal_kora_kulon,
		/obj/item/clothing/head/helmet/lethal_kulon_helmet,
	)

/obj/effect/spawner/random/lethalstation_armor_set/kuroba_super
	loot = list(
		/obj/item/clothing/suit/armor/lethal_kora_kulon/full_set,
		/obj/item/clothing/head/helmet/lethal_kulon_helmet/spawns_with_shield,
	)

/obj/effect/spawner/random/lethalstation_armor_set/val
	loot = list(
		/obj/item/clothing/suit/armor/sf_sacrificial,
		/obj/item/clothing/head/helmet/sf_sacrificial/spawns_with_shield,
	)

/obj/effect/spawner/random/lethalstation_armor_set/sushi
	loot = list(
		/obj/item/clothing/suit/armor/lethal_slick,
		/obj/item/clothing/head/helmet/lethal_larp_helmet,
	)

/obj/effect/spawner/random/lethalstation_armor_set/filtre_light
	loot = list(
		/obj/item/clothing/suit/armor/lethal_filtre,
		/obj/item/clothing/head/helmet/lethal_filtre_helmet,
	)

/obj/effect/spawner/random/lethalstation_armor_set/filtre_heavy
	loot = list(
		/obj/item/clothing/suit/armor/lethal_filtre/heavy,
		/obj/item/clothing/head/helmet/lethal_filtre_helmet,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_silly_arms
	name = "deathmatch silly arms spawner"
	desc = "Automagically transforms into a not-so-serious firearm."
	icon_state = "random_common_gun"
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol/sol = 1,
		/obj/item/gun/ballistic/automatic/pistol/sol/evil = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/signalis_real = 1,
		/obj/item/gun/energy/e_gun/mini = 1,
		/obj/item/gun/ballistic/automatic/pistol/weevil = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/kurwa = 1,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_silly_arms_blue
	name = "deathmatch silly arms spawner (blue)"
	desc = "Automagically transforms into a not-so-serious firearm."
	icon_state = "random_common_gun_blue"
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol/trappiste = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/takbok = 1,
		/obj/item/gun/ballistic/automatic/sol_smg = 1,
		/obj/item/gun/ballistic/automatic/pistol/plasma_marksman = 1,
		/obj/item/gun/ballistic/automatic/miecz = 1,
		/obj/item/gun/ballistic/automatic/seiba_smg = 1,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually
	name = "deathmatch single weapon spawner"

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/signalis_real
	loot = list(
		/obj/item/gun/ballistic/revolver/sol,
		/obj/item/ammo_box/magazine/ammo_stack/c35_sol/prefilled,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/takbok
	loot = list(
		/obj/item/gun/ballistic/revolver/takbok,
		/obj/item/ammo_box/magazine/ammo_stack/c585_trappiste/prefilled,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/kurwa
	loot = list(
		/obj/item/gun/ballistic/revolver/shotgun_revolver,
		/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/flechette,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_serious_arms
	name = "deathmatch serious arms spawner"
	desc = "Automagically transforms into a super serious firearm."
	icon_state = "random_rare_gun"
	loot = list(
		/obj/item/gun/ballistic/automatic/sol_grenade_launcher = 1,
		/obj/item/gun/ballistic/automatic/xhihao_smg = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/osako = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/shotgun = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/scoped_osako = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/gun/ballistic/automatic/lanca = 1,
		/obj/item/gun/ballistic/automatic/suppressed_rifle = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/lesbian_gun = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/super_shotgun = 1,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/osako
	loot = list(
		/obj/item/gun/ballistic/rifle/osako,
		/obj/item/ammo_box/magazine/ammo_stack/c310_strilka/prefilled,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/scoped_osako
	loot = list(
		/obj/item/gun/ballistic/rifle/osako/scoped,
		/obj/item/ammo_box/magazine/ammo_stack/c310_strilka/prefilled/kedown,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/shotgun
	loot = list(
		/obj/item/gun/ballistic/shotgun/riot/sol/thunderdome,
		/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/lesbian_gun
	loot = list(
		/obj/item/gun/ballistic/marsian_super_rifle,
		/obj/item/ammo_box/magazine/ammo_stack/c8marsian/prefilled,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/super_shotgun
	loot = list(
		/obj/item/gun/ballistic/shotgun/ramu,
		/obj/item/ammo_box/magazine/ammo_stack/s6gauge/prefilled,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_serious_arms_blue
	name = "deathmatch serious arms spawner (blue)"
	desc = "Automagically transforms into a super serious firearm."
	icon_state = "random_rare_gun_blue"
	loot = list(
		/obj/item/gun/ballistic/automatic/sol_rifle = 1,
		/obj/item/gun/ballistic/automatic/sol_rifle/evil = 1,
		/obj/item/gun/ballistic/automatic/sol_rifle/machinegun = 1,
		/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil = 1,
		/obj/item/gun/ballistic/automatic/xhihao_smg = 1,
		/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/shotgun_evil = 1,
		/obj/item/gun/energy/laser/hellgun = 1,
		/obj/item/gun/energy/tesla_cannon = 1,
		/obj/item/gun/ballistic/automatic/suppressed_rifle/marksman = 1,
		/obj/item/gun/ballistic/automatic/nomi_shotgun = 1,
		/obj/item/gun/ballistic/automatic/karim = 1,
	)

/obj/effect/spawner/random/lethalstation_armor_set/gun_actually/shotgun_evil
	loot = list(
		/obj/item/gun/ballistic/shotgun/riot/sol/evil/thunderdome,
		/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/flechette,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_grenade_or_explosive
	name = "deathmatch grenade or explosive spawner"
	desc = "Automagically transforms into some kind of explosive or grenade."
	icon_state = "random_bomb"
	loot = list(
		/obj/item/grenade/syndieminibomb/concussion/impact = 1,
		/obj/item/grenade/frag/impact = 1,
		/obj/item/grenade/antigravity = 1,
		/obj/item/grenade/barrier = 1,
		/obj/item/grenade/flashbang = 1,
		/obj/item/grenade/frag = 1,
		/obj/item/grenade/frag/mega = 1,
		/obj/item/grenade/mirage = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/grenade/stingbang = 1,
		/obj/item/grenade/stingbang/mega = 1,
		/obj/item/grenade/iedcasing/spawned = 1,
		/obj/item/grenade/syndieminibomb/concussion = 1,
		/obj/item/grenade/syndieminibomb = 1,
		/obj/item/grenade/clusterbuster/random = 1,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_medkit
	name = "deathmatch medkit spawner"
	desc = "Automagically transforms into a random medkit of some sort."
	icon_state = "random_medkit"
	loot = list(
		/obj/item/storage/pouch/cin_medkit/thunderdome = 1,
		/obj/item/storage/pouch/medical/thunderdome = 1,
		/obj/item/storage/pouch/medical/firstaid/thunderdome = 1,
		/obj/item/storage/medkit/civil_defense/stocked = 1,
		/obj/item/storage/medkit/civil_defense/thunderdome = 1,
		/obj/item/storage/medkit/frontier/stocked = 1,
		/obj/item/storage/medkit/combat_surgeon/stocked = 1,
		/obj/item/storage/medkit/robotic_repair/stocked = 1,
		/obj/item/storage/medkit/robotic_repair/preemo/stocked = 1,
		/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked = 1,
		/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked = 1,
		/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked/super = 1,
	)

/obj/effect/spawner/random/epic_loot/deathmatch_med_stack_item
	name = "deathmatch advanced medical item spawner"
	desc = "Automagically transforms into a random advanced medical stack item."
	icon_state = "random_med_stack_adv"
	loot = list(
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/suture/coagulant = 1,
		/obj/item/stack/medical/suture/bloody = 1,
		/obj/item/stack/medical/suture/medicated = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/ointment/red_sun = 1,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/stack/medical/mesh/bloody = 1,
		/obj/item/stack/medical/mesh/advanced = 1,
		/obj/item/stack/medical/aloe = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/bandage = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/medical/poultice = 1,
		/obj/item/stack/medical/wound_recovery = 1,
		/obj/item/stack/medical/wound_recovery/rapid_coagulant = 1,
		/obj/item/reagent_containers/blood/random = 1,
		/obj/item/stack/medical/wound_recovery/robofoam = 1,
		/obj/item/stack/medical/wound_recovery/robofoam_super = 1,
		/obj/item/reagent_containers/pill/robotic_patch/synth_repair = 1,
		// Medigels
		/obj/item/reagent_containers/medigel/libital = 1,
		/obj/item/reagent_containers/medigel/aiuri = 1,
		/obj/item/reagent_containers/medigel/synthflesh = 1,
		// Pill bottles
		/obj/item/storage/pill_bottle/iron = 1,
		/obj/item/storage/pill_bottle/painkiller = 1,
		/obj/item/storage/pill_bottle/probital = 1,
		// Tools
		/obj/item/bonesetter = 1,
		/obj/item/cautery = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/healthanalyzer/simple = 1,
		/obj/item/hemostat = 1,
		// Pens
		/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/twitch = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol = 1,
	)

/obj/item/storage/pouch/medical/firstaid/thunderdome

/obj/item/storage/pouch/medical/firstaid/thunderdome/PopulateContents()
	for(var/iterator in 1 to atom_storage.max_slots)
		new /obj/effect/spawner/random/epic_loot/deathmatch_med_stack_item(src)

/obj/item/storage/pouch/medical/thunderdome

/obj/item/storage/pouch/medical/thunderdome/PopulateContents()
	for(var/iterator in 1 to atom_storage.max_slots)
		new /obj/effect/spawner/random/epic_loot/deathmatch_med_stack_item(src)

/obj/item/storage/pouch/cin_medkit/thunderdome

/obj/item/storage/pouch/cin_medkit/thunderdome/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 8

/obj/item/storage/pouch/cin_medkit/thunderdome/PopulateContents()
	for(var/iterator in 1 to atom_storage.max_slots)
		new /obj/effect/spawner/random/epic_loot/deathmatch_med_stack_item(src)

/obj/effect/spawner/random/epic_loot/deathmatch_funny
	name = "deathmatch funnies spawner"
	desc = "Automagically transforms into a funny."
	icon_state = "random_tool"
	loot = list(
		/obj/item/melee/energy/sword = 1,
		/obj/item/melee/energy/axe = 1,
		/obj/item/fireaxe/boardingaxe = 1,
		/obj/item/fireaxe = 1,
		/obj/item/storage/belt/sabre = 1,
		/obj/item/autosurgeon/syndicate/sandy = 1,
		/obj/item/autosurgeon/syndicate/razorwire = 1,
		/obj/item/shield/ballistic = 1,
		/obj/item/shield/energy/advanced = 1,
		/obj/item/shield/energy = 1,
		/obj/item/melee/baseball_bat/ablative = 1,
		/obj/item/melee/baseball_bat/homerun = 1,
		/obj/item/clothing/gloves/tackler/combat = 1,
		/obj/item/clothing/gloves/race = 1,
		/obj/item/clothing/gloves/rapid = 1,
		/obj/item/shield/riot/flash = 1,
		/obj/item/knife/combat = 1,
	)
