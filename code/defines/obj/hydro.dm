// Plant analyzer

/obj/item/device/analyzer/plant_analyzer
	name = "Plant Analyzer"
	desc = "Analyzes plants."
	icon = 'device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"

	attack_self(mob/user as mob)
		return 0

// ********************************************************
// Here's all the seeds (=plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "seed"
	icon = 'seeds.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	flags = FPRINT | TABLEPASS
	w_class = 1.0 // Makes them pocketable
	var/mypath = "/obj/item/seeds"
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0 // If is -1, the plant/shroom/weed is never meant to be harvested
	var/oneharvest = 0
	var/potency = -1
	var/growthstages = 0
	var/plant_type = 0 // 0 = 'normal plant'; 1 = weed; 2 = shroom


/obj/item/seeds/chiliseed
	name = "Chili plant seeds"
	desc = "Seeds that grow into peppers."
	icon_state = "seed-chili"
	mypath = "/obj/item/seeds/chiliseed"
	species = "chili"
	plantname = "Chili plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/chili"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6

/obj/item/seeds/replicapod
	name = "Replica pod seeds"
	desc = "Used to make replica humans, but made of plants."
	icon_state = "seed-replicapod"
	mypath = "/obj/item/seeds/replicapod"
	species = "replicapod"
	plantname = "Replica pod"
	productname = "/mob/living/carbon/human" //verrry special -- Urist
	lifespan = 50 //no idea what those do
	endurance = 8
	maturation = 10
	production = 10
	yield = 1 //seeds if there isn't a dna inside
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	var/ui = null //for storing the guy
	var/se = null
	var/ckey = null
	var/realName = null
	var/datum/mind/mind = null
	gender = "male"

/obj/item/seeds/grapeseed
	name = "Grape seeds"
	desc = "Seeds that grows into grapes."
	icon_state = "seed-grapes"
	mypath = "/obj/item/seeds/grapeseed"
	species = "grape"
	plantname = "Grape Vine"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/grapes"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2

/obj/item/seeds/greengrapeseed
	name = "Green Grape seeds"
	desc = "Seeds that grows into green grapes."
	icon_state = "seed-greengrapes"
	mypath = "/obj/item/seeds/greengrapeseed"
	species = "greengrape"
	plantname = "Gren Grape Vine"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cabbageseed
	name = "Cabbage seeds"
	desc = "Seeds that grow into cabbages."
	icon_state = "seed-cabbage"
	mypath = "/obj/item/seeds/cabbageseed"
	species = "cabbage"
	plantname = "Cabbage Plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 1

/obj/item/seeds/berryseed
	name = "Berry seeds"
	desc = "Seeds that grow into berries."
	icon_state = "seed-berry"
	mypath = "/obj/item/seeds/berryseed"
	species = "berry"
	plantname = "Berry bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/berries"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/glowberryseed
	name = "Glow Berry seeds"
	desc = "Seeds that grow into glow berries."
	icon_state = "seed-glowberry"
	mypath = "/obj/item/seeds/glowberryseed"
	species = "glowberry"
	plantname = "Glow Berry bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries"
	lifespan = 30
	endurance = 25
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bananaseed
	name = "Banana seeds"
	desc = "Seeds that grow into bananas."
	icon_state = "seed-banana"
	mypath = "/obj/item/seeds/bananaseed"
	species = "banana"
	plantname = "Banana tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/banana"
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggplantseed
	name = "Eggplant seeds"
	desc = "These seeds grow into plants in the form of eggs."
	icon_state = "seed-eggplant"
	mypath = "/obj/item/seeds/eggplantseed"
	species = "eggplant"
	plantname = "Eggplant plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggyseed
	name = "Egg Plant seeds"
	desc = "These seeds grow into plants in the form of eggs."
	icon_state = "seed-eggy"
	mypath = "/obj/item/seeds/eggy"
	species = "eggy"
	plantname = "Egg Plant plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/egg"
	lifespan = 75
	endurance = 15
	maturation = 6
	production = 12
	yield = 2
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bloodtomatoseed
	name = "Blood Tomato seeds"
	desc = "Used to grow blood tomotoes."
	icon_state = "seed-bloodtomato"
	mypath = "/obj/item/seeds/bloodtomatoseed"
	species = "bloodtomato"
	plantname = "Blood Tomato plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato"
	lifespan = 25
	endurance = 20
	maturation = 8
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/tomatoseed
	name = "Tomato seeds"
	desc = "Used to grow tomotoes."
	icon_state = "seed-tomato"
	mypath = "/obj/item/seeds/tomatoseed"
	species = "tomato"
	plantname = "Tomato plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/tomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/killertomatoseed
	name = "Killer Tomato seeds"
	desc = "Used to grow killer tomotoes."
	icon_state = "seed-killertomato"
	mypath = "/obj/item/seeds/killertomatoseed"
	species = "killertomato"
	plantname = "Killer Tomato plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	oneharvest = 1
	growthstages = 2

