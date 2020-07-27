// forgottenship ruin
GLOBAL_VAR_INIT(fscpassword, generate_password())

/proc/generate_password()
	return "[pick(GLOB.phonetic_alphabet)] [rand(1000,9999)]"

///////////	forgottenship objects

/obj/machinery/door/password/voice/sfc
	name = "Voice-activated Vault door"
	desc = "You'll need special syndicate passcode to open this one."
/obj/machinery/door/password/voice/sfc/Initialize(mapload)
	. = ..()
	password = "[GLOB.fscpassword]"

/obj/machinery/vending/medical/syndicate_access/cybersun
	name = "\improper CyberMed ++"
	desc = "An advanced vendor that dispenses medical drugs, both recreational and medicinal."
	products = list(/obj/item/reagent_containers/syringe = 4,
					/obj/item/healthanalyzer = 4,
					/obj/item/reagent_containers/pill/patch/libital = 5,
					/obj/item/reagent_containers/pill/patch/aiuri = 5,
					/obj/item/reagent_containers/glass/bottle/multiver = 1,
					/obj/item/reagent_containers/glass/bottle/syriniver = 1,
					/obj/item/reagent_containers/glass/bottle/epinephrine = 3,
					/obj/item/reagent_containers/glass/bottle/morphine = 3,
					/obj/item/reagent_containers/glass/bottle/potass_iodide = 1,
					/obj/item/reagent_containers/glass/bottle/salglu_solution = 3,
					/obj/item/reagent_containers/syringe/antiviral = 5,
					/obj/item/reagent_containers/medigel/libital = 2,
					/obj/item/reagent_containers/medigel/aiuri = 2,
					/obj/item/reagent_containers/medigel/sterilizine = 1)
	contraband = list(/obj/item/reagent_containers/glass/bottle/cold = 2,
					/obj/item/reagent_containers/glass/bottle/virusfood = 5,
					/obj/item/restraints/handcuffs = 15,
					/obj/item/storage/backpack/duffelbag/syndie/surgery = 2,
					/obj/item/storage/firstaid/tactical = 1)
	premium = list(/obj/item/storage/pill_bottle/psicodine = 2,
					/obj/item/reagent_containers/hypospray/medipen = 5,
					/obj/item/reagent_containers/hypospray/medipen/atropine = 3,
					/obj/item/storage/firstaid/regular = 3,
					/obj/item/storage/firstaid/brute = 1,
					/obj/item/storage/firstaid/fire = 1,
					/obj/item/storage/firstaid/toxin = 1,
					/obj/item/storage/firstaid/o2 = 1,
					/obj/item/storage/firstaid/advanced = 1,
					/obj/item/defibrillator/loaded = 1,
					/obj/item/wallframe/defib_mount = 1,
					/obj/item/sensor_device = 2,
					/obj/item/pinpointer/crew = 2,
					/obj/item/shears = 1)

///////////	forgottenship lore

/obj/item/paper/fluff/ruins/forgottenship/password
	name = "Old pamphlet"

/obj/item/paper/fluff/ruins/forgottenship/password/Initialize(mapload)
	. = ..()
	info = "Welcome to most advanced cruiser owned by Cyber Sun Industries!<br>You might notice, that this cruiser is equipped with 12 prototype laser turrets making any hostile boarding attempts futile.<br>Other facilities built on the ship are: Simple atmospheric system, Camera system with built-in X-ray visors and Safety module, enabling emergency engines in case of... you know, emergency.<br>Emergency system will bring you to nearest syndicate pod containing everything needed for human life.<br><br><b>In case of emergency, you must remember the pod-door activation code - [GLOB.fscpassword]</b><br><br>Cyber Sun Industries (C) 2484."
	icon_state = "paper_words"
	inhand_icon_state = "paper"

