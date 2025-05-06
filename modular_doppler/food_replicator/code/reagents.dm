/datum/reagent/consumable/powdered_tea
	name = "Powdered Tea"
	description = "Tea in its powdered form. Tastes horribly."
	color = "#3a3a03"
	nutriment_factor = 0
	taste_description = "bitter powder"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/mug/tea

/datum/chemical_reaction/food/unpowdered_tea
	required_reagents = list(
		/datum/reagent/water = 1,
		/datum/reagent/consumable/powdered_tea = 1,
	)
	results = list(/datum/reagent/consumable/tea = 2)
	mix_message = "The mixture instantly heats up."
	reaction_flags = REACTION_INSTANT

/datum/reagent/consumable/powdered_coffee
	name = "Powdered Coffee"
	description = "Americano in its powdered form. Quite an ordinary thing to be honest."
	color = "#101000"
	nutriment_factor = 0
	taste_description = "very bitter powder"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/coffee

/datum/chemical_reaction/food/unpowdered_coffee
	required_reagents = list(
		/datum/reagent/water = 1,
		/datum/reagent/consumable/powdered_coffee = 1,
	)
	results = list(/datum/reagent/consumable/coffee = 2)
	mix_message = "The mixture instantly heats up."
	reaction_flags = REACTION_INSTANT

/datum/reagent/consumable/powdered_coco
	name = "Powdered Coco"
	description = "Made with love (citation needed), and reclaimed biomass."
	nutriment_factor = 0
	color = "#403010"
	taste_description = "dry chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/mug/coco

/datum/chemical_reaction/food/unpowdered_coco
	required_reagents = list(
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/powdered_coco = 1,
	)
	results = list(/datum/reagent/consumable/hot_coco = 2)
	mix_message = "The mixture instantly heats up."
	reaction_flags = REACTION_INSTANT

/datum/reagent/consumable/powdered_lemonade
	name = "Powdered Lemonade"
	description = "Sweet, tangy base of a lemonade. Would be good if you'd mix it with water."
	nutriment_factor = 0
	color = "#FFE978"
	taste_description = "intensely sour and sweet lemon powder"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/soda_cans/lemon_lime

/datum/chemical_reaction/food/unpowdered_lemonade
	required_reagents = list(
		/datum/reagent/water = 1,
		/datum/reagent/consumable/powdered_lemonade = 1,
	)
	results = list(/datum/reagent/consumable/lemonade = 2)
	mix_message = "The mixture instantly cools down."
	reaction_flags = REACTION_INSTANT

/datum/reagent/consumable/powdered_milk
	name = "Powdered Milk"
	description = "An opaque white powder produced by the biomass restructurizers of certain machines."
	nutriment_factor = 0
	color = "#DFDFDF"
	taste_description = "sweet dry milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/milk

/datum/chemical_reaction/food/unpowdered_milk
	required_reagents = list(
		/datum/reagent/water = 1,
		/datum/reagent/consumable/powdered_milk = 1,
	)
	results = list(/datum/reagent/consumable/milk = 2)
	mix_message = "The mixture cools down."
	reaction_flags = REACTION_INSTANT

/obj/item/reagent_containers/applicator/pill/convermol
	name = "convermol pill"
	desc = "Used to treat oxygen deprivation. Intoxicates the body."
	icon_state = "pill16"
	list_reagents = list(/datum/reagent/medicine/c2/convermol = 15)
	rename_with_volume = TRUE

/datum/reagent/consumable/nutriment/glucose
	name = "Synthetic Glucose"
	description = "A sticky yellow liquid, simple carbohydrate, allotrope of organic glucose. Gives your body a short-term energy boost."
	nutriment_factor = 1
	color = "#f3d00d"
	taste_description = "strong sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/delayed_satiety_drain = 30

/datum/reagent/consumable/nutriment/glucose/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(affected_mob.satiety < MAX_SATIETY)
		affected_mob.adjust_nutrition(15)
		delayed_satiety_drain += 15

	return ..()

/datum/reagent/consumable/nutriment/glucose/on_mob_delete(mob/living/carbon/detoxed_mob)
	detoxed_mob.adjust_nutrition(-delayed_satiety_drain)
	return ..()