/obj/item/seeds/bluetomatoseed
	name = "Blue Tomato seeds"
	desc = "Used to grow blue tomotoes."
	icon_state = "seed-bluetomato"
	mypath = "/obj/item/seeds/bluetomatoseed"
	species = "bluetomato"
	plantname = "Blue Tomato plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/cornseed
	name = "Corn seeds"
	desc = "Grows corn."
	icon_state = "seed-corn"
	mypath = "/obj/item/seeds/cornseed"
	species = "corn"
	plantname = "Corn plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/corn"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 3
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/seeds/poppyseed
	desc = "Grows poppies."
	name = "Poppy seeds"
	icon_state = "seed-poppy"
	mypath = "/obj/item/seeds/poppyseed"
	species = "poppy"
	plantname = "Poppy plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/poppy"
	lifespan = 25
	endurance = 10
	potency = 20
	maturation = 8
	production = 6
	yield = 6
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/seeds/potatoseed
	name = "Potato Seeds"
	desc = "Grows into potatoes.."
	icon_state = "seed-potato"
	mypath = "/obj/item/seeds/potatoseed"
	species = "potato"
	plantname = "Potato Plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/potato"
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
	name = "Ice pepper seeds"
	desc = "Grows mutant, frozen peppers."
	icon_state = "seed-icepepper"
	mypath = "/obj/item/seeds/icepepperseed"
	species = "chiliice"
	plantname = "Ice pepper plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper"
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6

/obj/item/seeds/soyaseed
	name = "Soybean seeds"
	desc = "These grow into soy.."
	icon_state = "seed-soybean"
	mypath = "/obj/item/seeds/soyaseed"
	species = "soybean"
	plantname = "Soybean plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans"
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 0
	plant_type = 0
	growthstages = 6

/obj/item/seeds/wheatseed
	name = "Wheat seeds"
	desc = "Grows into wheat."
	icon_state = "seed-wheat"
	mypath = "/obj/item/seeds/wheatseed"
	species = "wheat"
	plantname = "Wheat stalks"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/wheat"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 0
	oneharvest = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/carrotseed
	name = "Carrot seeds"
	desc = "Used to grow carrots."
	icon_state = "seed-carrot"
	mypath = "/obj/item/seeds/carrotseed"
	species = "carrot"
	plantname = "Carrot"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/carrot"
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	oneharvest = 1
	plant_type = 0
	growthstages = 5

