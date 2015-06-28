// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "A pack of seeds."
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				//Unknown plant seed - these shouldn't exist in-game.
	w_class = 1						//Pocketable.
	burn_state = 0 //Burnable
	var/plantname = "Plants"		//Name of plant when planted.
	var/product						//A type path. The thing that is created when the plant is harvested.
	var/species = ""				//Used to update icons. Should match the name in the sprites.
	var/lifespan = 0 				//How long before the plant begins to take damage from age.
	var/endurance = 0 				//Amount of health the plant has.
	var/maturation = 0 				//Used to determine which sprite to switch to when growing.
	var/production = 0 				//Changes the amount of time needed for a plant to become harvestable.
	var/yield = 0					//Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/oneharvest = 0				//If a plant is cleared from the tray after harvesting, e.g. a carrot.
	var/potency = -1				//The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/growthstages = 0			//Amount of growth sprites the plant has.
	var/plant_type = 0				//0 = 'normal plant'; 1 = weed; 2 = shroom
	var/rarity = 0					//How rare the plant is. Used for giving points to cargo when shipping off to Centcom.
	var/list/mutatelist = list()	//The type of plants that this plant can mutate into.

/obj/item/seeds/New(loc, parent)
	..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/seeds/proc/get_analyzer_text()  //in case seeds have something special to tell to the analyzer
	return

/obj/item/seeds/proc/on_chem_reaction(var/datum/reagents/S)  //in case seeds have some special interaction with special chems
	return

/obj/item/seeds/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "*** <B>[plantname]</B> ***"
		user << "-Plant Endurance: <span class='notice'>[endurance]</span>"
		user << "-Plant Lifespan: <span class='notice'>[lifespan]</span>"
		user << "-Species Discovery Value: <span class='notice'>[rarity]</span>"
		if(yield != -1)
			user << "-Plant Yield: <span class='notice'>[yield]</span>"
		user << "-Plant Production: <span class='notice'>[production]</span>"
		if(potency != -1)
			user << "-Plant Potency: <span class='notice'>[potency]</span>"
		var/list/text_strings = get_analyzer_text()
		if(text_strings)
			for(var/string in text_strings)
				user << string
		return
	..() // Fallthrough to item/attackby() so that bags can pick seeds up

/obj/item/seeds/chiliseed
	name = "pack of chili seeds"
	desc = "These seeds grow into chili plants. HOT! HOT! HOT!"
	icon_state = "seed-chili"
	species = "chili"
	plantname = "Chili Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/chili
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6
	rarity = 0 // CentComm knows about this species already, it's in exotic seeds crates.
	mutatelist = list(/obj/item/seeds/icepepperseed, /obj/item/seeds/chilighost)

/obj/item/seeds/replicapod
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
	product = /mob/living/carbon/human //verrry special -- Urist
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1 //seeds if there isn't a dna inside
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	var/ckey = null
	var/realName = null
	var/datum/mind/mind = null
	var/blood_gender = null
	var/blood_type = null
	var/list/features = null
	var/factions = null
	var/contains_sample = 0

/obj/item/seeds/replicapod/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/weapon/reagent_containers/syringe))
		if(!contains_sample)
			for(var/datum/reagent/blood/bloodSample in W.reagents.reagent_list)
				if(bloodSample.data["mind"] && bloodSample.data["cloneable"] == 1)
					mind = bloodSample.data["mind"]
					ckey = bloodSample.data["ckey"]
					realName = bloodSample.data["real_name"]
					blood_gender = bloodSample.data["gender"]
					blood_type = bloodSample.data["blood_type"]
					features = bloodSample.data["features"]
					factions = bloodSample.data["factions"]
					W.reagents.clear_reagents()
					user << "<span class='notice'>You inject the contents of the syringe into the seeds.</span>"
					contains_sample = 1
				else
					user << "<span class='warning'>The seeds reject the sample!</span>"
		else
			user << "<span class='warning'>The seeds already contain a genetic sample!</span>"
	..()


