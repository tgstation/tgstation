/mob/living/simple_animal/hostile/asteroid/wolf
	name = "white wolf"
	desc = "A beast that survives by feasting on weaker opponents, they're much stronger with numbers."
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	icon_state = "whitewolf"
	icon_living = "whitewolf"
	icon_dead = "whitewolf_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "howls at"
	friendly_verb_simple = "howl at"
	speak_emote = list("howls")
	speed = 5
	move_to_delay = 5
	maxHealth = 130
	health = 130
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	rapid_melee = 2 // every second attack
	dodging = TRUE
	dodge_prob = 50
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	vision_range = 7
	aggro_vision_range = 7
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/item/stack/sheet/sinew/wolf = 2, /obj/item/stack/sheet/bone = 2)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	stat_attack = HARD_CRIT
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	/// Message for when the wolf decides to start running away
	var/retreat_message_said = FALSE

/mob/living/simple_animal/hostile/asteroid/wolf/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/wolf/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(stat == DEAD || health > maxHealth*0.1)
		retreat_distance = initial(retreat_distance)
		return
	if(!retreat_message_said && target)
		visible_message("<span class='danger'>The [name] tries to flee from [target]!</span>")
		retreat_message_said = TRUE
	retreat_distance = 30

/mob/living/simple_animal/hostile/asteroid/wolf/Life()
	. = ..()
	if(!. || target)
		return
	adjustHealth(-maxHealth*0.025)
	retreat_message_said = FALSE
