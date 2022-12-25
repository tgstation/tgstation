GLOBAL_LIST_INIT(miner_callouts, list(
	/obj/item/stack/sheet/mineral/gold = list(":H We're rich!"),
	/obj/item/stack/ore/gold = list(":H Gold!", ":H There is gold here!", ":H There is gold!", ":H I found a gold vein!"),
	/obj/structure/flora/ash/leaf_shroom = list(":H Mushroom!"),
	/obj/structure/flora/ash/cap_shroom = list(":H Mushroom!"),
	/obj/structure/flora/ash/stem_shroom = list(":H Mushroom!"),
	/obj/structure/closet/crate/secure/loot = list(":H Abandoned crate here!", ":H Found a crate with a codelock over here!"),
	/obj/structure/closet/crate/necropolis = list(":H Spooky chest here, someone got a key?", ":H Necropolis chest here!"),
	/obj/structure/spawner/lavaland = list(":H Tendril spotted!", ":H Got a tendril here!", ":H Found a tendril!"),
	/obj/structure/geyser = list(":H Got a geyser here, those chemists'll be pleased!", ":H Found a geyser!", ":H Geyser here!"),
	/mob/living/simple_animal/hostile/asteroid/basilisk = list(":H Basilisk, watch out!", ":H Spotted a Basilisk!", ":H Look out for that Basilisk!"),
	/mob/living/simple_animal/hostile/asteroid/brimdemon = list(":H Brimdemon, don't stand around, move!", ":H There's a Brimdemon!", ":H Watch out for the Brimdemon!"),
	/mob/living/simple_animal/hostile/asteroid/goldgrub = list(":H Goldgrub here!", ":H Spotted a Goldgrub!", ":H Lootbug here!"),
	/mob/living/simple_animal/hostile/asteroid/goliath = list(":H Watch out for that Goliath!", ":H Found a Goliath!", ":H There's a goliath here, don't get hit by the tendrils!"),
	/mob/living/simple_animal/hostile/asteroid/gutlunch = list(":H Gutlunch here!", ":H Found a Gutlunch!", ":H Got a Gutlunch here!"),
	/mob/living/simple_animal/hostile/asteroid/hivelord = list(":H Hivelord here!", ":H Spotted a Hivelord!", ":H Hivelord!"),
	/mob/living/simple_animal/hostile/asteroid/ice_demon = list(":H Ice demon here!", ":H Spotted a real Ice Demon!", ":H Ice demon out here!"),
	/mob/living/simple_animal/hostile/asteroid/ice_whelp = list(":H Got an ice whelp!", ":H Ice whelp out here!", ":H Spotted an ice whelp!"),
	/mob/living/simple_animal/hostile/asteroid/lobstrosity = list(":H Lobstrosity!", ":H Look out for that Lobstrosity!", ":H Lobstrosity here!"),
	/mob/living/simple_animal/hostile/asteroid/polarbear = list(":H Polar bear here!", ":H Watch out for those bear claws!", ":H Polar bear over here!"),
	/mob/living/simple_animal/hostile/asteroid/wolf = list(":H Spotted a white wolf!", ":H Watch out for that wolf!", ":H Careful, wolf about!"),
	/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner = list(":H CRAZY MINER SPOTTED, WATCH OUT!", ":H THAT MINER'S GONE BLOOD DRUNK, BE CAREFUL!", ":H WATCH OUT FOR THAT BLOOD DRUNK MINER!"),
	/mob/living/simple_animal/hostile/megafauna/bubblegum = list(":H BUBBLEGUM SPOTTED!", ":H WATCH OUT, BUBBLEGUM!", ":H LOOK OUT FOR BUBBLEGUM!"),
	/mob/living/simple_animal/hostile/megafauna/clockwork_defender = list(":H CLOCKWORK DEFENDER, LOOK OUT!", ":H A CLOCKWORK DEFENDER, OUT HERE?", ":H WATCH OUT FOR THAT CLOCKWORK DEFENDER!"),
	/mob/living/simple_animal/hostile/megafauna/colossus = list(":H COLOSSUS!!!", ":H COLOSSUS IS HERE!!!", ":H WATCH OUT FOR THE COLOSSUS!!!"),
	/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner = list(":H THE COLD DROVE THAT MINER CRAZY, LOOK OUT!", ":H WATCH OUT FOR THAT FROST MINER!", ":H FROST CRAZED MINER, LOOK OUT!"),
	/mob/living/simple_animal/hostile/megafauna/dragon = list(":H ASH DRAKE, WATCH THE SKIES!", ":H LOOK OUT FOR THAT ASH DRAKE!", ":H ASH DRAKE SPOTTED!"),
	/mob/living/simple_animal/hostile/megafauna/hierophant = list(":H FOUND THE HIEROPHANT!", ":H FOUND A HIEROPHANT, GET READY TO DANCE!", ":H HIEROPHANT SPOTTED, AND HE'S ON RHYTHM!"),
	/mob/living/simple_animal/hostile/megafauna/legion = list(":H LEGION'S WOKEN UP!", ":H LOOKS LIKE LEGION WOKE UP!", ":H WATCH OUT FOR THE GIANT SKULL, LEGION!"),
	/mob/living/simple_animal/hostile/megafauna/wendigo = list(":H IT'S A WENDIGO!", ":H WATCH OUT FOR THAT WENDIGO!", ":H I KNEW WENDIGOS WERE REAL! WATCH OUT!"),
))

