//A beast that petrifies anyone who looks directly at it.
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
	ranged = 1
	ranged_message = "begins to stare intensely at"
	ranged_cooldown_time = 75
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
	loot = list(/obj/item/weapon/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/weapon/ore/diamond{layer = ABOVE_MOB_LAYER})
	var/gaze_sound = 'sound/magic/magic_missile.ogg'

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

/mob/living/simple_animal/hostile/asteroid/basilisk/OpenFire()
	Gaze()
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/basilisk/proc/Gaze()
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(L.has_status_effect(STATUS_EFFECT_PETRIFICATION) || L.incapacitated())
		return
	visible_message("<span class='warning'>[src] [ranged_message] [target]</span>")
	to_chat(L, "<span class='boldannounce'>Your body starts to lock up as you look at [src]!</span>")
	if(gaze_sound)
		playsound(src, gaze_sound, 75, FALSE)
	L.apply_status_effect(STATUS_EFFECT_PETRIFICATION, src)

//Watcher
/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	ranged_message = "rapidly waves its wings in an entrancing pattern at"
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
	butcher_results = list(/obj/item/weapon/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)
	gaze_sound = 'sound/magic/tail_swing.ogg'

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	fromtendril = TRUE
