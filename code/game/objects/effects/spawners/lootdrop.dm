/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	var/lootcount = 1 //how many items will be spawned
	var/lootdoubles = TRUE //if the same item can be spawned twice
	var/list/loot //a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself

/obj/effect/spawner/lootdrop/Initialize(mapload)
	..()
	if(loot?.len)
		var/loot_spawned = 0
		while((lootcount-loot_spawned) && loot.len)
			var/lootspawn = pickweight(loot)
			while(islist(lootspawn))
				lootspawn = pickweight(lootspawn)
			if(!lootdoubles)
				loot.Remove(lootspawn)

			if(lootspawn)
				var/atom/movable/spawned_loot = new lootspawn(loc)
				if (!fan_out_items)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else
					if (loot_spawned)
						spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
			loot_spawned++
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/lootdrop/donkpockets
	name = "donk pocket box spawner"
	lootdoubles = FALSE

	loot = list(
			/obj/item/storage/box/donkpockets/donkpocketspicy = 1,
			/obj/item/storage/box/donkpockets/donkpocketteriyaki = 1,
			/obj/item/storage/box/donkpockets/donkpocketpizza = 1,
			/obj/item/storage/box/donkpockets/donkpocketberry = 1,
			/obj/item/storage/box/donkpockets/donkpockethonk = 1,
		)

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

/obj/effect/spawner/lootdrop/gambling
	name = "gambling valuables spawner"
	loot = list(
				/obj/item/gun/ballistic/revolver/russian = 5,
				/obj/item/clothing/head/ushanka = 3,
				/obj/item/storage/box/syndie_kit/throwing_weapons,
				/obj/item/coin/gold,
				/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka,
				)

/obj/effect/spawner/lootdrop/garbage_spawner
	name = "garbage_spawner"
	loot = list(/obj/effect/spawner/lootdrop/food_packaging = 56,
				/obj/item/trash/can = 8,
				/obj/item/shard = 8,
				/obj/effect/spawner/lootdrop/botanical_waste = 8,
				/obj/effect/spawner/lootdrop/cigbutt = 8,
				/obj/item/reagent_containers/syringe = 5,
				/obj/item/food/deadmouse = 2,
				/obj/item/light/tube/broken = 3,
				/obj/item/light/tube/broken = 1,
				/obj/item/trash/candle = 1)

/obj/effect/spawner/lootdrop/cigbutt
	name = "cigarette butt spawner"
	loot = list(/obj/item/cigbutt = 65,
				/obj/item/cigbutt/roach = 20,
				/obj/item/cigbutt/cigarbutt = 15)

/obj/effect/spawner/lootdrop/food_packaging
	name = "food packaging spawner"
	loot = list(/obj/item/trash/raisins = 20,
				/obj/item/trash/cheesie = 10,
				/obj/item/trash/candy = 10,
				/obj/item/trash/chips = 10,
				/obj/item/trash/sosjerky = 10,
				/obj/item/trash/pistachios = 10,
				/obj/item/trash/boritos = 8,
				/obj/item/trash/can/food/beans = 6,
				/obj/item/trash/popcorn = 5,
				/obj/item/trash/energybar = 5,
				/obj/item/trash/can/food/peaches/maint = 4,
				/obj/item/trash/semki = 2)

/obj/effect/spawner/lootdrop/botanical_waste
	name = "botanical waste spawner"
	loot = list(/obj/item/grown/bananapeel = 60,
				/obj/item/grown/corncob = 30,
				/obj/item/food/grown/bungopit = 10)

/obj/effect/spawner/lootdrop/refreshing_beverage
	name = "good soda spawner"
	loot = list(/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 15,
				/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 15,
				/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 10,
				/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 10,
				/obj/item/reagent_containers/food/drinks/beer/light = 10,
				/obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry = 5,
				/obj/item/reagent_containers/food/drinks/soda_cans/cola = 5)