/obj/item/seeds/grapeseed
	name = "pack of grape seeds"
	desc = "These seeds grow into grape vines."
	icon_state = "seed-grapes"
	species = "grape"
	plantname = "Grape Vine"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2
	mutatelist = list(/obj/item/seeds/greengrapeseed)

/obj/item/seeds/greengrapeseed
	name = "pack of green grape seeds"
	desc = "These seeds grow into green-grape vines."
	icon_state = "seed-greengrapes"
	species = "greengrape"
	plantname = "Green-Grape Vine"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2
	rarity = 0 // Technically it's a beneficial mutant, but it's not exactly "new"...

/obj/item/seeds/cabbageseed
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "Cabbages"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 1
	mutatelist = list(/obj/item/seeds/replicapod)

/obj/item/seeds/berryseed
	name = "pack of berry seeds"
	desc = "These seeds grow into berry bushes."
	icon_state = "seed-berry"
	species = "berry"
	plantname = "Berry Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/berries
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/glowberryseed,/obj/item/seeds/poisonberryseed)

/obj/item/seeds/glowberryseed
	name = "pack of glow-berry seeds"
	desc = "These seeds grow into glow-berry bushes."
	icon_state = "seed-glowberry"
	species = "glowberry"
	plantname = "Glow-Berry Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow
	lifespan = 30
	endurance = 25
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	rarity = 20

/obj/item/seeds/bananaseed
	name = "pack of banana seeds"
	desc = "They're seeds that grow into banana trees. When grown, keep away from clown."
	icon_state = "seed-banana"
	species = "banana"
	plantname = "Banana Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/mimanaseed)

/obj/item/seeds/mimanaseed
	name = "pack of mimana seeds"
	desc = "They're seeds that grow into mimana trees. When grown, keep away from mime."
	icon_state = "seed-mimana"
	species = "mimana"
	plantname = "Mimana Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mimana
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggplantseed
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look nothing like eggs."
	icon_state = "seed-eggplant"
	species = "eggplant"
	plantname = "Eggplants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	potency = 20
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/eggyseed)

/obj/item/seeds/eggyseed
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look a lot like eggs."
	icon_state = "seed-eggy"
	species = "eggy"
	plantname = "Eggplants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/shell/eggy
	lifespan = 75
	endurance = 15
	maturation = 6
	production = 12
	yield = 2
	plant_type = 0
	growthstages = 6
	rarity = 0 // CentComm ships these to us in the exotic seeds crate.

/obj/item/seeds/bloodtomatoseed
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blood
	lifespan = 25
	endurance = 20
	maturation = 8
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6
	rarity = 20

/obj/item/seeds/tomatoseed
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluetomatoseed, /obj/item/seeds/bloodtomatoseed, /obj/item/seeds/killertomatoseed)

/obj/item/seeds/killertomatoseed
	name = "pack of killer-tomato seeds"
	desc = "These seeds grow into killer-tomato plants."
	icon_state = "seed-killertomato"
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	oneharvest = 1
	growthstages = 2
	rarity = 30

/obj/item/seeds/bluetomatoseed
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluespacetomatoseed)
	rarity = 20

/obj/item/seeds/bluespacetomatoseed
	name = "pack of blue-space tomato seeds"
	desc = "These seeds grow into blue-space tomato plants."
	icon_state = "seed-bluespacetomato"
	species = "bluespacetomato"
	plantname = "Blue-Space Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	rarity = 50

/obj/item/seeds/cornseed
	name = "pack of corn seeds"
	desc = "I don't mean to sound corny..."
	icon_state = "seed-corn"
	species = "corn"
	plantname = "Corn Stalks"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/corn
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 3
	plant_type = 0
	oneharvest = 1
	potency = 20
	growthstages = 3
	mutatelist = list(/obj/item/seeds/snapcornseed)

