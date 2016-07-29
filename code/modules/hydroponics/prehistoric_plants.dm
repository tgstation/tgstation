//Plants aquired through xenoarchaeology

/datum/seed/telriis
	name = "telriis"
	seed_name = "telriis"
	display_name = "telriis grass"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/telriis_clump)
	mutants = null
	packet_icon = "seed-telriis"
	plant_icon = "telriis"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),PWINE = list(0,2))

	lifespan = 60
	maturation = 6
	production = 4
	yield = 4
	potency = 20
	growth_stages = 4

/obj/item/seeds/telriis
	seed_type = "telriis"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/telriis_clump
	name = "telriis grass"
	desc = "A clump of telriis grass, not recommended for consumption by sentients."
	icon_state = "telriisclump"
	plantname = "telriis"

/datum/seed/thaadra
	name = "thaadra"
	seed_name = "thaadra"
	display_name = "thaa'dra grass"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/thaadrabloom)
	mutants = null
	packet_icon = "seed-thaadra"
	plant_icon = "thaadra"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),FROSTOIL = list(5,7))

	lifespan = 50
	maturation = 3
	production = 3
	yield = 5
	potency = 20
	growth_stages = 4

/obj/item/seeds/thaadra
	seed_type = "thaadra"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/thaadrabloom
	name = "thaa'dra bloom"
	desc = "Looks chewy, might be good to eat."
	icon_state = "thaadrabloom"
	plantname = "thaadra"

/datum/seed/jurlmah
	name = "jurlmah"
	seed_name = "jurlmah"
	display_name = "jurl'mah tree"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/jurlmah)
	mutants = null
	packet_icon = "seed-jurlmah"
	plant_icon = "jurlmah"
	chems = list(NUTRIMENT = list(1,10),SEROTROTIUM = list(0,10))

	lifespan = 25
	maturation = 6
	production = 1
	yield = 3
	potency = 30
	growth_stages = 5
	biolum = 1
	biolum_colour = "#9FE7EC"

	large = 0

/obj/item/seeds/jurlmah
	seed_type = "jurlmah"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/jurlmah
	name = "jurl'mah pod"
	desc = "Bulbous and veiny, it appears to pulse slightly as you look at it."
	icon_state = "jurlmahpod"
	plantname = "jurlmah"

/datum/seed/amauri
	name = "amauri"
	seed_name = "amauri"
	display_name = "amauri stalks"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/amauri)
	mutants = null
	packet_icon = "seed-amauri"
	plant_icon = "amauri"
	chems = list(NUTRIMENT = list(1,10),ZOMBIEPOWDER = list(0,2),CONDENSEDCAPSAICIN = list(0,5))

	lifespan = 25
	maturation = 10
	production = 1
	yield = 3
	potency = 30
	growth_stages = 3
	biolum = 1
	biolum_colour = "#5532E2"


	large = 0

/obj/item/seeds/amauri
	seed_type = "amauri"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/amauri
	name = "amauri fruit"
	desc = "It is small, round and hard. Its skin is a thick dark purple."
	icon_state = "amaurifruit"
	plantname = "amauri"

/datum/seed/gelthi
	name = "gelthi"
	seed_name = "gelthi"
	display_name = "gelthi stem"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/gelthi)
	mutants = null
	packet_icon = "seed-gelthi"
	plant_icon = "gelthi"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),STOXIN = list(0,1),CAPSAICIN = list(0,1))

	lifespan = 55
	maturation = 6
	production = 5
	yield = 3
	potency = 20
	growth_stages = 3

	large = 0

/obj/item/seeds/gelthi
	seed_type = "gelthi"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/gelthi
	name = "gelthi berries"
	desc = "They feel fluffy and slightly warm to the touch."
	icon_state = "gelthiberries"
	gender = PLURAL
	plantname = "gelthi"

/datum/seed/vale
	name = "vale"
	seed_name = "vale"
	display_name = "vale tree"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/vale)
	mutants = null
	packet_icon = "seed-vale"
	plant_icon = "vale"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),SPORTDRINK = list(0,2),DEXALIN = list(0,5))

	lifespan = 100
	maturation = 6
	production = 6
	yield = 4
	potency = 20
	growth_stages = 4

	large = 0

/obj/item/seeds/vale
	seed_type = "vale"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/vale
	name = "vale leaves"
	desc = "Small, curly leaves covered in a soft pale fur."
	icon_state = "valeleaves"
	plantname = "vale"

/datum/seed/surik
	name = "surik"
	seed_name = "surik"
	display_name = "surik stalks"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/surik)
	mutants = null
	packet_icon = "seed-surik"
	plant_icon = "surik"
	harvest_repeat = 1
	chems = list(NUTRIMENT = list(1,10),IMPEDREZENE = list(0,3),SYNAPTIZINE = list(0,5))

	lifespan = 55
	maturation = 7
	production = 6
	yield = 3
	potency = 20
	growth_stages = 4

	large = 0

/obj/item/seeds/surik
	seed_type = "surik"
	vending_cat = "prehistoric"

/obj/item/weapon/reagent_containers/food/snacks/grown/surik
	name = "surik fruit"
	desc = "Multiple layers of blue skin peeling away to reveal a spongey core, vaguely resembling an ear."
	icon_state = "surikfruit"
	plantname = "surik"