/obj/item/seeds/amanitamycelium
	name = "Fly Amanita mycelium"
	desc = "Grows into some kind of mushroom."
	icon_state = "mycelium-amanita"
	mypath = "/obj/item/seeds/amanitamycelium"
	species = "amanita"
	plantname = "Fly Amanita"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita"
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 10 // Damage based on potency?
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/angelmycelium
	name = "Destroying Angel mycelium"
	icon_state = "mycelium-angel"
	mypath = "/obj/item/seeds/angelmycelium"
	species = "angel"
	plantname = "Destroying Angel"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel"
	lifespan = 50
	endurance = 35
	maturation = 12
	production = 5
	yield = 2
	potency = 35
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/libertymycelium
	name = "Liberty Cap mycelium"
	desc = "It is said to grow drugs."
	icon_state = "mycelium-liberty"
	mypath = "/obj/item/seeds/libertymycelium"
	species = "liberty"
	plantname = "Liberty Cap"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap"
	lifespan = 25
	endurance = 15
	maturation = 7
	production = 1
	yield = 5
	potency = 15 // Lowish potency at start
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/chantermycelium
	name = "Chanterelle mycelium"
	desc = "Grows chanterelle."
	icon_state = "mycelium-chanter"
	mypath = "/obj/item/seeds/chantermycelium"
	species = "chanter"
	plantname = "Chanterelle"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle"
	lifespan = 35
	endurance = 20
	maturation = 7
	production = 1
	yield = 5
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/towermycelium
	name = "Tower Cap mycelium"
	desc = "Why does this sound so familiar...?"
	icon_state = "mycelium-tower"
	mypath = "/obj/item/seeds/towermycelium"
	species = "towercap"
	plantname = "Tower Cap"
	productname = "/obj/item/weapon/grown/log"
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/glowshroom
	name = "Glowshroom mycelium"
	desc = "This will glow into mushrooms."
	icon_state = "mycelium-glowshroom"
	mypath = "/obj/item/seeds/glowshroom"
	species = "glowshroom"
	plantname = "Glowshroom"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom"
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3 //-> spread
	potency = 30 //-> brightness
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/plumpmycelium
	name = "Plump Helmet mycelium"
	desc = "Grows into giant mushrooms. Very healthy to consume, unlike most."
	icon_state = "mycelium-plump"
	mypath = "/obj/item/seeds/plumpmycelium"
	species = "plump"
	plantname = "Plump Helmet"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 1
	yield = 4
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/walkingmushroommycelium
	name = "Walking Mushroom mycelium"
	desc = "This will grow into huge stuff."
	icon_state = "mycelium-walkingmushroom"
	mypath = "/obj/item/seeds/walkingmushroommycelium"
	species = "walkingmushroom"
	plantname = "Walking Mushroom"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom"
	lifespan = 30
	endurance = 30
	maturation = 5
	production = 1
	yield = 1
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/nettleseed
	name = "Nettle seeds"
	desc = "Grows into nettle."
	icon_state = "seed-nettle"
	mypath = "/obj/item/seeds/nettleseed"
	species = "nettle"
	plantname = "Nettle"
	productname = "/obj/item/weapon/grown/nettle"
	lifespan = 30
	endurance = 40 // tuff like a toiger
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1

/obj/item/seeds/deathnettleseed
	name = "Deathnettle seeds"
	desc = "Grows into Nettle."
	icon_state = "seed-deathnettle"
	mypath = "/obj/item/seeds/deathnettleseed"
	species = "deathnettle"
	plantname = "Death Nettle"
	productname = "/obj/item/weapon/grown/deathnettle"
	lifespan = 30
	endurance = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1

/obj/item/seeds/weeds
	name = "Weeds"
	desc = "These are not to be confused with the illegal kind of weed."
	icon_state = "seed"
	mypath = "/obj/item/seeds/weeds"
	species = "weeds"
	plantname = "Generic weeds"
	productname = ""
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
	name = "Harebell"
	desc = "Grows harebell."
	icon_state = "seed"
	mypath = "/obj/item/seeds/harebell"
	species = "harebell"
	plantname = "Harebell"
	productname = ""
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = -1
	potency = 1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/sunflowerseed
	name = "Sunflower seeds"
	desc = "Seeds that make sunflowers when they grow."
	icon_state = "seed-sunflower"
	mypath = "/obj/item/seeds/sunflowerseed"
	species = "sunflower"
	plantname = "Sunflower"
	productname = "/obj/item/weapon/grown/sunflower"
	lifespan = 25
	endurance = 20
	maturation = 6
	production = 1
	yield = 2
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 1

/obj/item/seeds/brownmold
	name = "Brown Mold"
	desc = "Moldy."
	icon_state = "seed"
	mypath = "/obj/item/seeds/brownmold"
	species = "mold"
	plantname = "Brown Mold"
	productname = ""
	lifespan = 50
	endurance = 30
	maturation = 10
	production = 1
	yield = -1
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/appleseed
	name = "Apple seeds"
	desc = "Grows apples."
	icon_state = "seed-apple"
	mypath = "/obj/item/seeds/appleseed"
	species = "apple"
	plantname = "Apple tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/apple"
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/ambrosiavulgarisseed
	name = "Ambrosia Vulgaris seeds"
	desc = "Plant seeds which grown by and from medicine."
	icon_state = "seed-ambrosiavulgaris"
	mypath = "/obj/item/seeds/ambrosiavulgarisseed"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris"
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 8
	plant_type = 0
	growthstages = 6

