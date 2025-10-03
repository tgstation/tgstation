///Has no special properties.
/datum/material/iron
	name = "iron"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	color = "#B6BEC2"
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/iron
	ore_type = /obj/item/stack/ore/iron
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	mat_rust_resistance = RUST_RESISTANCE_BASIC
	mineral_rarity = MATERIAL_RARITY_COMMON
	points_per_unit = 1 / SHEET_MATERIAL_AMOUNT
	minimum_value_override = 0
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON
	fish_weight_modifier = 1.3
	fishing_gravity_mult = 1.1

/datum/material/iron/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
		return TRUE

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	desc = "Glass forged by melting sand."
	color = "#6292AF"
	alpha = 150
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	integrity_modifier = 0.1
	sheet_type = /obj/item/stack/sheet/glass
	ore_type = /obj/item/stack/ore/glass/basalt
	shard_type = /obj/item/shard
	debris_type = /obj/effect/decal/cleanable/glass
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	minimum_value_override = 0
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON
	beauty_modifier = 0.05
	armor_modifiers = list(MELEE = 0.2, BULLET = 0.2, ENERGY = 1, BIO = 0.2, FIRE = 1, ACID = 0.2)
	mineral_rarity = MATERIAL_RARITY_COMMON
	points_per_unit = 1 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "shine"
	fish_weight_modifier = 1.2
	fishing_difficulty_modifier = 5
	fishing_experience_multiplier = 1.2
	fishing_bait_speed_mult = 0.9
	fishing_deceleration_mult = 1.2
	fishing_bounciness_mult = 0.5
	fishing_gravity_mult = 0.9

/datum/material/glass/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5, sharpness = TRUE) //cronch
		return TRUE

/datum/material/glass/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(isobj(source) && !isstack(source))
		source.AddElement(/datum/element/can_shatter, shard_type, round(mat_amount / SHEET_MATERIAL_AMOUNT * multiplier), SFX_SHATTER)

/datum/material/glass/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(isobj(source) && !isstack(source))
		source.RemoveElement(/datum/element/can_shatter, shard_type, round(mat_amount / SHEET_MATERIAL_AMOUNT * multiplier), SFX_SHATTER)

/*
Color matrices are like regular colors but unlike with normal colors, you can go over 255 on a channel.
Unless you know what you're doing, only use the first three numbers. They're in RGB order.
*/

///Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	desc = "Silver"
	color = "#B5BCBB"
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	ore_type = /obj/item/stack/ore/silver
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_UNCOMMON
	beauty_modifier = 0.075
	mineral_rarity = MATERIAL_RARITY_SEMIPRECIOUS
	points_per_unit = 16 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "shine"
	fish_weight_modifier = 1.35
	fishing_difficulty_modifier = -5
	fishing_experience_multiplier = 0.85
	fishing_completion_speed = 1.1
	fishing_deceleration_mult = 1.1
	fishing_bounciness_mult = 0.9
	fishing_gravity_mult = 1.1

/datum/material/silver/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
		return TRUE

///Slight force increase
/datum/material/gold
	name = "gold"
	desc = "Gold"
	color = "#E6BB45"
	strength_modifier = 1.2
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/gold
	ore_type = /obj/item/stack/ore/gold
	value_per_unit = 125 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_RARE
	beauty_modifier = 0.15
	armor_modifiers = list(MELEE = 1.1, BULLET = 1.1, LASER = 1.15, ENERGY = 1.15, BOMB = 1, BIO = 1, FIRE = 0.7, ACID = 1.1)
	mineral_rarity = MATERIAL_RARITY_PRECIOUS
	points_per_unit = 18 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "shine"
	fish_weight_modifier = 1.5
	fishing_difficulty_modifier = -8
	fishing_cast_range = 1
	fishing_experience_multiplier = 0.75
	fishing_completion_speed = 1.2
	fishing_bait_speed_mult = 1.1
	fishing_deceleration_mult = 1.2
	fishing_bounciness_mult = 0.8
	fishing_gravity_mult = 1.2

