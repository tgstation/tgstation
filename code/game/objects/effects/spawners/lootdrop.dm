/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	anchored = TRUE // Stops persistent lootdrop spawns from being shoved into lockers
	var/list/loot //a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/lootcount = 1 //how many items will be spawned
	var/lootdoubles = TRUE //if the same item can be spawned twice
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
	var/spawn_on_init = TRUE	// Whether the spawner should immediately spawn loot and cleanup on Initialize()
	var/spawn_all_loot = FALSE // Whether the spawner should spawn all the loot in the list
	var/spawn_loot_chance = 100 // The chance for the spawner to create loot (ignores lootcount)
	var/spawn_scatter_radius = 0	//determines how big of a range (in tiles) we should scatter things in.

/obj/effect/spawner/lootdrop/Initialize(mapload)
	. = ..()

	if(spawn_on_init)
		spawn_loot()
		return INITIALIZE_HINT_QDEL

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/lootdrop/proc/spawn_loot(lootcount_override)
	if(!prob(spawn_loot_chance))
		return INITIALIZE_HINT_QDEL

	var/list/spawn_locations = get_spawn_locations(spawn_scatter_radius)
	var/lootcount = isnull(lootcount_override) ? src.lootcount : lootcount_override

	if(spawn_all_loot)
		lootcount = INFINITY
		lootdoubles = FALSE

	if(loot?.len)
		var/loot_spawned = 0
		while((lootcount-loot_spawned) && loot.len)
			var/lootspawn = pickweight(loot)
			while(islist(lootspawn))
				lootspawn = pickweight(lootspawn)
			if(!lootdoubles)
				loot.Remove(lootspawn)
			if(lootspawn && (spawn_scatter_radius == 0 || spawn_locations.len))
				var/turf/spawn_loc = loc
				if(spawn_scatter_radius > 0)
					spawn_loc = pick_n_take(spawn_locations)

				var/atom/movable/spawned_loot = new lootspawn(spawn_loc)

				if (!fan_out_items)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else
					if (loot_spawned)
						spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
			loot_spawned++

///If the spawner has a spawn_scatter_radius set, this creates a list of nearby turfs available
/obj/effect/spawner/lootdrop/proc/get_spawn_locations(radius)
	var/list/scatter_locations = list()

	if(radius >= 0)
		for(var/turf/turf_in_view in view(radius, get_turf(src)))
			if(!turf_in_view.density)
				scatter_locations += turf_in_view

	return scatter_locations

/obj/effect/spawner/lootdrop/arcade_boards
	name = "arcade board spawner"
	lootdoubles = FALSE
	loot = list()

/obj/effect/spawner/lootdrop/arcade_boards/Initialize(mapload)
	loot += subtypesof(/obj/item/circuitboard/computer/arcade)
	return ..()


/obj/effect/spawner/lootdrop/armory_contraband
	name = "armory contraband gun spawner"
	lootdoubles = FALSE

	loot = list(
				/obj/item/gun/ballistic/automatic/pistol = 8,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/gun/ballistic/automatic/pistol/deagle,
				/obj/item/gun/ballistic/revolver/mateba
				)

/obj/effect/spawner/lootdrop/armory_contraband/metastation
	loot = list(/obj/item/gun/ballistic/automatic/pistol = 5,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/gun/ballistic/automatic/pistol/deagle,
				/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
				/obj/item/gun/ballistic/revolver/mateba)

/obj/effect/spawner/lootdrop/armory_contraband/donutstation
	loot = list(/obj/item/grenade/clusterbuster/teargas = 5,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/bikehorn/golden,
				/obj/item/grenade/clusterbuster,
				/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
				/obj/item/gun/ballistic/revolver/mateba)