/obj/item/seeds/snapcornseed
	name = "pack of snapcorn seeds"
	desc = "Oh snap!"
	icon_state = "seed-snapcorn"
	species = "snapcorn"
	plantname = "Snapcorn Stalks"
	product = /obj/item/weapon/grown/snapcorn
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 3
	plant_type = 0
	oneharvest = 1
	potency = 20
	growthstages = 3

/obj/item/seeds/poppyseed
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 6
	potency = 20
	plant_type = 0
	oneharvest = 1
	growthstages = 3
	mutatelist = list(/obj/item/seeds/geraniumseed, /obj/item/seeds/lilyseed)

/obj/item/seeds/geraniumseed
	name = "pack of geranium seeds"
	desc = "These seeds grow into geranium."
	icon_state = "seed-geranium"
	species = "geranium"
	plantname = "geranium Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy/geranium
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 6
	potency = 20
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/seeds/lilyseed
	name = "pack of lily seeds"
	desc = "These seeds grow into lilies."
	icon_state = "seed-lily"
	species = "lily"
	plantname = "Lily Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy/lily
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 6
	potency = 20
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/seeds/potatoseed
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	species = "potato"
	plantname = "Potato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	lifespan = 30
	endurance = 15
	maturation = 10
	production = 1
	yield = 4
	plant_type = 0
	oneharvest = 1
	potency = 10
	growthstages = 4
	mutatelist = list(/obj/item/seeds/sweetpotatoseed)

/obj/item/seeds/sweetpotatoseed
	name = "pack of sweet potato seeds"
	desc = "These seeds grow into sweet potato plants"
	icon_state = "seed-sweetpotato"
	species = "sweetpotato"
	plantname = "Sweet Potato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/sweetpotato
	lifespan = 30
	endurance = 15
	maturation = 10
	production = 1
	yield = 4
	plant_type = 0
	oneharvest = 1
	potency = 10
	growthstages = 4

/obj/item/seeds/icepepperseed
	name = "pack of ice pepper seeds"
	desc = "These seeds grow into ice pepper plants."
	icon_state = "seed-icepepper"
	species = "chiliice"
	plantname = "Ice Pepper Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6
	rarity = 20

/obj/item/seeds/soyaseed
	name = "pack of soybean seeds"
	desc = "These seeds grow into soybean plants."
	icon_state = "seed-soybean"
	species = "soybean"
	plantname = "Soybean Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 15
	plant_type = 0
	growthstages = 4
	mutatelist = list(/obj/item/seeds/koiseed)

/obj/item/seeds/koiseed
	name = "pack of koibean seeds"
	desc = "These seeds grow into koibean plants."
	icon_state = "seed-koibean"
	species = "soybean"
	plantname = "Koibean Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/koibeans
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 4
	rarity = 20

/obj/item/seeds/wheatseed
	name = "pack of wheat seeds"
	desc = "These may, or may not, grow into wheat."
	icon_state = "seed-wheat"
	species = "wheat"
	plantname = "Wheat Stalks"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 15
	oneharvest = 1
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/oatseed, /obj/item/seeds/riceseed)

/obj/item/seeds/oatseed
	name = "pack of oat seeds"
	desc = "These may, or may not, grow into oat."
	icon_state = "seed-oat"
	species = "oat"
	plantname = "Oat Stalks"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/oat
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 15
	oneharvest = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/riceseed
	name = "pack of rice seeds"
	desc = "These may, or may not, grow into rice."
	icon_state = "seed-rice"
	species = "rice"
	plantname = "Rice Stalks"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/rice
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 15
	oneharvest = 1
	plant_type = 0
	growthstages = 3

/obj/item/seeds/carrotseed
	name = "pack of carrot seeds"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	oneharvest = 1
	plant_type = 0
	growthstages = 3
	mutatelist = list(/obj/item/seeds/parsnipseed)