/obj/item/seeds/whitebeetseed
	name = "White Beet seed"
	desc = "Seeds for white beets."
	icon_state = "seed-whitebeet"
	mypath = "/obj/item/seeds/whitebeetseed"
	species = "whitebeet"
	plantname = "White Beet Plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet"
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 4
	plant_type = 0
	growthstages = 6

/obj/item/seeds/sugarcaneseed
	name = "Sugarcane seed"
	desc = "Seeds for sugarcane."
	icon_state = "seed-sugarcane"
	mypath = "/obj/item/seeds/sugarcaneseed"
	species = "sugarcane"
	plantname = "Sugarcane"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane"
	lifespan = 60
	endurance = 50
	maturation = 3
	production = 6
	yield = 4
	plant_type = 0
	growthstages = 3

/obj/item/seeds/watermelonseed
	name = "Watermelon Seed"
	desc = "Some seeds for watermelons."
	icon_state = "seed-watermelon"
	mypath = "/obj/item/seeds/watermelonseed"
	species = "watermelon"
	plantname = "Watermelon Plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon"
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6

/obj/item/seeds/pumpkinseed
	name = "Pumpkin Seed"
	desc = "Some seeds for pumpkins."
	icon_state = "seed-pumpkin"
	mypath = "/obj/item/seeds/pumpkinseed"
	species = "pumpkin"
	plantname = "pumpkin Plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin"
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 3


/obj/item/seeds/limeseed
	name = "Lime Seed"
	desc = "Seeds for limes."
	icon_state = "seed-lime"
	mypath = "/obj/item/seeds/limeseed"
	species = "lime"
	plantname = "Lime Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/lime"
	lifespan = 55
	endurance = 50
	maturation = 6
	production = 6
	yield = 4
	plant_type = 0
	growthstages = 6

/obj/item/seeds/lemonseed
	name = "Lemon Seed"
	desc = "Seeds for lemons."
	icon_state = "seed-lemon"
	mypath = "/obj/item/seeds/lemonseed"
	species = "lemon"
	plantname = "Lemon Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/lemon"
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	plant_type = 0
	growthstages = 6

/obj/item/seeds/orangeseed
	name = "Orange Seed"
	desc = "Seeds for oranges."
	icon_state = "seed-orange"
	mypath = "/obj/item/seeds/orangeseed"
	species = "orange"
	plantname = "Orange Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/orange"
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/poisonberryseed
	name = "Poison Berry seeds"
	desc = "Seeds that grows into poison berries."
	icon_state = "seed-poisonberry"
	mypath = "/obj/item/seeds/poisonberryseed"
	species = "poisonberry"
	plantname = "Poison Berry bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/deathberryseed
	name = "Death Berry seeds"
	desc = "Seeds that grows into death berries."
	icon_state = "seed-deathberry"
	mypath = "/obj/item/seeds/deathberryseed"
	species = "deathberry"
	plantname = "Death Berry bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries"
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 3
	potency = 50
	plant_type = 0
	growthstages = 6

/obj/item/seeds/grassseed
	name = "Grass seeds"
	desc = "Seeds that will one day become grass."
	icon_state = "seed-grass"
	mypath = "/obj/item/seeds/grassseed"
	species = "grass"
	plantname = "Grass"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/grass"
	lifespan = 60
	endurance = 50
	maturation = 2
	production = 5
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cocoapodseed
	name = "Cocoa Pod seeds"
	desc = "Seeds for cocoa; a major ingredient in chocolate."
	icon_state = "seed-cocoapod"
	mypath = "/obj/item/seeds/cocoapodseed"
	species = "cocoapod"
	plantname = "Cocoa Pod Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 5

/*  // Maybe one day when I get it to work like a grenade which exlodes gibs.
/obj/item/seeds/gibtomatoseed
	name = "Gib Tomato seeds"
	desc = "Used to grow gib tomotoes."
	icon_state = "seed-gibtomato"
	mypath = "/obj/item/seeds/gibtomatoseed"
	species = "gibtomato"
	plantname = "Gib Tomato plant"
	productname = "/obj/item/weapon/grown/gibtomato"
	lifespan = 35
	endurance = 25
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6
*/

/*
/obj/item/seeds/
	name = ""
	icon_state = "seed"
	mypath = "/obj/item/seeds/"
	species = ""
	plantname = ""
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/"
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = -1
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 0

*/



// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
/obj/item/weapon/reagent_containers/food/snacks/grown/ //New subclass so we can pass on values
	var/seed = ""
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = -1
	var/plant_type = 0
	icon = 'harvest.dmi'
	New(newloc,newpotency)
		if (!isnull(newpotency))
			potency = newpotency
		..()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "This is a \blue [name]"
		switch(plant_type)
			if(0)
				user << "- Plant type: \blue Normal plant"
			if(1)
				user << "- Plant type: \blue Weed"
			if(2)
				user << "- Plant type: \blue Mushroom"
		user << "- Potency: \blue [potency]"
		user << "- Yield: \blue [yield]"
		user << "- Maturation speed: \blue [maturation]"
		user << "- Production speed: \blue [production]"
		user << "- Endurance: \blue [endurance]"
		user << "- Healing properties: \blue [reagents.get_reagent_amount("nutriment")]"
		return

/obj/item/weapon/grown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "This is a \blue [name]"
		switch(plant_type)
			if(0)
				user << "- Plant type: \blue Normal plant"
			if(1)
				user << "- Plant type: \blue Weed"
			if(2)
				user << "- Plant type: \blue Mushroom"
		user << "- Acid strength: \blue [potency]"
		user << "- Yield: \blue [yield]"
		user << "- Maturation speed: \blue [maturation]"
		user << "- Production speed: \blue [production]"
		user << "- Endurance: \blue [endurance]"
		user << ""

		return
