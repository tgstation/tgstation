///Has no special properties.
/datum/material/iron
	name = "iron"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	color = "#B6BEC2"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 6,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 2,
		MATERIAL_REFLECTIVITY = 3,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 7,
		MATERIAL_CHEMICAL = 3,
	)
	sheet_type = /obj/item/stack/sheet/iron
	ore_type = /obj/item/stack/ore/iron
	material_reagent = /datum/reagent/iron
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	mat_rust_resistance = RUST_RESISTANCE_BASIC
	mineral_rarity = MATERIAL_RARITY_COMMON
	points_per_unit = 1 / SHEET_MATERIAL_AMOUNT
	minimum_value_override = 0
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON

/datum/material/iron/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
		return TRUE

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	desc = "Glass forged by melting sand."
	color = "#6292AF"
	alpha = 150
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 4,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 7,
		MATERIAL_ELECTRICAL = 0,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 8,
	)
	material_reagent = /datum/reagent/silicon
	sheet_type = /obj/item/stack/sheet/glass
	ore_type = /obj/item/stack/ore/glass/basalt
	shard_type = /obj/item/shard
	debris_type = /obj/effect/decal/cleanable/glass
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	minimum_value_override = 0
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON
	mineral_rarity = MATERIAL_RARITY_COMMON
	points_per_unit = 1 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "shine"

/datum/material/glass/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
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

/// Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	desc = "A precious metal known for being hated by oversized bats and dogs."
	color = "#B5BCBB"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 7,
		MATERIAL_HARDNESS = 4,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 4,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 4,
	)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	ore_type = /obj/item/stack/ore/silver
	material_reagent = /datum/reagent/silver
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_UNCOMMON
	mineral_rarity = MATERIAL_RARITY_SEMIPRECIOUS
	points_per_unit = 16 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "shine"

/datum/material/silver/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
		return TRUE

///Slight force increase
/datum/material/gold
	name = "gold"
	desc = "All that glitters is not gold."
	color = "#E6BB45"
	mat_properties = list(
		MATERIAL_DENSITY = 9,
		MATERIAL_HARDNESS = 3,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 6,
		MATERIAL_ELECTRICAL = 8,
		MATERIAL_THERMAL = 8,
		MATERIAL_CHEMICAL = 2,
	)
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	sheet_type = /obj/item/stack/sheet/mineral/gold
	ore_type = /obj/item/stack/ore/gold
	material_reagent = /datum/reagent/gold
	value_per_unit = 125 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_RARE
	mineral_rarity = MATERIAL_RARITY_PRECIOUS
	points_per_unit = 18 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "shine"

/datum/material/gold/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
		return TRUE

///Has no special properties
/datum/material/diamond
	name = "diamond"
	desc = "Highly pressurized carbon."
	color = "#C9D8F2"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 4, // Wow these are light
		MATERIAL_HARDNESS = 9,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 10,
		MATERIAL_ELECTRICAL = 0, // Did you know they're also an *extremely* potent insulator, only beaten by some synthetic compounds?
		MATERIAL_THERMAL = 9,
		MATERIAL_CHEMICAL = 4,
	)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	ore_type = /obj/item/stack/ore/diamond
	material_reagent = /datum/reagent/carbon
	alpha = 132
	starlight_color = COLOR_BLUE_LIGHT
	value_per_unit = 500 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_EXOTIC
	mineral_rarity = MATERIAL_RARITY_RARE
	points_per_unit = 50 / SHEET_MATERIAL_AMOUNT

/datum/material/diamond/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
		return TRUE

/// Is slightly radioactive
/datum/material/uranium
	name = "uranium"
	desc = "Very spicy rocks."
	color = "#2C992C"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 9,
		MATERIAL_HARDNESS = 5,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 0, // Its a bar of glowing stone
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 6,
		MATERIAL_CHEMICAL = 6,
		MATERIAL_BEAUTY = 0.3, // Overriden cause its ~shiny~
		MATERIAL_RADIOACTIVITY = 4,
	)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	ore_type = /obj/item/stack/ore/uranium
	material_reagent = /datum/reagent/uranium
	value_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_RARE
	mineral_rarity = MATERIAL_RARITY_SEMIPRECIOUS
	points_per_unit = 30 / SHEET_MATERIAL_AMOUNT