/datum/material/gold/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Has no special properties
/datum/material/diamond
	name = "diamond"
	desc = "Highly pressurized carbon"
	color = "#C9D8F2"
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	ore_type = /obj/item/stack/ore/diamond
	alpha = 132
	starlight_color = COLOR_BLUE_LIGHT
	value_per_unit = 500 / SHEET_MATERIAL_AMOUNT
	strength_modifier = 1.1
	integrity_modifier = 1.25
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_EXOTIC
	beauty_modifier = 0.3
	armor_modifiers = list(MELEE = 1.3, BULLET = 1.3, LASER = 0.6, ENERGY = 1, BOMB = 1.2, BIO = 1, FIRE = 1, ACID = 1)
	mineral_rarity = MATERIAL_RARITY_RARE
	points_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 1.4
	fishing_difficulty_modifier = -12
	fishing_cast_range = -1
	fishing_experience_multiplier = 0.7
	fishing_completion_speed = 1.25
	fishing_bait_speed_mult = 1.1
	fishing_deceleration_mult = 1.25
	fishing_bounciness_mult = 0.8
	fishing_gravity_mult = 1.1

/datum/material/diamond/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
		return TRUE

///Is slightly radioactive
/datum/material/uranium
	name = "uranium"
	desc = "Uranium"
	color = "#2C992C"
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	ore_type = /obj/item/stack/ore/uranium
	value_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_RARE
	beauty_modifier = 0.3 //It shines so beautiful
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.4, LASER = 0.5, ENERGY = 0.5, FIRE = 1, ACID = 1)
	mineral_rarity = MATERIAL_RARITY_SEMIPRECIOUS
	points_per_unit = 30 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 2
	fishing_completion_speed = 0.9
	fishing_bait_speed_mult = 0.8
	fishing_deceleration_mult = 1.4
	fishing_bounciness_mult = 0.6
	fishing_gravity_mult = 1.4

/datum/material/uranium/on_applied(atom/source, mat_amount, multiplier)
	. = ..()

	// Uranium structures should irradiate, but not items, because item irradiation is a lot more annoying.
	// For example, consider picking up uranium as a miner.
	if (isitem(source))
		return

	source.AddElement(/datum/element/radioactive, chance = URANIUM_IRRADIATION_CHANCE * multiplier)

/datum/material/uranium/on_removed(atom/source, mat_amount, multiplier)
	. = ..()

	if (isitem(source))
		return

	source.RemoveElement(/datum/element/radioactive, chance = URANIUM_IRRADIATION_CHANCE * multiplier)

/datum/material/uranium/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/uranium, rand(4, 6))
	source_item?.reagents?.add_reagent(/datum/reagent/uranium, source_item.reagents.total_volume*(2/5))
	return TRUE

///Adds firestacks on hit (Still needs support to turn into gas on destruction)
/datum/material/plasma
	name = "plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	color = "#BA3692"
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	ore_type = /obj/item/stack/ore/plasma
	value_per_unit = 200 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.15
	armor_modifiers = list(MELEE = 1.4, BULLET = 0.7, ENERGY = 1.2, BIO = 1.2, ACID = 0.5)
	mineral_rarity = MATERIAL_RARITY_PRECIOUS
	points_per_unit = 15 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 1.3
	fishing_deceleration_mult = 1.3
	fishing_bounciness_mult = 0.6

/datum/material/plasma/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(ismovable(source))
		source.AddElement(/datum/element/firestacker, 1 * multiplier)
	source.AddComponent(/datum/component/combustible_flooder, "plasma", mat_amount * 0.05 * multiplier) //Empty temp arg, fully dependent on whatever ignited it.
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/plasma/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	source.RemoveElement(/datum/element/firestacker, mat_amount = 1 * multiplier)
	qdel(source.GetComponent(/datum/component/combustible_flooder))
	qdel(source.GetComponent(/datum/component/explodable))
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/plasma/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(6, 8))
	source_item?.reagents?.add_reagent(/datum/reagent/toxin/plasma, source_item.reagents.total_volume*(2/5))
	return TRUE