/obj/effect/spawner/lootdrop/prison_contraband
	name = "prison contraband loot spawner"
	loot = list(/obj/item/clothing/mask/cigarette/space_cigarette = 4,
				/obj/item/clothing/mask/cigarette/robust = 2,
				/obj/item/clothing/mask/cigarette/carp = 3,
				/obj/item/clothing/mask/cigarette/uplift = 2,
				/obj/item/clothing/mask/cigarette/dromedary = 3,
				/obj/item/clothing/mask/cigarette/robustgold = 1,
				/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
				/obj/item/storage/fancy/cigarettes = 3,
				/obj/item/clothing/mask/cigarette/rollie/cannabis = 4,
				/obj/item/toy/crayon/spraycan = 2,
				/obj/item/crowbar = 1,
				/obj/item/assembly/flash/handheld = 1,
				/obj/item/restraints/handcuffs/cable/zipties = 1,
				/obj/item/restraints/handcuffs = 1,
				/obj/item/radio/off = 1,
				/obj/item/lighter = 3,
				/obj/item/storage/box/matches = 3,
				/obj/item/reagent_containers/syringe/contraband/space_drugs = 1,
				/obj/item/reagent_containers/syringe/contraband/krokodil = 1,
				/obj/item/reagent_containers/syringe/contraband/crank = 1,
				/obj/item/reagent_containers/syringe/contraband/methamphetamine = 1,
				/obj/item/reagent_containers/syringe/contraband/bath_salts = 1,
				/obj/item/reagent_containers/syringe/contraband/fentanyl = 1,
				/obj/item/reagent_containers/syringe/contraband/morphine = 1,
				/obj/item/storage/pill_bottle/happy = 1,
				/obj/item/storage/pill_bottle/lsd = 1,
				/obj/item/storage/pill_bottle/psicodine = 1,
				/obj/item/reagent_containers/food/drinks/beer = 4,
				/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
				/obj/item/paper/fluff/jobs/prisoner/letter = 1,
				/obj/item/grenade/smokebomb = 1,
				/obj/item/flashlight/seclite = 1,
				/obj/item/tailclub = 1, //want to buy makeshift wooden club sprite
				/obj/item/kitchen/knife/shiv = 4,
				/obj/item/kitchen/knife/shiv/carrot = 1,
				/obj/item/kitchen/knife = 1,
				/obj/item/storage/wallet/random = 1,
				/obj/item/pda = 1
				)

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"
	desc = "Come on Lady Luck, spawn me a pair of sunglasses."
	spawn_on_init = FALSE
	// see code/_globalvars/lists/maintenance_loot.dm for loot table

/obj/effect/spawner/lootdrop/maintenance/examine(mob/user)
	. = ..()
	. += span_info("This spawner has an effective loot count of [get_effective_lootcount()].")

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	. = ..()
	// There is a single callback in SSmapping to spawn all delayed maintenance loot
	// so we don't just make one callback per loot spawner
	GLOB.maintenance_loot_spawners += src
	loot = GLOB.maintenance_loot

	// Late loaded templates like shuttles can have maintenance loot
	if(SSticker.current_state >= GAME_STATE_SETTING_UP)
		spawn_loot()
		hide()

/obj/effect/spawner/lootdrop/maintenance/Destroy()
	GLOB.maintenance_loot_spawners -= src
	return ..()

/obj/effect/spawner/lootdrop/maintenance/proc/hide()
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/spawner/lootdrop/maintenance/proc/get_effective_lootcount()
	var/effective_lootcount = lootcount

	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		effective_lootcount = FLOOR(lootcount * 1.5, 1)

	else if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		effective_lootcount = FLOOR(lootcount * 0.5, 1)

	return effective_lootcount

/obj/effect/spawner/lootdrop/maintenance/spawn_loot(lootcount_override)
	if(isnull(lootcount_override))
		lootcount_override = get_effective_lootcount()
	. = ..()

	// In addition, closets that are closed will have the maintenance loot inserted inside.
	for(var/obj/structure/closet/closet in get_turf(src))
		if(!closet.opened)
			closet.take_contents()

/obj/effect/spawner/lootdrop/maintenance/two
	name = "2 x maintenance loot spawner"
	lootcount = 2

/obj/effect/spawner/lootdrop/maintenance/three
	name = "3 x maintenance loot spawner"
	lootcount = 3

/obj/effect/spawner/lootdrop/maintenance/four
	name = "4 x maintenance loot spawner"
	lootcount = 4

/obj/effect/spawner/lootdrop/maintenance/five
	name = "5 x maintenance loot spawner"
	lootcount = 5

