/mob/living/simple_animal/hostile/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	gender = NEUTER
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
	turns_per_move = 5
	speak_emote = list("rattles")
	emote_see = list("rattles")
	combat_mode = TRUE
	maxHealth = 40
	health = 40
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0 //they're skeletons how would bruise packs help them??
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
	robust_searching = 1
	stat_attack = HARD_CRIT
	faction = list("skeleton")
	// Going for a sort of pale bluegreen here, shooting for boneish
	lighting_cutoff_red = 15
	lighting_cutoff_green = 25
	lighting_cutoff_blue = 35
	footstep_type = FOOTSTEP_MOB_SHOE
	death_message = "collapses into a pile of bones!"
	del_on_death = TRUE
	loot = list(/obj/effect/decal/remains/human)
	/// Path of the outfit we give to the mob's visuals.
	var/outfit = null
	/// Path of the species we give to the mob's visuals.
	var/species = /datum/species/skeleton
	/// Path of the held item we give to the mob's visuals.
	var/held_item

/mob/living/simple_animal/hostile/skeleton/Initialize(mapload)
	. = ..()
	apply_dynamic_human_icon(src, outfit, species, r_hand = held_item)

/mob/living/simple_animal/hostile/skeleton/eskimo
	name = "undead eskimo"
	desc = "The reanimated remains of some poor traveler."
	maxHealth = 55
	health = 55
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	melee_damage_lower = 17
	melee_damage_upper = 20
	death_message = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(
		/obj/effect/decal/remains/human,
		/obj/item/spear,
		/obj/item/clothing/shoes/winterboots,
		/obj/item/clothing/suit/hooded/wintercoat,
	)
	outfit = /datum/outfit/eskimo
	held_item = /obj/item/spear

/datum/outfit/eskimo
	name = "Eskimo"
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/winterboots

/mob/living/simple_animal/hostile/skeleton/templar
	name = "undead templar"
	desc = "The reanimated remains of a holy templar knight."
	maxHealth = 150
	health = 150
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	speed = 2
	speak_chance = 1
	speak = list("THE GODS WILL IT!","DEUS VULT!","REMOVE KABAB!")
	force_threshold = 10 //trying to simulate actually having armor
	obj_damage = 50
	melee_damage_lower = 25
	melee_damage_upper = 30
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

/mob/living/simple_animal/hostile/skeleton/ice
	name = "ice skeleton"
	desc = "A reanimated skeleton protected by a thick sheet of natural ice armor. Looks slow, though."
	speed = 5
	maxHealth = 75
	health = 75
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	color = rgb(114,228,250)
	loot = list(/obj/effect/decal/remains/human{color = rgb(114,228,250)})

/mob/living/simple_animal/hostile/skeleton/plasmaminer
	name = "shambling miner"
	desc = "A plasma-soaked miner, their exposed limbs turned into a grossly incandescent bone seemingly made of plasma."
	icon_state = "plasma_miner"
	icon_living = "plasma_miner"
	icon_dead = "plasma_miner"
	maxHealth = 150
	health = 150
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 20
	light_color = LIGHT_COLOR_PURPLE
	light_range = 2
	death_message = "collapses into a pile of bones, their suit dissolving among the plasma!"
	loot = list(/obj/effect/decal/remains/plasma)
	outfit = /datum/outfit/plasma_miner
	species = /datum/species/plasmaman

/mob/living/simple_animal/hostile/skeleton/plasmaminer/jackhammer
	desc = "A plasma-soaked miner, their exposed limbs turned into a grossly incandescent bone seemingly made of plasma. They seem to still have their mining tool in their hand, gripping tightly."
	icon_state = "plasma_miner_tool"
	icon_living = "plasma_miner_tool"
	icon_dead = "plasma_miner_tool"
	maxHealth = 185
	health = 185
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 25
	attack_verb_continuous = "blasts"
	attack_verb_simple = "blast"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_vis_effect = null // jackhammer moment
	loot = list(/obj/effect/decal/remains/plasma, /obj/item/pickaxe/drill/jackhammer)
	held_item = /obj/item/pickaxe/drill/jackhammer

/datum/outfit/plasma_miner
	name = "Plasma Miner"
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
