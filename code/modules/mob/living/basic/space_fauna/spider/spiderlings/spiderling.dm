/**
 * # Spiderlings
 *
 * Baby spiders that are generated through a variety of means (like botany for instance).
 * Able to vent-crawl and eventually grow into a full fledged giant spider.
 *
 */
/mob/living/basic/spider/growing/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	icon_dead = "spiderling_dead"
	density = FALSE
	speed = -0.75
	move_resist = INFINITY // YOU CAN'T HANDLE ME LET ME BE FREE LET ME BE FREE LET ME BE FREE
	speak_emote = list("hisses")
	initial_language_holder = /datum/language_holder/spider
	basic_mob_flags = FLAMMABLE_MOB | DEL_ON_DEATH
	mob_size = MOB_SIZE_TINY
	melee_damage_lower = 1
	melee_damage_upper = 2
	health = 5
	maxHealth = 5
	death_message = "lets out a final hiss..."
	player_speed_modifier = 0
	spider_growth_time = 40 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/spiderling

/mob/living/basic/spider/growing/spiderling/Initialize(mapload)
	. = ..()
	// random placement since we're pretty small and to make the swarming component actually look like it's doing something when we have a buncha these fuckers
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)

	add_overlay(image(icon = src.icon, icon_state = "spiderling_click_underlay", layer = BELOW_MOB_LAYER))

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW, volume = 0.2) // they're small but you can hear 'em
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/spiderling_web)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/fast_web)

	// keep in mind we have infinite range (the entire pipenet is our playground, it's just a matter of random choice as to where we end up) so lower and upper both have their gives and takes.
	// but, also remember the more time we aren't in a vent, the more susceptible we are to dying to anything and everything.
	// also remember we can't evolve if we're in a vent. lots to keep in mind when you set these variables.
	ai_controller.set_blackboard_key(BB_LOWER_VENT_TIME_LIMIT, rand(9, 11) SECONDS)
	ai_controller.set_blackboard_key(BB_UPPER_VENT_TIME_LIMIT, rand(12, 14) SECONDS)

/mob/living/basic/spider/growing/spiderling/death(gibbed)
	if(isturf(get_turf(loc)) && (basic_mob_flags & DEL_ON_DEATH || gibbed))
		var/obj/item/food/spiderling/dead_spider = new(loc) // mmm yummy
		dead_spider.name = name
		dead_spider.icon_state = icon_dead

	return ..()

/mob/living/basic/spider/growing/spiderling/start_pulling(atom/movable/pulled_atom, state, force = move_force, supress_message = FALSE) // we're TOO FUCKING SMALL
	return

/// Opportunistically hops in and out of vents, if it can find one. We aren't interested in attacking due to how weak we are, we gotta be quick and hidey.
/datum/ai_controller/basic_controller/spiderling
	blackboard = list(
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/larger, // Run away from mobs bigger than we are
		BB_VENTCRAWL_COOLDOWN = 20 SECONDS, // enough time to get splatted while we're out in the open.
		BB_TIME_TO_GIVE_UP_ON_VENT_PATHING = 30 SECONDS,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	// We understand that vents are nice little hidey holes through epigenetic inheritance, so we'll use them.
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/opportunistic_ventcrawler,
		/datum/ai_planning_subtree/random_speech/insect,
	)
