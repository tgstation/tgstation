///A spawner that only spawns specific stuff on holidays
/obj/effect/spawner/holiday
	icon = 'icons/effects/random_spawners.dmi' //reusing icons for efficiency
	name = "holiday spawner"
	desc = "a spawner effect that only spawns stuff if a holiday is being celebrated."
	///It contains holiday names (use macros please) as key, and the list of things to spawn on said holiday as value.
	var/list/holidays_to_spawn
	///If set and no holiday object is spawned, spawn this instead.
	var/non_holiday_spawn

/obj/effect/spawner/holiday/Initialize(mapload)
	. = ..()
	var/found_holiday = FALSE
	for(var/holiday in holidays_to_spawn)
		if(check_holidays(holiday))
			found_holiday = TRUE
			var/list/spawn_list = holidays_to_spawn[holiday]
			for(var/path in spawn_list)
				new path(loc)
	if(!found_holiday && non_holiday_spawn)
		new non_holiday_spawn(loc)

/obj/effect/spawner/holiday/powdered_ingredient
	name = "holiday powdered ingredient"
	desc = "A little extra for the kitchen during specific holidays like moth and tiziran festivities."
	icon_state = "chips"
	holidays_to_spawn = list(
		LIZARD_ATRAKOR_DAY = list( //korta flour is made of this
			/obj/item/reagent_containers/condiment/korta_flour,
			/obj/item/reagent_containers/condiment/korta_flour,
		),
		MOTH_FLEET_DAY = list( //mothic dough is made of this, and a lot other things.
			/obj/item/reagent_containers/condiment/cornmeal,
			/obj/item/reagent_containers/condiment/cornmeal,
		),
	)

/obj/effect/spawner/holiday/liquid_ingredient
	name = "holiday liquid ingredient"
	desc = /obj/effect/spawner/holiday/powdered_ingredient::desc
	icon_state = "condiment"
	holidays_to_spawn = list(
		LIZARD_ATRAKOR_DAY = list( //a few lizard recipes use this (there are more that use olive oil but this is more iconic of the culture)
			/obj/item/reagent_containers/cup/bottle/syrup_bottle/korta_nectar,
		),
		MOTH_FLEET_DAY = list( //needed for mothic dough and other mothic recipes
			/obj/item/reagent_containers/condiment/olive_oil,
			/obj/item/reagent_containers/condiment/yoghurt,
		),
		BEE_DAY = list(
			/obj/item/reagent_containers/condiment/honey,
			/obj/item/reagent_containers/condiment/honey,
		),
		BEER_DAY = list(
			/obj/effect/spawner/random/food_or_drink/booze,
		),
	)

/obj/effect/spawner/holiday/meat_ingredient
	name = "holiday meat ingredient"
	desc = /obj/effect/spawner/holiday/powdered_ingredient::desc
	icon_state = "condiment"
	holidays_to_spawn = list(
		LIZARD_ATRAKOR_DAY = list(
			/obj/item/food/raw_tiziran_sausage,
			/obj/item/organ/liver,
			/obj/item/food/canned/larvae,
		),
		MOTH_FLEET_DAY = list(
			/obj/item/grown/cotton,
			/obj/item/grown/cotton,
			/obj/item/grown/cotton,
		),
		VEGAN_DAY = list( ///plant-based "meat" slabs to allow chefs to cook meat recipes anyway. Plus some veggies.
			/obj/item/food/meat/slab/killertomato,
			/obj/item/food/meat/slab/killertomato,
			/obj/item/food/meat/slab/human/mutant/plant,
			/obj/item/food/meat/slab/human/mutant/plant,
			/obj/item/food/grown/tomato,
			/obj/item/food/grown/cabbage,
			/obj/item/food/grown/onion/red,
			/obj/item/food/grown/herbs,
		),
	)

/obj/effect/spawner/holiday/bar_keg
	name = "bar keg spawner"
	desc = "The spawner of the keg on the station. Special stuff on Beer Day and St. Patrick's Day."
	icon_state = "keg"
	holidays_to_spawn = list(
		ST_PATRICK_DAY = list(
			/obj/structure/reagent_dispensers/keg/gold/irish,
		),
		TALK_LIKE_A_PIRATE_DAY = list(
			/obj/structure/reagent_dispensers/keg/gold/rum,
		),
		BEER_DAY = list(
			/obj/structure/reagent_dispensers/keg/gold/trappist,
		),
	)

	non_holiday_spawn = /obj/effect/spawner/random/food_or_drink/keg
