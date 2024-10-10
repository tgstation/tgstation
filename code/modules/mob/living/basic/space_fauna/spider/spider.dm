/**
 * Base type of various spider life stages
 */
/mob/living/basic/spider
	name = "abstract spider"
	desc = "Furry and abstract, it makes you shudder to look at it. This one should not exist."
	icon = 'icons/mob/simple/arachnoid.dmi'
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	speak_emote = list("chitters")
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	initial_language_holder = /datum/language_holder/spider
	melee_attack_cooldown = CLICK_CD_MELEE
	damage_coeff = list(BRUTE = 1, BURN = 1.25, TOX = 1, STAMINA = 1, OXY = 1)
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = NONE
	unsuitable_cold_damage = 4
	unsuitable_heat_damage = 4
	combat_mode = TRUE
	faction = list(FACTION_SPIDER)
	pass_flags = PASSTABLE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	unique_name = TRUE
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	/// Speed modifier to apply if controlled by a human player
	var/player_speed_modifier = -4
	/// What reagent the mob injects targets with
	var/poison_type = /datum/reagent/toxin/hunterspider
	/// How much of a reagent the mob injects on attack
	var/poison_per_bite = 0
	/// How tough is our bite?
	var/bite_injection_flags = NONE
	/// Multiplier to apply to web laying speed. Fractional numbers make it faster, because it's a multiplier.
	var/web_speed = 1
	/// Type of webbing ability to learn.
	var/web_type = /datum/action/cooldown/mob_cooldown/lay_web
	/// The message that the mother spider left for this spider when the egg was layed.
	var/directive = ""
	/// Short description of what this mob is capable of, for radial menu uses
	var/menu_description = "Tanky and strong for the defense of the nest and other spiders."
	/// If true then you shouldn't be told that you're a spider antagonist as soon as you are placed into this mob
	var/apply_spider_antag = TRUE

/datum/emote/spider
	mob_type_allowed_typecache = /mob/living/basic/spider
	mob_type_blacklist_typecache = list()

/datum/emote/spider/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/insect/chitter.ogg'

/mob/living/basic/spider/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_WEB_SURFER, TRAIT_FENCE_CLIMBER), INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "this tastes awful!")
	AddElement(/datum/element/cliff_walking)
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 1.5)

	if(poison_per_bite)
		AddElement(/datum/element/venomous, poison_type, poison_per_bite, injection_flags = bite_injection_flags)

	var/datum/action/cooldown/mob_cooldown/lay_web/webbing = new web_type(src)
	webbing.webbing_time *= web_speed
	webbing.Grant(src)
	ai_controller?.set_blackboard_key(BB_SPIDER_WEB_ACTION, webbing)

/mob/living/basic/spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	GLOB.spidermobs[src] = TRUE
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier, multiplicative_slowdown = player_speed_modifier)

/mob/living/basic/spider/Logout()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier)

/mob/living/basic/spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/basic/spider/mob_negates_gravity()
	if(locate(/obj/structure/spider/stickyweb) in loc)
		return TRUE
	return ..()

/mob/living/basic/spider/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE)
	. = ..()
	for(var/datum/reagent/toxin/pestkiller/current_reagent in reagents)
		apply_damage(50 * volume_modifier, STAMINA, BODY_ZONE_CHEST)

/// Spider which turns into another spider over time
/mob/living/basic/spider/growing
	/// The mob type we will grow into.
	var/mob/living/basic/spider/grow_as = null
	/// The time it takes for the spider to grow into the next stage
	var/spider_growth_time = 1 MINUTES

/mob/living/basic/spider/growing/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = spider_growth_time,\
		growth_path = grow_as,\
		growth_probability = 25,\
		lower_growth_value = 1,\
		upper_growth_value = 2,\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(grow_up))\
	)

/**
 * Checks to see if we're ready to grow, primarily if we are on solid ground and not in a vent or something.
 * The component will automagically grow us when we return TRUE and that threshold has been met.
 */
/mob/living/basic/spider/growing/proc/ready_to_grow()
	if(isturf(loc))
		return TRUE

	return FALSE

/// Actually grows the young spider into a giant spider. We have to do a bunch of unique behavior that really can't be genericized, so we have to override the component in this manner.
/**
 * Actually move to our next stage of life.
 */
/mob/living/basic/spider/growing/proc/grow_up()
	if(isnull(grow_as))
		if(prob(3))
			grow_as = pick(/mob/living/basic/spider/giant/tarantula, /mob/living/basic/spider/giant/viper, /mob/living/basic/spider/giant/midwife)
		else
			grow_as = pick(/mob/living/basic/spider/giant/guard, /mob/living/basic/spider/giant/ambush, /mob/living/basic/spider/giant/hunter, /mob/living/basic/spider/giant/scout, /mob/living/basic/spider/giant/nurse, /mob/living/basic/spider/giant/tangle)

	var/mob/living/basic/spider/giant/grown = change_mob_type(grow_as, get_turf(src), initial(grow_as.name))
	ADD_TRAIT(grown, TRAIT_WAS_EVOLVED, REF(src))
	grown.faction = faction.Copy()
	grown.directive = directive
	grown.set_name()
	grown.setBruteLoss(getBruteLoss())
	grown.setFireLoss(getFireLoss())
	qdel(src)

/**
 * ### Duct Spider
 * A less than giant spider which lives in the maintenance ducts and makes them annoying to traverse.
 */
/mob/living/basic/spider/maintenance
	name = "duct spider"
	desc = "Nanotrasen's imported solution to mice, comes with its own problems."
	icon_state = "maint_spider"
	icon_living = "maint_spider"
	icon_dead = "maint_spider_dead"
	can_be_held = TRUE
	mob_size = MOB_SIZE_TINY
	held_w_class = WEIGHT_CLASS_TINY
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'
	density = FALSE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	gold_core_spawnable = FRIENDLY_SPAWN
	maxHealth = 10
	health = 10
	melee_damage_lower = 1
	melee_damage_upper = 1
	speed = 0
	player_speed_modifier = 0
	web_speed = 0.25
	menu_description = "Fragile spider variant which is not good for much other than laying webs."
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	ai_controller = /datum/ai_controller/basic_controller/giant_spider/pest
	apply_spider_antag = FALSE
	///list of pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/perform_trick_sequence,
	)

/mob/living/basic/spider/maintenance/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/average_web)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddElement(/datum/element/tiny_mob_hunter)
