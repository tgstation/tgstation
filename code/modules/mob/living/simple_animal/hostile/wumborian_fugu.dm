//A fragile mob that becomes temporarily invincible and large to attack
/mob/living/simple_animal/hostile/asteroid/fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Fugu"
	icon_living = "Fugu"
	icon_aggro = "Fugu"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 5
	friendly = "floats near"
	speak_emote = list("puffs")
	vision_range = 5
	speed = 0
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "chomps"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "is avoided by the"
	aggro_vision_range = 9
	idle_vision_range = 5
	mob_size = MOB_SIZE_SMALL
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/wumbo = 0
	var/inflate_cooldown = 0
	loot = list(/obj/item/asteroid/fugu_gland{layer = ABOVE_MOB_LAYER})

/mob/living/simple_animal/hostile/asteroid/fugu/Life()
	if(!wumbo)
		inflate_cooldown = max((inflate_cooldown - 1), 0)
	if(target && AIStatus == AI_ON)
		Inflate()
	..()

/mob/living/simple_animal/hostile/asteroid/fugu/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && wumbo)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/asteroid/fugu/Aggro()
	..()
	Inflate()

/mob/living/simple_animal/hostile/asteroid/fugu/verb/Inflate()
	set name = "Inflate"
	set category = "Fugu"
	set desc = "Temporarily increases your size, and makes you significantly more dangerous and tough."
	if(wumbo)
		to_chat(src, "<span class='notice'>You're already inflated.</span>")
		return
	if(inflate_cooldown)
		to_chat(src, "<span class='notice'>We need time to gather our strength.</span>")
		return
	if(buffed)
		to_chat(src, "<span class='notice'>Something is interfering with our growth.</span>")
		return
	wumbo = 1
	icon_state = "Fugu_big"
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	harm_intent_damage = 0
	throw_message = "is absorbed by the girth of the"
	retreat_distance = null
	minimum_distance = 1
	move_to_delay = 6
	transform *= 2
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mob_size = MOB_SIZE_LARGE
	speed = 1
	addtimer(CALLBACK(src, .proc/Deflate), 100)

/mob/living/simple_animal/hostile/asteroid/fugu/proc/Deflate()
	if(wumbo)
		walk(src, 0)
		wumbo = 0
		icon_state = "Fugu"
		obj_damage = 0
		melee_damage_lower = 0
		melee_damage_upper = 0
		harm_intent_damage = 5
		throw_message = "is avoided by the"
		retreat_distance = 9
		minimum_distance = 9
		move_to_delay = 2
		transform /= 2
		inflate_cooldown = 4
		environment_smash = ENVIRONMENT_SMASH_NONE
		mob_size = MOB_SIZE_SMALL
		speed = 0

/mob/living/simple_animal/hostile/asteroid/fugu/death(gibbed)
	Deflate()
	..(gibbed)

/obj/item/asteroid/fugu_gland
	name = "wumborian fugu gland"
	desc = "The key to the wumborian fugu's ability to increase its mass arbitrarily, this disgusting remnant can apply the same effect to other creatures, giving them great strength."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fugu_gland"
	flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	origin_tech = "biotech=6"
	var/list/banned_mobs()

/obj/item/asteroid/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && isanimal(target))
		var/mob/living/simple_animal/A = target
		if(A.buffed || (A.type in banned_mobs) || A.stat)
			to_chat(user, "<span class='warning'>Something's interfering with the [src]'s effects. It's no use.</span>")
			return
		A.buffed++
		A.maxHealth *= 1.5
		A.health = min(A.maxHealth,A.health*1.5)
		A.melee_damage_lower = max((A.melee_damage_lower * 2), 10)
		A.melee_damage_upper = max((A.melee_damage_upper * 2), 10)
		A.transform *= 2
		A.environment_smash += 2
		to_chat(user, "<span class='info'>You increase the size of [A], giving it a surge of strength!</span>")
		qdel(src)