/// Adds firestacks on hit (Still needs support to turn into gas on destruction)
/datum/material/plasma
	name = "plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	color = "#BA3692"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 6,
		MATERIAL_HARDNESS = 4,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 10,
		MATERIAL_THERMAL = 8,
		MATERIAL_CHEMICAL = 0,
		MATERIAL_FLAMMABILITY = 9, // Literally sets itself on fire from any excitement
	)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	ore_type = /obj/item/stack/ore/plasma
	material_reagent = /datum/reagent/toxin/plasma
	value_per_unit = 200 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_PRECIOUS
	points_per_unit = 15 / SHEET_MATERIAL_AMOUNT

/datum/material/plasma/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(ismovable(source))
		source.AddElement(/datum/element/firestacker, 1 * multiplier)
	source.AddComponent(/datum/component/combustible_flooder, GAS_PLASMA, mat_amount * 0.05 * multiplier) //Empty temp arg, fully dependent on whatever ignited it.
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/plasma/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	source.RemoveElement(/datum/element/firestacker, mat_amount = 1 * multiplier)
	qdel(source.GetComponent(/datum/component/combustible_flooder))
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_LAVA_USABLE, REF(src))

///Can cause bluespace effects on use. (Teleportation) (Not yet implemented)
/datum/material/bluespace
	name = "bluespace crystal"
	desc = "Crystals with bluespace properties."
	color = "#2E50B7"
	alpha = 200
	starlight_color = COLOR_BLUE
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL
	mat_properties = list(
		MATERIAL_DENSITY = 2,
		MATERIAL_HARDNESS = 8,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 10,
		MATERIAL_ELECTRICAL = 10,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 4,
		MATERIAL_BEAUTY = 0.5, // Absolutely mesmerizing
	)
	sheet_type = /obj/item/stack/sheet/bluespace_crystal
	ore_type = /obj/item/stack/ore/bluespace_crystal
	material_reagent = /datum/reagent/bluespace
	value_per_unit = 300 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_RARE
	points_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_EXOTIC
	texture_layer_icon_state = "shine"

/datum/material/bluespace/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		RegisterSignal(source, COMSIG_ROD_BEGIN_FISHING, PROC_REF(on_begin_fishing))

/datum/material/bluespace/proc/on_begin_fishing(obj/item/fishing_rod/rod, datum/fishing_challenge/challenge)
	SIGNAL_HANDLER
	if(prob(67))
		return
	var/list/elegible_fish_sources = assoc_to_values(GLOB.preset_fish_sources)
	for(var/datum/fish_source/source as anything in elegible_fish_sources)
		if(source.fish_source_flags & FISH_SOURCE_FLAG_NO_BLUESPACE_ROD)
			elegible_fish_sources -= source
	var/datum/fish_source/new_source = pick(elegible_fish_sources)
	challenge.register_reward_signals(new_source)

/datum/material/bluespace/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		UnregisterSignal(source, COMSIG_ROD_BEGIN_FISHING)

///Honks and slips
/datum/material/bananium
	name = "bananium"
	desc = "Material with hilarious properties."
	color = list(460/255, 464/255, 0, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //obnoxiously bright yellow //It's literally perfect I can't change it
	greyscale_color = "#FFF269"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 2,
		MATERIAL_REFLECTIVITY = 4,
		MATERIAL_ELECTRICAL = 1, // ...Rubbery?
		MATERIAL_THERMAL = 6,
		MATERIAL_CHEMICAL = 6,
		MATERIAL_BEAUTY = 0.5, // Honk
	)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	ore_type = /obj/item/stack/ore/bananium
	material_reagent = /datum/reagent/consumable/banana
	value_per_unit = 1000 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED
	points_per_unit = 60 / SHEET_MATERIAL_AMOUNT

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

///Mediocre force increase
/datum/material/titanium
	name = "titanium"
	desc = "Titanium"
	color = "#EFEFEF"
	mat_properties = list(
		MATERIAL_DENSITY = 5,
		MATERIAL_HARDNESS = 7,
		MATERIAL_FLEXIBILITY = 2,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 6,
	)
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	ore_type = /obj/item/stack/ore/titanium
	value_per_unit = 125 / SHEET_MATERIAL_AMOUNT
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_UNCOMMON
	mat_rust_resistance = RUST_RESISTANCE_TITANIUM
	mineral_rarity = MATERIAL_RARITY_SEMIPRECIOUS
	texture_layer_icon_state = "shine"

