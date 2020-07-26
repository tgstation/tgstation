///Has no special properties.
/datum/material/iron
	name = "iron"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	color = "#878687"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/metal
	value_per_unit = 0.0025

/datum/material/iron/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	desc = "Glass forged by melting sand."
	color = "#88cdf1"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	integrity_modifier = 0.1
	sheet_type = /obj/item/stack/sheet/glass
	value_per_unit = 0.0025
	beauty_modifier = 0.05
	armor_modifiers = list("melee" = 0.2, "bullet" = 0.2, "laser" = 0, "energy" = 1, "bomb" = 0, "bio" = 0.2, "rad" = 0.2, "fire" = 1, "acid" = 0.2)

/datum/material/glass/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5, sharpness = TRUE) //cronch
	return TRUE

/*
Color matrices are like regular colors but unlike with normal colors, you can go over 255 on a channel.
Unless you know what you're doing, only use the first three numbers. They're in RGB order.
*/

///Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	desc = "Silver"
	color = list(255/255, 284/255, 302/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	value_per_unit = 0.025
	beauty_modifier = 0.075

/datum/material/silver/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Slight force increase
/datum/material/gold
	name = "gold"
	desc = "Gold"
	color = list(340/255, 240/255, 50/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //gold is shiny, but not as bright as bananium
	strength_modifier = 1.2
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/gold
	value_per_unit = 0.0625
	beauty_modifier = 0.15
	armor_modifiers = list("melee" = 1.1, "bullet" = 1.1, "laser" = 1.15, "energy" = 1.15, "bomb" = 1, "bio" = 1, "rad" = 1, "fire" = 0.7, "acid" = 1.1)

/datum/material/gold/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Has no special properties
/datum/material/diamond
	name = "diamond"
	desc = "Highly pressurized carbon"
	color = list(48/255, 272/255, 301/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	alpha = 132
	value_per_unit = 0.25
	beauty_modifier = 0.3
	armor_modifiers = list("melee" = 1.3, "bullet" = 1.3, "laser" = 0.6, "energy" = 1, "bomb" = 1.2, "bio" = 1, "rad" = 1, "fire" = 1, "acid" = 1)

/datum/material/diamond/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
	return TRUE

///Is slightly radioactive
/datum/material/uranium
	name = "uranium"
	desc = "Uranium"
	color = rgb(48, 237, 26)
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	value_per_unit = 0.05
	beauty_modifier = 0.3 //It shines so beautiful
	armor_modifiers = list("melee" = 1.5, "bullet" = 1.4, "laser" = 0.5, "energy" = 0.5, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 1, "acid" = 1)

/datum/material/uranium/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/radioactive, amount / 20, source, 0) //half-life of 0 because we keep on going.

/datum/material/uranium/on_removed(atom/source, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/radioactive))

/datum/material/uranium/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/uranium, rand(4, 6))
	S?.reagents?.add_reagent(/datum/reagent/uranium, S.reagents.total_volume*(2/5))
	return TRUE

///Adds firestacks on hit (Still needs support to turn into gas on destruction)
/datum/material/plasma
	name = "plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	color = list(298/255, 46/255, 352/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	value_per_unit = 0.1
	beauty_modifier = 0.15
	armor_modifiers = list("melee" = 1.4, "bullet" = 0.7, "laser" = 0, "energy" = 1.2, "bomb" = 0, "bio" = 1.2, "rad" = 1, "fire" = 0, "acid" = 0.5)

/datum/material/plasma/on_applied(atom/source, amount, material_flags)
	. = ..()
	if(ismovable(source))
		source.AddElement(/datum/element/firestacker, amount=1)
		source.AddComponent(/datum/component/explodable, 0, 0, amount / 2500, amount / 1250)

/datum/material/plasma/on_removed(atom/source, material_flags)
	. = ..()
	source.RemoveElement(/datum/element/firestacker, amount=1)
	qdel(source.GetComponent(/datum/component/explodable))

/datum/material/plasma/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(6, 8))
	S?.reagents?.add_reagent(/datum/reagent/toxin/plasma, S.reagents.total_volume*(2/5))
	return TRUE

