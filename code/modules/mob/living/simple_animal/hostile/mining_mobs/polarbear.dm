/mob/living/simple_animal/hostile/asteroid/polarbear
	name = "polar bear"
	desc = "An aggressive animal that defends its territory with incredible power. These beasts don't run from their enemies."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "growls at"
	friendly_verb_simple = "growl at"
	speak_emote = list("growls")
	speed = 3
	move_to_delay = 8
	maxHealth = 300
	health = 300
	obj_damage = 40
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	vision_range = 2 // don't aggro unless you basically antagonize it, though they will kill you worse than a goliath will
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/food/meat/slab/bear = 3, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide = 1)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/bear_paw
	stat_attack = HARD_CRIT
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	/// Message for when the polar bear starts to attack faster
	var/aggressive_message_said = FALSE

/mob/living/simple_animal/hostile/asteroid/polarbear/Initialize(mapload)
	. = ..()
	AddElement(\
		/datum/element/change_force_on_death,\
		move_force = MOVE_FORCE_DEFAULT,\
		move_resist = MOVE_RESIST_DEFAULT,\
		pull_force = PULL_FORCE_DEFAULT,\
	)

/mob/living/simple_animal/hostile/asteroid/polarbear/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health > maxHealth*0.5)
		rapid_melee = initial(rapid_melee)
		return
	if(!aggressive_message_said && target)
		visible_message(span_danger("\The [src] gets an enraged look at [target]!"))
		aggressive_message_said = TRUE
	rapid_melee = 2

/mob/living/simple_animal/hostile/asteroid/polarbear/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(!. || target)
		return
	aggressive_message_said = FALSE

/mob/living/simple_animal/hostile/asteroid/polarbear/lesser
	name = "magic polar bear"
	desc = "It seems sentient somehow."
	faction = list(FACTION_NEUTRAL)