/obj/effect/spawner/lootdrop/maint_drugs
	name = "maint drugs spawner"
	loot = list(/obj/item/reagent_containers/food/drinks/bottle/hooch = 50,
				/obj/item/clothing/mask/cigarette/rollie/cannabis = 15,
				/obj/item/clothing/mask/cigarette/rollie/mindbreaker = 5,
				/obj/item/reagent_containers/syringe = 15,
				/obj/item/cigbutt/roach = 15)

/obj/effect/spawner/lootdrop/grille_or_trash
	name = "maint grille or trash spawner"
	loot = list(/obj/structure/grille = 5,
			/obj/item/cigbutt = 1,
			/obj/item/trash/cheesie = 1,
			/obj/item/trash/candy = 1,
			/obj/item/trash/chips = 1,
			/obj/item/food/deadmouse = 1,
			/obj/item/trash/pistachios = 1,
			/obj/item/trash/plate = 1,
			/obj/item/trash/popcorn = 1,
			/obj/item/trash/raisins = 1,
			/obj/item/trash/sosjerky = 1,
			/obj/item/trash/syndi_cakes = 1)

/obj/effect/spawner/lootdrop/three_course_meal
	name = "three course meal spawner"
	lootcount = 3
	lootdoubles = FALSE
	var/soups = list(
			/obj/item/food/soup/beet,
			/obj/item/food/soup/sweetpotato,
			/obj/item/food/soup/stew,
			/obj/item/food/soup/hotchili,
			/obj/item/food/soup/nettle,
			/obj/item/food/soup/meatball)
	var/salads = list(
			/obj/item/food/salad/herbsalad,
			/obj/item/food/salad/validsalad,
			/obj/item/food/salad/fruit,
			/obj/item/food/salad/jungle,
			/obj/item/food/salad/aesirsalad)
	var/mains = list(
			/obj/item/food/bearsteak,
			/obj/item/food/enchiladas,
			/obj/item/food/stewedsoymeat,
			/obj/item/food/burger/bigbite,
			/obj/item/food/burger/superbite,
			/obj/item/food/burger/fivealarm)

/obj/effect/spawner/lootdrop/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"
	// see code/_globalvars/lists/maintenance_loot.dm for loot table

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	loot = GLOB.maintenance_loot

	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		lootcount = FLOOR(lootcount * 1.5, 1)

	else if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		lootcount = FLOOR(lootcount * 0.5, 1)

	. = ..()

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

/obj/effect/spawner/lootdrop/organ_spawner
	name = "ayylien organ spawner"
	loot = list(
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/heart/gland/transform = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
		/obj/item/organ/regenerative_core = 2)
	lootcount = 3

/obj/effect/spawner/lootdrop/memeorgans
	name = "meme organ spawner"
	loot = list(
		/obj/item/organ/ears/penguin,
		/obj/item/organ/ears/cat,
		/obj/item/organ/eyes/moth,
		/obj/item/organ/eyes/snail,
		/obj/item/organ/tongue/bone,
		/obj/item/organ/tongue/fly,
		/obj/item/organ/tongue/snail,
		/obj/item/organ/tongue/lizard,
		/obj/item/organ/tongue/alien,
		/obj/item/organ/tongue/ethereal,
		/obj/item/organ/tongue/robot,
		/obj/item/organ/tongue/zombie,
		/obj/item/organ/appendix,
		/obj/item/organ/liver/fly,
		/obj/item/organ/lungs/plasmaman,
		/obj/item/organ/tail/cat,
		/obj/item/organ/tail/lizard)
	lootcount = 5

/obj/effect/spawner/lootdrop/two_percent_xeno_egg_spawner
	name = "2% chance xeno egg spawner"
	loot = list(
		/obj/effect/decal/remains/xeno = 49,
		/obj/effect/spawner/xeno_egg_delivery = 1)