///Can cause bluespace effects on use. (Teleportation) (Not yet implemented)
/datum/material/bluespace
	name = "bluespace crystal"
	desc = "Crystals with bluespace properties"
	color = list(119/255, 217/255, 396/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	alpha = 200
	categories = list(MAT_CATEGORY_ORE = TRUE)
	beauty_modifier = 0.5
	sheet_type = /obj/item/stack/sheet/bluespace_crystal
	value_per_unit = 0.15

/datum/material/bluespace/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/bluespace, rand(5, 8))
	S?.reagents?.add_reagent(/datum/reagent/bluespace, S.reagents.total_volume*(2/5))
	return TRUE

///Honks and slips
/datum/material/bananium
	name = "bananium"
	desc = "Material with hilarious properties"
	color = list(460/255, 464/255, 0, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //obnoxiously bright yellow
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	value_per_unit = 0.5
	beauty_modifier = 0.5
	armor_modifiers = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 0) //Clowns cant be blown away.

/datum/material/bananium/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)
	source.AddComponent(/datum/component/slippery, min(amount / 10, 80))

/datum/material/bananium/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/slippery))
	qdel(source.GetComponent(/datum/component/squeak))

/datum/material/bananium/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/consumable/banana, rand(8, 12))
	S?.reagents?.add_reagent(/datum/reagent/consumable/banana, S.reagents.total_volume*(2/5))
	return TRUE

///Mediocre force increase
/datum/material/titanium
	name = "titanium"
	desc = "Titanium"
	color = "#b3c0c7"
	strength_modifier = 1.3
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	value_per_unit = 0.0625
	beauty_modifier = 0.05
	armor_modifiers = list("melee" = 1.35, "bullet" = 1.3, "laser" = 1.3, "energy" = 1.25, "bomb" = 1.25, "bio" = 1, "rad" = 1, "fire" = 0.7, "acid" = 1)

/datum/material/titanium/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
	return TRUE

/datum/material/runite
	name = "runite"
	desc = "Runite"
	color = "#3F9995"
	strength_modifier = 1.3
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/runite
	value_per_unit = 0.3
	beauty_modifier = 0.5
	armor_modifiers = list("melee" = 1.35, "bullet" = 2, "laser" = 0.5, "energy" = 1.25, "bomb" = 1.25, "bio" = 1, "rad" = 1, "fire" = 1.4, "acid" = 1) //rune is weak against magic lasers but strong against bullets. This is the combat triangle.

/datum/material/runite/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
	return TRUE

///Force decrease
/datum/material/plastic
	name = "plastic"
	desc = "Plastic"
	color = "#caccd9"
	strength_modifier = 0.85
	sheet_type = /obj/item/stack/sheet/plastic
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	value_per_unit = 0.0125
	beauty_modifier = -0.01
	armor_modifiers = list("melee" = 1.5, "bullet" = 1.1, "laser" = 0.3, "energy" = 0.5, "bomb" = 1, "bio" = 1, "rad" = 1, "fire" = 1.1, "acid" = 1)

/datum/material/plastic/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.adjust_disgust(17)
	return TRUE

///Force decrease and mushy sound effect. (Not yet implemented)
/datum/material/biomass
	name = "biomass"
	desc = "Organic matter"
	color = "#735b4d"
	strength_modifier = 0.8
	value_per_unit = 0.025

/datum/material/wood
	name = "wood"
	desc = "Flexible, durable, but flamable. Hard to come across in space."
	color = "#bb8e53"
	strength_modifier = 0.5
	sheet_type = /obj/item/stack/sheet/mineral/wood
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	value_per_unit = 0.01
	beauty_modifier = 0.1
	armor_modifiers = list("melee" = 1.1, "bullet" = 1.1, "laser" = 0.4, "energy" = 0.4, "bomb" = 1, "bio" = 0.2, "rad" = 0, "fire" = 0, "acid" = 0.3)

/datum/material/wood/on_applied_obj(obj/source, amount, material_flags)
	. = ..()
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/wooden = source
		wooden.resistance_flags |= FLAMMABLE

/datum/material/wood/on_removed_obj(obj/source, material_flags)
	. = ..()
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/wooden = source
		wooden.resistance_flags &= ~FLAMMABLE

/datum/material/wood/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(5, BRUTE, BODY_ZONE_HEAD)

	var/obj/item/reagent_containers/food/snacks/food_S = S
	if(istype(food_S) && food_S?.tastes?.len)
		food_S.tastes += "wood chips and sawdust"
		food_S.tastes["wood chips and sawdust"] = 3
	return TRUE

