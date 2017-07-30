///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

//see code/modules/research/designs/biogenerator_designs.dm for the rest


/* Botany Chemicals */

/datum/design/ash
	name = "Ash"
	id = "ash"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 3)
	make_reagents = list("ash" = 10)
	category = list("initial","Botany Chemicals")

/datum/design/ammonia
	name = "Ammonia"
	id = "ammonia"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 5)
	make_reagents = list("ammonia" = 10)
	category = list("initial","Botany Chemicals")

/datum/design/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 10)
	make_reagents = list("saltpetre" = 10)
	category = list("initial","Botany Chemicals")

/datum/design/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 20)
	make_reagents = list("diethylamine" = 10)
	category = list("initial","Botany Chemicals")

/datum/design/mutagen
	name = "Unstable Mutagen"
	id = "mutagen"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 80)
	make_reagents = list("mutagen" = 10)
	category = list("initial","Botany Chemicals")


/* Botany Chemical Bottles */

/datum/design/plantbgone_bottle
	name = "Plant-B-Gone Bottle"
	id = "plantbgone_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/weapon/reagent_containers/spray/plantbgone
	category = list("initial","Botany Chemicals")

/datum/design/mutagen_bottle
	name = "Unstable Mutagen Bottle"
	id = "mutagen_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/precision/mutagen
	category = list("initial","Botany Chemicals")

/datum/design/ash_bottle
	name = "Ash Bottle"
	id = "ash_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 15)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/precision/ash
	category = list("initial","Botany Chemicals")

/datum/design/ammonia_bottle
	name = "Ammonia Bottle"
	id = "ammonia_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/precision/ammonia
	category = list("initial","Botany Chemicals")

/datum/design/saltpetre_bottle
	name = "Saltpetre Bottle"
	id = "saltpetre_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/precision/saltpetre
	category = list("initial","Botany Chemicals")

/datum/design/diethylamine_bottle
	name = "Diethylamine Bottle"
	id = "diethylamine_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 100)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/precision/diethylamine
	category = list("initial","Botany Chemicals")


/* Storage */

/datum/design/book_bag
	name = "Book bag"
	id = "book_bag"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 200)
	build_path = /obj/item/weapon/storage/bag/books
	category = list("initial","Leather and Cloth")

/datum/design/plant_bag
	name = "Plant bag"
	id = "plant_bag"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 200)
	build_path = /obj/item/weapon/storage/bag/plants
	category = list("initial","Leather and Cloth")

/datum/design/mining_satchel
	name = "Mining satchel"
	id = "mining_satchel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 200)
	build_path = /obj/item/weapon/storage/bag/ore
	category = list("initial","Leather and Cloth")

/datum/design/chemistry_bag
	name = "Chemistry bag"
	id = "chemistry_bag"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 200)
	build_path = /obj/item/weapon/storage/bag/chemistry
	category = list("initial","Leather and Cloth")


/datum/design/leather_satchel
	name = "Leather satchel"
	id = "leather_satchel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/weapon/storage/backpack/satchel
	category = list("initial","Leather and Cloth")

/datum/design/wallet
	name = "Wallet"
	id = "wallet"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 100)
	build_path = /obj/item/weapon/storage/wallet
	category = list("initial","Leather and Cloth")


/* Gloves */

/datum/design/botany_gloves
	name = "Botanical gloves"
	id = "botany_gloves"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 150)
	build_path = /obj/item/clothing/gloves/botanic_leather
	category = list("initial","Leather and Cloth")


/* Belts */

/datum/design/toolbelt
	name = "Utility Belt"
	id = "toolbelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/weapon/storage/belt/utility
	category = list("initial","Leather and Cloth")


/datum/design/bandolier
	name = "Bandolier belt"
	id = "bandolier"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/weapon/storage/belt/bandolier
	category = list("initial","Leather and Cloth")

/* Jackets */

/datum/design/leather_jacket
	name = "Leather jacket"
	id = "leather_jacket"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/clothing/suit/jacket/leather
	category = list("initial","Leather and Cloth")

/datum/design/leather_overcoat
	name = "Leather overcoat"
	id = "leather_overcoat"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 1000)
	build_path = /obj/item/clothing/suit/jacket/leather/overcoat
	category = list("initial","Leather and Cloth")


/* Misc */

/datum/design/damp_rag
	name = "Damp rag"
	id = "damp_rag"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 200)
	build_path = /obj/item/weapon/reagent_containers/glass/rag
	category = list("initial","Leather and Cloth")

/datum/design/baseball_bat
	name = "Baseball bat"
	id = "baseball_bat"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 100)
	build_path = /obj/item/weapon/melee/baseball_bat
	category = list("initial","Leather and Cloth")