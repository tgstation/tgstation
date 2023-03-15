///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

//MonkeStation changes:
//Adds 4 tiers to the biogenerator designs

/datum/design/milk
	category = list("initial","Food")

/datum/design/cream
	category = list("initial","Food")

/datum/design/milk_carton
	category = list("tier_two","Food")

/datum/design/cream_carton
	category = list("tier_two","Food")

/datum/design/black_pepper
	category = list("initial","Food")

/datum/design/pepper_mill
	category = list("tier_two","Food")

/datum/design/enzyme
	category = list("tier_two","Food")

/datum/design/universal_enzyme
	name = "Universal Enzyme Bottle"
	id = "enzyme_bottle"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/food/condiment/enzyme
	make_reagents = list()
	category = list("tier_three","Food")

/datum/design/flour_sack
	category = list("tier_two","Food")

/datum/design/sugar_sack
	category = list("tier_two","Food")

/datum/design/donk_pocket
	name = "Plain Donk Pocket"
	id = "donk_pocket"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 200)
	build_path = /obj/item/food/donkpocket
	category = list("tier_two","Food")

/datum/design/monkey_cube
	category = list("tier_three", "Food")

/datum/design/strange_seeds
	name = "Pack of Strange Seeds"
	id = "strange_seed"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 7500) //Unlocked only at Tier 3/4 parts now. Cost of 2500/1875 biomass.
	build_path = /obj/item/seeds/random
	category = list("tier_three", "Food")

/datum/design/ez_nut
	category = list("initial","Botany Chemicals")

/datum/design/l4z_nut
	category = list("tier_two","Botany Chemicals")

/datum/design/rh_nut
	category = list("tier_three","Botany Chemicals")

/datum/design/weed_killer
	category = list("tier_two","Botany Chemicals")

/datum/design/pest_spray
	category = list("tier_two","Botany Chemicals")

/datum/design/botany_bottle
	category = list("initial", "Botany Chemicals")

/datum/design/medical_spray
	name = "Empty Medical Spray"
	id = "medical_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 10000)
	build_path = /obj/item/reagent_containers/medspray
	category = list("tier_three","Botany Chemicals")

/datum/design/spray_bottle
	name = "Empty Spray Bottle"
	id = "spray_bottle"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 10000)
	build_path = /obj/item/reagent_containers/spray
	category = list("tier_three","Botany Chemicals")

/datum/design/paper_bin
	name = "Paper Bin"
	id = "paper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 100)
	build_path = /obj/item/paper_bin
	category = list("initial","Organic Materials")

/datum/design/paper_bin_colored
	name = "Construction Paper Bin"
	id = "paper_colored"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 100)
	build_path = /obj/item/paper_bin/construction
	category = list("initial","Organic Materials")

/datum/design/cloth
	category = list("tier_three","Organic Materials")

/datum/design/cardboard
	category = list("tier_two","Organic Materials")

/datum/design/leather
	category = list("tier_three","Organic Materials")

/datum/design/wig
	name = "Wig"
	id = "wig"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 4000)
	build_path = /obj/item/clothing/head/wig
	category = list("tier_three","Clothing")

/datum/design/bible
	name = "Bible"//All SS13 players need this
	id = "bible"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 4000)
	build_path = /obj/item/storage/book/bible
	category = list("tier_three","Organic Materials")

/datum/design/toolbelt
	category = list("tier_three","Clothing")

/datum/design/secbelt
	category = list("tier_three","Clothing")

/datum/design/medbelt
	category = list("tier_three","Clothing")

/datum/design/janibelt
	category = list("tier_three","Clothing")

/datum/design/s_holster
	category = list("tier_three","Clothing")

/datum/design/wallet
	name = "Wallet"
	id = "wallet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/storage/wallet
	category = list("tier_three","Clothing")

/datum/design/rice_hat
	category = list("initial","Clothing")

/datum/design/carton_soy_milk
	category = list("tier_two","Food")

//Tier four rewards
//Remember, everything is 1/4 the price at this tier. Go high.

/datum/design/armor_vest
	name = "Light Armor Vest"
	id = "armor_vest"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/suit/armor/vest
	category = list("tier_four","Clothing")

/datum/design/mime_mask
	name = "Mime Mask"
	id = "mime_mask"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/mask/gas/mime
	category = list("tier_four","Clothing")

/datum/design/clown_mask
	name = "Clown Mask"
	id = "clown_mask"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/mask/gas/clown_hat
	category = list("tier_four","Clothing")

/datum/design/clown_shoes
	name = "Clown Shoes"
	id = "clown_shoes"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/shoes/clown_shoes
	category = list("tier_four","Clothing")

/datum/design/EVA_helmet
	name = "Space Helmet"
	id = "space_helmet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/head/helmet/space/eva
	category = list("tier_four","Clothing")

/datum/design/EVA_suit
	name = "Space Suit"
	id = "space_suit"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/suit/space/eva
	category = list("tier_four","Clothing")

/datum/design/tactical_vest
	name = "Snacktical Vest"
	id = "snack_vest"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/storage/belt/military/snack
	category = list("tier_four","Clothing")

/datum/design/champion_belt
	name = "Championship Belt"
	id = "champ_belt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/storage/belt/champion
	category = list("tier_four","Clothing")

/datum/design/chef_hat
	name = "Chef Hat"
	id = "chef_hat"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/clothing/head/chefhat
	category = list("tier_four","Clothing")

/datum/design/fanny_pack
	name = "Fannypack"
	id = "fanny_pack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20000)
	build_path = /obj/item/storage/belt/fannypack
	category = list("tier_four","Clothing")


/datum/design/plastic
	name = "Plastic Sheets"
	id = "plastic_sheets"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 4000)
	build_path = /obj/item/stack/sheet/plastic
	category = list("tier_four","Organic Materials")

/datum/design/greyslime //Late-game DIY xenobio
	name = "Grey Slime Core"
	id = "greyslime"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 100000)
	build_path = /obj/item/slime_extract/grey
	category = list("tier_four","Organic Materials")
