/// Dead god's finest
/mob/living/basic/trooper/clock_cultist
	name = "Rat Var's Cultist"
	desc = "Some still cling to the dead god's embrace. Or maybe they don't know the god is dead?"
	speed = 0.9 ///slower but tankier.
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 15
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_RUSSIAN) ///  No clock cult faction anymore and Marx was apparently a clock cultist...
	attack_verb_continuous = list("stabs", "pokes", "slashes", "clocks")
	attack_verb_simple = list("stab", "poke", "slash", "clock")
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	initial_language_holder = /datum/language_holder/spinwarder_exclusive

	mob_spawner = /obj/effect/mob_spawn/corpse/human/clockcultist
	r_hand = /obj/item/brass_spear
	corpse = /obj/effect/mob_spawn/corpse/human/clockcultist
	loot = list(/obj/item/brass_spear)

//spess ninja initiates
/mob/living/basic/trooper/spiderclan_mook
	name = "Spider Clan Innitiate"
	desc = "Not quite good enough to be granted all the tech. Good enough to cut you like a bamboo shoot."
	speed = 1.5 ///speed
	maxHealth = 100
	health = 100
	melee_damage_lower = 10
	melee_damage_upper = 30
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_SPIDER) /// Spider clan, close enough.
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	initial_language_holder = /datum/language_holder/felinid

	mob_spawner = /obj/effect/mob_spawn/corpse/human/spiderclan_mook
	r_hand = /obj/item/katana
	corpse = /obj/effect/mob_spawn/corpse/human/spiderclan_mook
	loot = list(/obj/item/clothing/mask/gas/ninja)

//Cavemen
/mob/living/basic/trooper/caveman
	name = "Caveman"
	desc = "Savages!"
	speed = 1
	maxHealth = 150
	health = 150
	melee_damage_lower = 10
	melee_damage_upper = 14
	unsuitable_cold_damage = 0.1
	unsuitable_heat_damage = 1
	faction = list(FACTION_JUNGLE)
	attack_verb_continuous = list("clubs", "bludgeons")
	attack_verb_simple = list("club", "bludgeon")
	attack_vis_effect = ATTACK_EFFECT_SMASH
	initial_language_holder = /datum/language_holder/monkey

	mob_spawner = /obj/effect/mob_spawn/corpse/human/caveman
	r_hand = /obj/item/tailclub
	corpse = /obj/effect/mob_spawn/corpse/human/caveman
	loot = list(/obj/item/tailclub)

//Evil Chef
/mob/living/basic/trooper/angry_chef
	name = "Angry Chef"
	desc = "Chop chop chop!"
	speed = 1
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_PLANTS) ///It's ingridients are obedient
	attack_verb_continuous = list("slices", "dices", "chops", "cubes", "minces", "juliennes", "chiffonades", "batonnets")
	attack_verb_simple = list("slice", "dice", "chop", "cube", "mince", "julienne", "chiffonade", "batonnet")
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH

	mob_spawner = /obj/effect/mob_spawn/corpse/human/angry_chef
	r_hand = /obj/item/knife/butcher
	corpse = /obj/effect/mob_spawn/corpse/human/angry_chef
	loot = list(/obj/item/knife/butcher)

//Evil Clown
/mob/living/basic/trooper/clown
	name = "Clown"
	desc = "Normally clowns have no malice in their hearths... But this one does."
	speed = 1.5
	maxHealth = 120
	health = 120
	melee_damage_lower = 13
	melee_damage_upper = 13
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_CLOWN)
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/items/weapons/chainsawhit.ogg'

	mob_spawner = /obj/effect/mob_spawn/corpse/human/evil_clown
	r_hand = /obj/item/chainsaw
	corpse = /obj/effect/mob_spawn/corpse/human/evil_clown
	loot = list(/obj/item/chainsaw)

//Evil Clown
/mob/living/basic/trooper/tormented
	name = "Clown"
	desc = "Normally clowns have no malice in their hearths... But this one does."
	speed = 1.5
	maxHealth = 120
	health = 120
	melee_damage_lower = 13
	melee_damage_upper = 13
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_CLOWN)
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/items/weapons/chainsawhit.ogg'

	mob_spawner = /obj/effect/mob_spawn/corpse/human/evil_clown
	r_hand = /obj/item/chainsaw
	corpse = /obj/effect/mob_spawn/corpse/human/evil_clown
	loot = list(/obj/item/chainsaw)
