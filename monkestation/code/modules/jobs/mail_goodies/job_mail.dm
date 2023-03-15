//All of the /tg/ mail non-junk job items are in here for modularity and easy editing later.


//ASSISTANT
/datum/job/assistant
	mail_goodies = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy = 10,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki = 10,
		/obj/item/storage/box/donkpockets/donkpocketpizza = 10,
		/obj/item/storage/box/donkpockets/donkpocketberry = 10,
		/obj/item/storage/box/donkpockets = 10,
		/obj/item/clothing/mask/gas = 10,
		/obj/item/clothing/gloves/color/fyellow = 7,
		/obj/item/choice_beacon/music = 5,
		/obj/item/reagent_containers/spray/gamerspray = 5,
		/obj/item/toy/crayon/spraycan = 3,
		/obj/item/crowbar/large = 1
	)

//ATMOSPHERIC TECHNICIAN
/datum/job/atmos
	mail_goodies = list(
		/obj/item/pipe_dispenser = 20,
		/obj/item/holosign_creator/atmos = 15,
		/obj/item/book/manual/wiki/atmospherics = 10,
		/obj/item/storage/firstaid/radbgone = 5,
		/datum/supply_pack/emergency/atmostank = 5, //FIGHT FIRE WITH NOT FIRE
		/obj/item/flamethrower/full = 1				//FIGHT FIRE WITH FIRE
	)

//BARTENDER
/datum/job/bartender
	mail_goodies = list(
		/obj/item/storage/box/rubbershot = 30,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/reagent_containers/glass/bottle/clownstears = 10,
		/obj/item/stack/sheet/mineral/uranium = 10,
	)

//BOTANIST
/datum/job/botanist
	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/mutagen = 20,
		/obj/item/reagent_containers/glass/bottle/saltpetre = 20,
		/obj/item/reagent_containers/glass/bottle/diethylamine = 20,
		/obj/item/gun/energy/floragun = 10,
		/obj/item/seeds/random = 5,
		/obj/item/food/monkeycube/bee = 2
	)

//BRIG PHYSICIAN
/datum/job/brig_phys
	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
		/obj/item/storage/fancy/cigarettes = 15,
		/obj/item/food/donut = 10,
		/obj/item/food/donut/caramel = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival = 5
	)

//CAPTAIN, NOT THE DOG, BUT THE ACTUAL CAPTAIN OF THE STATION
/datum/job/captain
	mail_goodies = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 10
	)

//CARGO TECH
/datum/job/cargo_technician
	mail_goodies = list(
		/obj/item/pizzabox = 10,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 4,
		/obj/item/stack/sheet/mineral/diamond = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 1
	)

//CHAPLAIN
/datum/job/chaplain
	mail_goodies = list(
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 30,
		/obj/item/toy/plush/awakenedplushie = 10,
		/obj/item/grenade/chem_grenade/holy = 5,
		/obj/item/toy/plush/narplush = 2,
		/obj/item/toy/plush/plushvar = 1
	)

//CHEMIST
/datum/job/chemist
	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/flash_powder = 15,
		/obj/item/reagent_containers/glass/bottle/teslium = 5,
		/obj/item/reagent_containers/glass/bottle/lexorin = 5,
	)

//CHIEF ENGINEER
/datum/job/chief_engineer
	mail_goodies = list(
		/obj/item/food/cracker = 25, //you know. for poly
		/obj/item/stack/sheet/mineral/diamond = 15,
		/obj/item/stack/sheet/mineral/uranium/five = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 15,
		/obj/item/stack/sheet/mineral/gold = 15,
		/obj/item/wrench/caravan = 3,
		/obj/item/wirecutters/caravan = 3,
		/obj/item/screwdriver/caravan = 3,
		/obj/item/crowbar/red/caravan = 3
	)

//CHIEF MEDICAL OFFICER
/datum/job/chief_medical_officer
	mail_goodies = list(
		/obj/item/paper/fluff/jobs/medical/hippocratic = 5,
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/heart/gland/pop = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
		/obj/item/organ/regenerative_core = 2,
		/obj/item/scalpel/advanced = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/cautery/augment = 1,
		/obj/item/scalpel/alien = 1,
		/obj/item/hemostat/alien = 1,
		/obj/item/retractor/alien = 1,
		/obj/item/circular_saw/alien = 1,
		/obj/item/surgicaldrill/alien = 1,
		/obj/item/cautery/alien = 1
	)

//CLOWN
/datum/job/clown
	mail_goodies = list(
		/obj/item/food/grown/banana = 100,
		/obj/item/food/pie/cream = 50,
		/obj/item/storage/box/donkpockets/donkpockethonk = 10,
		/obj/item/clothing/shoes/clown_shoes/combat = 10,
		/obj/item/reagent_containers/spray/waterflower/lube = 20, 		// lube
		/obj/item/reagent_containers/spray/waterflower/superlube = 1, 	// Superlube, good lord.
		/mob/living/simple_animal/hostile/retaliate/clown = 10 			//HONK!!
	)
