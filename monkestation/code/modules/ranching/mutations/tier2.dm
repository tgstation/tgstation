/datum/mutation/ranching/chicken/spicy
	chicken_type = /mob/living/basic/chicken/spicy
	egg_type = /obj/item/food/egg/spicy
	food_requirements = list(/obj/item/food/grown/chili)
	needed_temperature = 400
	temperature_variance = 50

	can_come_from_string = "White Chicken, Brown Chicken"
/datum/mutation/ranching/chicken/raptor
	chicken_type = /mob/living/basic/chicken/raptor
	egg_type = /obj/item/food/egg/raptor
	happiness = 55
	food_requirements = list(/obj/item/food/meat/slab/monkey)
	reagent_requirements = list(/datum/reagent/blood)

	can_come_from_string = "Brown Chicken"
/datum/mutation/ranching/chicken/cotton_candy
	chicken_type = /mob/living/basic/chicken/cotton_candy
	egg_type = /obj/item/food/egg/cotton_candy
	reagent_requirements = list(/datum/reagent/consumable/cream, /datum/reagent/consumable/sugar, /datum/reagent/consumable/bluecherryshake)
	happiness = 50

	can_come_from_string = "Silkie"

/datum/mutation/ranching/chicken/snowy
	chicken_type = /mob/living/basic/chicken/snowy
	egg_type = /obj/item/food/egg/snowy
	temperature_variance = 20
	needed_temperature = 4
	needed_pressure = 1003
	pressure_variance = 1000

	can_come_from_string = "White Silkie"

/datum/mutation/ranching/chicken/pigeon
	chicken_type = /mob/living/basic/chicken/pigeon
	egg_type = /obj/item/food/egg/pigeon
	happiness = 30
	nearby_items = list(/obj/item/radio)
	food_requirements = list(/obj/item/food/grown/corn)

	can_come_from_string = "Silkie"

/datum/mutation/ranching/chicken/stone
	chicken_type = /mob/living/basic/chicken/stone
	egg_type = /obj/item/food/egg/stone
	needed_turfs = list(/turf/open/floor/fakebasalt)
	nearby_items = list(/obj/item/pickaxe)
	food_requirements = list(/obj/item/food/grown/cannabis)

	can_come_from_string = "Glass Chicken"

/datum/mutation/ranching/chicken/wiznerd
	chicken_type = /mob/living/basic/chicken/wiznerd
	egg_type = /obj/item/food/egg/wiznerd
	food_requirements = list(/obj/item/food/grown/mushroom/amanita)
	nearby_items = list(/obj/item/clothing/head/wizard/fake)

	can_come_from_string = "Glass Chicken"
/datum/mutation/ranching/chicken/sword
	chicken_type = /mob/living/basic/chicken/sword
	egg_type = /obj/item/food/egg/sword
	food_requirements = list(/obj/item/food/grown/meatwheat)
	nearby_items = list(/obj/item/grown/log/steel)

	can_come_from_string = "Onagadori"
/datum/mutation/ranching/chicken/gold
	chicken_type = /mob/living/basic/chicken/golden
	egg_type = /obj/item/food/egg/golden
	happiness = 1000

	can_come_from_string = "Brown Chicken"
/datum/mutation/ranching/chicken/clown_sad
	chicken_type = /mob/living/basic/chicken/clown_sad
	egg_type = /obj/item/food/egg/clown_sad
	happiness = -1000

	can_come_from_string = "Henkster"
/datum/mutation/ranching/chicken/mime
	chicken_type = /mob/living/basic/chicken/mime
	egg_type = /obj/item/food/egg/mime
	food_requirements = list(/obj/item/food/baguette)
	reagent_requirements = list(/datum/reagent/consumable/nothing)

	can_come_from_string = "Henkster"