/obj/effect/spawner/lootdrop/maintenance/six
	name = "6 x maintenance loot spawner"
	lootcount = 6

/obj/effect/spawner/lootdrop/maintenance/seven
	name = "7 x maintenance loot spawner"
	lootcount = 7

/obj/effect/spawner/lootdrop/maintenance/eight
	name = "8 x maintenance loot spawner"
	lootcount = 8

/obj/effect/spawner/lootdrop/crate_spawner
	name = "lootcrate spawner" //USE PROMO CODE "SELLOUT" FOR 20% OFF!
	lootdoubles = FALSE

	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80
				)

// Minor lootdrops follow

/obj/effect/spawner/lootdrop/aimodule_harmless // These shouldn't allow the AI to start butchering people
	name = "harmless AI module spawner"
	loot = list(
				/obj/item/ai_module/core/full/asimov,
				/obj/item/ai_module/core/full/asimovpp,
				/obj/item/ai_module/core/full/hippocratic,
				/obj/item/ai_module/core/full/paladin_devotion,
				/obj/item/ai_module/core/full/paladin
				)

/obj/effect/spawner/lootdrop/aimodule_neutral // These shouldn't allow the AI to start butchering people without reason
	name = "neutral AI module spawner"
	loot = list(
				/obj/item/ai_module/core/full/corp,
				/obj/item/ai_module/core/full/maintain,
				/obj/item/ai_module/core/full/drone,
				/obj/item/ai_module/core/full/peacekeeper,
				/obj/item/ai_module/core/full/reporter,
				/obj/item/ai_module/core/full/robocop,
				/obj/item/ai_module/core/full/liveandletlive,
				/obj/item/ai_module/core/full/hulkamania
				)

/obj/effect/spawner/lootdrop/aimodule_harmful // These will get the shuttle called
	name = "harmful AI module spawner"
	loot = list(
				/obj/item/ai_module/core/full/antimov,
				/obj/item/ai_module/core/full/balance,
				/obj/item/ai_module/core/full/tyrant,
				/obj/item/ai_module/core/full/thermurderdynamic,
				/obj/item/ai_module/core/full/damaged,
				/obj/item/ai_module/reset/purge
				)

// Tech storage circuit board spawners

/obj/effect/spawner/lootdrop/techstorage
	name = "generic circuit board spawner"
	lootdoubles = FALSE
	fan_out_items = TRUE
	lootcount = INFINITY

/obj/effect/spawner/lootdrop/techstorage/service
	name = "service circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/arcade/battle,
				/obj/item/circuitboard/computer/arcade/orion_trail,
				/obj/item/circuitboard/machine/autolathe,
				/obj/item/circuitboard/computer/mining,
				/obj/item/circuitboard/machine/ore_redemption,
				/obj/item/circuitboard/machine/mining_equipment_vendor,
				/obj/item/circuitboard/machine/microwave,
				/obj/item/circuitboard/machine/chem_dispenser/drinks,
				/obj/item/circuitboard/machine/chem_dispenser/drinks/beer,
				/obj/item/circuitboard/computer/slot_machine
				)

/obj/effect/spawner/lootdrop/techstorage/rnd
	name = "RnD circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/aifixer,
				/obj/item/circuitboard/machine/rdserver,
				/obj/item/circuitboard/machine/mechfab,
				/obj/item/circuitboard/machine/circuit_imprinter/department,
				/obj/item/circuitboard/computer/teleporter,
				/obj/item/circuitboard/machine/destructive_analyzer,
				/obj/item/circuitboard/computer/rdconsole,
				/obj/item/circuitboard/computer/scan_consolenew,
				/obj/item/circuitboard/machine/dnascanner
				)

/obj/effect/spawner/lootdrop/techstorage/security
	name = "security circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/secure_data,
				/obj/item/circuitboard/computer/security,
				/obj/item/circuitboard/computer/prisoner
				)

/obj/effect/spawner/lootdrop/techstorage/engineering
	name = "engineering circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/atmos_alert,
				/obj/item/circuitboard/computer/stationalert,
				/obj/item/circuitboard/computer/powermonitor
				)

