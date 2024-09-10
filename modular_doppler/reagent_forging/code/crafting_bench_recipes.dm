/datum/crafting_bench_recipe
	/// The name of the recipe to show
	var/recipe_name = "generic debug recipe"
	/// The items required to create the resulting item
	var/list/recipe_requirements
	/// What the end result of this recipe should be
	var/resulting_item = /obj/item/forging
	/// If we use the materials from the component parts
	var/transfers_materials = TRUE
	/// How many times should you have to swing the hammer to finish this item
	var/required_good_hits = 6
	/// What skill is relevant to the creation of this item?
	var/relevant_skill = /datum/skill/smithing
	/// How much experience in our relevant skill do we give upon completion?
	var/relevant_skill_reward = 30

/datum/crafting_bench_recipe/weapon_completion_recipe //Exists so I don't have to modify the code too much for weapon completion
	recipe_name = "generic weapon completion recipe (should not be visible)"
	recipe_requirements = list(
		/obj/item/stack/sheet/mineral/wood = 2,
	)

/datum/crafting_bench_recipe/plate_helmet
	recipe_name = "plate helmet"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 4,
	)
	resulting_item = /obj/item/clothing/head/helmet/forging_plate_helmet
	required_good_hits = 8

/datum/crafting_bench_recipe/plate_vest
	recipe_name = "plate vest"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 6,
	)
	resulting_item = /obj/item/clothing/suit/armor/forging_plate_armor
	required_good_hits = 12

/datum/crafting_bench_recipe/plate_gloves
	recipe_name = "plate gloves"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 2,
	)
	resulting_item = /obj/item/clothing/gloves/forging_plate_gloves
	required_good_hits = 4

/datum/crafting_bench_recipe/plate_boots
	recipe_name = "plate boots"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 4,
	)
	resulting_item = /obj/item/clothing/shoes/forging_plate_boots
	required_good_hits = 8

/datum/crafting_bench_recipe/ring
	recipe_name = "ring"
	recipe_requirements = list(
		/obj/item/forging/complete/chain = 2,
	)
	resulting_item = /obj/item/clothing/gloves/ring/reagent_clothing
	required_good_hits = 4

// /datum/crafting_bench_recipe/collar
// 	recipe_name = "collar"
// 	recipe_requirements = list(
// 		/obj/item/forging/complete/chain = 3,
// 	)
// 	resulting_item = /obj/item/clothing/neck/collar/reagent_clothing
// 	required_good_hits = 6

/datum/crafting_bench_recipe/handcuffs
	recipe_name = "handcuffs"
	recipe_requirements = list(
		/obj/item/forging/complete/chain = 5,
	)
	resulting_item = /obj/item/restraints/handcuffs/reagent_clothing
	required_good_hits = 10

/datum/crafting_bench_recipe/pavise
	recipe_name = "pavise"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 8,
	)
	resulting_item = /obj/item/shield/buckler/reagent_weapon/pavise
	required_good_hits = 16

/datum/crafting_bench_recipe/buckler
	recipe_name = "buckler"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 5,
	)
	resulting_item = /obj/item/shield/buckler/reagent_weapon
	required_good_hits = 10

/datum/crafting_bench_recipe/seed_mesh
	recipe_name = "seed mesh"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 1,
		/obj/item/forging/complete/chain = 2,
	)
	resulting_item = /obj/item/seed_mesh
	required_good_hits = 10

/datum/crafting_bench_recipe/centrifuge
	recipe_name = "centrifuge"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 1,
	)
	resulting_item = /obj/item/reagent_containers/cup/primitive_centrifuge
	required_good_hits = 4

/datum/crafting_bench_recipe/soup_pot
	recipe_name = "soup pot"
	recipe_requirements = list(
		/obj/item/forging/complete/plate = 4,
	)
	resulting_item = /obj/item/reagent_containers/cup/soup_pot
	required_good_hits = 10

/datum/crafting_bench_recipe/bokken
	recipe_name = "bokken"
	recipe_requirements = list(
		/obj/item/stack/sheet/mineral/wood = 4,
	)
	resulting_item = /obj/item/forging/reagent_weapon/bokken
	required_good_hits = 8

/datum/crafting_bench_recipe/bow
	recipe_name = "bow"
	recipe_requirements = list(
		/obj/item/stack/sheet/mineral/wood = 4,
	)
	resulting_item = /obj/item/forging/incomplete_bow
	required_good_hits = 8
