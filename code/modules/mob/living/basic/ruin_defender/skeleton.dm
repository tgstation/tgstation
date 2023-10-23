/mob/living/basic/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	gender = NEUTER
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
	speak_emote = list("rattles")
	maxHealth = 40
	health = 40
	basic_mob_flags = DEL_ON_DEATH
	melee_damage_lower = 15
	melee_damage_upper = 15
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	faction = list(FACTION_SKELETON)
	// Going for a sort of pale bluegreen here, shooting for boneish
	lighting_cutoff_red = 15
	lighting_cutoff_green = 25
	lighting_cutoff_blue = 35
	death_message = "collapses into a pile of bones!"
	ai_controller = /datum/ai_controller/basic_controller/skeleton
	/// Loot this mob drops on death.
	var/list/loot = list(/obj/effect/decal/remains/human)
	/// Path of the outfit we give to the mob's visuals.
	var/outfit = null
	/// Path of the species we give to the mob's visuals.
	var/species = /datum/species/skeleton
	/// Path of the held item we give to the mob's visuals.
	var/held_item
	/// Types of milk skeletons like to drink
	var/static/list/good_drinks = list(
		/obj/item/reagent_containers/condiment/milk,
	)
	/// Bad milk that skeletons hate
	var/static/list/bad_drinks = list(
		/obj/item/reagent_containers/condiment/soymilk,
	)

/mob/living/basic/skeleton/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, outfit, species, r_hand = held_item)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	if(LAZYLEN(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)
	AddElement(/datum/element/basic_eating, heal_amt = 50, drinking = TRUE, food_types = good_drinks)
	AddElement(/datum/element/basic_eating, heal_amt = 0, damage_amount = 25, damage_type = BURN, drinking = TRUE, food_types = bad_drinks)
	ADD_TRAIT(src, TRAIT_SNOWSTORM_IMMUNE, INNATE_TRAIT)
	ai_controller?.set_blackboard_key(BB_BASIC_FOODS, good_drinks + bad_drinks)

/mob/living/basic/skeleton/settler
	name = "undead settler"
	desc = "The reanimated remains of some poor settler."
	maxHealth = 55
	health = 55
	melee_damage_lower = 17
	melee_damage_upper = 20
	attack_verb_continuous = "jabs"
	attack_verb_simple = "jab"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	death_message = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(
		/obj/effect/decal/remains/human,
		/obj/item/spear,
		/obj/item/clothing/shoes/winterboots,
		/obj/item/clothing/suit/hooded/wintercoat,
	)
	outfit = /datum/outfit/settler
	held_item = /obj/item/spear

/datum/outfit/settler
	name = "Settler"
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/winterboots

/mob/living/basic/skeleton/templar
	name = "undead templar"
	desc = "The reanimated remains of a holy templar knight."
	maxHealth = 150
	health = 150
	speed = 2
	force_threshold = 10 //trying to simulate actually having armor
	obj_damage = 50
	melee_damage_lower = 25
	melee_damage_upper = 30
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	death_message = "collapses into a pile of bones, its gear clanging as it hits the ground!"
	loot = list(
		/obj/effect/decal/remains/human,
		/obj/item/clothing/suit/chaplainsuit/armor/templar,
		/obj/item/clothing/head/helmet/chaplain,
		/obj/item/claymore/weak{name = "holy sword"}
	)
	outfit = /datum/outfit/templar

/datum/outfit/templar
	name = "Templar"
	head = /obj/item/clothing/head/helmet/chaplain
	suit = /obj/item/clothing/suit/chaplainsuit/armor/templar
	r_hand = /obj/item/claymore/weak

/mob/living/basic/skeleton/ice
	name = "ice skeleton"
	desc = "A reanimated skeleton protected by a thick sheet of natural ice armor. Looks slow, though."
	speed = 5
	maxHealth = 75
	health = 75
	color = rgb(114,228,250)
	loot = list(/obj/effect/decal/remains/human{color = rgb(114,228,250)})

/mob/living/basic/skeleton/plasmaminer
	name = "shambling miner"
	desc = "A plasma-soaked miner, their exposed limbs turned into a grossly incandescent bone seemingly made of plasma."
	icon_state = "plasma_miner"
	icon_living = "plasma_miner"
	icon_dead = "plasma_miner"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	light_color = LIGHT_COLOR_PURPLE
	light_range = 2
	death_message = "collapses into a pile of bones, their suit dissolving among the plasma!"
	loot = list(/obj/effect/decal/remains/plasma)
	outfit = /datum/outfit/plasma_miner
	species = /datum/species/plasmaman

/mob/living/basic/skeleton/plasmaminer/jackhammer
	desc = "A plasma-soaked miner, their exposed limbs turned into a grossly incandescent bone seemingly made of plasma. They seem to still have their mining tool in their hand, gripping tightly."
	icon_state = "plasma_miner_tool"
	icon_living = "plasma_miner_tool"
	icon_dead = "plasma_miner_tool"
	maxHealth = 185
	health = 185
	melee_damage_lower = 20
	melee_damage_upper = 25
	attack_verb_continuous = "blasts"
	attack_verb_simple = "blast"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_vis_effect = null
	loot = list(/obj/effect/decal/remains/plasma, /obj/item/pickaxe/drill/jackhammer)
	held_item = /obj/item/pickaxe/drill/jackhammer

/datum/outfit/plasma_miner
	name = "Plasma Miner"
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer

// Skeleton AI

/// Skeletons mostly just beat people to death, but they'll also find and drink milk.
/datum/ai_controller/basic_controller/skeleton
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_EMOTE_KEY = "rattles",
		BB_EMOTE_CHANCE = 20,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/run_emote,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
