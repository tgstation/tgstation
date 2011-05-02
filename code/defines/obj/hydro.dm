// Plant analyzer

/obj/item/device/analyzer/plant_analyzer
	name = "Plant Analyzer"
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
	var/mind = null
	gender = "male"

/obj/item/seeds/berryseed
	name = "Berry seeds"
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

/obj/item/seeds/eggplantseed
	name = "Eggplant seeds"
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
	icon_state = "seed-eggy"
	mypath = "/obj/item/seeds/eggy"
	species = "eggy"
	plantname = "Egg Plant plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/egg"
	lifespan = 75
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	plant_type = 0
	growthstages = 6

/obj/item/seeds/tomatoseed
	name = "Tomato seeds"
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

/obj/item/seeds/cornseed
	name = "Corn seeds"
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
/*
/obj/item/seeds/poppyseed
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
	yield = 3
	plant_type = 0
	oneharvest = 1
	growthstages = 3
*/
/obj/item/seeds/potatoseed
	name = "Potato Seeds"
	icon_state = "seed-potato"
	mypath = "/obj/item/seeds/potatoseed"
	species = "potato"
	plantname = "Potato Plant"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/potato"
	lifespan = 30
	endurance = 15
	maturation = 10
	production = 1
	yield = 2
	plant_type = 0
	oneharvest = 1
	potency = 10
	growthstages = 4

/obj/item/seeds/icepepperseed
	name = "Ice pepper seeds"
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
	icon_state = "seed-carrot"
	mypath = "/obj/item/seeds/carrotseed"
	species = "carrot"
	plantname = "CURROTS MAN CURROTS"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/carrot"
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = 4
	potency = 10
	oneharvest = 1
	plant_type = 0
	growthstages = 5

/obj/item/seeds/amanitamycelium
	name = "Fly Amanita mycelium"
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
	icon_state = "mycelium-liberty"
	mypath = "/obj/item/seeds/libertymycelium"
	species = "liberty"
	plantname = "Liberty Cap"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap"
	lifespan = 25
	endurance = 15
	maturation = 7
	production = 1
	yield = 6
	potency = 15 // Lowish potency at start
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/chantermycelium
	name = "Chanterelle mycelium"
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
	potency = -1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/towermycelium
	name = "Tower Cap mycelium"
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
	potency = -1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/glowshroom
	name = "Glowshroom mycelium"
	icon_state = "mycelium-glowshroom"
	mypath = "/obj/item/seeds/glowshroom"
	species = "glowshroom"
	plantname = "Glowshroom"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom"
	lifespan = 60 //ten times that is the delay
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

/obj/item/seeds/nettleseed
	name = "Nettle seeds"
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
	potency = 8
	oneharvest = 0
	growthstages = 5
	plant_type = 1

/obj/item/seeds/deathnettleseed
	name = "Deathnettle seeds"
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
	potency = 20
	oneharvest = 0
	growthstages = 5
	plant_type = 1

/obj/item/seeds/weeds
	name = "Weeds"
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
	potency = -1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/brownmold
	name = "Brown Mold"
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
	potency = -1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

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
	icon_state = "corn"
	New()
		..()
		reagents.add_reagent("nutriment", 2)
/*
/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	seed = "/obj/item/seeds/poppyseed"
	name = "Poppy"
	icon_state = "poppy"
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("opium", max(round((potency / 5), 1), 2))
		bitesize = reagents.total_volume
*/

/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = "/obj/item/seeds/potatoseed"
	name = "Potato"
	desc = "Starchy!"
	icon_state = "potato"
	New()
		..()
		reagents.add_reagent("nutriment", max(round((potency / 5), 1), 2))

	/*attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/cable_coil))
			if(W:amount >= 5)
				W:amount -= 5
				if(!W:amount) del(W)
				user << "\blue You add cable to the potato."
				new /obj/item/weapon/cell/potato(src.loc)
				del(src)*/


/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = "/obj/item/seeds/berryseed"
	name = "Berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed = "/obj/item/seeds/chiliseed"
	name = "Chili"
	desc = "Spicy!"
	icon_state = "chilipepper"
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("capsaicin", max(round(potency / 5, 1), 4))
		bitesize = max(round(reagents.total_volume / 2, 1), 1)

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
		reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed = "/obj/item/seeds/soyaseed"
	name = "Soybeans"
	desc = "Pretty bland, but the possibilities..."
	icon_state = "soybeans"
	New()
		..()
		reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed = "/obj/item/seeds/tomatoseed"
	name = "Tomato"
	desc = "Tom-mae-to or to-mah-to? You decide."
	icon_state = "tomato"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed = "/obj/item/seeds/wheatseed"
	name = "Wheat"
	desc = "I wouldn't eat this, unless you're one of those health freaks.."
	icon_state = "wheat"
	New()
		..()
		reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed = "/obj/item/seeds/icepepperseed"
	name = "Icepepper"
	desc = "A mutant strain of chile"
	icon_state = "icepepper"
	potency = 20
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("frostoil", max(round(potency / 5, 1), 4))
		bitesize = max(round(reagents.total_volume / 2, 1), 1)

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
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("imidazoline", max(round(potency / 5, 1), 4))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = "/obj/item/seeds/amanitamycelium"
	name = "Fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	potency = 10
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("amatoxin", max(round(potency * 0.4, 1), 4))
		reagents.add_reagent("psilocybin", max(round(potency / 25, 1), 1))
		bitesize = max(round(reagents.total_volume / 2, 1), 1)

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
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("amatoxin", max(round(potency * 0.4, 1), 14))
		reagents.add_reagent("psilocybin", max(round(potency / 25, 1), 1))
		bitesize = max(round(reagents.total_volume / 2, 1), 1)

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
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("psilocybin", max(round(potency / 5, 1), 4))
		bitesize = max(round(reagents.total_volume / 2), 1)

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
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = "/obj/item/seeds/chantermycelium"
	name = "Chanterelle"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty! There's a lot!"
	icon_state = "chanterelle"
	New()
		..()
		reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = "/obj/item/seeds/glowshroom"
	name = "Glowshroom"
	desc = "<i>Glowshroom</i>: These species of mushrooms glown in the dark. OR DO THEY?"
	icon_state = "glowshroom"
	New()
		..()
		reagents.add_reagent("radium",1)
		if(istype(src.loc,/mob))
			pickup(src.loc)
		else
			src.sd_SetLuminosity(potency/10)
	lifespan = 60 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/obj/glowshroom/planted = new /obj/glowshroom(user.loc)

	planted.delay = lifespan * 10
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
	user.sd_SetLuminosity(user.luminosity + potency/10)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/dropped(mob/user)
	user.sd_SetLuminosity(user.luminosity - potency/10)
	src.sd_SetLuminosity(potency/10)


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