///Can cause bluespace effects on use. (Teleportation) (Not yet implemented)
/datum/material/bluespace
	name = "bluespace crystal"
	desc = "Crystals with bluespace properties"
	color = "#2E50B7"
	alpha = 200
	starlight_color = COLOR_BLUE
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	beauty_modifier = 0.5
	sheet_type = /obj/item/stack/sheet/bluespace_crystal
	ore_type = /obj/item/stack/ore/bluespace_crystal
	value_per_unit = 300 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_RARE
	points_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_EXOTIC
	texture_layer_icon_state = "shine"
	fish_weight_modifier = 1.3
	fishing_difficulty_modifier = -5
	fishing_cast_range = 5 //space-bending scifi magic
	fishing_experience_multiplier = 0.85
	fishing_completion_speed = 1.1
	fishing_bait_speed_mult = 1.1
	fishing_deceleration_mult = 0.9
	fishing_bounciness_mult = 1.1

/datum/material/bluespace/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		RegisterSignal(source, COMSIG_ROD_BEGIN_FISHING, PROC_REF(on_begin_fishing))

/datum/material/bluespace/proc/on_begin_fishing(obj/item/fishing_rod/rod, datum/fishing_challenge/challenge)
	SIGNAL_HANDLER
	if(prob(67))
		return
	var/list/elegible_fish_sources = flatten_list(GLOB.preset_fish_sources)
	for(var/datum/fish_source/source as anything in elegible_fish_sources)
		if(source.fish_source_flags & FISH_SOURCE_FLAG_NO_BLUESPACE_ROD)
			elegible_fish_sources -= source
	var/datum/fish_source/new_source = pick(elegible_fish_sources)
	challenge.register_reward_signals(new_source)

/datum/material/bluespace/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		UnregisterSignal(source, COMSIG_ROD_BEGIN_FISHING)

/datum/material/bluespace/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/bluespace, rand(5, 8))
	source_item?.reagents?.add_reagent(/datum/reagent/bluespace, source_item.reagents.total_volume*(2/5))
	return TRUE

///Honks and slips
/datum/material/bananium
	name = "bananium"
	desc = "Material with hilarious properties"
	color = list(460/255, 464/255, 0, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //obnoxiously bright yellow //It's literally perfect I can't change it
	greyscale_color = "#FFF269"
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	ore_type = /obj/item/stack/ore/bananium
	value_per_unit = 1000 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.5
	armor_modifiers = list(BOMB = 100, FIRE = 10) //Clowns cant be blown away.
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED
	points_per_unit = 60 / SHEET_MATERIAL_AMOUNT
	fishing_difficulty_modifier = 20 //can't get a good grip on slipperiness.
	fishing_cast_range = 3 //long slide
	fishing_experience_multiplier = 1.6
	fishing_completion_speed = 1.3
	fishing_bait_speed_mult = 1.5
	fishing_deceleration_mult = 0.5
	fishing_bounciness_mult = 2

/datum/material/bananium/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	source.LoadComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50 * multiplier, falloff_exponent = 20)
	source.AddComponent(/datum/component/slippery, min(mat_amount / 10 * multiplier, 80 * multiplier))

/datum/material/bananium/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		RegisterSignal(source, COMSIG_ROD_BEGIN_FISHING, PROC_REF(on_begin_fishing))

/datum/material/bananium/proc/on_begin_fishing(obj/item/fishing_rod/rod, datum/fishing_challenge/challenge)
	SIGNAL_HANDLER
	if(prob(40))
		RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_ROLL_REWARD, PROC_REF(roll_funny_fish))

/datum/material/bananium/proc/roll_funny_fish(datum/source, obj/item/fishing_rod/rod, mob/fisherman, atom/location, list/rewards)
	SIGNAL_HANDLER
	var/static/list/funny_fish = list(
		/obj/item/fish/clownfish = 5,
		/obj/item/fish/clownfish/lube = 3,
		/obj/item/fish/soul = 2,
		/obj/item/fish/skin_crab = 2,
		/obj/item/fish/donkfish = 2,
	)
	rewards += pick_weight(funny_fish)

/datum/material/bananium/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	qdel(source.GetComponent(/datum/component/slippery))
	qdel(source.GetComponent(/datum/component/squeak))

/datum/material/bananium/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		UnregisterSignal(source, COMSIG_ROD_BEGIN_FISHING)

/datum/material/bananium/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/consumable/banana, rand(8, 12))
	source_item?.reagents?.add_reagent(/datum/reagent/consumable/banana, source_item.reagents.total_volume*(2/5))
	return TRUE

