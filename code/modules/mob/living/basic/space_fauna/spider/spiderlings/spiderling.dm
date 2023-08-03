/**
 * # Spiderlings
 *
 * Baby spiders that are generated through a variety of means (like botany for instance).
 * Able to vent-crawl and eventually grow into a full fledged giant spider.
 *
 */
/mob/living/basic/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "spiderling"
	icon_dead = "spiderling_dead"
	density = FALSE
	faction = list(FACTION_SPIDER)
	speed = -0.75
	move_resist = INFINITY // YOU CAN'T HANDLE ME LET ME BE FREE LET ME BE FREE LET ME BE FREE
	speak_emote = list("hisses")
	initial_language_holder = /datum/language_holder/spider
	basic_mob_flags = FLAMMABLE_MOB | DEL_ON_DEATH
	mob_size = MOB_SIZE_TINY

	unique_name = TRUE

	// we have _some_ bite
	melee_damage_lower = 1
	melee_damage_upper = 2

	health = 5 // very low.
	maxHealth = 5
	unsuitable_cold_damage = 4
	unsuitable_heat_damage = 4
	death_message = "lets out a final hiss..."

	ai_controller = /datum/ai_controller/basic_controller/spiderling

	// VERY red, to fit the eyes
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5

	/// The mob we will grow into.
	var/mob/living/basic/young_spider/grow_as = null
	/// The message that the mother left for our big strong selves.
	var/directive = ""
	/// Simple boolean that determines if we should apply the spider antag to the player if they possess this mob. TRUE by default since we're always going to evolve into a spider that will have an antagonistic role.
	var/apply_spider_antag = TRUE
	/// The time it takes for the spider to grow into the next stage
	var/spider_growth_time = 40 SECONDS

/mob/living/basic/spiderling/Initialize(mapload)
	. = ..()
	// random placement since we're pretty small and to make the swarming component actually look like it's doing something when we have a buncha these fuckers
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)

	add_overlay(image(icon = src.icon, icon_state = "spiderling_click_underlay", layer = BELOW_MOB_LAYER))

	// the proc that handles passtable is nice but we should always be able to pass through table since we're so small so we can eschew adding that here
	pass_flags |= PASSTABLE
	add_traits(list(TRAIT_PASSTABLE, TRAIT_VENTCRAWLER_ALWAYS, TRAIT_WEB_SURFER), INNATE_TRAIT)
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW, volume = 0.2) // they're small but you can hear 'em
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/spiderling_web)

	// it's A-OKAY for grow_as to be null for the purposes of this component since we override that behavior anyhow.
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = spider_growth_time,\
		growth_path = grow_as,\
		growth_probability = 25,\
		lower_growth_value = 1,\
		upper_growth_value = 2,\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(grow_into_young_spider))\
	)

	// keep in mind we have infinite range (the entire pipenet is our playground, it's just a matter of random choice as to where we end up) so lower and upper both have their gives and takes.
	// but, also remember the more time we aren't in a vent, the more susceptible we are to dying to anything and everything.
	// also remember we can't evolve if we're in a vent. lots to keep in mind when you set these variables.
	ai_controller.set_blackboard_key(BB_LOWER_VENT_TIME_LIMIT, rand(9, 11) SECONDS)
	ai_controller.set_blackboard_key(BB_UPPER_VENT_TIME_LIMIT, rand(12, 14) SECONDS)

/mob/living/basic/spiderling/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/basic/spiderling/death(gibbed)
	if(isturf(get_turf(loc)) && (basic_mob_flags & DEL_ON_DEATH || gibbed))
		var/obj/item/food/spiderling/dead_spider = new(loc) // mmm yummy
		dead_spider.name = name
		dead_spider.icon_state = icon_dead

	return ..()

/mob/living/basic/spiderling/Login() // this is only really here for admins dragging and dropping players into spiderlings, player control of spiderlings is otherwise unimplemented
	. = ..()
	if(!. || isnull(client))
		return FALSE
	basic_mob_flags &= ~DEL_ON_DEATH // we don't want to be deleted if we die while player controlled in case there's some revive schenanigans going on that can bring us back
	GLOB.spidermobs[src] = TRUE
	if (apply_spider_antag)
		var/datum/antagonist/spider/spider_antag = new(directive)
		mind.add_antag_datum(spider_antag)

/mob/living/basic/spiderling/mob_negates_gravity() // in case our sisters want to give us a helping hand
	if(locate(/obj/structure/spider/stickyweb) in loc)
		return TRUE
	return ..()

/mob/living/basic/spiderling/start_pulling(atom/movable/pulled_atom, state, force = move_force, supress_message = FALSE) // we're TOO FUCKING SMALL
	return

/// Checks to see if we're ready to grow, primarily if we are on solid ground and not in a vent or something.
/// The component will automagically grow us when we return TRUE and that threshold has been met.
/mob/living/basic/spiderling/proc/ready_to_grow()
	if(isturf(loc))
		return TRUE

	return FALSE

/// Actually grows the spiderling into a young spider. We have to do a bunch of unique behavior that really can't be genericized, so we have to override the component in this manner.
/mob/living/basic/spiderling/proc/grow_into_young_spider()
	if(isnull(grow_as))
		if(prob(3))
			grow_as = pick(/mob/living/basic/young_spider/tarantula, /mob/living/basic/young_spider/viper, /mob/living/basic/young_spider/midwife)
		else
			grow_as = pick(/mob/living/basic/young_spider/guard, /mob/living/basic/young_spider/ambush, /mob/living/basic/young_spider/hunter, /mob/living/basic/young_spider/scout, /mob/living/basic/young_spider/nurse, /mob/living/basic/young_spider/tangle)

	var/mob/living/basic/young_spider/grown = change_mob_type(grow_as, get_turf(src), initial(grow_as.name))
	ADD_TRAIT(grown, TRAIT_WAS_EVOLVED, REF(src))
	grown.faction = faction.Copy()
	grown.directive = directive
	grown.set_name()

	qdel(src)

/// Opportunistically hops in and out of vents, if it can find one. We aren't interested in attacking due to how weak we are, we gotta be quick and hidey.
/datum/ai_controller/basic_controller/spiderling
	blackboard = list(
		BB_FLEE_TARGETTING_DATUM = new /datum/targetting_datum/basic/of_size/larger, // Run away from mobs bigger than we are
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_VENTCRAWL_COOLDOWN = 20 SECONDS, // enough time to get splatted while we're out in the open.
		BB_TIME_TO_GIVE_UP_ON_VENT_PATHING = 30 SECONDS,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	// We understand that vents are nice little hidey holes through epigenetic inheritance, so we'll use them.
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/opportunistic_ventcrawler,
		/datum/ai_planning_subtree/random_speech/insect,
	)
