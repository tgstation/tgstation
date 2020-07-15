/mob/living/simple_animal/hostile/asteroid/lobstrosity
	name = "lobstrosity"
	desc = "A marvel of evolution gone wrong, the frosty ice produces underground lakes where these ill tempered seafood gather. Beware its charge."
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	icon_state = "lobstrosity"
	icon_living = "lobstrosity"
	icon_dead = "lobstrosity_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "chitters at"
	friendly_verb_simple = "chits at"
	speak_emote = list("clatters")
	speed = 6
	move_to_delay = 6
	maxHealth = 100
	health = 100
	obj_damage = 15
	melee_damage_lower = 10
	melee_damage_upper = 12
	attack_verb_continuous = "snips"
	attack_verb_simple = "snip"
	attack_sound = 'sound/weapons/bite.ogg'
	vision_range = 5
	aggro_vision_range = 7
	charger = TRUE
	charger_speed = 2

	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/crab = 2, /obj/item/stack/sheet/bone = 2)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