/obj/effect/spawner/lootdrop/costume
	name = "random costume spawner"

/obj/effect/spawner/lootdrop/costume/Initialize()
	loot = list()
	for(var/path in subtypesof(/obj/effect/spawner/bundle/costume))
		loot[path] = TRUE
	. = ..()

// Minor lootdrops follow

/obj/effect/spawner/lootdrop/minor/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/head/rabbitears = 1)

/obj/effect/spawner/lootdrop/minor/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/bowler = 1,
		/obj/item/clothing/head/that = 1)

/obj/effect/spawner/lootdrop/minor/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/kitty = 1,
		/obj/item/clothing/head/rabbitears = 1)

/obj/effect/spawner/lootdrop/minor/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/pirate = 1,
		/obj/item/clothing/head/bandana = 1)

/obj/effect/spawner/lootdrop/minor/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	loot = list(
		/obj/item/clothing/mask/gas/cyborg = 25,
		"" = 75)

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
				/obj/item/circuitboard/computer/nanite_chamber_control,
				/obj/item/circuitboard/computer/nanite_cloud_controller,
				/obj/item/circuitboard/machine/nanite_chamber,
				/obj/item/circuitboard/machine/nanite_programmer,
				/obj/item/circuitboard/machine/nanite_program_hub,
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
				/obj/item/circuitboard/computer/cloning,
				/obj/item/circuitboard/machine/clonepod,
				/obj/item/circuitboard/machine/chem_dispenser,
				/obj/item/circuitboard/computer/med_data,
				/obj/item/circuitboard/machine/smoke_machine,
				/obj/item/circuitboard/machine/chem_master,
				/obj/item/circuitboard/machine/clonescanner,
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

/obj/effect/spawner/lootdrop/mafia_outfit
	name = "mafia outfit spawner"
	loot = list(
				/obj/effect/spawner/bundle/costume/mafia = 20,
				/obj/effect/spawner/bundle/costume/mafia/white = 5,
				/obj/effect/spawner/bundle/costume/mafia/checkered = 2,
				/obj/effect/spawner/bundle/costume/mafia/beige = 5
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

/// Space loot spawner. Randomlu picks 5 wads of space cash.
/obj/effect/spawner/lootdrop/space/cashmoney
	lootcount = 5
	fan_out_items = TRUE
	loot = list(
		/obj/item/stack/spacecash/c1 = 100,
		/obj/item/stack/spacecash/c10 = 80,
		/obj/item/stack/spacecash/c20 = 60,
		/obj/item/stack/spacecash/c50 = 40,
		/obj/item/stack/spacecash/c100 = 30,
		/obj/item/stack/spacecash/c200 = 20,
		/obj/item/stack/spacecash/c500 = 10,
		/obj/item/stack/spacecash/c1000 = 5,
		/obj/item/stack/spacecash/c10000 = 1
	)

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

/// Space loot spawner. A bunch of rarer seeds. /obj/item/seeds/random is not a random seed, but an exotic seed.
/obj/effect/spawner/lootdrop/space/rareseed
	lootcount = 5
	loot = list(
		/obj/item/seeds/random = 30,
		/obj/item/seeds/angel = 1,
		/obj/item/seeds/glowshroom/glowcap = 1,
		/obj/item/seeds/glowshroom/shadowshroom = 1,
		/obj/item/seeds/liberty = 5,
		/obj/item/seeds/nettle/death = 1,
		/obj/item/seeds/plump/walkingmushroom = 1,
		/obj/item/seeds/reishi = 5,
		/obj/item/seeds/cannabis/rainbow = 1,
		/obj/item/seeds/cannabis/death = 1,
		/obj/item/seeds/cannabis/white = 1,
		/obj/item/seeds/cannabis/ultimate = 1,
		/obj/item/seeds/replicapod = 5,
		/obj/item/seeds/kudzu = 1
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
		/obj/item/stack/tile/bronze/thirty = 20,
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
