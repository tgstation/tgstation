/mob/living/basic/pony
	name = "pony"
	desc = "Look at my horse, my horse is amazing!"
	icon_state = "pony"
	icon_living = "pony"
	icon_dead = "pony_dead"
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("neighs", "winnies")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	melee_damage_lower = 5
	melee_damage_upper = 10
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/pony
	/// Do we register a unique rider?
	var/unique_tamer = FALSE
	/// The person we've been tamed by
	var/datum/weakref/my_owner

	greyscale_config = /datum/greyscale_config/pony
	/// Greyscale color config; 1st color is body, 2nd is mane
	var/list/ponycolors = list("#cc8c5d", "#cc8c5d")

/mob/living/basic/pony/Initialize(mapload)
	. = ..()

	apply_colour()
	AddElement(/datum/element/pet_bonus, "whickers.")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/waddling)
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/apple), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, PROC_REF(tamed)), unique = unique_tamer)

/mob/living/basic/pony/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	playsound(src, 'sound/creatures/pony/snort.ogg', 50)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/pony)
	visible_message(span_notice("[src] snorts happily."))
	new /obj/effect/temp_visual/heart(loc)

	ai_controller.replace_planning_subtrees(list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/pony/tamed
	))

	if(unique_tamer)
		my_owner = WEAKREF(tamer)
		RegisterSignal(src, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_prebuckle))

/mob/living/basic/pony/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_PREBUCKLE)
	my_owner = null
	return ..()

/// Only let us get ridden if the buckler is our owner, if we have a unique owner.
/mob/living/basic/pony/proc/on_prebuckle(mob/source, mob/living/buckler, force, buckle_mob_flags)
	SIGNAL_HANDLER
	var/mob/living/tamer = my_owner?.resolve()
	if(!unique_tamer || (isnull(tamer) && unique_tamer))
		return
	if(buckler != tamer)
		whinny_angrily()
		return COMPONENT_BLOCK_BUCKLE

/mob/living/basic/pony/proc/apply_colour()
	if(!greyscale_config)
		return
	set_greyscale(colors = ponycolors)

/mob/living/basic/pony/proc/whinny_angrily()
	manual_emote("whinnies ANGRILY!")

	playsound(src, pick(list(
		'sound/creatures/pony/whinny01.ogg',
		'sound/creatures/pony/whinny02.ogg',
		'sound/creatures/pony/whinny03.ogg'
	)), 50)

/mob/living/basic/pony/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	if (prob(33))
		whinny_angrily()

/mob/living/basic/pony/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()

	if (!.)
		return

	whinny_angrily()

/datum/ai_controller/basic_controller/pony
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/pony
	)

// A stronger horse is required for our strongest cowboys.
/mob/living/basic/pony/syndicate
	health = 300
	maxHealth = 300
	desc = "A special breed of horse engineered by the syndicate to be capable of surviving in the deep reaches of space. A modern outlaw's best friend."
	faction = list(ROLE_SYNDICATE)
	ponycolors = list("#5d566f", COLOR_RED)
	pressure_resistance = 200
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	unique_tamer = TRUE

/mob/living/basic/pony/syndicate/Initialize(mapload)
	. = ..()
	// Help discern your horse from your allies
	var/mane_colors = list(
		COLOR_RED=6,
		COLOR_BLUE=6,
		COLOR_PINK=3,
		COLOR_GREEN=3,
		COLOR_BLACK=3,
		COLOR_YELLOW=2,
		COLOR_ORANGE=1,
		COLOR_WHITE=1,
		COLOR_DARK_BROWN=1,
	)
	ponycolors = list("#5d566f", pick_weight(mane_colors))
	name = pick("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
	// Only one person can tame these fellas, and they only need one apple
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/apple), tame_chance = 100, bonus_tame_chance = 15, after_tame = CALLBACK(src, PROC_REF(tamed)), unique = unique_tamer)
