/// Slow moving mob which attempts to immobilise its target
/mob/living/basic/mining/goliath
	name = "goliath"
	desc = "A hulking, armor-plated beast with long tendrils arching from its back."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_dead = "goliath_dead"
	// icon_aggro = "goliath"
	// pre_attack_icon = "goliath_preattack"
	pixel_x = -12
	base_pixel_x = -12
	gender = MALE
	basic_mob_flags = IMMUNE_TO_FISTS
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speed = 3
	maxHealth = 300
	health = 300
	friendly_verb_continuous = "wails at"
	friendly_verb_simple = "wail at"
	speak_emote = list("bellows")
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_verb_continuous = "pulverizes"
	attack_verb_simple = "pulverize"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	butcher_results = list(/obj/item/food/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)

/mob/living/basic/mining/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