/datum/job/shaft_miner
	title = JOB_SHAFT_MINER
	description = "Travel to strange lands. Mine ores. \
		Meet strange creatures. Kill them for their gold."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = SUPERVISOR_QM
	selection_color = "#dcba97"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SHAFT_MINER"

	outfit = /datum/outfit/job/miner
	plasmaman_outfit = /datum/outfit/plasmaman/mining

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR

	mind_traits = list(TRAIT_DETECT_STORM)

	display_order = JOB_DISPLAY_ORDER_SHAFT_MINER
	bounty_types = CIV_JOB_MINE
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(/obj/item/pickaxe/mini, /obj/item/shovel)
	rpg_title = "Adventurer"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/job/shaft_miner/after_spawn(mob/living/spawned, client/player_client)
	..()
	RegisterSignal(spawned, COMSIG_MOB_POINTED, PROC_REF(point_speech))

/datum/job/shaft_miner/proc/point_speech(mob/pointing_miner, atom/movable/object_of_interest)
	SIGNAL_HANDLER
	if(object_of_interest.type in GLOB.miner_callouts)
		var/list/lines = GLOB.miner_callouts[object_of_interest.type]
		pointing_miner.say(pick(lines), forced = "Miner Pointing Callouts")

/datum/outfit/job/miner
	name = "Shaft Miner"
	jobtype = /datum/job/shaft_miner

	id_trim = /datum/id_trim/job/shaft_miner
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/marker_beacon/ten = 1,
		)
	belt = /obj/item/modular_computer/pda/shaftminer
	ears = /obj/item/radio/headset/headset_cargo/mining
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots/mining
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/storage/bag/ore //causes issues if spawned in backpack

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag/explorer

	box = /obj/item/storage/box/survival/mining
	chameleon_extras = /obj/item/gun/energy/recharge/kinetic_accelerator

/datum/outfit/job/miner/equipped
	name = "Shaft Miner (Equipment)"

	suit = /obj/item/clothing/suit/hooded/explorer
	suit_store = /obj/item/tank/internals/oxygen
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/gun/energy/recharge/kinetic_accelerator = 1,
		/obj/item/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/marker_beacon/ten = 1,
		/obj/item/t_scanner/adv_mining_scanner/lesser = 1,
		)
	glasses = /obj/item/clothing/glasses/meson
	mask = /obj/item/clothing/mask/gas/explorer
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/miner/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	if(istype(H.wear_suit, /obj/item/clothing/suit/hooded))
		var/obj/item/clothing/suit/hooded/S = H.wear_suit
		S.ToggleHood()

/datum/outfit/job/miner/equipped/mod
	name = "Shaft Miner (Equipment + MODsuit)"
	back = /obj/item/mod/control/pre_equipped/mining
	suit = null
	mask = /obj/item/clothing/mask/gas/explorer