///Stronk force increase
/datum/material/adamantine
	name = "adamantine"
	desc = "A powerful material made out of magic, I mean science!"
	color = "#6d7e8e"
	strength_modifier = 1.5
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/adamantine
	value_per_unit = 0.25
	beauty_modifier = 0.4
	armor_modifiers = list("melee" = 1.5, "bullet" = 1.5, "laser" = 1.3, "energy" = 1.3, "bomb" = 1, "bio" = 1, "rad" = 1, "fire" = 2.5, "acid" = 1)

/datum/material/adamantine/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
	return TRUE

///RPG Magic.
/datum/material/mythril
	name = "mythril"
	desc = "How this even exists is byond me"
	color = "#f2d5d7"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/mythril
	value_per_unit = 0.75
	strength_modifier = 1.2
	armor_modifiers = list("melee" = 1.5, "bullet" = 1.5, "laser" = 1.5, "energy" = 1.5, "bomb" = 1.5, "bio" = 1.5, "rad" = 1.5, "fire" = 1.5, "acid" = 1.5)
	beauty_modifier = 0.5

/datum/material/mythril/on_applied_obj(atom/source, amount, material_flags)
	. = ..()
	if(istype(source, /obj/item))
		source.AddComponent(/datum/component/fantasy)

/datum/material/mythril/on_removed_obj(atom/source, material_flags)
	. = ..()
	if(istype(source, /obj/item))
		qdel(source.GetComponent(/datum/component/fantasy))

/datum/material/mythril/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 10)
	return TRUE

//formed when freon react with o2, emits a lot of plasma when heated
/datum/material/hot_ice
	name = "hot ice"
	desc = "A weird kind of ice, feels warm to the touch"
	color = "#88cdf1"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/hot_ice
	value_per_unit = 0.2
	beauty_modifier = 0.2

/datum/material/hot_ice/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/hot_ice, "plasma", amount*150, amount*20+300)

/datum/material/hot_ice/on_removed(atom/source, amount, material_flags)
	qdel(source.GetComponent(/datum/component/hot_ice, "plasma", amount*150, amount*20+300))
	return ..()

/datum/material/hot_ice/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(5, 6))
	S?.reagents?.add_reagent(/datum/reagent/toxin/plasma, S.reagents.total_volume*(3/5))
	var/obj/item/reagent_containers/food/snacks/food_S = S
	if(istype(food_S) && food_S?.tastes?.len)
		food_S.tastes += "salt"
		food_S.tastes["salt"] = 3
	return TRUE

/datum/material/metalhydrogen
	name = "Metal Hydrogen"
	desc = "Solid metallic hydrogen. Some say it should be impossible"
	color = "#f2d5d7"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/metal_hydrogen
	value_per_unit = 0.35
	beauty_modifier = 0.35
	strength_modifier = 1.2
	armor_modifiers = list("melee" = 1.35, "bullet" = 1.3, "laser" = 1.3, "energy" = 1.25, "bomb" = 0.7, "bio" = 1, "rad" = 1, "fire" = 1.3, "acid" = 1)

/datum/material/metalhydrogen/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
	return TRUE

//I don't like sand. It's coarse, and rough, and irritating, and it gets everywhere.
/datum/material/sand
	name = "sand"
	desc = "You know, it's amazing just how structurally sound sand can be."
	color = "#EDC9AF"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/sandblock
	value_per_unit = 0.001
	strength_modifier = 0.5
	integrity_modifier = 0.1
	armor_modifiers = list("melee" = 0.25, "bullet" = 0.25, "laser" = 1.25, "energy" = 0.25, "bomb" = 0.25, "bio" = 0.25, "rad" = 1.5, "fire" = 1.5, "acid" = 1.5)
	beauty_modifier = 0.25
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "sand"

/datum/material/sand/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.adjust_disgust(17)
	return TRUE