/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	seed = "/obj/item/seeds/cornseed"
	name = "Corn"
	desc = "I like corm!"
	icon_state = "corn"
	potency = 40
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	seed = "/obj/item/seeds/poppyseed"
	name = "Poppy"
	icon_state = "poppy"
	potency = 30
	New()
		..()
		reagents.add_reagent("nutriment", round((potency / 20), 1))
		reagents.add_reagent("opium", 1+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 3, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = "/obj/item/seeds/potatoseed"
	name = "Potato"
	desc = "Starchy!"
	icon_state = "potato"
	potency = 25
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = reagents.total_volume

	/*attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/cable_coil))
			if(W:amount >= 5)
				W:amount -= 5
				if(!W:amount) del(W)
				user << "\blue You add cable to the potato."
				new /obj/item/weapon/cell/potato(src.loc)
				del(src)*/


/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	seed = "/obj/item/seeds/grapeseed"
	name = "Grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		reagents.add_reagent("sugar", 1+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
	seed = "/obj/item/seeds/greengrapeseed"
	name = "Green Grapes"
	desc = "Nutritious!"
	icon_state = "greengrapes"
	potency = 25
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		reagents.add_reagent("kelotane", 3+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed = "/obj/item/seeds/cabbageseed"
	name = "Cabbage"
	desc = "Ewwwwwwwwww"
	icon_state = "cabbage"
	potency = 25
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = "/obj/item/seeds/berryseed"
	name = "Berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	seed = "/obj/item/seeds/glowberryseed"
	name = "Glow Berries"
	desc = "Nutritious!"
	var/on = 1
	var/brightness_on = 2 //luminosity when on
	icon_state = "glowberrypile"
	New()
		..()
		reagents.add_reagent("nutriment", round((potency / 10), 1))
		reagents.add_reagent("radium", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/Del()
	if(istype(loc,/mob))
		loc.sd_SetLuminosity(loc.luminosity - potency/5)
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/pickup(mob/user)
	src.sd_SetLuminosity(0)
	user.total_luminosity += potency/5

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/dropped(mob/user)
	user.total_luminosity -= potency/5
	src.sd_SetLuminosity(potency/5)

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	seed = "/obj/item/seeds/cocoapodseed"
	name = "Cocoa Pod"
	desc = "Fattening"
	icon_state = "cocoapod"
	potency = 50
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		reagents.add_reagent("coco", 4+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

//This object is just a transition object. All it does is make a grass tile and delete itself.
/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	seed = "/obj/item/seeds/grassseed"
	name = "Grass"
	desc = "Greeny"
	icon_state = "grass"
	potency = 20
	New()
		new/obj/item/stack/tile/grass(src.loc)
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed = "/obj/item/seeds/sugarcaneseed"
	name = "Sugarcane"
	desc = "Sugary"
	icon_state = "sugarcane"
	potency = 50
	New()
		..()
		reagents.add_reagent("sugar", 4+round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	seed = "/obj/item/seeds/poisonberryseed"
	name = "Poison Berries"
	desc = "Nutritious in a deadly way."
	icon_state = "poisonberrypile"
	potency = 15
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("toxin", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
	seed = "/obj/item/seeds/deathberryseed"
	name = "Death Berries"
	desc = "Nutritious in a deadly way."
	icon_state = "deathberrypile"
	potency = 50
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("toxin", 3+round(potency / 3, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
	seed = "/obj/item/seeds/ambrosiavulgarisseed"
	name = "Ambrosia Vulgaris"
	desc = "A plant containing various healing chemicals."
	icon_state = "ambrosiavulgaris"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("space_drugs", 3+round(potency / 5, 1))
		reagents.add_reagent("kelotane", 3+round(potency / 5, 1))
		reagents.add_reagent("bicaridine", 3+round(potency / 5, 1))
		reagents.add_reagent("toxin", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	seed = "/obj/item/seeds/appleseed"
	name = "Apple"
	desc = "A piece of Eden."
	icon_state = "apple"
	potency = 15
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	seed = "/obj/item/seeds/watermelonseed"
	name = "Watermelon"
	desc = "A melon full of watery goodness"
	icon_state = "watermelon"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	seed = "/obj/item/seeds/pumpkinseed"
	name = "Pumpkin"
	desc = "A large and scary pumpkin"
	icon_state = "pumpkin"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/lime
	seed = "/obj/item/seeds/limeseed"
	name = "Lime"
	desc = "A fruit so sour it twists your face."
	icon_state = "lime"
	potency = 20
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	seed = "/obj/item/seeds/lemonseed"
	name = "Lemon"
	desc = "A sour fruit that makes your mouth bleed."
	icon_state = "lemon"
	potency = 20
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/orange
	seed = "/obj/item/seeds/orangeseed"
	name = "Orange"
	desc = "A sweet and sour fruit."
	icon_state = "orange"
	potency = 20
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed = "/obj/item/seeds/whitebeetseed"
	name = "White Beet"
	desc = "A beeting of white."
	icon_state = "whitebeet"
	potency = 15
	New()
		..()
		reagents.add_reagent("nutriment", round((potency / 20), 1))
		reagents.add_reagent("sugar", 1+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	seed = "/obj/item/seeds/bananaseed"
	name = "Banana"
	desc = "A banana. Excellent clown weapon."
	icon = 'items.dmi'
	icon_state = "banana"
	item_state = "banana"
	On_Consume()
		if(!reagents.total_volume)
			var/mob/M = usr
			var/obj/item/weapon/bananapeel/W = new /obj/item/weapon/bananapeel( M )
			M << "\blue You peel the banana."
			M.put_in_hand(W)
			W.add_fingerprint(M)
	New()
		..()
		reagents.add_reagent("banana", 1+round((potency / 10), 1))
		bitesize = 5
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed = "/obj/item/seeds/chiliseed"
	name = "Chili"
	desc = "Spicy! Wait...ITS BURNING ME!"
	icon_state = "chilipepper"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
		reagents.add_reagent("capsaicin", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "- Capsaicin: \blue [reagents.get_reagent_amount("capsaicin")]%"

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed = "/obj/item/seeds/eggplantseed"
	name = "Eggplant"
	desc = "Yum!"
	icon_state = "eggplant"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed = "/obj/item/seeds/soyaseed"
	name = "Soybeans"
	desc = "Pretty bland, but the possibilities..."
	icon_state = "soybeans"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed = "/obj/item/seeds/tomatoseed"
	name = "Tomato"
	desc = "Tom-mae-to or to-mah-to? You decide."
	icon_state = "tomato"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/tomato_smudge(src.loc)
		src.visible_message("\red [src.name] has been squashed.","\red You hear a smack.")
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
	seed = "/obj/item/seeds/killertomatoseed"
	name = "Killer Tomato"
	desc = "Tom-mae-to or to-mah-to? You decide."
	icon_state = "killertomato"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)
		if(istype(src.loc,/mob))
			pickup(src.loc)
	lifespan = 120
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	new /obj/effect/critter/killertomato(user.loc)

	del(src)

	user << "You plant the killertomato."

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	seed = "/obj/item/seeds/bloodtomatoseed"
	name = "Blood Tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		reagents.add_reagent("blood", 1+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	seed = "/obj/item/seeds/bluetomatoseed"
	name = "Blue Tomato"
	desc = "Tom-mae-to or to-mah-to? You decide."
	icon_state = "bluetomato"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
		reagents.add_reagent("lube", 1+round((potency / 5), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed = "/obj/item/seeds/wheatseed"
	name = "Wheat"
	desc = "I wouldn't eat this, unless you're one of those health freaks.."
	icon_state = "wheat"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed = "/obj/item/seeds/icepepperseed"
	name = "Icepepper"
	desc = "A mutant strain of chile"
	icon_state = "icepepper"
	potency = 20
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
		reagents.add_reagent("frostoil", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "- Frostoil: \blue [reagents.get_reagent_amount("frostoil")]%"

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = "/obj/item/seeds/carrotseed"
	name = "Carrot"
	desc = "Good for the eyes!"
	icon_state = "carrot"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
		reagents.add_reagent("imidazoline", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = "/obj/item/seeds/amanitamycelium"
	name = "Fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("amatoxin", 3+round(potency / 3, 1))
		reagents.add_reagent("psilocybin", 1+round(potency / 25, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "- Amatoxins: \blue [reagents.get_reagent_amount("amatoxin")]%"
		user << "- Psilocybin: \blue [reagents.get_reagent_amount("psilocybin")]%"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	seed = "/obj/item/seeds/angelmycelium"
	name = "Destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	potency = 35
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
		reagents.add_reagent("amatoxin", 13+round(potency / 3, 1))
		reagents.add_reagent("psilocybin", 1+round(potency / 25, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "- Amatoxins: \blue [reagents.get_reagent_amount("amatoxin")]%"
		user << "- Psilocybin: \blue [reagents.get_reagent_amount("psilocybin")]%"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed = "/obj/item/seeds/libertymycelium"
	name = "Liberty cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	potency = 15
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
		reagents.add_reagent("psilocybin", 3+round(potency / 5, 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "- Psilocybin: \blue [reagents.get_reagent_amount("psilocybin")]%"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed = "/obj/item/seeds/plumpmycelium"
	name = "Plump Helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	New()
		..()
		reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed = "/obj/item/seeds/walkingmushroom"
	name = "Walking Mushroom"
	desc = "The beginging of the great walk."
	icon_state = "walkingmushroom"
	New()
		..()
		reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)
		if(istype(src.loc,/mob))
			pickup(src.loc)
	lifespan = 120
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	new /obj/effect/critter/walkingmushroom(user.loc)

	del(src)

	user << "You plant the walking mushroom."

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = "/obj/item/seeds/chantermycelium"
	name = "Chanterelle"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty! There's a lot!"
	icon_state = "chanterelle"
	New()
		..()
		reagents.add_reagent("nutriment",1+round((potency / 25), 1))
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = "/obj/item/seeds/glowshroom"
	name = "Glowshroom"
	desc = "<i>Glowshroom</i>: These species of mushrooms glown in the dark. OR DO THEY?"
	icon_state = "glowshroom"
	New()
		..()
		reagents.add_reagent("radium",1+round((potency / 20), 1))
		if(istype(src.loc,/mob))
			pickup(src.loc)
		else
			src.sd_SetLuminosity(potency/10)
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/obj/effect/glowshroom/planted = new /obj/effect/glowshroom(user.loc)

	planted.delay = lifespan * 50
	planted.endurance = endurance
	planted.yield = yield
	planted.potency = potency

	del(src)

	user << "You plant the glowshroom."

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/Del()
	if(istype(loc,/mob))
		loc.sd_SetLuminosity(loc.luminosity - potency/10)
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/pickup(mob/user)
	src.sd_SetLuminosity(0)
	user.total_luminosity += potency/10

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/dropped(mob/user)
	user.total_luminosity -= potency/10
	src.sd_SetLuminosity(potency/10)

// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'weapons.dmi'
	var/seed = ""
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 20
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 1
	var/plant_type = 0
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

/obj/item/weapon/grown/log
	desc = "It's better than bad, it's good!"
	icon = 'harvest.dmi'
	name = "Tower Cap Log"
	icon_state = "logs"
	force = 5
	flags = TABLEPASS
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	plant_type = 2
	origin_tech = "materials=1"
	seed = "/obj/item/seeds/towermycelium"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/circular_saw))
			W.visible_message(" \red <B>You make planks out of the [src]! </B>", 1)
			for(var/i=0,i<2,i++)
				new /obj/item/stack/sheet/wood (src.loc)
			del(src)
			return

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	desc = "This is a beautiful sunflower! A certain person might beat you to death if you trample these."
	icon = 'harvest.dmi'
	name = "Sunflower"
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/sunflower"
/*
/obj/item/weapon/grown/gibtomato
	desc = "A plump tomato."
	icon = 'harvest.dmi'
	name = "Gib Tomato"
	icon_state = "gibtomato"
	damtype = "fire"
	force = 0
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/gibtomato"
	New()
		..()


/obj/item/weapon/grown/gibtomato/New()
	..()
	src.gibs = new /obj/effect/gibspawner/human(get_turf(src))
	src.gibs.attach(src)
	src.smoke.set_up(10, 0, usr.loc)
*/
/obj/item/weapon/grown/nettle // -- Skie
	desc = "This is a nettle. It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'weapons.dmi'
	name = "Nettle"
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	origin_tech = "combat=1"
	seed = "/obj/item/seeds/nettleseed"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
		reagents.add_reagent("acid", round(potency, 1))
		force = round((5+potency/5), 1)

/obj/item/weapon/grown/deathnettle // -- Skie
	desc = "The \red glowing \black nettle incites \red<B>rage</B>\black in you just from looking at it!"
	icon = 'weapons.dmi'
	name = "Deathnettle"
	icon_state = "deathnettle"
	damtype = "fire"
	force = 30
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/deathnettleseed"
	origin_tech = "combat=3"
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
		reagents.add_reagent("pacid", round(potency, 1))
		force = round((5+potency/2.5), 1)

// *************************************
// Pestkiller defines for hydroponics
// *************************************

/obj/item/pestkiller
	name = ""
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	var/toxicity = 0
	var/PestKillStr = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/carbaryl
	name = "Carbaryl"
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	toxicity = 4
	PestKillStr = 2
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/lindane
	name = "Lindane"
	icon = 'chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	toxicity = 6
	PestKillStr = 4
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/phosmet
	name = "Phosmet"
	icon = 'chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	toxicity = 8
	PestKillStr = 7
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/weapon/plantbgone // -- Skie
	desc = "Plant-B-Gone! Kill those pesky weeds!"
	icon = 'hydroponics.dmi'
	name = "Plant-B-Gone"
	icon_state = "plantbgone"
	item_state = "plantbgone"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/empty = 0


/obj/item/weapon/weedspray // -- Skie
	desc = "Toxic mixture in spray form to kill small weeds."
	icon = 'hydroponics.dmi'
	name = "Weed Spray"
	icon_state = "weedspray"
	item_state = "spray"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/WeedKillStr = 2

/obj/item/weapon/pestspray // -- Skie
	desc = "Pest eliminator spray! Do not inhale!"
	icon = 'hydroponics.dmi'
	name = "Pest Spray"
	icon_state = "pestspray"
	item_state = "spray"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/PestKillStr = 2

/obj/item/weapon/minihoe // -- Numbers
	name = "Mini hoe"
	desc = "Use for removing weeds or scratching your back. Might be convinced for other uses."
	icon = 'weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50

// *************************************
// Weedkiller defines for hydroponics
// *************************************

/obj/item/weedkiller
	name = ""
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	var/toxicity = 0
	var/WeedKillStr = 0

/obj/item/weedkiller/triclopyr
	name = "Glyphosate"
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	toxicity = 4
	WeedKillStr = 2

/obj/item/weedkiller/lindane
	name = "Triclopyr"
	icon = 'chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	toxicity = 6
	WeedKillStr = 4

/obj/item/weedkiller/D24
	name = "2,4-D"
	icon = 'chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	toxicity = 8
	WeedKillStr = 7

// *************************************
// Nutrient defines for hydroponics
// *************************************

/obj/item/nutrient
	name = ""
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	w_class = 1.0
	var/mutmod = 0
	var/yieldmod = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/nutrient/ez
	name = "E-Z-Nutrient"
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	mutmod = 1
	yieldmod = 1
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/nutrient/l4z
	name = "Left 4 Zed"
	icon = 'chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	mutmod = 2
	yieldmod = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/nutrient/rh
	name = "Robust Harvest"
	icon = 'chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	mutmod = 0
	yieldmod = 2
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)
