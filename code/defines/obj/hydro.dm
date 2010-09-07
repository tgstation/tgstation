// ********************************************************
// Here's all the seeds (=plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "seed"
	icon = 'hydroponics.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	flags = FPRINT | TABLEPASS
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
	plant_type = 0
	growthstages = 6

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
	potency = 0
	oneharvest = 1
	plant_type = 0
	growthstages = 5

/obj/item/seeds/amanitamycelium
	name = "Fly Amanita mycelium"
	icon_state = "mycelium-amanita"
	mypath = "/obj/item/seeds/amanitamycelium"
	species = "amanita"
	plantname = "Fly Amanita"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/amanita"
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
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/angel"
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
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/libertycap"
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
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/chanterelle"
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
	productname = "" // Doesn't exist yet
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = -1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/plumpmycelium
	name = "Plump Helmet mycelium"
	icon_state = "mycelium-plump"
	mypath = "/obj/item/seeds/plumpmycelium"
	species = "plump"
	plantname = "Plump Helmet"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/plumphelmet"
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

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = "/obj/item/seeds/berryseed"
	name = "Berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	amount = 2
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed = "/obj/item/seeds/chiliseed"
	name = "Chili"
	desc = "Spicy!"
	icon_state = "chilipepper"
	amount = 1
	heal_amt = 2
	heat_amt = 20
	potency = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed = "/obj/item/seeds/eggplantseed"
	name = "Eggplant"
	desc = "Yum!"
	icon_state = "eggplant"
	amount = 1
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed = "/obj/item/seeds/soyaseed"
	name = "Soybeans"
	desc = "Pretty bland, but the possibilities..."
	icon_state = "soybeans"
	amount = 2
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed = "/obj/item/seeds/tomatoseed"
	name = "Tomato"
	desc = "Tom-mae-to or to-mah-to? You decide."
	icon_state = "tomato"
	amount = 2
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed = "/obj/item/seeds/wheatseed"
	name = "Wheat"
	desc = "I wouldn't eat this, unless you're one of those health freaks.."
	icon_state = "wheat"
	amount = 1
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed = "/obj/item/seeds/icepepperseed"
	name = "Icepepper"
	desc = "A mutant strain of chile"
	icon_state = "icepepper"
	amount = 1
	heal_amt = 3
	heat_amt = 20
	potency = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = "/obj/item/seeds/carrotseed"
	name = "Carrot"
	desc = "Good for the eyes!"
	icon_state = "carrot"
	amount = 3
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/amanita
	seed = "/obj/item/seeds/amanitamycelium"
	name = "Fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	amount = 1
	heal_amt = 0
	poison_amt = 25
	potency = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/angel
	seed = "/obj/item/seeds/angelmycelium"
	name = "Destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	amount = 1
	heal_amt = 0
	poison_amt = 75
	potency = 35

/obj/item/weapon/reagent_containers/food/snacks/grown/libertycap
	seed = "/obj/item/seeds/libertymycelium"
	name = "Liberty cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	amount = 1
	heal_amt = 3
	drug_amt = 15
	potency = 15

/obj/item/weapon/reagent_containers/food/snacks/grown/plumphelmet
	seed = "/obj/item/seeds/plumpmycelium"
	name = "Plump Helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	amount = 2
	heal_amt = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/chanterelle
	seed = "/obj/item/seeds/chantermycelium"
	name = "Chanterelle"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty! There's a lot!"
	icon_state = "chanterelle"
	amount = 3
	heal_amt = 2








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

/obj/item/pestkiller/carbaryl
	name = "Carbaryl"
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	toxicity = 4
	PestKillStr = 2

/obj/item/pestkiller/lindane
	name = "Lindane"
	icon = 'chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	toxicity = 6
	PestKillStr = 4

/obj/item/pestkiller/phosmet
	name = "Phosmet"
	icon = 'chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	toxicity = 8
	PestKillStr = 7








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