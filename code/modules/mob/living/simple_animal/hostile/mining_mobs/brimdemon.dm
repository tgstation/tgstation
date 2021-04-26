/mob/living/simple_animal/hostile/asteroid/brimdemon
	name = "brimdemon"
	desc = "A beast from demonic realms. Fires a blood laser barrage."
	icon = 'icons/mob/brimdemon.dmi'
	icon_state = "brimdemon"
	icon_living = "brimdemon"
	icon_dead = "brimdemon_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	combat_mode = TRUE
	ranged = TRUE
	ranged_cooldown_time = 7.5 SECONDS
	speed = 5
	move_to_delay = 5
	maxHealth = 200
	health = 200
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	rapid_melee = 2 // every second attack
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(/obj/item/food/meat/slab = 2)
	loot = list()
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	deathmessage = "screams in agony as it sublimates into a sulfurous smoke."
	deathsound = 'sound/magic/demon_dies.ogg'
	/// Are we charging/firing? If yes stops our movement.
	var/firing = FALSE

/mob/living/simple_animal/hostile/asteroid/brimdemon/OpenFire()
	if(firing)
		to_chat(src, "<span class='notice'>You are already firing!</span>")
	firing = TRUE
	visible_message("<span class='danger'>[src] starts charging!</span>")
	icon_state = "brimdemon_firing"
	addtimer(CALLBACK(src, .proc/fire_laser), 1.6 SECONDS)

/mob/living/simple_animal/hostile/asteroid/brimdemon/death()
	firing = FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Goto(target, delay, minimum_distance)
	if(!firing)
		..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/MoveToTarget(list/possible_targets)
	if(!firing)
		..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/proc/fire_laser()
	return
