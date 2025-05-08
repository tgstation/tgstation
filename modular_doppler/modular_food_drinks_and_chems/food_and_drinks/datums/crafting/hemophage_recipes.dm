/datum/chemical_reaction/food/uncooked_blood_rice
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/blood = 20)
	mix_message = "The rice absorbs the blood."
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/uncooked_blood_rice/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/hemophage/blood_rice_pearl/raw(location)

/datum/crafting_recipe/food/hemophage
	category = CAT_HEMOPHAGE

/datum/crafting_recipe/food/hemophage/blood_curd
	name = "Blood Curd"
	reqs = list(
		/datum/reagent/blood = 20,
	)
	result = /obj/item/food/hemophage/blood_curd

/datum/crafting_recipe/food/hemophage/blood_noodles
	name = "Raw Blood Noodles"
	reqs = list(
		/obj/item/food/spaghetti/raw = 1,
		/datum/reagent/blood = 20,
	)
	result = /obj/item/food/hemophage/blood_noodles/raw
	added_foodtypes = RAW | GORE | BLOODY

/datum/crafting_recipe/food/hemophage/boat_noodles
	name = "Boat Noodles"
	reqs = list(
		/obj/item/food/hemophage/blood_noodles = 1,
		/obj/item/food/hemophage/blood_curd = 1,
	)
	result = /obj/item/food/hemophage/blood_noodles/boat_noodles
	added_foodtypes = GRAIN | GORE | BLOODY

/datum/crafting_recipe/food/hemophage/blood_cake
	name = "Ti Hoeh Koe"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/datum/reagent/blood = 20,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	result = /obj/item/food/hemophage/blood_cake
	added_foodtypes = GORE | BLOODY | SUGAR | NUTS

/datum/crafting_recipe/food/reaction/soup/blood_soup
	reaction = /datum/chemical_reaction/food/soup/blood_soup