/obj/item/seeds/parsnipseed
	name = "pack of parsnip seeds"
	desc = "These seeds grow into parsnips."
	icon_state = "seed-parsnip"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	oneharvest = 1
	plant_type = 0
	growthstages = 3

/obj/item/seeds/reishimycelium
	name = "pack of reishi mycelium"
	desc = "This mycelium grows into something medicinal and relaxing."
	icon_state = "mycelium-reishi"
	species = "reishi"
	plantname = "Reishi"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	lifespan = 35
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 15
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/amanitamycelium
	name = "pack of fly amanita mycelium"
	desc = "This mycelium grows into something horrible."
	icon_state = "mycelium-amanita"
	species = "amanita"
	plantname = "Fly Amanitas"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 10
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/angelmycelium)

/obj/item/seeds/angelmycelium
	name = "pack of destroying angel mycelium"
	desc = "This mycelium grows into something devastating."
	icon_state = "mycelium-angel"
	species = "angel"
	plantname = "Destroying Angels"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	lifespan = 50
	endurance = 35
	maturation = 12
	production = 5
	yield = 2
	potency = 35
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	rarity = 30

/obj/item/seeds/libertymycelium
	name = "pack of liberty-cap mycelium"
	desc = "This mycelium grows into liberty-cap mushrooms."
	icon_state = "mycelium-liberty"
	species = "liberty"
	plantname = "Liberty-Caps"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	lifespan = 25
	endurance = 15
	maturation = 7
	production = 1
	yield = 5
	potency = 15
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/chantermycelium
	name = "pack of chanterelle mycelium"
	desc = "This mycelium grows into chanterelle mushrooms."
	icon_state = "mycelium-chanter"
	species = "chanter"
	plantname = "Chanterelle Mushrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	lifespan = 35
	endurance = 20
	maturation = 7
	production = 1
	yield = 5
	potency = 15
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/towermycelium
	name = "pack of tower-cap mycelium"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	species = "towercap"
	plantname = "Tower Caps"
	product = /obj/item/weapon/grown/log
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 50
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/steelmycelium)

/obj/item/seeds/steelmycelium
	name = "pack of steel-cap mycelium"
	desc = "This mycelium grows into steel logs."
	icon_state = "mycelium-steelcap"
	species = "steelcap"
	plantname = "Steel Caps"
	product = /obj/item/weapon/grown/log/steel
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 50
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/glowshroom
	name = "pack of glowshroom mycelium"
	desc = "This mycelium -glows- into mushrooms!"
	icon_state = "mycelium-glowshroom"
	species = "glowshroom"
	plantname = "Glowshrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3 //-> spread
	potency = 30 //-> brightness
	oneharvest = 1
	growthstages = 4
	plant_type = 2
	rarity = 20

/obj/item/seeds/plumpmycelium
	name = "pack of plump-helmet mycelium"
	desc = "This mycelium grows into helmets... maybe."
	icon_state = "mycelium-plump"
	species = "plump"
	plantname = "Plump-Helmet Mushrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 1
	yield = 4
	potency = 15
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/walkingmushroommycelium)

/obj/item/seeds/walkingmushroommycelium
	name = "pack of walking mushroom mycelium"
	desc = "This mycelium will grow into huge stuff!"
	icon_state = "mycelium-walkingmushroom"
	species = "walkingmushroom"
	plantname = "Walking Mushrooms"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	lifespan = 30
	endurance = 30
	maturation = 5
	production = 1
	yield = 1
	potency = 10
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	rarity = 30

/obj/item/seeds/nettleseed
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/weapon/grown/nettle/basic
	lifespan = 30
	endurance = 40 // tuff like a toiger
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1
	mutatelist = list(/obj/item/seeds/deathnettleseed)

/obj/item/seeds/deathnettleseed
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	species = "deathnettle"
	plantname = "Death Nettles"
	product = /obj/item/weapon/grown/nettle/death
	lifespan = 30
	endurance = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1
	rarity = 10