/datum/material/titanium/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
		return TRUE

/datum/material/runite
	name = "runite"
	desc = "Runite"
	color = "#526F77"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 9,
		MATERIAL_HARDNESS = 9,
		MATERIAL_FLEXIBILITY = 1,
		MATERIAL_REFLECTIVITY = 0,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 0,
		MATERIAL_CHEMICAL = 9,
	)
	sheet_type = /obj/item/stack/sheet/mineral/runite
	value_per_unit = 600 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT

/datum/material/runite/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/runite/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/runite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
		return TRUE

///Force decrease
/datum/material/plastic
	name = "plastic"
	desc = "Plastic"
	color = "#BFB9AC"
	mat_flags = MATERIAL_SILO_STORED | MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_POLYMER | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 3,
		MATERIAL_HARDNESS = 2,
		MATERIAL_FLEXIBILITY = 5,
		MATERIAL_REFLECTIVITY = 3,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 4,
		MATERIAL_FLAMMABILITY = 4,
	)
	sheet_type = /obj/item/stack/sheet/plastic
	ore_type = /obj/item/stack/ore/slag // No plastic or coal ore, so we use slag.
	material_reagent = /datum/reagent/plastic_polymers
	value_per_unit = 25 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED // Nobody's found oil on lavaland yet.
	points_per_unit = 4 / SHEET_MATERIAL_AMOUNT

/// Force decrease and mushy sound effect. (Not yet implemented)
/datum/material/biomass
	name = "biomass"
	desc = "Organic matter."
	color = "#735b4d"
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT

/datum/material/wood
	name = "wood"
	desc = "Flexible, durable, but flammable. Hard to come across in space."
	color = "#855932"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_ORGANIC | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 2,
		MATERIAL_HARDNESS = 4,
		MATERIAL_FLEXIBILITY = 4,
		MATERIAL_REFLECTIVITY = 1,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 3,
		MATERIAL_CHEMICAL = 1,
		MATERIAL_FLAMMABILITY = 6,
		MATERIAL_BEAUTY = 0.1, // Pretty patterns
	)
	sheet_type = /obj/item/stack/sheet/mineral/wood
	material_reagent = /datum/reagent/cellulose
	value_per_unit = 20 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "woodgrain"

/datum/material/wood/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		return TRUE

/// Stronk force increase
/datum/material/adamantine
	name = "adamantine"
	desc = "A powerful material made out of magic, I mean science!"
	color = "#2B7A74"
	mat_properties = list(
		MATERIAL_DENSITY = 7,
		MATERIAL_HARDNESS = 9,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 6,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 9,
	)
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	sheet_type = /obj/item/stack/sheet/mineral/adamantine
	value_per_unit = 500 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED // Doesn't naturally spawn on lavaland.
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT

/datum/material/adamantine/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) // light-absorbing, environment-cancelling fishing rod.

/datum/material/adamantine/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) // light-absorbing, environment-cancelling fishing rod.

/datum/material/adamantine/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
		return TRUE

/// RPG Magic.
/datum/material/mythril
	name = "mythril"
	desc = "How this even exists is byond me"
	color = "#f2d5d7"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 10,
		MATERIAL_FLEXIBILITY = 4,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 9,
		MATERIAL_BEAUTY = 0.5,
		MATERIAL_INTEGRITY = 2, // This is magic, I ain't gotta explain shit
	)
	sheet_type = /obj/item/stack/sheet/mineral/mythril
	value_per_unit = 1500 / SHEET_MATERIAL_AMOUNT
	mineral_rarity = MATERIAL_RARITY_UNDISCOVERED // Doesn't naturally spawn on lavaland.
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT

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
	. = ..()
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
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 2,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 9,
		MATERIAL_THERMAL = 8,
		MATERIAL_CHEMICAL = 4,
		MATERIAL_FLAMMABILITY = 10,
	)
	sheet_type = /obj/item/stack/sheet/hot_ice
	material_reagent = /datum/reagent/toxin/plasma
	value_per_unit = 400 / SHEET_MATERIAL_AMOUNT