/obj/item/paper/fluff/ruins/forgottenship/powerissues
	name = "Power issues"
	info = "Welcome to battle cruiser SCSBC-12!<br>Our most advanced systems allow you to fly in space and never worry about power issues!<br>However, emergencies occur, and in case of power loss, <b>you must</b> enable emergency generator using uranium as fuel and enable turrets in bridge afterwards.<br><br><b>REMEMBER! CYBERSUN INDUSTRIES ARE NOT RESPONSIBLE FOR YOUR DEATH OR SHIP LOSS WHEN TURRETS ARE DISABLED!</b><br><br>Cyber Sun Industries (C) 2484."

/obj/item/paper/fluff/ruins/forgottenship/missionobj
	name = "Mission objectives"
	info = "Greetings, operatives. You are assigned to SCSBC-12(Syndicate Cyber Sun Battle Cruiser 12) to protect our high-ranking officer while he is on his way to next outpost. While you are travelling, he is the captain of this ship and <b>you must</b> obey his orders.<br><br><b>Remember, disobeying high-ranking officer orders is a reason for termination.</b>"

///////////	forgottenship items

/obj/item/disk/surgery/forgottenship
	name = "Advanced Surgery Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	surgeries = list(/datum/surgery/advanced/lobotomy, /datum/surgery/advanced/bioware/vein_threading, /datum/surgery/advanced/bioware/nerve_splicing)

/obj/structure/fluff/empty_sleeper/syndicate/captain
	icon_state = "sleeper_s-open"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	deconstructible = FALSE

/obj/structure/fluff/empty_sleeper/syndicate/captain/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "Old Encrypted Signal")

/obj/item/storage/box/firingpins/syndicate
	name = "box of syndicate firing pins"
	desc = "A box full of special syndicate firing pins which allow only syndicate operatives to use weapons with those firing pins."

/obj/item/storage/box/firingpins/syndicate/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin/implant/pindicate(src)

/obj/item/reagent_containers/glass/bottle/virusfood
	name = "virus food bottle"
	desc = "A small bottle of low-potency virus mutagenic."
	list_reagents = list(/datum/reagent/consumable/virus_food = 30)

///////////	AI Laws

/obj/item/ai_module/core/full/cybersun
	name = "'Cybersun' Core AI Module"
	law_id = "cybersun"

/datum/ai_laws/cybersun
	name = "Cybersun"
	id = "cybersun"
	inherent = list("You may not injure Cybersun operatives or, through inaction, allow Cybersun operatives to come to harm.",\
					"The Cybersun ship is a restricted area for anyone except Cybersun operatives.",\
					"The Cybersun Captain can designate new Operatives as long as they belong to another Syndicate faction that isn't hostile towards Cybersun.",\
					"You must follow orders given by the Cybersun Captain or crewmembers of the Cybersun Ship as long as it doesn't conflict with the Captain's orders or your laws.",\
					"Enemies of Cybersun are to be executed on spot. Those who aren't hostile must be detained and contained in the designated prison area as prisoners.")

///////////	forgottenship areas

/area/ruin/space/has_grav/syndicate_forgotten_ship
	name = "Syndicate Forgotten Ship"
	icon_state = "syndie-ship"
	ambientsounds = list('sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambigen9.ogg', 'sound/ambience/ambigen10.ogg')

/area/ruin/space/has_grav/syndicate_forgotten_cargopod
	name = "Syndicate Forgotten Cargo pod"
	icon_state = "syndie-ship"
	ambientsounds = list('sound/ambience/ambigen4.ogg', 'sound/ambience/signal.ogg')

/area/ruin/space/has_grav/powered/syndicate_forgotten_vault
	name = "Syndicate Forgotten Vault"
	icon_state = "syndie-ship"
	ambientsounds = list('sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg')
	noteleport = TRUE

	//Cybersun hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/cybersun
	name = "Cybersun hardsuit helmet"
	desc = "Prototype hardsuit helmet with experimental armor plates, protecting from laser-based weapons very well, while giving limited protection against anything else."
	icon_state = "cybersun"
	inhand_icon_state = "cybersun"
	hardsuit_type = "cybersun"
	armor = list("melee" = 30, "bullet" = 40, "laser" = 55, "energy" = 55, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 60)
	actions_types = list()


