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
	speed = -1
	maxHealth = 130
	health = 130
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	rapid_melee = 2 // every second attack
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	vision_range = 7
	aggro_vision_range = 7
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/corgi = 1)
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	var/retreat_message_said = FALSE

/mob/living/simple_animal/hostile/asteroid/wolf/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/wolf/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health <= maxHealth*0.1)
		if(!retreat_message_said && target)
			visible_message("<span class='danger'>The [name] tries to flee from [target]!</span>")
			retreat_message_said = TRUE
		retreat_distance = 30
	else
		retreat_distance = initial(retreat_distance)

/mob/living/simple_animal/hostile/asteroid/wolf/Life()
	. = ..()
	if(target == null)
		adjustHealth(-maxHealth*0.025)
		retreat_message_said = FALSE
