/**
 * # Wumborian Fugu
 *
 * A strange alien creature capable of increasing its mass when threatened, giving it unmatched defensive capabilities with decent offensive capabilities.
 *
 * A mining mob currently unavailable outside of xenobiology, the wumborian fugu grows in size to take on attackers, an ability which renders it immune to all damage while it is in effect.
 * It will eventually deflate after growing, however, opening it up to attack while its power is on cooldown.  Killing the fugu grants access to its gland, which can be used to supersize most simplemobs
 * and give them a sizeable buff.
 */
/mob/living/simple_animal/hostile/asteroid/fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "Fugu0"
	icon_living = "Fugu0"
	icon_aggro = "Fugu0"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	health_doll_icon = "Fugu0"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 2
	friendly_verb_continuous = "floats near"
	friendly_verb_simple = "float near"
	speak_emote = list("puffs")
	vision_range = 5
	speed = 0
	maxHealth = 50
	health = 50
	pixel_x = -16
	base_pixel_x = -16
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	throw_message = "is avoided by the"
	aggro_vision_range = 9
	mob_size = MOB_SIZE_SMALL
	environment_smash = ENVIRONMENT_SMASH_NONE
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/item/fugu_gland{layer = ABOVE_MOB_LAYER})
	retreat_distance = 9
	///Whether or not the fugu is currently enlarged.
	var/wumbo = FALSE
	///The cooldown for the fugu's growth ability.
	var/inflate_cooldown = 0
	///How long the fugu's buffed form lasts.
	var/inflate_time = 10 SECONDS
	///How long it takes for the fugu to be able to grow again after shrinking.
	var/reinflation_time = 8 SECONDS

/mob/living/simple_animal/hostile/asteroid/fugu/Life(delta_time = SSMOBS_DT, times_fired)
	if(!wumbo && inflate_cooldown != 0)
		//delta time is in seconds, needs to be converted to deciseconds
		inflate_cooldown = max(inflate_cooldown - (10 * delta_time), 0)
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

/mob/living/simple_animal/hostile/asteroid/fugu/ranged_secondary_attack(atom/target, modifiers)
	Inflate()

/**
 * Inflates the fugu, making it invulnerable to attack and buffing its offensive and destructive capabilities.
 *
 * If the fugu is capable of going wumbo, it will do so.  This gives it invulnerability to damage, high object damage,
 * and offensive AI as opposed to its default evasive manuvers.  The fugu will deflate after 10 seconds.
 */
/mob/living/simple_animal/hostile/asteroid/fugu/proc/Inflate()
	if(wumbo)
		to_chat(src, "<span class='warning'>YOU'RE ALREADY WUMBO!</span>")
		return
	if(inflate_cooldown)
		to_chat(src, "<span class='warning'>You need time to gather your strength!</span>")
		return
	if(buffed)
		to_chat(src, "<span class='warning'>Something is interfering with your growth!</span>")
		return
	wumbo = TRUE
	icon_state = "Fugu1"
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	harm_intent_damage = 0
	throw_message = "is absorbed by the girth of the"
	retreat_distance = null
	minimum_distance = 1
	move_to_delay = 6
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mob_size = MOB_SIZE_LARGE
	set_varspeed(1)
	addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/asteroid/fugu/proc/Deflate), inflate_time)

/**
 * Deflates the fugu, resetting it to default state.
 *
 * Deflating the fugu undoes all the buffs inflating gives it, setting it back to normal.
 * This proc also sets the cooldown for the ability, which is by default 4 seconds.
 */
/mob/living/simple_animal/hostile/asteroid/fugu/proc/Deflate()
	if(!wumbo)
		return
	walk(src, 0)
	wumbo = FALSE
	icon_state = "Fugu0"
	obj_damage = initial(obj_damage)
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	harm_intent_damage = initial(harm_intent_damage)
	throw_message = initial(throw_message)
	retreat_distance = initial(retreat_distance)
	minimum_distance = initial(minimum_distance)
	move_to_delay = 2
	inflate_cooldown = reinflation_time
	environment_smash = initial(environment_smash)
	mob_size = initial(mob_size)
	set_varspeed(0)

/mob/living/simple_animal/hostile/asteroid/fugu/death(gibbed)
	Deflate()
	..(gibbed)

/**
 * # Fugu Gland
 *
 * A gland dropped by the wumborian fugu when killed.  Using it on a simplemob increases the mob's size, health, and strength.
 *
 * An item used to buff simplemobs by increasing their size, attack damage, and health.  It also gives them the ability to smash rwalls.
 * Buffing a simplemob in this manner renders it unable to be buffed again by any means.  Some mobs are notably immune to being affected
 * by the gland for balance concerns.
 */
/obj/item/fugu_gland
	name = "wumborian fugu gland"
	desc = "The key to the wumborian fugu's ability to increase its mass arbitrarily, this disgusting remnant can apply the same effect to other creatures, giving them great strength."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fugu_gland"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	///A list of all the mob types unable to use this item.
	var/list/banned_mobs

/obj/item/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !isanimal(target))
		return
	var/mob/living/simple_animal/animal_target = target
	if(animal_target.buffed || (animal_target.type in banned_mobs) || animal_target.stat)
		to_chat(user, "<span class='warning'>Something's interfering with [src]'s effects. It's no use.</span>")
		return
	animal_target.buffed++
	animal_target.maxHealth *= 1.5
	animal_target.health = min(animal_target.maxHealth, animal_target.health*1.5)
	animal_target.melee_damage_lower = max((animal_target.melee_damage_lower * 2), 10)
	animal_target.melee_damage_upper = max((animal_target.melee_damage_upper * 2), 10)
	animal_target.transform *= 2
	animal_target.environment_smash |= ENVIRONMENT_SMASH_STRUCTURES | ENVIRONMENT_SMASH_RWALLS
	to_chat(user, "<span class='info'>You increase the size of [animal_target], giving it a surge of strength!</span>")
	qdel(src)