///Mediocre force increase
/datum/material/titanium
	name = "titanium"
	desc = "Titanium"
	color = "#EFEFEF"
	strength_modifier = 1.3
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	ore_type = /obj/item/stack/ore/titanium
	value_per_unit = 125 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_UNCOMMON
	beauty_modifier = 0.05
	armor_modifiers = list(MELEE = 1.35, BULLET = 1.3, LASER = 1.3, ENERGY = 1.25, BOMB = 1.25, BIO = 1, FIRE = 0.7, ACID = 1)
	mat_rust_resistance = RUST_RESISTANCE_TITANIUM
	mineral_rarity = MATERIAL_RARITY_SEMIPRECIOUS
	texture_layer_icon_state = "shine"
	fish_weight_modifier = 1.2
	fishing_difficulty_modifier = -5
	fishing_cast_range = 1
	fishing_completion_speed = 1.15
	fishing_bait_speed_mult = 1.1
	fishing_deceleration_mult = 1.3
	fishing_bounciness_mult = 0.75
	fishing_gravity_mult = 1.1

/datum/material/titanium/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
		return TRUE

/datum/material/runite
	name = "runite"
	desc = "Runite"
	color = "#526F77"
	strength_modifier = 1.3
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/runite
	value_per_unit = 600 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.5
	armor_modifiers = list(MELEE = 1.35, BULLET = 2, LASER = 0.5, ENERGY = 1.25, BOMB = 1.25, BIO = 1, FIRE = 1.4, ACID = 1) //rune is weak against magic lasers but strong against bullets. This is the combat triangle.
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 1.5
	fishing_difficulty_modifier = -13
	fishing_cast_range = 1
	fishing_experience_multiplier = 3.2 //grind all the way to level 100 in no time.
	fishing_completion_speed = 1.3
	fishing_bait_speed_mult = 0.9
	fishing_deceleration_mult = 1.2
	fishing_gravity_mult = 1.2

/datum/material/runite/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/runite/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/runite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
		return TRUE

///Force decrease
/datum/material/plastic
	name = "plastic"
	desc = "Plastic"
	color = "#BFB9AC"
	strength_modifier = 0.85
	sheet_type = /obj/item/stack/sheet/plastic
	ore_type = /obj/item/stack/ore/slag //No plastic or coal ore, so we use slag.
	categories = list(
		MAT_CATEGORY_SILO = TRUE,
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	value_per_unit = 25 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = -0.01
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.1, LASER = 0.3, ENERGY = 0.5, BOMB = 1, BIO = 1, FIRE = 1.1, ACID = 1)
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED //Nobody's found oil on lavaland yet.
	points_per_unit = 4 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 0.8
	fishing_difficulty_modifier = -5
	fishing_cast_range = 2
	fishing_experience_multiplier = 1.2
	fishing_bait_speed_mult = 1.2
	fishing_deceleration_mult = 0.8
	fishing_bounciness_mult = 1.3
	fishing_gravity_mult = 0.85

/datum/material/plastic/on_accidental_mat_consumption(mob/living/carbon/eater, obj/item/food)
	eater.reagents.add_reagent(/datum/reagent/plastic_polymers, rand(6, 8))
	food?.reagents?.add_reagent(/datum/reagent/plastic_polymers, food.reagents.total_volume*(2/5))
	return TRUE

///Force decrease and mushy sound effect. (Not yet implemented)
/datum/material/biomass
	name = "biomass"
	desc = "Organic matter."
	color = "#735b4d"
	strength_modifier = 0.8
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT

/datum/material/wood
	name = "wood"
	desc = "Flexible, durable, but flammable. Hard to come across in space."
	color = "#855932"
	strength_modifier = 0.5
	sheet_type = /obj/item/stack/sheet/mineral/wood
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	value_per_unit = 20 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.1
	armor_modifiers = list(MELEE = 1.1, BULLET = 1.1, LASER = 0.4, ENERGY = 0.4, BOMB = 1, BIO = 0.2, ACID = 0.3)
	texture_layer_icon_state = "woodgrain"
	fish_weight_modifier = 0.5
	fishing_difficulty_modifier = 8
	fishing_cast_range = -1
	fishing_experience_multiplier = 1.3
	fishing_completion_speed = 0.9
	fishing_bait_speed_mult = 0.8
	fishing_deceleration_mult = 1.3
	fishing_bounciness_mult = 0.4
	fishing_gravity_mult = 0.8