/obj/effect/spawner/lootdrop/techstorage/tcomms
	name = "tcomms circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/message_monitor,
				/obj/item/circuitboard/machine/telecomms/broadcaster,
				/obj/item/circuitboard/machine/telecomms/bus,
				/obj/item/circuitboard/machine/telecomms/server,
				/obj/item/circuitboard/machine/telecomms/receiver,
				/obj/item/circuitboard/machine/telecomms/processor,
				/obj/item/circuitboard/machine/announcement_system,
				/obj/item/circuitboard/computer/comm_server,
				/obj/item/circuitboard/computer/comm_monitor
				)

/obj/effect/spawner/lootdrop/techstorage/medical
	name = "medical circuit board spawner"
	loot = list(
				/obj/item/circuitboard/machine/chem_dispenser,
				/obj/item/circuitboard/computer/med_data,
				/obj/item/circuitboard/machine/smoke_machine,
				/obj/item/circuitboard/machine/chem_master,
				/obj/item/circuitboard/computer/pandemic
				)

/obj/effect/spawner/lootdrop/techstorage/ai
	name = "secure AI circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/aiupload,
				/obj/item/circuitboard/computer/borgupload,
				/obj/item/circuitboard/aicore
				)

/obj/effect/spawner/lootdrop/techstorage/command
	name = "secure command circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/crew,
				/obj/item/circuitboard/computer/communications
				)

/obj/effect/spawner/lootdrop/techstorage/rnd_secure
	name = "secure RnD circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/mecha_control,
				/obj/item/circuitboard/computer/apc_control,
				/obj/item/circuitboard/computer/robotics
				)

//finds the probabilities of items spawning from a loot spawner's loot pool
/obj/item/loot_table_maker
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	var/spawner_to_test = /obj/effect/spawner/lootdrop/maintenance //what lootdrop spawner to use the loot pool of
	var/loot_count = 180 //180 is about how much maint loot spawns per map as of 11/14/2019
	//result outputs
	var/list/spawned_table //list of all items "spawned" and how many
	var/list/stat_table //list of all items "spawned" and their occurrance probability

/obj/item/loot_table_maker/Initialize()
	. = ..()
	make_table()

/obj/item/loot_table_maker/attack_self(mob/user)
	to_chat(user, "Loot pool re-rolled.")
	make_table()

/obj/item/loot_table_maker/proc/make_table()
	spawned_table = list()
	stat_table = list()
	var/obj/effect/spawner/lootdrop/spawner_to_table = new spawner_to_test
	var/lootpool = spawner_to_table.loot
	qdel(spawner_to_table)
	for(var/i in 1 to loot_count)
		var/loot_spawn = pick_loot(lootpool)
		if(!(loot_spawn in spawned_table))
			spawned_table[loot_spawn] = 1
		else
			spawned_table[loot_spawn] += 1
	stat_table += spawned_table
	for(var/item in stat_table)
		stat_table[item] /= loot_count

/obj/item/loot_table_maker/proc/pick_loot(lootpool) //selects path from loot table and returns it
	var/lootspawn = pickweight(lootpool)
	while(islist(lootspawn))
		lootspawn = pickweight(lootspawn)
	return lootspawn

/obj/effect/spawner/lootdrop/space
	name = "generic space ruin loot spawner"
	lootcount = 1

/// Space loot spawner. Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
/obj/effect/spawner/lootdrop/space/fancytech
	lootcount = 2
	loot = list(
		/obj/item/raw_anomaly_core/random = 1,
		/obj/item/disk/tech_disk/spaceloot = 1,
		/obj/item/camera_bug = 1
	)

/// Space loot spawner. Some sort of random and rare tool. Only a single drop.
/obj/effect/spawner/lootdrop/space/fancytool
	lootcount = 1
	loot = list(
		/obj/item/wrench/abductor = 1,
		/obj/item/wirecutters/abductor = 1,
		/obj/item/screwdriver/abductor = 1,
		/obj/item/crowbar/abductor = 1,
		/obj/item/weldingtool/abductor = 1,
		/obj/item/multitool/abductor = 1,
		/obj/item/scalpel/alien = 1,
		/obj/item/hemostat/alien = 1,
		/obj/item/retractor/alien = 1,
		/obj/item/circular_saw/alien = 1,
		/obj/item/surgicaldrill/alien = 1,
		/obj/item/cautery/alien = 1,
		/obj/item/wrench/caravan = 1,
		/obj/item/wirecutters/caravan = 1,
		/obj/item/screwdriver/caravan = 1,
		/obj/item/crowbar/red/caravan = 1
	)

