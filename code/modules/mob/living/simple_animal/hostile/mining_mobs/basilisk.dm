//A beast that fire freezing blasts.
/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	ranged_cooldown_time = 30
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = INTENT_HARM
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	aggro_vision_range = 9
	idle_vision_range = 2
	turns_per_move = 5
	loot = list(/obj/item/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/ore/diamond{layer = ABOVE_MOB_LAYER})

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)//No more being shot at point blank or spammed with RNG beams
			OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
		if(2)
			adjustBruteLoss(140)
		if(3)
			adjustBruteLoss(110)

//Watcher
/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	pixel_x = -10
	throw_message = "bounces harmlessly off of"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "impales"
	a_intent = INTENT_HARM
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	stat_attack = UNCONSCIOUS
	movement_type = FLYING
	robust_searching = 1
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	loot = list()
	butcher_results = list(/obj/item/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/make_shiny()
	if(prob(75))
		name = "magmawing watcher"
		real_name = name
		desc = "When raised very close to lava, some watchers adapt to the extreme heat and change coloration. Such watchers are known as magmawings and use intense heat as their tool for hunting and defense."
		icon_state = "watcher_magmawing"
		icon_living = "watcher_magmawing"
		icon_aggro = "watcher_magmawing"
		icon_dead = "watcher_magmawing_dead"
		maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
		health = 215
		projectiletype = /obj/item/projectile/temp/basilisk/magmawing
	else
		name = "icewing watcher"
		real_name = name
		desc = "Very rarely, some watchers will eke out an existence far from heat sources. In the absence of warmth, their wings will become papery and turn to an icy blue; these watchers are fragile but much quicker to fire their trademark freezing blasts."
		icon_state = "watcher_icewing"
		icon_living = "watcher_icewing"
		icon_aggro = "watcher_icewing"
		icon_dead = "watcher_icewing_dead"
		maxHealth = 150
		health = 150
		ranged_cooldown_time = 20
		butcher_results = list(/obj/item/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable

/obj/item/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	icon_state = "gaussstrong"
	temperature = 500 //Heats you up!

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	fromtendril = TRUE