/datum/material/wood/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(source.material_flags & MATERIAL_AFFECT_STATISTICS && isobj(source))
		var/obj/wooden = source
		wooden.resistance_flags |= FLAMMABLE

/datum/material/wood/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(source.material_flags & MATERIAL_AFFECT_STATISTICS && isobj(source))
		var/obj/wooden = source
		wooden.resistance_flags &= ~FLAMMABLE

/datum/material/wood/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
	victim.reagents.add_reagent(/datum/reagent/cellulose, rand(8, 12))
	source_item?.reagents?.add_reagent(/datum/reagent/cellulose, source_item.reagents.total_volume*(2/5))

	return TRUE

///Stronk force increase
/datum/material/adamantine
	name = "adamantine"
	desc = "A powerful material made out of magic, I mean science!"
	color = "#2B7A74"
	strength_modifier = 1.5
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/adamantine
	value_per_unit = 500 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.4
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.5, LASER = 1.3, ENERGY = 1.3, BOMB = 1, BIO = 1, FIRE = 2.5, ACID = 1)
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED //Doesn't naturally spawn on lavaland.
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 1.6
	fishing_difficulty_modifier = -17
	fishing_cast_range = 1
	fishing_experience_multiplier = 0.6
	fishing_completion_speed = 1.3
	fishing_bait_speed_mult = 1.2
	fishing_deceleration_mult = 1.3
	fishing_bounciness_mult = 0.7
	fishing_gravity_mult = 1.3

/datum/material/adamantine/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/adamantine/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/adamantine/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
		return TRUE

///RPG Magic.
/datum/material/mythril
	name = "mythril"
	desc = "How this even exists is byond me"
	color = "#f2d5d7"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/mythril
	value_per_unit = 1500 / SHEET_MATERIAL_AMOUNT
	strength_modifier = 1.2
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.5, LASER = 1.5, ENERGY = 1.5, BOMB = 1.5, BIO = 1.5, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = 0.5
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED //Doesn't naturally spawn on lavaland.
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	fish_weight_modifier = 1.4
	fishing_difficulty_modifier = -20
	fishing_cast_range = 2
	fishing_experience_multiplier = 0.5
	fishing_completion_speed = 1.35
	fishing_bait_speed_mult = 1.2
	fishing_deceleration_mult = 1.35
	fishing_bounciness_mult = 0.65
	fishing_gravity_mult = 1.3

/datum/material/mythril/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(isitem(source))
		source.AddComponent(/datum/component/fantasy)
		ADD_TRAIT(source, TRAIT_INNATELY_FANTASTICAL_ITEM, REF(src)) // DO THIS LAST OR WE WILL NEVER GET OUR BONUSES!!!

/datum/material/mythril/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(isitem(source))
		REMOVE_TRAIT(source, TRAIT_INNATELY_FANTASTICAL_ITEM, REF(src)) // DO THIS FIRST OR WE WILL NEVER GET OUR BONUSES DELETED!!!
		qdel(source.GetComponent(/datum/component/fantasy))

/datum/material/mythril/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
		return TRUE

//formed when freon react with o2, emits a lot of plasma when heated
/datum/material/hot_ice
	name = "hot ice"
	desc = "A weird kind of ice, feels warm to the touch"
	color = "#88cdf1"
	alpha = 150
	starlight_color = COLOR_BLUE_LIGHT
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/hot_ice
	value_per_unit = 400 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.2
	fish_weight_modifier = 0.9
	fishing_difficulty_modifier = -8
	fishing_cast_range = 1
	fishing_experience_multiplier = 0.9
	fishing_completion_speed = 1.4
	fishing_bait_speed_mult = 1.3
	fishing_deceleration_mult = 0.5
	fishing_bounciness_mult = 0.3
	fishing_gravity_mult = 0.8

/datum/material/hot_ice/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	source.AddComponent(/datum/component/combustible_flooder, "plasma", mat_amount * 1.5 * multiplier, (mat_amount * 0.2 + 300) * multiplier)

/datum/material/hot_ice/on_removed(atom/source, mat_amount, multiplier)
	qdel(source.GetComponent(/datum/component/combustible_flooder))
	return ..()

