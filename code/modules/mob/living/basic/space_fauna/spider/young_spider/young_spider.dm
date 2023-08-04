/**
 * # Young Spider
 *
 * A mob which can be created by spiderlings/spider eggs.
 * The basic type is the guard, which is slow but sturdy and outputs good damage.
 * All spiders can produce webbing.
 */
/mob/living/basic/young_spider
	name = "young spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_guard"
	icon_living = "young_guard"
	icon_dead = "young_guard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	speak_emote = list("chitters")
	butcher_results = list(/obj/item/food/meat/slab/spider = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	initial_language_holder = /datum/language_holder/spider
	speed = 1
	maxHealth = 60
	health = 60
	damage_coeff = list(BRUTE = 1, BURN = 1.25, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 1)
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = NONE
	unsuitable_cold_damage = 4
	unsuitable_heat_damage = 4
	obj_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 12
	combat_mode = TRUE
	faction = list(FACTION_SPIDER)
	pass_flags = PASSTABLE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	unique_name = TRUE
	// VERY red, to fit the eyes
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	ai_controller = /datum/ai_controller/basic_controller/young_spider
	/// The mob we will grow into.
	var/mob/living/basic/giant_spider/grow_as = null
	/// Speed modifier to apply if controlled by a human player
	var/player_speed_modifier = -1
	/// What reagent the mob injects targets with
	var/poison_type = /datum/reagent/toxin/hunterspider
	/// How much of a reagent the mob injects on attack
	var/poison_per_bite = 0
	/// Multiplier to apply to web laying speed. Fractional numbers make it faster, because it's a multiplier.
	var/web_speed = 1
	/// Type of webbing ability to learn.
	var/web_type = /datum/action/cooldown/lay_web
	/// The message that the mother spider left for this spider when the egg was layed.
	var/directive = ""
	/// Short description of what this mob is capable of, for radial menu uses
	var/menu_description = "Tanky and strong for the defense of the nest and other spiders."
	/// If true then you shouldn't be told that you're a spider antagonist as soon as you are placed into this mob
	var/apply_spider_antag = TRUE
	/// The time it takes for the spider to grow into the next stage
	var/spider_growth_time = 1 MINUTES

/mob/living/basic/young_spider/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEB_SURFER, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "this tastes awful!")
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/young_web)

	if(poison_per_bite)
		AddElement(/datum/element/venomous, poison_type, poison_per_bite)

	var/datum/action/cooldown/lay_web/webbing = new web_type(src)
	webbing.webbing_time *= web_speed
	webbing.Grant(src)
	ai_controller.set_blackboard_key(BB_SPIDER_WEB_ACTION, webbing)
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = spider_growth_time,\
		growth_path = grow_as,\
		growth_probability = 25,\
		lower_growth_value = 1,\
		upper_growth_value = 2,\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(grow_into_giant_spider))\
	)

/mob/living/basic/young_spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	GLOB.spidermobs[src] = TRUE
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier, multiplicative_slowdown = player_speed_modifier)
	if (apply_spider_antag)
		var/datum/antagonist/spider/spider_antag = new(directive)
		mind.add_antag_datum(spider_antag)

/mob/living/basic/young_spider/Logout()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier)

/mob/living/basic/young_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/basic/young_spider/mob_negates_gravity()
	if(locate(/obj/structure/spider/stickyweb) in loc)
		return TRUE
	return ..()

/mob/living/basic/young_spider/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE)
	. = ..()
	for(var/datum/reagent/toxin/pestkiller/current_reagent in reagents)
		apply_damage(50 * volume_modifier, STAMINA, BODY_ZONE_CHEST)

/// Checks to see if we're ready to grow, primarily if we are on solid ground and not in a vent or something.
/// The component will automagically grow us when we return TRUE and that threshold has been met.
/mob/living/basic/young_spider/proc/ready_to_grow()
	if(isturf(loc))
		return TRUE

	return FALSE

/// Actually grows the young spider into a giant spider. We have to do a bunch of unique behavior that really can't be genericized, so we have to override the component in this manner.
/mob/living/basic/young_spider/proc/grow_into_giant_spider()
	if(isnull(grow_as))
		if(prob(3))
			grow_as = pick(/mob/living/basic/giant_spider/tarantula, /mob/living/basic/giant_spider/viper, /mob/living/basic/giant_spider/midwife)
		else
			grow_as = pick(/mob/living/basic/giant_spider/guard, /mob/living/basic/giant_spider/ambush, /mob/living/basic/giant_spider/hunter, /mob/living/basic/giant_spider/scout, /mob/living/basic/giant_spider/nurse, /mob/living/basic/giant_spider/tangle)

	var/mob/living/basic/giant_spider/grown = change_mob_type(grow_as, get_turf(src), initial(grow_as.name))
	ADD_TRAIT(grown, TRAIT_WAS_EVOLVED, REF(src))
	grown.faction = faction.Copy()
	grown.directive = directive
	grown.set_name()
	if(getBruteLoss() - 5 > 0)
		grown.setBruteLoss(getBruteLoss() - 5)
	if(getFireLoss() - 5 > 0)
		grown.setFireLoss(getFireLoss() - 5)

	qdel(src)

/// Used by all young spiders if they ever appear.
/datum/ai_controller/basic_controller/young_spider
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/spin_web,
	)

/datum/ai_behavior/run_away_from_target/young_spider
	run_distance = 6