/// Mail loot spawner. Some sort of random and rare building tool. No alien tech here.
/obj/effect/spawner/lootdrop/space/fancytool/engineonly
	loot = list(
		/obj/item/wrench/caravan = 1,
		/obj/item/wirecutters/caravan = 1,
		/obj/item/screwdriver/caravan = 1,
		/obj/item/crowbar/red/caravan = 1
	)

/// Space loot spawner. A single roundstart species language book.
/obj/effect/spawner/lootdrop/space/languagebook
	lootcount = 1
	loot = list(
		/obj/item/language_manual/roundstart_species = 100,
		/obj/item/language_manual/roundstart_species/five = 3,
		/obj/item/language_manual/roundstart_species/unlimited = 1
	)

/// Space loot spawner. Random selecton of a few rarer materials.
/obj/effect/spawner/lootdrop/space/material
	lootcount = 3
	loot = list(
		/obj/item/stack/sheet/plastic/fifty = 5,
		/obj/item/stack/sheet/runed_metal/ten = 20,
		/obj/item/stack/sheet/runed_metal/fifty = 5,
		/obj/item/stack/sheet/mineral/diamond{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/uranium{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/plasma{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/gold{amount = 15} = 15,
	)

/// A selection of cosmetic syndicate items. Just a couple. No hardsuits or weapons.
/obj/effect/spawner/lootdrop/space/syndiecosmetic
	lootcount = 2
	loot = list(
		/obj/item/clothing/under/syndicate = 10,
		/obj/item/clothing/under/syndicate/skirt = 10,
		/obj/item/clothing/under/syndicate/bloodred = 10,
		/obj/item/clothing/under/syndicate/bloodred/sleepytime = 5,
		/obj/item/clothing/under/syndicate/tacticool = 10,
		/obj/item/clothing/under/syndicate/tacticool/skirt = 10,
		/obj/item/clothing/under/syndicate/sniper = 10,
		/obj/item/clothing/under/syndicate/camo = 10,
		/obj/item/clothing/under/syndicate/soviet = 10,
		/obj/item/clothing/under/syndicate/combat = 10,
		/obj/item/clothing/under/syndicate/rus_army = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 1
	)

/obj/effect/spawner/lootdrop/decorative_material
	lootcount = 1
	loot = list(
		/obj/item/stack/sheet/sandblock{amount = 30} = 25,
		/obj/item/stack/sheet/mineral/wood{amount = 30} = 25,
		/obj/item/stack/sheet/bronze/thirty = 20,
		/obj/item/stack/tile/noslip{amount = 20} = 10,
		/obj/item/stack/sheet/plastic{amount = 30} = 10,
		/obj/item/stack/tile/pod{amount = 20} = 4,
		/obj/item/stack/tile/pod/light{amount = 20} = 3,
		/obj/item/stack/tile/pod/dark{amount = 20} = 3,
	)

/obj/effect/spawner/lootdrop/maintenance_carpet
	lootcount = 1
	loot = list(
		/obj/item/stack/tile/carpet{amount = 30} = 35,
		/obj/item/stack/tile/carpet/black{amount = 30} = 20,
		/obj/item/stack/tile/carpet/donk/thirty = 15,
		/obj/item/stack/tile/carpet/stellar/thirty = 15,
		/obj/item/stack/tile/carpet/executive/thirty = 15,
	)

/obj/effect/spawner/lootdrop/decorations_spawner
	lootcount = 1
	loot = list(
	/obj/effect/spawner/lootdrop/maintenance_carpet = 25,
	/obj/effect/spawner/lootdrop/decorative_material = 25,
	/obj/item/sign = 10,
	/obj/item/flashlight/lamp/green = 10,
	/obj/item/plaque = 5,
	/obj/item/flashlight/lantern/jade = 5,
	/obj/item/phone = 5,
	/obj/item/flashlight/lamp/bananalamp = 3
	)