/obj/item/seeds/weeds
	name = "pack of weed seeds"
	desc = "Yo mang, want some weeds?"
	icon_state = "seed"
	species = "weeds"
	plantname = "Starthistle"
	lifespan = 100
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = -1
	potency = -1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/harebell
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	species = "harebell"
	plantname = "Harebells"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 30
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/sunflowerseed
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	species = "sunflower"
	plantname = "Sunflowers"
	product = /obj/item/weapon/grown/sunflower
	lifespan = 25
	endurance = 20
	maturation = 6
	production = 2
	yield = 2
	potency = 10
	oneharvest = 1
	growthstages = 3
	plant_type = 0
	mutatelist = list(/obj/item/seeds/moonflowerseed,/obj/item/seeds/novaflowerseed)

/obj/item/seeds/moonflowerseed
	name = "pack of moonflower seeds"
	desc = "These seeds grow into moonflowers."
	icon_state = "seed-moonflower"
	species = "moonflower"
	plantname = "Moonflowers"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	lifespan = 25
	endurance = 20
	maturation = 6
	production = 2
	yield = 2
	potency = 15
	oneharvest = 1
	growthstages = 3
	plant_type = 0
	rarity = 10

/obj/item/seeds/novaflowerseed
	name = "pack of novaflower seeds"
	desc = "These seeds grow into novaflowers."
	icon_state = "seed-novaflower"
	species = "novaflower"
	plantname = "Novaflowers"
	product = /obj/item/weapon/grown/novaflower
	lifespan = 25
	endurance = 20
	maturation = 6
	production = 2
	yield = 2
	potency = 20
	oneharvest = 1
	growthstages = 3
	plant_type = 0

/obj/item/seeds/appleseed
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/goldappleseed)

/obj/item/seeds/poisonedappleseed
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6
	rarity = 50 // Source of cyanide, and impossible obtain normally.

/obj/item/seeds/goldappleseed
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6
	rarity = 40 // Alchemy!

/obj/item/seeds/ambrosiavulgarisseed
	name = "pack of ambrosia vulgaris seeds"
	desc = "These seeds grow into common ambrosia, a plant grown by and from medicine."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/ambrosiadeusseed)

/obj/item/seeds/ambrosiadeusseed
	name = "pack of ambrosia deus seeds"
	desc = "These seeds grow into ambrosia deus. Could it be the food of the gods..?"
	icon_state = "seed-ambrosiadeus"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6
	rarity = 40

/obj/item/seeds/whitebeetseed
	name = "pack of white-beet seeds"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	species = "whitebeet"
	plantname = "White-Beet Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 6
	oneharvest = 1
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/redbeetseed)

/obj/item/seeds/redbeetseed
	name = "pack of redbeet seeds"
	desc = "These seeds grow into red beet producing plants."
	icon_state = "seed-redbeet"
	species = "redbeet"
	plantname = "Red-Beet Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/redbeet
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 6
	oneharvest = 1
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/sugarcaneseed
	name = "pack of sugarcane seeds"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	lifespan = 60
	endurance = 50
	maturation = 3
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/watermelonseed
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/holymelonseed)

/obj/item/seeds/holymelonseed
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/holymelon
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/pumpkinseed
	name = "pack of pumpkin seeds"
	desc = "These seeds grow into pumpkin vines."
	icon_state = "seed-pumpkin"
	species = "pumpkin"
	plantname = "Pumpkin Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 3
	mutatelist = list(/obj/item/seeds/blumpkinseed)

/obj/item/seeds/blumpkinseed
	name = "pack of blumpkin seeds"
	desc = "These seeds grow into blumpkin vines."
	icon_state = "seed-blumpkin"
	species = "blumpkin"
	plantname = "Blumpkin Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/limeseed
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime
	lifespan = 55
	endurance = 50
	maturation = 6
	production = 6
	yield = 4
	potency = 15
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/orangeseed)