//COOK
/datum/job/cook
	mail_goodies = list(
		/obj/item/storage/box/ingredients/american = 20,
		/obj/item/storage/box/ingredients/carnivore = 20,
		/obj/item/storage/box/ingredients/delights = 20,
		/obj/item/storage/box/ingredients/exotic = 20,
		/obj/item/storage/box/ingredients/fiesta = 20,
		/obj/item/storage/box/ingredients/grains = 20,
		/obj/item/storage/box/ingredients/italian = 20,
		/obj/item/storage/box/ingredients/sweets = 20,
		/obj/item/storage/box/ingredients/vegetarian = 20,
		/obj/item/reagent_containers/glass/bottle/caramel = 20,
		/obj/item/reagent_containers/food/condiment/flour = 20,
		/obj/item/reagent_containers/food/condiment/rice = 20,
		/obj/item/reagent_containers/food/condiment/enzyme = 15,
		/obj/item/reagent_containers/food/condiment/soymilk = 15,
		/obj/item/choice_beacon/pet/goat = 10,
		/obj/item/kitchen/knife = 4,
		/obj/item/kitchen/knife/butcher = 2
	)

//CURATOR
/datum/job/curator
	mail_goodies = list(
		/obj/item/storage/toolbox/artistic = 20,
		/obj/item/canvas/nineteen_nineteen = 10,
		/obj/item/paper/fluff/curator/chaos = 5,
		/obj/item/paper/fluff/curator/kobold = 5,
		/obj/item/paper/fluff/curator/dwarf = 5,
		/obj/item/paper/fluff/curator/wgw = 5,
		/obj/item/paper/fluff/curator/wordsofgod = 5,
		/obj/item/soapstone = 5,
		/obj/item/book/granter/spell/summonitem = 2
	)

//DEBTOR
/datum/job/gimmick/hobo
	mail_goodies = list(
		/obj/item/food/deadmouse = 30,
		/obj/item/reagent_containers/food/drinks/bottle/hooch = 10,
		/obj/item/radio = 10,
		/obj/item/storage/pill_bottle/floorpill = 10,
		/obj/item/storage/pill_bottle/lsd = 5,
		/obj/item/storage/pill_bottle/happiness = 5,
		/obj/item/clothing/head/foilhat = 5,
		/obj/item/gps = 5,
		/obj/item/melee/skateboard = 5,
		/obj/item/melee/baseball_bat = 5,
		/mob/living/simple_animal/mouse = 5


	)

//DETECTIVE
/datum/job/detective
	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 25,
		/obj/item/ammo_box/c38 = 25,
		/obj/item/ammo_box/c38/dumdum = 5,
		/obj/item/ammo_box/c38/hotshot = 5,
		/obj/item/ammo_box/c38/iceblox = 5,
		/obj/item/ammo_box/c38/match = 5,
		/obj/item/ammo_box/c38/trac = 5,
		/obj/item/clothing/accessory/holster/detective = 1
	)

//DEPUTY...IS THIS JOB EVEN ACTIVE? I DON'T THINK IT IS
/datum/job/deputy //Copy of the sec officer, since this one may not even be active.
	mail_goodies = list(
		/obj/item/food/donut = 10,
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/chaos = 5,
		/obj/item/melee/baton = 1
	)
//EXPLORATION CREW
/datum/job/exploration //Slightly more powerful due to the rarity of them ever actually getting a chance to get their mail.
	mail_goodies = list(
		/obj/item/tank/internals/emergency_oxygen/engi = 20,
		/obj/item/storage/box/minertracker = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 10,
		/obj/item/pinpointer/crew = 10,
		/obj/item/extraction_pack = 5,
		/obj/item/pickaxe/diamond = 3
	)

//GENETICIST
/datum/job/geneticist
	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 10,
		/obj/item/chromosome/energy = 5,
		/obj/item/chromosome/power = 5,
		/obj/item/chromosome/reinforcer = 5,
		/obj/item/chromosome/stabilizer = 5,
		/obj/item/chromosome/synchronizer = 5
		)

//HEAD OF PERSONNEL
/datum/job/hop
	mail_goodies = list(
		/obj/item/card/id/silver = 25,
		/obj/item/lazarus_injector = 15,
		/obj/item/stack/sheet/bone = 5
	)

//HEAD OF SECURITY
/datum/job/hos
	mail_goodies = list(
		/obj/item/reagent_containers/food/drinks/coffee = 20,
		/obj/item/food/donut = 10,
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/chaos = 5,
		/obj/item/shield/riot/tele = 5,
		/obj/item/melee/baton = 1
	)

//JANITOR
/datum/job/janitor
	mail_goodies = list(
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10,
		/obj/item/choice_beacon/janicart = 5
	)

//LAWYER
/datum/job/lawyer
	mail_goodies = list(
		/obj/item/book/manual/wiki/security_space_law = 15, //Can never have enough LAW
		/obj/item/clothing/accessory/lawyers_badge = 10,
		/obj/item/storage/secure/briefcase = 10,
		/obj/item/megaphone = 5,
		/obj/item/clothing/glasses/sunglasses/advanced/garb = 5,
		/obj/item/gavelhammer = 5
	)

