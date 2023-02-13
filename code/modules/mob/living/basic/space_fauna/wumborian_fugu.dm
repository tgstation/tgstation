/**
 * # Wumborian Fugu
 *
 * A strange alien creature capable of increasing its mass when threatened, when not inflated it is virtually defenceless.
 * Mostly only appears from xenobiology, or the occasional wizard.
 * On death, the "fugu gland" is dropped, which can be used on mobs to increase their size, health, strength, and lets them smash walls.
 */
/mob/living/basic/wumborian_fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/simple/lavaland/64x64megafauna.dmi'
	icon_state = "Fugu0"
	icon_living = "Fugu0"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	health_doll_icon = "Fugu0"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	move_to_delay = 5
	friendly_verb_continuous = "floats near"
	friendly_verb_simple = "float near"
	speak_emote = list("puffs")
	speed = 0
	maxHealth = 50
	health = 50
	pixel_x = -16
	base_pixel_x = -16
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("mining")
	status_flags = 0
	combat_mode = TRUE
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	loot = list(/obj/item/fugu_gland{layer = ABOVE_MOB_LAYER})
	var/datum/action/cooldown/expand/expand

/mob/living/basic/wumborian_fugu/Initialize(mapload)
	. = ..()
	expand = new(src)
	expand.Grant(src)
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, ROUNDSTART_TRAIT)

/mob/living/basic/wumborian_fugu/Destroy()
	QDEL_NULL(expand)
	return ..()

/**
 * Action which inflates you, making you larger and stronger for the duration.
 * This is pretty much all just handled by a status effect.
 */
/datum/action/cooldown/expand
	name = "Inflate"
	desc = "Temporarily increases your size, and makes you significantly more dangerous and tough!"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "expand"
	background_icon_state = "bg_fugu"
	overlay_icon_state = "bg_fugu_border"
	cooldown_time = 16 SECONDS

/datum/action/cooldown/expand/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	if(!istype(owner, /mob/living/basic/wumborian_fugu)) // A shame but there's not any good way to make this work on other mobs
		if (feedback)
			owner.balloon_alert(owner, "not stretchy enough!")
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_FUGU_GLANDED))
		if (feedback)
			owner.balloon_alert(owner, "ALREADY WUMBO!")
		return FALSE
	return TRUE

/datum/action/cooldown/expand/Activate(atom/target)
	. = ..()
	var/mob/living/living_owner = owner
	living_owner.apply_status_effect(/datum/status_effect/inflated)

/**
 * Status effect from the Expand action, makes you big and round and strong.
 */
/datum/status_effect/inflated
	id = "wumbo_inflated"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/inflated

/atom/movable/screen/alert/status_effect/inflated
	name = "WUMBO"
	desc = "You feel big and strong!"
	icon_state = "lobster" // TODO: replace

/datum/status_effect/inflated/on_creation(mob/living/new_owner, ...)
	if (!istype(new_owner, /mob/living/basic/wumborian_fugu))
		return FALSE
	return ..()

/datum/status_effect/inflated/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/inflated)
	ADD_TRAIT(owner, TRAIT_FUGU_GLANDED, TRAIT_STATUS_EFFECT(id))
	owner.AddElement(/datum/element/wall_smasher)
	owner.mob_size = MOB_SIZE_LARGE
	owner.icon_state = "Fugu1"
	owner.obj_damage = 60
	owner.melee_damage_lower = 15
	owner.melee_damage_upper = 20

/datum/status_effect/inflated/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/inflated)
	REMOVE_TRAIT(owner, TRAIT_FUGU_GLANDED, TRAIT_STATUS_EFFECT(id))
	if (!istype(owner, /mob/living/basic/wumborian_fugu))
		return
	owner.RemoveElement(/datum/element/wall_smasher)
	owner.mob_size = MOB_SIZE_SMALL
	owner.obj_damage = 0
	owner.melee_damage_lower = 0
	owner.melee_damage_upper = 0
	if (owner.stat != DEAD)
		owner.icon_state = "Fugu0"

/// Item you use on a mob to make it bigger and stronger
/obj/item/fugu_gland
	name = "wumborian fugu gland"
	desc = "The key to the wumborian fugu's ability to increase its mass arbitrarily, this disgusting remnant can apply the same effect to other creatures, giving them great strength."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "fugu_gland"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	/// List of mob types which you can't apply the gland to
	var/static/list/fugu_blacklist

/obj/item/fugu_gland/Initialize(mapload)
	. = ..()
	if(fugu_blacklist)
		return
	fugu_blacklist = typecacheof(list(
		/mob/living/simple_animal/hostile/guardian,
	))

/obj/item/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !isanimal_or_basicmob(target) || fugu_blacklist[target.type])
		return
	var/mob/living/animal = target

	if(animal.stat == DEAD || HAS_TRAIT(animal, TRAIT_FAKEDEATH))
		balloon_alert(user, "it's dead!")
		return
	if(HAS_TRAIT(animal, TRAIT_FUGU_GLANDED))
		balloon_alert(user, "already wumboed!")
		return

	ADD_TRAIT(animal, TRAIT_FUGU_GLANDED, type)
	animal.maxHealth *= 1.5
	animal.health = min(animal.maxHealth, animal.health * 1.5)
	animal.melee_damage_lower = max((animal.melee_damage_lower * 2), 10)
	animal.melee_damage_upper = max((animal.melee_damage_upper * 2), 10)
	animal.transform *= 2
	animal.AddElement(/datum/element/wall_smasher, strength_flag = ENVIRONMENT_SMASH_RWALLS)
	to_chat(user, span_info("You increase the size of [animal], giving [animal.p_them()] a surge of strength!"))
	qdel(src)