/obj/item/seeds/lemonseed
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
	icon_state = "seed-lemon"
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/cashseed)

/obj/item/seeds/cashseed
	name = "pack of money seeds"
	desc = "When life gives you lemons, mutate them into cash."
	icon_state = "seed-cash"
	species = "cashtree"
	plantname = "Money Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6
	rarity = 50  // Nanotrasen approves... but are these seeds even attainable?  Drag the tray to the shuttle?

/obj/item/seeds/orangeseed
	name = "pack of orange seed"
	desc = "Sour seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 5
	potency = 20
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/limeseed)

/obj/item/seeds/poisonberryseed
	name = "pack of poison-berry seeds"
	desc = "These seeds grow into poison-berry bushes."
	icon_state = "seed-poisonberry"
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/deathberryseed)
	rarity = 10 // Mildly poisonous berries are common in reality

/obj/item/seeds/deathberryseed
	name = "pack of death-berry seeds"
	desc = "These seeds grow into death berries."
	icon_state = "seed-deathberry"
	species = "deathberry"
	plantname = "Death Berry Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/berries/death
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 3
	potency = 50
	plant_type = 0
	growthstages = 6
	rarity = 30

/obj/item/seeds/grassseed
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/grass
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 2
	mutatelist = list(/obj/item/seeds/carpetseed)

/obj/item/seeds/carpetseed
	name = "pack of carpet seeds"
	desc = "These seeds grow into stylish carpet samples."
	icon_state = "seed-carpet"
	species = "carpet"
	plantname = "Carpet"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/carpet
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cocoapodseed
	name = "pack of cocoa pod seeds"
	desc = "These seeds grow into cacao trees. They look fattening." //SIC: cocoa is the seeds. The trees are spelled cacao.
	icon_state = "seed-cocoapod"
	species = "cocoapod"
	plantname = "Cocao Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 5
	mutatelist = list(/obj/item/seeds/vanillapodseed)

/obj/item/seeds/vanillapodseed
	name = "pack of vanilla pod seeds"
	desc = "These seeds grow into vanilla trees. They look fattening."
	icon_state = "seed-vanillapod"
	species = "vanillapod"
	plantname = "Vanilla Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/vanillapod
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/cherryseed
	name = "pack of cherry pits"
	desc = "Careful not to crack a tooth on one... That'd be the pits."
	icon_state = "seed-cherry"
	species = "cherry"
	plantname = "Cherry Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/bluecherryseed
	name = "pack of blue cherry pits"
	desc = "The blue kind of cherries"
	icon_state = "seed-bluecherry"
	species = "bluecherry"
	plantname = "Blue Cherry Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/kudzuseed
	name = "pack of kudzu seeds"
	desc = "These seeds grow into a weed that grows incredibly fast."
	icon_state = "seed-kudzu"
	species = "kudzu"
	plantname = "Kudzu"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	lifespan = 20
	endurance = 10
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growthstages = 4
	plant_type = 1
	rarity = 30
	var/list/mutations = list()

/obj/item/seeds/kudzuseed/New(loc, obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod/parent)
	..()
	if(parent)
		mutations = parent.mutations

/obj/item/seeds/kudzuseed/harvest()
	var/list/prod = ..()
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod/K in prod)
		K.mutations = mutations

/obj/item/seeds/kudzuseed/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/turf/T = get_turf(src)
	user << "<span class='notice'>You plant the kudzu. You monster.</span>"
	message_admins("Kudzu planted by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) at ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>)",0,1)
	investigate_log("was planted by [key_name(user)] at ([T.x],[T.y],[T.z])","kudzu")
	new /obj/effect/spacevine_controller(user.loc, mutations, potency, production)
	qdel(src)