//MAGICIAN GIMMICK
/datum/job/gimmick/magician
	mail_goodies = list(
		/mob/living/simple_animal/chicken/rabbit/normal = 40, //AND FOR MY NEXT TRICK...
		/obj/item/gun/magic/wand = 10,
		/obj/item/clothing/head/collectable/tophat = 10,
		/obj/item/clothing/head/bowler = 5
	)

//MEDICAL DOCTOR
/datum/job/doctor
	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/augment = 6,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 6,
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/heart/gland/pop = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
		/obj/item/organ/regenerative_core = 2
	)

//MIME
/datum/job/mime
	mail_goodies = list(
		/obj/item/food/baguette = 15,
		/obj/item/food/cheesewedge = 10,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 10,
		/obj/item/book/mimery = 1,
	)

//PARAMEDIC / EMT / EMERGENCY MEDICAL TECHNICIAN
/datum/job/emt
	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
		/obj/item/reagent_containers/hypospray/medipen/stimpack = 10,
		/obj/item/reagent_containers/hypospray/medipen/morphine = 10,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 10,
		/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival = 5
	)

//PSYCHOLOGIST / SHRINK GIMMICK
/datum/job/gimmick/shrink
	mail_goodies =  list(
		/obj/item/storage/pill_bottle/mannitol = 30,
		/obj/item/storage/pill_bottle/happy = 5,
		/obj/item/gun/syringe = 1
	)

//QUARTERMASTER
/datum/job/qm
	mail_goodies = list(
		/obj/item/clothing/accessory/medal/ribbon/cargo = 10,
		/mob/living/simple_animal/sloth = 5,
		/obj/item/circuitboard/machine/emitter = 3
	)

//RESEARCH DIRECTOR
/datum/job/research_director
	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 30,
		/obj/item/circuitboard/machine/sleeper = 3,
		/obj/item/borg/upgrade/ai = 2
	)

//ROBOTICIST
/datum/job/roboticist
	mail_goodies = list(
		/obj/item/storage/box/flashes = 20,
		/obj/item/stack/sheet/iron/twenty = 15,
		/obj/item/modular_computer/tablet/preset/advanced = 5
	)//ADD BUTT ORGANS WHEN THOSE ARE MERGED

//SCIENTIST
/datum/job/scientist
	mail_goodies = list(
		/obj/item/anomaly_neutralizer = 10,
		/obj/item/disk/tech_disk/research/random = 2,
		/obj/item/camera_bug = 1
	)

//SECURITY OFFICER
/datum/job/officer
	mail_goodies = list(
		/obj/item/food/donut = 10,
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/chaos = 5,
		/obj/item/melee/baton = 1
	)

//MAILMAN GIMMICK
/datum/job/gimmick/mailman //
	mail_goodies = list(
		/obj/item/shovel = 4,
		/obj/item/scythe = 4,
		/obj/item/melee/baseball_bat = 4,
		/mob/living/simple_animal/pet/cat = 4, //You all know what this means.
		/obj/item/clipboard = 4, //Will you sign my petition?
		/obj/item/toy/katana = 4,
		/obj/item/toy/plush/moth/tyriaplush = 4 //OH MY GOD IT'S KROTCHY THE MOTH
	)

//SHAFT MINER
/datum/job/mining
	mail_goodies = list(
		/obj/item/tank/internals/emergency_oxygen/engi = 20,
		/obj/item/storage/box/minertracker = 15,
		/obj/item/lazarus_injector = 10,
		/obj/item/clothing/mask/facehugger/toy = 10,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium = 10,
		/obj/item/pickaxe/diamond = 3
	)

//ENGINEER
/datum/job/engineer
	mail_goodies = list(
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10,
		/obj/item/holosign_creator/engineering = 8,
		/obj/item/clothing/head/hardhat/red = 1
	)

//VIROLOGIST
/datum/job/virologist
	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/random_virus = 15, //yes, lets just send a random disease through the post
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 10,
		/obj/item/reagent_containers/glass/bottle/synaptizine = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/uranium = 5,
		/obj/item/choice_beacon/pet/hamster = 5 //hampter.
	)

//VIP / CELEBRITY GIMMICK
/datum/job/gimmick/celebrity
	mail_goodies = list(
		/obj/item/clothing/ears/headphones = 10, 			//WOW THE NEW BEATS BY DR.MOFF?
		/obj/item/clothing/under/syndicate/tacticool = 10,	//Only on the iScream 12
		/obj/item/reagent_containers/food/drinks/flask/gold = 10,
		/obj/item/choice_beacon/pet = 5,
		/obj/item/storage/bag/money = 5,
		/obj/item/coin/gold = 5,
		/obj/item/coin/silver = 5,
		/obj/item/encryptionkey/heads/captain = 1 //Tiny chance to harass the entire crew
	)

//WARDEN
/datum/job/warden
	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 15,
		/obj/item/storage/box/handcuffs = 10,
		/obj/item/storage/box/teargas = 10,
		/obj/item/storage/box/flashbangs = 10,
		/obj/item/storage/box/rubbershot = 10,
		/obj/item/storage/box/lethalshot = 5,
		/obj/item/choice_beacon/pet/mouse = 5
	)