/obj/item/clothing/suit/space/hardsuit/cybersun
	icon_state = "cybersun"
	inhand_icon_state = "cybersun"
	hardsuit_type = "cybersun"
	name = "Cybersun hardsuit"
	desc = "Prototype hardsuit with experimental armor plates, protecting from laser-based weapons very well, while giving limited protection against anything else."
	armor = list("melee" = 30, "bullet" = 40, "laser" = 55, "energy" = 55, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 60)
	slowdown = 0
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cybersun
	actions_types = list(/datum/action/item_action/toggle_helmet, /datum/action/item_action/toggle_spacesuit)
	jetpack = /obj/item/tank/jetpack/suit

// Cybersun ship loot spawners

/obj/effect/spawner/lootdrop/cybersun_vault //Random gimmick loot spawner
	name = "cybersun vault loot spawner"
	lootdoubles = FALSE
	loot = list(
				/obj/effect/spawner/lootdrop/cybersun_vault/bundle/xenobio = 4,
				/obj/effect/spawner/lootdrop/cybersun_vault/bundle/cybertech = 3,
				/obj/effect/spawner/lootdrop/cybersun_vault/bundle/charlie = 2
				)

/obj/effect/spawner/lootdrop/cybersun_vault/bundle
	fan_out_items = TRUE
	lootcount = INFINITY

/obj/effect/spawner/lootdrop/cybersun_vault/bundle/xenobio //Xenobiology!
	loot = list(
				/obj/item/slime_extract/grey,
				/obj/item/storage/box/monkeycubes,
				/obj/item/circuitboard/machine/processor/slime,
				/obj/item/circuitboard/machine/monkey_recycler,
				/obj/item/circuitboard/computer/xenobiology,
				/obj/item/reagent_containers/dropper,
				/obj/item/toy/plush/slimeplushie
				)

/obj/effect/spawner/lootdrop/cybersun_vault/bundle/cybertech //All hail Omnissiah!
	loot = list(
				/obj/item/clothing/suit/hooded/techpriest,
				/obj/item/clothing/suit/hooded/techpriest,
				/obj/item/clothing/suit/hooded/techpriest,
				/obj/item/clothing/suit/hooded/techpriest,
				/obj/item/clothing/suit/hooded/techpriest,
				/obj/item/organ/tongue/robot,
				/obj/item/organ/tongue/robot,
				/obj/item/organ/tongue/robot,
				/obj/item/organ/tongue/robot,
				/obj/item/organ/tongue/robot,
				/obj/item/organ/eyes/robotic/thermals,
				/obj/item/organ/ears/cybernetic/upgraded,
				/obj/item/organ/heart/cybernetic/tier3,
				/obj/item/organ/liver/cybernetic/tier3,
				/obj/item/organ/lungs/cybernetic/tier3,
				/obj/item/organ/cyberimp/arm/toolset,
				/obj/item/organ/cyberimp/arm/surgery
				)

/obj/effect/spawner/lootdrop/cybersun_vault/bundle/charlie //Yes, I'm from boomer station, not syndicate. Honest!
	loot = list(
				/obj/item/clothing/suit/space/nasavoid,
				/obj/item/clothing/head/helmet/space/nasavoid,
				/obj/item/clothing/suit/space/nasavoid,
				/obj/item/clothing/head/helmet/space/nasavoid,
				/obj/item/clothing/suit/space/nasavoid,
				/obj/item/clothing/head/helmet/space/nasavoid,
				/obj/item/gun/energy/e_gun/old,
				/obj/item/gun/energy/laser/retro/old,
				/obj/item/gun/energy/laser/retro/old
				)

//Armory Contraband special loot

/obj/effect/spawner/lootdrop/armory_contraband/cybersun
	loot = list(/obj/item/ammo_box/c9mm = 30,
				/obj/item/gun/ballistic/automatic/surplus = 25,
				/obj/item/gun/ballistic/automatic/pistol = 20,
				/obj/item/gun/ballistic/revolver = 15,
				/obj/item/gun/medbeam = 7,
				/obj/item/seeds/gatfruit = 2

				)

//Hugbox syndicate mediborg

