/obj/item/food/hemophage
	name = "bloody food"
	desc = "If you see this, then something's gone very wrong and you should report it whenever you get the chance."
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/hemophage_food.dmi'
	foodtypes = GORE | BLOODY

/obj/item/food/hemophage/blood_rice_pearl
	name = "kessen shinju"
	desc = "A fun finger food. Little clumps of sticky rice with a bit of ground pork and green onion, all soaked and rolled in fresh blood; giving it a crimson hue. Recommended to serve hot!"
	icon_state = "blood_rice_pearl"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/blood = 10,
	)
	tastes = list("rice" = 3, "blood" = 5)
	foodtypes = GRAIN | GORE | BLOODY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/hemophage/blood_rice_pearl/raw
	name = "uncooked blood rice"
	desc = "A clump of raw rice, drenched in blood."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "uncooked_rice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/blood = 10,
	)
	tastes = list("raw rice" = 3, "blood" = 5)
	color = "#810000"
	foodtypes = GRAIN | GORE | BLOODY | RAW
	crafting_complexity = FOOD_COMPLEXITY_0

/obj/item/food/hemophage/blood_rice_pearl/raw/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/hemophage/blood_rice_pearl)

/obj/item/food/hemophage/blood_noodles
	name = "boiled blood noodles"
	desc = "A plain dish of blood-soaked noodles, it would probably be better with more ingredients."
	icon = 'icons/obj/food/spaghetti.dmi'
	icon_state = "spaghettiboiled"
	color = "#810000"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/blood = 20,
	)
	tastes = list("blood" = 5, "pasta" = 1)
	foodtypes = GRAIN | GORE | BLOODY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/hemophage/blood_noodles/raw
	name = "raw blood noodles"
	desc = "Noodles thoroughly soaked in blood. Eating them raw doesn't sound appetizing. Nor does eating them at all, really."
	color = "#ad0000"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/blood = 15, // You should really be cooking those if you want the full amount of blood out of them
	)
	tastes = list("blood" = 5, "raw pasta" = 1)
	foodtypes = GRAIN | GORE | BLOODY | RAW
	crafting_complexity = FOOD_COMPLEXITY_0

/obj/item/food/hemophage/blood_noodles/raw/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/hemophage/blood_noodles)

/obj/item/food/hemophage/blood_noodles/boat_noodles
	name = "boat noodles"
	desc = "A dish with normally made with a very strong combination of pork and beef; the main attraction in this meatless version being the combination of blood curds and curly noodles, seasoned and immersed in fresh blood to the point they've turned crimson. It reeks of iron."
	icon_state = "meatballspaghetti"
	color = "#d10000"
	max_volume = 70
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		/datum/reagent/blood = 50,
	)
	tastes = list("blood" = 5, "congealed blood" = 3, "pasta" = 1)
	foodtypes = GRAIN | GORE | BLOODY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/hemophage/blood_curd
	name = "blood curd"
	desc = "Also known as 'blood tofu' or 'blood pudding,' this Konjin delicacy looks to be made of congealed and cooked blood. It's soft and smooth, slightly chewy, and rich in riboflavin."
	icon_state = "blood_curd"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/blood = 15,
	)
	tastes = list("congealed blood" = 1)
	foodtypes = GORE | BLOODY | RAW
	crafting_complexity = FOOD_COMPLEXITY_0

/obj/item/food/hemophage/blood_cake
	name = "ti hoeh koe"
	desc = "Also known as 'pig's blood cake' or 'black cake', this is a variant of blood pudding normally served as street food in night markets. Created from steamed blood and sticky rice, it's been coated in peanut powder and coriander, and can be served with some dipping sauces. It seems the amount of blood in this meal has been turned up a lot, giving the all-too-familiar twinge of iron when it's tasted."
	icon_state = "blood_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/peanut_butter = 5,
		/datum/reagent/blood = 25,
	)
	tastes = list("blood" = 5, "crunchy rice" = 2, "peanut butter" = 2)
	foodtypes = GRAIN | GORE | BLOODY | SUGAR | NUTS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/soup/hemophage/blood_soup
	name = "dinuguan"
	desc = "A savory stew normally made of offal or freshly-simmered meat. This version features blood curds instead, while also featuring a rich, spicy and dark gravy made of fresh blood and vinegar. Chili and garlic were also added to enhance the savory flavor of the broth."
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/hemophage_food.dmi'
	icon_state = "blood_soup"
	max_volume = 90
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/blood = 60,
	)
	tastes = list("blood" = 5, "congealed blood" = 2, "chili" = 3, "vinegar" = 1, "garlic" = 1)
	foodtypes = GORE | BLOODY | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_4
