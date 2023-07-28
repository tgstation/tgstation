//Space bears!
/mob/living/basic/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/costume/bearpelt = 1)

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"

	maxHealth = 60
	health = 60
	speed = 0

	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	wound_bonus = -5
	bare_wound_bonus = 10 // BEAR wound bonus am i right
	sharpness = SHARP_EDGED
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	friendly_verb_continuous = "bear hugs"
	friendly_verb_simple = "bear hug"

	faction = list(FACTION_RUSSIAN)

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 1500
	/// is the bear wearing a armor?
	var/armored = FALSE

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/basic/bear/hudson
	name = "Hudson"
	gender = MALE
	desc = "Feared outlaw, this guy is one bad news bear." //I'm sorry...

/mob/living/basic/bear/snow
	name = "space polar bear"
	icon_state = "snowbear"
	icon_living = "snowbear"
	icon_dead = "snowbear_dead"
	desc = "It's a polar bear, in space, but not actually in space."
/mob/living/basic/bear/russian
	name = "combat bear"
	desc = "A ferocious brown bear decked out in armor plating, a red star with yellow outlining details the shoulder plating."
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	faction = list(FACTION_RUSSIAN)
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/costume/bearpelt = 1, /obj/item/bear_armor = 1)
	melee_damage_lower = 18
	melee_damage_upper = 20
	wound_bonus = 0
	armour_penetration = 20
	health = 120
	maxHealth = 120
	gold_core_spawnable = HOSTILE_SPAWN
	armored = TRUE

/mob/living/basic/bear/butter //The mighty companion to Cak. Several functions used from it.
	name = "Terrygold"
	icon_state = "butterbear"
	icon_living = "butterbear"
	icon_dead = "butterbear_dead"
	desc = "I can't believe its not a bear!"
	faction = list(FACTION_NEUTRAL, FACTION_RUSSIAN)
	obj_damage = 11
	melee_damage_lower = 0
	melee_damage_upper = 0
	sharpness = NONE //it's made of butter
	armour_penetration = 0
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	death_message = "loses its false life and collapses!"
	butcher_results = list(/obj/item/food/butter = 6, /obj/item/food/meat/slab = 3, /obj/item/organ/internal/brain = 1, /obj/item/organ/internal/heart = 1)
	attack_sound = 'sound/weapons/slap.ogg'
	attack_vis_effect = ATTACK_EFFECT_DISARM
	attack_verb_simple = "slap"
	attack_verb_continuous = "slaps"