/obj/item/seeds/kudzuseed/get_analyzer_text()
	var/list/mut_text = list()
	var/text_string = ""
	for(var/datum/spacevine_mutation/SM in mutations)
		text_string += "[(text_string == "") ? "" : ", "][SM.name]"
	mut_text += "-Plant Mutations: [(text_string == "") ? "None" : text_string]"
	return mut_text

/obj/item/seeds/kudzuseed/on_chem_reaction(var/datum/reagents/S)

	var/list/temp_mut_list = list()

	if(S.has_reagent("sterilizine", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == NEGATIVE)
				temp_mut_list += SM
		if(prob(20))
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()
	if(S.has_reagent("welding_fuel", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == POSITIVE)
				temp_mut_list += SM
		if(prob(20))
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()
	if(S.has_reagent("phenol", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == MINOR_NEGATIVE)
				temp_mut_list += SM
		if(prob(20))
			mutations.Remove(pick(temp_mut_list))
	if(S.has_reagent("blood", 15))
		production += rand(15, -5)
	if(S.has_reagent("amatoxin", 5))
		production += rand(5, -15)
	if(S.has_reagent("plasma", 5))
		potency += rand(5, -15)
	if(S.has_reagent("holywater", 10))
		potency += rand(15, -5)

/obj/item/seeds/chilighost
	name = "pack of ghost chili seeds"
	desc = "These seeds grow into a chili said to be the hottest in the galaxy."
	icon_state = "seed-chilighost"
	species = "chilighost"
	plantname = "chilighost"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili
	lifespan = 20
	endurance = 10
	maturation = 10
	production = 10
	yield = 3
	potency = 20
	plant_type = 0
	growthstages = 6
	rarity = 20

/obj/item/seeds/gatfruit
	name = "pack of gatfruit seeds"
	desc = "These seeds grow into .357 revolvers."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "gatfruit"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/gatfruit
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	plant_type = 0
	growthstages = 2
	rarity = 50 // Seems admin-only.

/obj/item/seeds/coffee_arabica_seed
	name = "pack of coffee arabica seeds"
	desc = "These seeds grow into coffee arabica bushes."
	icon_state = "seed-coffeea"
	species = "coffeea"
	plantname = "Coffee Arabica Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/coffee/arabica
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 5
	mutatelist = list(/obj/item/seeds/coffee_robusta_seed)

/obj/item/seeds/coffee_robusta_seed
	name = "pack of coffee robusta seeds"
	desc = "These seeds grow into coffee robusta bushes."
	icon_state = "seed-coffeer"
	species = "coffeer"
	plantname = "Coffee Robusta Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 5
	rarity = 20

/obj/item/seeds/tobacco_seed
	name = "pack of tobacco seeds"
	desc = "These seeds grow into tobacco plants."
	icon_state = "seed-tobacco"
	species = "tobacco"
	plantname = "Tobacco Plant"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	oneharvest = 1
	yield = 10
	potency = 10
	plant_type = 0
	growthstages = 3
	mutatelist = list(/obj/item/seeds/tobacco_space_seed)

/obj/item/seeds/tobacco_space_seed
	name = "pack of space tobacco seeds"
	desc = "These seeds grow into space tobacco plants."
	icon_state = "seed-stobacco"
	species = "stobacco"
	plantname = "Space Tobacco Plant"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	oneharvest = 1
	yield = 10
	potency = 10
	plant_type = 0
	growthstages = 3
	rarity = 20

/obj/item/seeds/tea_aspera_seed
	name = "pack of tea aspera seeds"
	desc = "These seeds grow into tea plants."
	icon_state = "seed-teaaspera"
	species = "teaaspera"
	plantname = "Tea Aspera Plant"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tea/aspera
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 5
	mutatelist = list(/obj/item/seeds/tea_astra_seed)

/obj/item/seeds/tea_astra_seed
	name = "pack of tea astra seeds"
	desc = "These seeds grow into tea plants."
	icon_state = "seed-teaastra"
	species = "teaastra"
	plantname = "Tea Astra Plant"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 5
	rarity = 20