/datum/material/hot_ice/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	source.AddComponent(/datum/component/combustible_flooder, GAS_PLASMA, mat_amount * 1.5 * multiplier, (mat_amount * 0.2 + 300) * multiplier)

/datum/material/hot_ice/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	qdel(source.GetComponent(/datum/component/combustible_flooder))

// It's basically adamantine, but it isn't!
/datum/material/metalhydrogen
	name = "Metal Hydrogen"
	desc = "Solid metallic hydrogen. Some say it should be impossible"
	color = "#62708A"
	starlight_color = COLOR_MODERATE_BLUE
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 3,
		MATERIAL_HARDNESS = 10,
		MATERIAL_FLEXIBILITY = 1,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 2,
		MATERIAL_THERMAL = 2,
		MATERIAL_CHEMICAL = 8,
	)
	sheet_type = /obj/item/stack/sheet/mineral/metal_hydrogen
	material_reagent = /datum/reagent/hydrogen
	value_per_unit = 700 / SHEET_MATERIAL_AMOUNT

/datum/material/metalhydrogen/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
		return TRUE

//I don't like sand. It's coarse, and rough, and irritating, and it gets everywhere.
/datum/material/sand
	name = "sand"
	desc = "You know, it's amazing just how structurally sound sand can be."
	color = "#EDC9AF"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_AMORPHOUS
	mat_properties = list(
		MATERIAL_DENSITY = 2,
		MATERIAL_HARDNESS = 0,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 7,
		MATERIAL_ELECTRICAL = 3,
		MATERIAL_THERMAL = 8,
		MATERIAL_CHEMICAL = 4,
	)
	ore_type = /obj/item/stack/ore/glass
	material_reagent = /datum/reagent/silicon
	value_per_unit = 2 / SHEET_MATERIAL_AMOUNT
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "sand"
	mat_rust_resistance = RUST_RESISTANCE_BASIC

/datum/material/sand/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	victim.adjust_disgust(17)
	return TRUE

//And now for our lavaland dwelling friends, sand, but in stone form! Truly revolutionary.
/datum/material/sandstone
	name = "sandstone"
	desc = "Bialtaakid 'ant taerif ma hdha."
	color = "#ECD5A8"
	mat_flags = MATERIAL_BASIC_RECIPES
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 1,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 2,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 6,
		MATERIAL_CHEMICAL = 6,
	)
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	material_reagent = /datum/reagent/silicon
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	turf_sound_override = FOOTSTEP_WOOD
	texture_layer_icon_state = "brick"
	mat_rust_resistance = RUST_RESISTANCE_BASIC

/datum/material/snow
	name = "snow"
	desc = "There's no business like snow business."
	color = COLOR_WHITE
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_AMORPHOUS
	mat_properties = list(
		MATERIAL_DENSITY = 2,
		MATERIAL_HARDNESS = 2,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 6,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 6,
		MATERIAL_CHEMICAL = 1,
	)
	sheet_type = /obj/item/stack/sheet/mineral/snow
	material_reagent = /datum/reagent/consumable/ice
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "sand"
	mat_rust_resistance = RUST_RESISTANCE_ORGANIC

/datum/material/runedmetal
	name = "runed metal"
	desc = "Mir'ntrath barhah Nar'sie."
	color = "#504742"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 7,
		MATERIAL_HARDNESS = 7,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 2,
		MATERIAL_ELECTRICAL = 5,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 8,
	)
	sheet_type = /obj/item/stack/sheet/runed_metal
	value_per_unit = 1500 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "runed"

/datum/material/runedmetal/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	victim.reagents.add_reagent(/datum/reagent/fuel/unholywater, rand(8, 12))
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/datum/material/bronze
	name = "bronze"
	desc = "Clock Cult? Never heard of it."
	color = "#876223"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 8, // Bronze is *very* dense, almost as dense as lead
		MATERIAL_HARDNESS = 5,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 7,
		MATERIAL_ELECTRICAL = 8,
		MATERIAL_THERMAL = 8,
		MATERIAL_CHEMICAL = 5,
	)
	sheet_type = /obj/item/stack/sheet/bronze
	material_reagent = list(/datum/reagent/iron = 0.75, /datum/reagent/copper = 0.25)
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT

/datum/material/paper
	name = "paper"
	desc = "Ten thousand folds of pure starchy power."
	color = "#E5DCD5"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_ORGANIC
	mat_properties = list(
		MATERIAL_DENSITY = 0,
		MATERIAL_HARDNESS = 0,
		MATERIAL_FLEXIBILITY = 8,
		MATERIAL_REFLECTIVITY = 1,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 0,
		MATERIAL_FLAMMABILITY = 8,
		MATERIAL_BEAUTY = 0.3, // Origami is beautiful
	)
	material_reagent = /datum/reagent/cellulose
	sheet_type = /obj/item/stack/sheet/paperframes
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "paper"

/datum/material/paper/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isobj(source) || !(source.material_flags & MATERIAL_AFFECT_STATISTICS))
		return
	var/obj/paper = source
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
	if(istype(source, /obj/item/fishing_rod) && (source.material_flags & MATERIAL_AFFECT_STATISTICS))
		UnregisterSignal(source, COMSIG_ROD_BEGIN_FISHING)

/datum/material/cardboard
	name = "cardboard"
	desc = "They say cardboard is used by hobos to make incredible things."
	color = "#5F625C"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_ORGANIC
	mat_properties = list(
		MATERIAL_DENSITY = 1,
		MATERIAL_HARDNESS = 0,
		MATERIAL_FLEXIBILITY = 6,
		MATERIAL_REFLECTIVITY = 1,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 2,
		MATERIAL_FLAMMABILITY = 6,
	)
	sheet_type = /obj/item/stack/sheet/cardboard
	material_reagent = /datum/reagent/cellulose
	value_per_unit = 6 / SHEET_MATERIAL_AMOUNT

/datum/material/cardboard/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(isobj(source) && source.material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/cardboard = source
		cardboard.obj_flags |= UNIQUE_RENAME

/datum/material/bone
	name = "bone"
	desc = "Man, building with this will make you the coolest caveman on the block."
	color = "#e3dac9"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_ORGANIC | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 3,
		MATERIAL_HARDNESS = 5,
		MATERIAL_FLEXIBILITY = 2,
		MATERIAL_REFLECTIVITY = 4,
		MATERIAL_ELECTRICAL = 3,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 2,
	)
	sheet_type = /obj/item/stack/sheet/bone
	material_reagent = /datum/reagent/bone_dust
	value_per_unit = 100 / SHEET_MATERIAL_AMOUNT

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
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_ORGANIC | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 3, // Denser and bendier than wood, but pretty much the same otherwise
		MATERIAL_HARDNESS = 4,
		MATERIAL_FLEXIBILITY = 5,
		MATERIAL_REFLECTIVITY = 1,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 3,
		MATERIAL_CHEMICAL = 1,
		MATERIAL_FLAMMABILITY = 6,
		MATERIAL_BEAUTY = 0.2, // Prettier patterns
	)
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	material_reagent = /datum/reagent/cellulose
	value_per_unit = 5 / SHEET_MATERIAL_AMOUNT
	turf_sound_override = FOOTSTEP_WOOD
	texture_layer_icon_state = "bamboo"

/datum/material/zaukerite
	name = "zaukerite"
	desc = "A light absorbing crystal"
	color = COLOR_ALMOST_BLACK
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL
	mat_properties = list(
		MATERIAL_DENSITY = 1,
		MATERIAL_HARDNESS = 9,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 0,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 9,
		MATERIAL_CHEMICAL = 0,
	)
	sheet_type = /obj/item/stack/sheet/mineral/zaukerite
	material_reagent = /datum/reagent/toxin/plasma
	value_per_unit = 900 / SHEET_MATERIAL_AMOUNT

/datum/material/zaukerite/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		ADD_TRAIT(source, TRAIT_ROD_IGNORE_ENVIRONMENT, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/zaukerite/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_IGNORE_ENVIRONMENT, REF(src)) //light-absorbing, environment-cancelling fishing rod.

/datum/material/zaukerite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	. = ..()
	if(!HAS_TRAIT(victim, TRAIT_ROCK_EATER))
		victim.apply_damage(30, BURN, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE
