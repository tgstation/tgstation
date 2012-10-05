// Plant analyzer

/obj/item/device/analyzer/plant_analyzer
	name = "plant analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"

	attack_self(mob/user as mob)
		return 0

// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "pack of seeds"
	icon = 'icons/obj/seeds.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	flags = FPRINT | TABLEPASS
	w_class = 1.0 // Makes them pocketable
	var/mypath = "/obj/item/seeds"
	var/plantname = "Plants"
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
	name = "pack of chili seeds"
	desc = "These seeds grow into chili plants. HOT! HOT! HOT!"
	icon_state = "seed-chili"
	mypath = "/obj/item/seeds/chiliseed"
	species = "chili"
	plantname = "Chili Plants"
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
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	mypath = "/obj/item/seeds/replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
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
	gender = MALE

/obj/item/seeds/grapeseed
	name = "pack of grape seeds"
	desc = "These seeds grow into grape vines."
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
	name = "pack of green grape seeds"
	desc = "These seeds grow into green-grape vines."
	icon_state = "seed-greengrapes"
	mypath = "/obj/item/seeds/greengrapeseed"
	species = "greengrape"
	plantname = "Green-Grape Vine"
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
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	mypath = "/obj/item/seeds/cabbageseed"
	species = "cabbage"
	plantname = "Cabbages"
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
	name = "pack of berry seeds"
	desc = "These seeds grow into berry bushes."
	icon_state = "seed-berry"
	mypath = "/obj/item/seeds/berryseed"
	species = "berry"
	plantname = "Berry Bush"
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
	name = "pack of glow-berry seeds"
	desc = "These seeds grow into glow-berry bushes."
	icon_state = "seed-glowberry"
	mypath = "/obj/item/seeds/glowberryseed"
	species = "glowberry"
	plantname = "Glow-Berry Bush"
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
	name = "pack of banana seeds"
	desc = "They're seeds that grow into banana trees."
	icon_state = "seed-banana"
	mypath = "/obj/item/seeds/bananaseed"
	species = "banana"
	plantname = "Banana Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/banana"
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggplantseed
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look nothing like eggs."
	icon_state = "seed-eggplant"
	mypath = "/obj/item/seeds/eggplantseed"
	species = "eggplant"
	plantname = "Eggplants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	potency = 20
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggyseed
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look a lot like eggs."
	icon_state = "seed-eggy"
	mypath = "/obj/item/seeds/eggy"
	species = "eggy"
	plantname = "Eggplants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/egg"
	lifespan = 75
	endurance = 15
	maturation = 6
	production = 12
	yield = 2
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bloodtomatoseed
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	mypath = "/obj/item/seeds/bloodtomatoseed"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
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
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	mypath = "/obj/item/seeds/tomatoseed"
	species = "tomato"
	plantname = "Tomato Plants"
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
	name = "pack of killer-tomato seeds"
	desc = "These seeds grow into killer-tomato plants."
	icon_state = "seed-killertomato"
	mypath = "/obj/item/seeds/killertomatoseed"
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
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
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	mypath = "/obj/item/seeds/bluetomatoseed"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bluespacetomatoseed
	name = "pack of blue-space tomato seeds"
	desc = "These seeds grow into blue-space tomato plants."
	icon_state = "seed-bluespacetomato"
	mypath = "/obj/item/seeds/bluespacetomatoseed"
	species = "bluespacetomato"
	plantname = "Blue-Space Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/cornseed
	name = "pack of corn seeds"
	desc = "I don't mean to sound corny..."
	icon_state = "seed-corn"
	mypath = "/obj/item/seeds/cornseed"
	species = "corn"
	plantname = "Corn Stalks"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/corn"
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
	mypath = "/obj/item/seeds/poppyseed"
	species = "poppy"
	plantname = "Poppy Plants"
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
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	mypath = "/obj/item/seeds/potatoseed"
	species = "potato"
	plantname = "Potato-Plants"
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
	name = "pack of ice-pepper seeds"
	desc = "These seeds grow into ice-pepper plants."
	icon_state = "seed-icepepper"
	mypath = "/obj/item/seeds/icepepperseed"
	species = "chiliice"
	plantname = "Ice-Pepper Plants"
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
	name = "pack of soybean seeds"
	desc = "These seeds grow into soybean plants."
	icon_state = "seed-soybean"
	mypath = "/obj/item/seeds/soyaseed"
	species = "soybean"
	plantname = "Soybean Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans"
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/wheatseed
	name = "pack of wheat seeds"
	desc = "These may, or may not, grow into weed."
	icon_state = "seed-wheat"
	mypath = "/obj/item/seeds/wheatseed"
	species = "wheat"
	plantname = "Wheat Stalks"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/wheat"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	oneharvest = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/carrotseed
	name = "pack of carrot seeds"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	mypath = "/obj/item/seeds/carrotseed"
	species = "carrot"
	plantname = "Carrots"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/carrot"
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
	desc = "This mycelium grows into something relaxing."
	icon_state = "mycelium-reishi"
	mypath = "/obj/item/seeds/reishimycelium"
	species = "reishi"
	plantname = "Reishi"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi"
	lifespan = 35
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 15 // Sleeping based on potency?
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/amanitamycelium
	name = "pack of fly amanita mycelium"
	desc = "This mycelium grows into something horrible."
	icon_state = "mycelium-amanita"
	mypath = "/obj/item/seeds/amanitamycelium"
	species = "amanita"
	plantname = "Fly Amanitas"
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
	name = "pack of destroying angel mycelium"
	desc = "This mycelium grows into something devestating."
	icon_state = "mycelium-angel"
	mypath = "/obj/item/seeds/angelmycelium"
	species = "angel"
	plantname = "Destroying Angels"
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
	name = "pack of liberty-cap mycelium"
	desc = "This mycelium grows into liberty-cap mushrooms."
	icon_state = "mycelium-liberty"
	mypath = "/obj/item/seeds/libertymycelium"
	species = "liberty"
	plantname = "Liberty-Caps"
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
	name = "pack of chanterelle mycelium"
	desc = "This mycelium grows into chanterelle mushrooms."
	icon_state = "mycelium-chanter"
	mypath = "/obj/item/seeds/chantermycelium"
	species = "chanter"
	plantname = "Chanterelle Mushrooms"
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
	name = "pack of tower-cap mycelium"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	mypath = "/obj/item/seeds/towermycelium"
	species = "towercap"
	plantname = "Tower Caps"
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
	name = "pack of glowshroom mycelium"
	desc = "This mycelium -glows- into mushrooms!"
	icon_state = "mycelium-glowshroom"
	mypath = "/obj/item/seeds/glowshroom"
	species = "glowshroom"
	plantname = "Glowshrooms"
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
	name = "pack of plump-helmet mycelium"
	desc = "This mycelium grows into helmets... maybe."
	icon_state = "mycelium-plump"
	mypath = "/obj/item/seeds/plumpmycelium"
	species = "plump"
	plantname = "Plump-Helmet Mushrooms"
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
	name = "pack of walking mushroom mycelium"
	desc = "This mycelium will grow into huge stuff!"
	icon_state = "mycelium-walkingmushroom"
	mypath = "/obj/item/seeds/walkingmushroommycelium"
	species = "walkingmushroom"
	plantname = "Walking Mushrooms"
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
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	mypath = "/obj/item/seeds/nettleseed"
	species = "nettle"
	plantname = "Nettles"
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
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	mypath = "/obj/item/seeds/deathnettleseed"
	species = "deathnettle"
	plantname = "Death Nettles"
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
	name = "pack of weed seeds"
	desc = "Yo mang, want some weeds?"
	icon_state = "seed"
	mypath = "/obj/item/seeds/weeds"
	species = "weeds"
	plantname = "Starthistle"
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
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	mypath = "/obj/item/seeds/harebell"
	species = "harebell"
	plantname = "Harebells"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/harebell"
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/sunflowerseed
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	mypath = "/obj/item/seeds/sunflowerseed"
	species = "sunflower"
	plantname = "Sunflowers"
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
	name = "pack of brown mold"
	desc = "Eww.. moldy."
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
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	mypath = "/obj/item/seeds/appleseed"
	species = "apple"
	plantname = "Apple Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/apple"
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/goldappleseed
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	mypath = "/obj/item/seeds/goldappleseed"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple"
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/ambrosiavulgarisseed
	name = "pack of ambrosia vulgaris seeds"
	desc = "These seeds grow into common ambrosia, a plant grown by and from medicine."
	icon_state = "seed-ambrosiavulgaris"
	mypath = "/obj/item/seeds/ambrosiavulgarisseed"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris"
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/ambrosiadeusseed
	name = "pack of ambrosia deus seeds"
	desc = "These seeds grow into ambrosia deus. Could it be the food of the gods..?"
	icon_state = "seed-ambrosiadeus"
	mypath = "/obj/item/seeds/ambrosiadeusseed"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus"
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/whitebeetseed
	name = "pack of white-beet seeds"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	mypath = "/obj/item/seeds/whitebeetseed"
	species = "whitebeet"
	plantname = "White-Beet Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet"
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
	mypath = "/obj/item/seeds/sugarcaneseed"
	species = "sugarcane"
	plantname = "Sugarcane"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane"
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
	mypath = "/obj/item/seeds/watermelonseed"
	species = "watermelon"
	plantname = "Watermelon Vines"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon"
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/pumpkinseed
	name = "pack of pumpkin seeds"
	desc = "These seeds grow into pumpkin vines."
	icon_state = "seed-pumpkin"
	mypath = "/obj/item/seeds/pumpkinseed"
	species = "pumpkin"
	plantname = "Pumpkin Vines"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin"
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
	mypath = "/obj/item/seeds/limeseed"
	species = "lime"
	plantname = "Lime Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/lime"
	lifespan = 55
	endurance = 50
	maturation = 6
	production = 6
	yield = 4
	potency = 15
	plant_type = 0
	growthstages = 6

/obj/item/seeds/lemonseed
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
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
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/cashseed
	name = "pack of money seeds"
	desc = "When life gives you lemons, mutate them into cash."
	icon_state = "seed-cash"
	mypath = "/obj/item/seeds/cashseed"
	species = "cashtree"
	plantname = "Money Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/money"
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/orangeseed
	name = "pack of orange seed"
	desc = "Sour seeds."
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
	potency = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/poisonberryseed
	name = "pack of poison-berry seeds"
	desc = "These seeds grow into poison-berry bushes."
	icon_state = "seed-poisonberry"
	mypath = "/obj/item/seeds/poisonberryseed"
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
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
	name = "pack of death-berry seeds"
	desc = "These seeds grow into death berries."
	icon_state = "seed-deathberry"
	mypath = "/obj/item/seeds/deathberryseed"
	species = "deathberry"
	plantname = "Death Berry Bush"
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
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
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
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cocoapodseed
	name = "pack of cocoa pod seeds"
	desc = "These seeds grow into cacao trees. They look fattening." //SIC: cocoa is the seeds. The tress ARE spelled cacao.
	icon_state = "seed-cocoapod"
	mypath = "/obj/item/seeds/cocoapodseed"
	species = "cocoapod"
	plantname = "Cocao Tree" //SIC: see above
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod"
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
	mypath = "/obj/item/seeds/cherryseed"
	species = "cherry"
	plantname = "Cherry Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cherries"
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	yield = 3
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

// *****************oolokitthesefancystars********
// Grown FOOD types moved to reagents
// **********************

// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
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

/obj/item/weapon/grown/proc/changePotency(newValue) //-QualityVan
	potency = newValue

/obj/item/weapon/grown/log
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/harvest.dmi'
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
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || (istype(W, /obj/item/weapon/twohanded/fireaxe) && W:wielded) || istype(W, /obj/item/weapon/melee/energy))
			user.show_message("<span class='notice'>You make planks out of the [src]!</span>", 1)
			for(var/i=0,i<2,i++)
				var/obj/item/stack/sheet/wood/NG = new (user.loc)
				for (var/obj/item/stack/sheet/wood/G in user.loc)
					if(G==NG)
						continue
					if(G.amount>=G.max_amount)
						continue
					G.attackby(NG, user)
					usr << "You add the newly-formed wood to the stack. It now contains [NG.amount] planks."
			del(src)
			return


/obj/item/weapon/grown/sunflower // FLOWER POWER!
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/harvest.dmi'
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
	icon = 'icons/obj/harvest.dmi'
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
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	name = "nettle"
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
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
			reagents.add_reagent("sacid", round(potency, 1))
			force = round((5+potency/5), 1)

/obj/item/weapon/grown/deathnettle // -- Skie
	desc = "The \red glowing \black nettle incites \red<B>rage</B>\black in you just from looking at it!"
	icon = 'icons/obj/weapons.dmi'
	name = "deathnettle"
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
	attack_verb = list("stung")
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
			reagents.add_reagent("pacid", round(potency, 1))
			force = round((5+potency/2.5), 1)

// *************************************
// Pestkiller defines for hydroponics
// *************************************

/obj/item/pestkiller
	name = "bottle of pestkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	var/toxicity = 0
	var/PestKillStr = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/carbaryl
	name = "bottle of carbaryl"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	toxicity = 4
	PestKillStr = 2
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/lindane
	name = "bottle of lindane"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	toxicity = 6
	PestKillStr = 4
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/phosmet
	name = "bottle of phosmet"
	icon = 'icons/obj/chemical.dmi'
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

/obj/item/weapon/weedspray // -- Skie
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics.dmi'
	name = "weed-spray"
	icon_state = "weedspray"
	item_state = "spray"
	flags = TABLEPASS | OPENCONTAINER | FPRINT | USEDELAY
	slot_flags = SLOT_BELT
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/WeedKillStr = 2

/obj/item/weapon/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics.dmi'
	name = "pest-spray"
	icon_state = "pestspray"
	item_state = "spray"
	flags = TABLEPASS | OPENCONTAINER | FPRINT | USEDELAY
	slot_flags = SLOT_BELT
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/PestKillStr = 2

/obj/item/weapon/minihoe // -- Numbers
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50
	attack_verb = list("slashed", "sliced", "cut", "clawed")

// *************************************
// Weedkiller defines for hydroponics
// *************************************

/obj/item/weedkiller
	name = "bottle of weedkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	var/toxicity = 0
	var/WeedKillStr = 0

/obj/item/weedkiller/triclopyr
	name = "bottle of glyphosate"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	toxicity = 4
	WeedKillStr = 2

/obj/item/weedkiller/lindane
	name = "bottle of triclopyr"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	toxicity = 6
	WeedKillStr = 4

/obj/item/weedkiller/D24
	name = "bottle of 2,4-D"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	toxicity = 8
	WeedKillStr = 7

// *************************************
// Nutrient defines for hydroponics
// *************************************

/obj/item/nutrient
	name = "bottle of nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	w_class = 1.0
	var/mutmod = 0
	var/yieldmod = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	mutmod = 1
	yieldmod = 1
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/nutrient/l4z
	name = "bottle of Left 4 Zed"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	mutmod = 2
	yieldmod = 0
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/nutrient/rh
	name = "bottle of Robust Harvest"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	mutmod = 0
	yieldmod = 2
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)