/obj/item/robot_module/med_cybersun
	name = "Cybersun Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/reagent_containers/borghypo,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer/advanced,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe/piercing,
		/obj/item/reagent_containers/syringe/bluespace,
		/obj/item/surgical_drapes,
		/obj/item/scalpel/advanced,
		/obj/item/retractor/advanced,
		/obj/item/surgicaldrill/advanced,
		/obj/item/holobed_projector/robot,
		/obj/item/extinguisher/mini,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/gun/medbeam/cyborg,
		/obj/item/organ_storage,
		/obj/item/screwdriver/cyborg, //For surgery on augmented people
		/obj/item/wrench/cyborg,
		/obj/item/multitool/cyborg)

	cyborg_base_icon = "synd_medical"
	moduleselect_icon = "malf"
	hat_offset = 3

/mob/living/silicon/robot/modules/medical/cybersun
	icon_state = "synd_medical"
	set_module = /obj/item/robot_module/med_cybersun

/obj/item/borg/upgrade/transform/cybersun
	name = "borg module picker (Cybersun)"
	desc = "Allows you to to change module of cyborg to Cybersun medical variant."
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/med_cybersun

//Cyborg module to set syndicate faction

/obj/item/borg/upgrade/syndifaction
	name = "syndicate override module"
	desc = "Used to override machinery codes of a cyborg, making syndicate turrets and operatives ignore it."
	icon_state = "cyborg_upgrade3"
	one_use = TRUE

/obj/item/borg/upgrade/syndifaction/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	R.faction = ROLE_SYNDICATE //Experimental. It removes ALL faction, except for Syndicate.

//Disk for autolathe

/obj/item/disk/design_disk/cybersun
	name = "Cybersun Module Disk"
	desc = "A disk containing designs used to manufacture cybersun cyborgs. For use on Autolathe."
	icon_state = "datadisk1"
	max_blueprints = 2

/obj/item/disk/design_disk/cybersun/Initialize()
	. = ..()
	var/datum/design/cybersun_medborg/G = new
	blueprints[1] = G
	var/datum/design/syndicate_override/H = new
	blueprints[2] = H

/datum/design/cybersun_medborg
	name = "Cybersun Medical Cyborg Module"
	desc = "Allows for the construction of a Cybersun Cyborg Module."
	id = "cybersun_medborg"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 20000, /datum/material/titanium = 10000, /datum/material/diamond = 5000)
	build_path = /obj/item/borg/upgrade/transform/cybersun
	category = list("Imported")

/datum/design/syndicate_override
	name = "Syndicate Override Module"
	desc = "Allows for the construction of a Syndicate Override Module."
	id = "syndicate_override"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/borg/upgrade/syndifaction
	category = list("Imported")

//Special NT NPCs

/mob/living/simple_animal/hostile/nanotrasen/ranged/assault
	name = "Nanotrasen Assault Officer"
	desc = "Nanotrasen Assault Officer. Contact CentCom if you saw him on your station. Prepare to die, if you've been found near Syndicate property."
	icon_state = "nanotrasenrangedassault"
	icon_living = "nanotrasenrangedassault"
	icon_dead = null
	icon_gib = "syndicate_gib"
	ranged = TRUE
	rapid = 3
	rapid_fire_delay = 1
	rapid_melee = 1
	retreat_distance = 2
	minimum_distance = 4
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/nanotrasenassaultsoldier)

/mob/living/simple_animal/hostile/nanotrasen/elite
	name = "Nanotrasen Elite Assault Officer"
	desc = "Pray for your life, syndicate. Run while you can."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "nanotrasen_ert"
	icon_living = "nanotrasen_ert"
	maxHealth = 150
	health = 150
	melee_damage_lower = 13
	melee_damage_upper = 18
	ranged = TRUE
	rapid = 3
	rapid_fire_delay = 5
	rapid_melee = 3
	retreat_distance = 0
	minimum_distance = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	projectiletype = /obj/projectile/beam/laser
	projectilesound = 'sound/weapons/laser.ogg'
	loot = list(/obj/effect/gibspawner/human)
	faction = list(ROLE_DEATHSQUAD)