/datum/material/hot_ice/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(5, 6))
	source_item?.reagents?.add_reagent(/datum/reagent/toxin/plasma, source_item.reagents.total_volume*(3/5))
	return TRUE

// It's basically adamantine, but it isn't!
/datum/material/metalhydrogen
	name = "Metal Hydrogen"
	desc = "Solid metallic hydrogen. Some say it should be impossible"
	color = "#62708A"
	alpha = 150
	starlight_color = COLOR_MODERATE_BLUE
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/metal_hydrogen
	value_per_unit = 700 / SHEET_MATERIAL_AMOUNT
	beauty_modifier = 0.35
	strength_modifier = 1.2
	armor_modifiers = list(MELEE = 1.35, BULLET = 1.3, LASER = 1.3, ENERGY = 1.25, BOMB = 0.7, BIO = 1, FIRE = 1.3, ACID = 1)
	fish_weight_modifier = 0.6 //It may be metallic, but it's just "denser" hydrogen at the end of the day, no?
	fishing_difficulty_modifier = -13
	fishing_cast_range = 4
	fishing_experience_multiplier = 0.8
	fishing_completion_speed = 1.4
	fishing_bait_speed_mult = 1.3
	fishing_deceleration_mult = 0.8
	fishing_bounciness_mult = 1.7
	fishing_gravity_mult = 0.7

/datum/material/metalhydrogen/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
		return TRUE

//I don't like sand. It's coarse, and rough, and irritating, and it gets everywhere.
/datum/material/sand
	name = "sand"
	desc = "You know, it's amazing just how structurally sound sand can be."
	color = "#EDC9AF"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	ore_type = /obj/item/stack/ore/glass
	value_per_unit = 2 / SHEET_MATERIAL_AMOUNT
	strength_modifier = 0.5
	integrity_modifier = 0.1
	armor_modifiers = list(MELEE = 0.25, BULLET = 0.25, LASER = 1.25, ENERGY = 0.25, BOMB = 0.25, BIO = 0.25, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = 0.25
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "sand"
	fish_weight_modifier = 1.2
	fishing_difficulty_modifier = 30 //Sand fishing rods? What the hell are you doing?
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.2
	fishing_completion_speed = 0.8
	fishing_bait_speed_mult = 0.8
	fishing_deceleration_mult = 2.5
	fishing_bounciness_mult = 0.3
	fishing_gravity_mult = 0.9

/datum/material/sand/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.adjust_disgust(17)
	return TRUE

//And now for our lavaland dwelling friends, sand, but in stone form! Truly revolutionary.
/datum/material/sandstone
	name = "sandstone"
	desc = "Bialtaakid 'ant taerif ma hdha."
	color = "#ECD5A8"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 0.5, BULLET = 0.5, LASER = 1.25, ENERGY = 0.5, BOMB = 0.5, BIO = 0.25, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_WOOD
	texture_layer_icon_state = "brick"
	fish_weight_modifier = 1.2
	fishing_difficulty_modifier = 25 //Sand fishing rods? What the hell are you doing?
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.3
	fishing_completion_speed = 0.9
	fishing_bait_speed_mult = 0.8
	fishing_deceleration_mult = 2.5
	fishing_bounciness_mult = 0.2
	fishing_gravity_mult = 0.9

/datum/material/snow
	name = "snow"
	desc = "There's no business like snow business."
	color = COLOR_WHITE
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/snow
	strength_modifier = 0.4
	integrity_modifier = 0.4
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 0.25, BULLET = 0.25, LASER = 0.25, ENERGY = 0.25, BOMB = 0.25, BIO = 0.25, FIRE = 0.25, ACID = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "sand"
	fish_weight_modifier = 0.8
	fishing_difficulty_modifier = 25
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.3
	fishing_completion_speed = 0.9
	fishing_bait_speed_mult = 0.75
	fishing_deceleration_mult = 0.3
	fishing_bounciness_mult = 0.2
	fishing_gravity_mult = 0.7

/datum/material/snow/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/water, rand(5, 10))
	return TRUE