//And now for our lavaland dwelling friends, sand, but in stone form! Truly revolutionary.
/datum/material/sandstone
	name = "sandstone"
	desc = "Bialtaakid 'ant taerif ma hdha."
	color = "#B77D31"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	value_per_unit = 0.0025
	armor_modifiers = list("melee" = 0.5, "bullet" = 0.5, "laser" = 1.25, "energy" = 0.5, "bomb" = 0.5, "bio" = 0.25, "rad" = 1.5, "fire" = 1.5, "acid" = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_WOOD
	texture_layer_icon_state = "brick"

/datum/material/snow
	name = "snow"
	desc = "There's no business like snow business."
	color = "#FFFFFF"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/snow
	value_per_unit = 0.0025
	armor_modifiers = list("melee" = 0.25, "bullet" = 0.25, "laser" = 0.25, "energy" = 0.25, "bomb" = 0.25, "bio" = 0.25, "rad" = 1.5, "fire" = 0.25, "acid" = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "sand"

/datum/material/snow/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/water, rand(5, 10))
	return TRUE

/datum/material/runedmetal
	name = "runed metal"
	desc = "Mir'ntrath barhah Nar'sie."
	color = "#3C3434"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/runed_metal
	value_per_unit = 0.75
	armor_modifiers = list("melee" = 1.2, "bullet" = 1.2, "laser" = 1, "energy" = 1, "bomb" = 1.2, "bio" = 1.2, "rad" = 1.5, "fire" = 1.5, "acid" = 1.5)
	beauty_modifier = -0.15
	texture_layer_icon_state = "runed"

/datum/material/runedmetal/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/fuel/unholywater, rand(8, 12))
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/datum/material/bronze
	name = "bronze"
	desc = "Clock Cult? Never heard of it."
	color = "#92661A"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/tile/bronze
	value_per_unit = 0.025
	armor_modifiers = list("melee" = 1, "bullet" = 1, "laser" = 1, "energy" = 1, "bomb" = 1, "bio" = 1, "rad" = 1.5, "fire" = 1.5, "acid" = 1.5)
	beauty_modifier = 0.2

/datum/material/paper
	name = "paper"
	desc = "Ten thousand folds of pure starchy power."
	color = "#E5DCD5"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/paperframes
	value_per_unit = 0.0025
	armor_modifiers = list("melee" = 0.1, "bullet" = 0.1, "laser" = 0.1, "energy" = 0.1, "bomb" = 0.1, "bio" = 0.1, "rad" = 1.5, "fire" = 0, "acid" = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_SAND
	texture_layer_icon_state = "paper"

/datum/material/paper/on_applied_obj(obj/source, amount, material_flags)
	. = ..()
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/paper = source
		paper.resistance_flags |= FLAMMABLE
		paper.obj_flags |= UNIQUE_RENAME

/datum/material/paper/on_removed_obj(obj/source, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/paper = source
		paper.resistance_flags &= ~FLAMMABLE
	return ..()

/datum/material/cardboard
	name = "cardboard"
	desc = "They say cardboard is used by hobos to make incredible things."
	color = "#5F625C"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/cardboard
	value_per_unit = 0.003
	armor_modifiers = list("melee" = 0.25, "bullet" = 0.25, "laser" = 0.25, "energy" = 0.25, "bomb" = 0.25, "bio" = 0.25, "rad" = 1.5, "fire" = 0, "acid" = 1.5)
	beauty_modifier = -0.1

/datum/material/cardboard/on_applied_obj(obj/source, amount, material_flags)
	. = ..()
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/cardboard = source
		cardboard.resistance_flags |= FLAMMABLE
		cardboard.obj_flags |= UNIQUE_RENAME

/datum/material/cardboard/on_removed_obj(obj/source, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/cardboard = source
		cardboard.resistance_flags &= ~FLAMMABLE
	return ..()

/datum/material/bone
	name = "bone"
	desc = "Man, building with this will make you the coolest caveman on the block."
	color = "#e3dac9"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/bone
	value_per_unit = 0.05
	armor_modifiers = list("melee" = 1.2, "bullet" = 0.75, "laser" = 0.75, "energy" = 1.2, "bomb" = 1, "bio" = 1, "rad" = 1.5, "fire" = 1.5, "acid" = 1.5)
	beauty_modifier = -0.2

/datum/material/bamboo
	name = "bamboo"
	desc = "If it's good enough for pandas, it's good enough for you."
	color = "#339933"
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	value_per_unit = 0.0025
	armor_modifiers = list("melee" = 0.5, "bullet" = 0.5, "laser" = 0.5, "energy" = 0.5, "bomb" = 0.5, "bio" = 0.51, "rad" = 1.5, "fire" = 0.5, "acid" = 1.5)
	beauty_modifier = 0.2
	turf_sound_override = FOOTSTEP_WOOD
	texture_layer_icon_state = "bamboo"
