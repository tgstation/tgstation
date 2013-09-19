// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "pack of seeds"
	icon = 'icons/obj/seeds.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	flags = FPRINT | TABLEPASS
	w_class = 1.0 // Makes them pocketable
	var/plantname = "Plants"
	var/product	//a type path
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
	var/list/mutatelist = list()

/obj/item/seeds/New()
	..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/seeds/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "*** <B>[plantname]</B> ***"
		user << "-Plant Endurance: \blue [endurance]"
		user << "-Plant Lifespan: \blue [lifespan]"
		if(yield != -1)
			user << "-Plant Yield: \blue [yield]"
		user << "-Plant Production: \blue [production]"
		if(potency != -1)
			user << "-Plant Potency: \blue [potency]"
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
	mutatelist = list(/obj/item/seeds/icepepperseed, /obj/item/seeds/chillighost)


/obj/item/seeds/replicapod
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
	product = /mob/living/carbon/human //verrry special -- Urist
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
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
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
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
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
	product = /obj/item/weapon/reagent_containers/food/snacks/egg
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
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
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
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
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
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
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
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluespacetomatoseed)

/obj/item/seeds/bluespacetomatoseed
	name = "pack of blue-space tomato seeds"
	desc = "These seeds grow into blue-space tomato plants."
	icon_state = "seed-bluespacetomato"
	species = "bluespacetomato"
	plantname = "Blue-Space Tomato Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
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

/obj/item/seeds/poppyseed
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy
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
	species = "potato"
	plantname = "Potato-Plants"
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

/obj/item/seeds/icepepperseed
	name = "pack of ice-pepper seeds"
	desc = "These seeds grow into ice-pepper plants."
	icon_state = "seed-icepepper"
	species = "chiliice"
	plantname = "Ice-Pepper Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
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
	species = "soybean"
	plantname = "Soybean Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 5
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
	potency = 5
	oneharvest = 1
	plant_type = 0
	growthstages = 6

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

/obj/item/seeds/reishimycelium
	name = "pack of reishi mycelium"
	desc = "This mycelium grows into something relaxing."
	icon_state = "mycelium-reishi"
	species = "reishi"
	plantname = "Reishi"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
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
	species = "amanita"
	plantname = "Fly Amanitas"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 10 // Damage based on potency?
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/angelmycelium)

/obj/item/seeds/angelmycelium
	name = "pack of destroying angel mycelium"
	desc = "This mycelium grows into something devestating."
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
	potency = 15 // Lowish potency at start
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
	potency = 1
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
	potency = 1
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
	potency = 0
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
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/nettleseed
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/weapon/grown/nettle
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
	product = /obj/item/weapon/grown/deathnettle
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
	potency = 1
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

/obj/item/seeds/brownmold
	name = "pack of brown mold"
	desc = "Eww.. moldy."
	icon_state = "seed"
	species = "mold"
	plantname = "Brown Mold"
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

/obj/item/seeds/goldappleseed
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple
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
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
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
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus
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
	potency = 1
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

/obj/item/seeds/limeseed
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/lime
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
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/lemon
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
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/money
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
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/orange
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
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/deathberryseed)

/obj/item/seeds/deathberryseed
	name = "pack of death-berry seeds"
	desc = "These seeds grow into death berries."
	icon_state = "seed-deathberry"
	species = "deathberry"
	plantname = "Death Berry Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
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

/obj/item/seeds/kudzuseed/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	user << "<span class='notice'>You plant the kudzu. You monster.</span>"
	new /obj/effect/spacevine_controller(user.loc)
	del(src)

/obj/item/seeds/chillighost
	name = "pack of ghost chilli seeds"
	desc = "These seeds grow into a chili said to be the hottest in the galaxy."
	icon_state = "seed-chilighost"
	species = "chilighost"
	plantname = "chilighost"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chilli
	lifespan = 20
	endurance = 10
	maturation = 10
	production = 10
	yield = 3
	potency = 20
	plant_type = 0
	growthstages = 6