/datum/material/runedmetal
	name = "runed metal"
	desc = "Mir'ntrath barhah Nar'sie."
	color = "#504742"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/runed_metal
	value_per_unit = 1500 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 1.2, BULLET = 1.2, LASER = 1, ENERGY = 1, BOMB = 1.2, BIO = 1.2, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = -0.15
	texture_layer_icon_state = "runed"
	fish_weight_modifier = 1.5
	fishing_difficulty_modifier = -6.66
	fishing_experience_multiplier = 0.666
	fishing_completion_speed = 1.666
	fishing_bait_speed_mult = 1.666
	fishing_deceleration_mult = 1.666
	fishing_bounciness_mult = 0.666
	fishing_gravity_mult = 1.666

/datum/material/runedmetal/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.reagents.add_reagent(/datum/reagent/fuel/unholywater, rand(8, 12))
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/datum/material/bronze
	name = "bronze"
	desc = "Clock Cult? Never heard of it."
	color = "#876223"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/bronze
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 1, BULLET = 1, LASER = 1, ENERGY = 1, BOMB = 1, BIO = 1, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = 0.2
	fish_weight_modifier = 1.4
	fishing_bait_speed_mult = 1.1
	fishing_deceleration_mult = 0.8
	fishing_bounciness_mult = 1.2
	fishing_gravity_mult = 1.05

/datum/material/paper
	name = "paper"
	desc = "Ten thousand folds of pure starchy power."
	color = "#E5DCD5"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/paperframes
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	strength_modifier = 0.3
	armor_modifiers = list(MELEE = 0.1, BULLET = 0.1, LASER = 0.1, ENERGY = 0.1, BOMB = 0.1, BIO = 0.1, ACID = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "paper"
	fish_weight_modifier = 0.4
	fishing_difficulty_modifier = 40 //child's play
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.1
	fishing_bait_speed_mult = 0.7
	fishing_deceleration_mult = 1.5
	fishing_bounciness_mult = 0.2
	fishing_gravity_mult = 0.6

/datum/material/paper/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isobj(source) || !(source.material_flags & MATERIAL_AFFECT_STATISTICS))
		return
	var/obj/paper = source
	paper.resistance_flags |= FLAMMABLE
	paper.obj_flags |= UNIQUE_RENAME
	if(istype(paper, /obj/item/fishing_rod))
		RegisterSignal(paper, COMSIG_ROD_BEGIN_FISHING, PROC_REF(on_begin_fishing))

/datum/material/paper/proc/on_begin_fishing(obj/item/fishing_rod/rod, datum/fishing_challenge/challenge)
	SIGNAL_HANDLER
	if(prob(40)) //consider the default reward and it's 15%
		RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_ROLL_REWARD, PROC_REF(roll_stickman))

/datum/material/paper/proc/roll_stickman(datum/source, obj/item/fishing_rod/rod, mob/fisherman, atom/location, list/rewards)
	SIGNAL_HANDLER
	rewards += pick(/mob/living/basic/stickman, /mob/living/basic/stickman/dog, /mob/living/basic/stickman/ranged)

/datum/material/paper/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isobj(source) || !(source.material_flags & MATERIAL_AFFECT_STATISTICS))
		return
	var/obj/paper = source
	paper.resistance_flags &= ~FLAMMABLE
	if(istype(paper, /obj/item/fishing_rod))
		UnregisterSignal(paper, COMSIG_ROD_BEGIN_FISHING)

/datum/material/cardboard
	name = "cardboard"
	desc = "They say cardboard is used by hobos to make incredible things."
	color = "#5F625C"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/cardboard
	value_per_unit = 6 / SHEET_MATERIAL_AMOUNT
	strength_modifier = 0.3
	armor_modifiers = list(MELEE = 0.25, BULLET = 0.25, LASER = 0.25, ENERGY = 0.25, BOMB = 0.25, BIO = 0.25, ACID = 1.5)
	beauty_modifier = -0.1
	fish_weight_modifier = 0.4
	fishing_difficulty_modifier = 40 //child's play
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.1
	fishing_bait_speed_mult = 0.7
	fishing_deceleration_mult = 1.5
	fishing_bounciness_mult = 0.2
	fishing_gravity_mult = 0.6

/datum/material/cardboard/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(isobj(source) && source.material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/cardboard = source
		cardboard.resistance_flags |= FLAMMABLE
		cardboard.obj_flags |= UNIQUE_RENAME

/datum/material/cardboard/on_main_removed(atom/source, mat_amount, multiplier)
	if(isobj(source) && source.material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/cardboard = source
		cardboard.resistance_flags &= ~FLAMMABLE
	return ..()

/datum/material/bone
	name = "bone"
	desc = "Man, building with this will make you the coolest caveman on the block."
	color = "#e3dac9"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/bone
	value_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 1.2, BULLET = 0.75, LASER = 0.75, ENERGY = 1.2, BOMB = 1, BIO = 1, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = -0.2
	fish_weight_modifier = 1.05
	fishing_difficulty_modifier = 15
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.85
	fishing_completion_speed = 0.9
	fishing_bait_speed_mult = 0.9
	fishing_deceleration_mult = 0.9
	fishing_bounciness_mult = 0.8
	fishing_gravity_mult = 0.85

/datum/material/bone/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		RegisterSignal(source, COMSIG_ROD_BEGIN_FISHING, PROC_REF(on_begin_fishing))
	else if(istype(source, /obj/item/fish))
		ADD_TRAIT(source, TRAIT_FISH_MADE_OF_BONE, REF(src))

/datum/material/bone/proc/on_begin_fishing(obj/item/fishing_rod/rod, datum/fishing_challenge/challenge)
	SIGNAL_HANDLER
	if(prob(40))
		RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_ROLL_REWARD, PROC_REF(roll_bones))

/datum/material/bone/proc/roll_bones(datum/source, obj/item/fishing_rod/rod, mob/fisherman, atom/location, list/rewards)
	SIGNAL_HANDLER
	var/static/list/bones = list(
		/obj/item/fish/boned = 65,
		/obj/item/fish/mastodon = 8,
		/mob/living/basic/skeleton = 6,
		/mob/living/basic/skeleton/ice = 6,
		/mob/living/basic/skeleton/templar = 6,
		/obj/item/instrument/trumpet/spectral/one_doot = 3,
		/obj/item/instrument/saxophone/spectral/one_doot = 3,
		/obj/item/instrument/trombone/spectral/one_doot = 3,
	)
	rewards += pick_weight(bones)

/datum/material/bone/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		UnregisterSignal(source, COMSIG_ROD_BEGIN_FISHING)
	else if(istype(source, /obj/item/fish))
		REMOVE_TRAIT(source, TRAIT_FISH_MADE_OF_BONE, REF(src))

/datum/material/bamboo
	name = "bamboo"
	desc = "If it's good enough for pandas, it's good enough for you."
	color = "#87a852"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	strength_modifier = 0.5
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 0.5, BULLET = 0.5, LASER = 0.5, ENERGY = 0.5, BOMB = 0.5, BIO = 0.51, FIRE = 0.5, ACID = 1.5)
	beauty_modifier = 0.2
	turf_sound_override = FOOTSTEP_WOOD
	texture_layer_icon_state = "bamboo"
	fish_weight_modifier = 0.5
	fishing_difficulty_modifier = -4
	fishing_cast_range = -1
	fishing_experience_multiplier = 1.3
	fishing_completion_speed = 1.15
	fishing_bait_speed_mult = 1.1
	fishing_deceleration_mult = 0.8
	fishing_bounciness_mult = 0.7
	fishing_gravity_mult = 0.7

/datum/material/zaukerite
	name = "zaukerite"
	desc = "A light absorbing crystal"
	color = COLOR_ALMOST_BLACK
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/mineral/zaukerite
	value_per_unit = 900 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 0.9, BULLET = 0.9, LASER = 1.75, ENERGY = 1.75, BOMB = 0.5, BIO = 1, FIRE = 0.1, ACID = 1)
	beauty_modifier = 0.001
	fish_weight_modifier = 1.2
	fishing_difficulty_modifier = -14
	fishing_experience_multiplier = 0.9
	fishing_completion_speed = 1.3
	fishing_bait_speed_mult = 1.2
	fishing_deceleration_mult = 1.3
	fishing_bounciness_mult = 1.1
	fishing_gravity_mult = 1.3

/datum/material/zaukerite/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_IGNORE_ENVIRONMENT, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/zaukerite/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_IGNORE_ENVIRONMENT, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/zaukerite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(30, BURN, BODY_ZONE_HEAD, wound_bonus = 5)
	source_item?.reagents?.add_reagent(/datum/reagent/toxin/plasma, source_item.reagents.total_volume*5)
	return TRUE
