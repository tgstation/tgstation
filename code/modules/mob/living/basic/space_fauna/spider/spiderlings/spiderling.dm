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
	icon_state = "spiderling"
	faction = list(FACTION_SPIDER)
	speed = 1
	move_resist = INFINITY // YOU CAN'T HANDLE ME LET ME BE FREE LET ME BE FREE LET ME BE FREE
	speak_emote = list("hisses")
	basic_mob_flags = FLAMMABLE_MOB

	unique_name = TRUE
	gold_core_spawnable = HOSTILE_SPAWN // because of what we grow into!

	// we have _some_ bite
	melee_damage_lower = 2
	melee_damage_upper = 4

	health = 5 // very low.
	maxHealth = 5
	unsuitable_cold_damage = 4
	unsuitable_heat_damage = 4
	death_message = "lets out a final hiss..."

	// VERY red, to fit the eyes
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	/// The mob we will grow into.
	var/mob/living/basic/giant_spider/grow_as = null
	/// The message that the mother left for our big strong selves.
	var/directive = ""
	/// Simple boolean that determines if we should apply the spider antag to the player if they possess this mob. TRUE by default since we're always going to evolve into a spider that will have an antagonistic role.
	var/apply_spider_antag = TRUE

/mob/living/basic/spiderling/Initialize(mapload)
	. = ..()
	// random placement since we're pretty small and to make the swarming component actually look like it's doing something when we have a buncha these fuckers
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)

	// the proc that handles passtable is nice but we should always be able to pass through table since we're so small so we can eschew adding that here
	pass_flags |= PASSTABLE
	ADD_TRAIT(src, TRAIT_PASSTABLE, INNATE_TRAIT)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW, volume = 0.2) // they're small but you can hear 'em

	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = 10 MINUTES,\
		growth_path = grow_as,\ // it's kinder to pass in a null to this proc since we're also doing optional_grow_behavior so let's just let it cook
		growth_probability = 25,\
		lower_growth_value = 1,\
		upper_growth_value = 2,\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(grow_into_giant_spider))
	)

/mob/living/basic/spiderling/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/basic/spiderling/death(gibbed)
	// If we're actually player-controlled, don't drop a body.
	if(mind)
		return ..()

	. = ..(gibbed = TRUE) // we're going to get rid of the body, so we must invoke parent with gibbed as TRUE.

	// alright, after we've done the parent stuff, and we weren't *actually* gibbed (per the arguments of THIS proc), we should spawn our corpse because it's food. yummy
	if(!gibbed)
		var/obj/item/food/spiderling/dead_spider = new(loc)
		dead_spider.name = name

	qdel(src)

/mob/living/basic/spiderling/Login() // this is only really here for admins dragging and dropping players into spiderlings, player control of spiderlings is otherwise unimplemented
	. = ..()
	if(!. || isnull(client))
		return FALSE
	GLOB.spidermobs[src] = TRUE
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier, multiplicative_slowdown = -2) // let's pick up the tempo, we are meant to be fast after all
	if (apply_spider_antag)
		var/datum/antagonist/spider/spider_antag = new(directive)
		mind.add_antag_datum(spider_antag)

/mob/living/basic/spiderling/Logout()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier)

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

/// Actually grows the spiderling into a giant spider. We have to do a bunch of unique behavior that really can't be genericized, so we have to override the component in this manner.
/mob/living/basic/spiderling/proc/grow_into_giant_spider()
	if(isnull(grow_as))
		if(prob(3))
			grow_as = pick(/mob/living/basic/giant_spider/tarantula, /mob/living/basic/giant_spider/viper, /mob/living/basic/giant_spider/midwife)
		else
			grow_as = pick(/mob/living/basic/giant_spider, /mob/living/basic/giant_spider/hunter, /mob/living/basic/giant_spider/nurse)

	var/mob/living/basic/giant_spider/grown = change_mob_type(grow_as, old_mob.loc)
	ADD_TRAIT(grown, TRAIT_WAS_EVOLVED, REF(src))
	grown.faction = faction.Copy()
	grown.directive = directive

	qdel(src)

/obj/structure/spider/spiderling
	var/amount_grown = 0

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipeline/entry_vent_parent = entry_vent.parents[1]
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmos_machines)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								span_hear("You hear something scampering through the ventilation ducts."))

			addtimer(CALLBACK(src, PROC_REF(vent_move), exit_vent), rand(20,60))

	//=================

	else if(prob(33))
		var/list/nearby = oview(10, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			SSmove_manager.move_to(src, target_atom)
			if(prob(40))
				src.visible_message(span_notice("\The [src] skitters[pick(" away"," around","")]."))
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				SSmove_manager.move_to(src, entry_vent, 1)
				break

/// Opportunistically hops in and out of vents, if it can find one. We aren't interested in attacking due to how weak we are, we gotta be quick and hidey.
/datum/ai_controller/basic_controller/spiderling
	blackboard = list(
		BB_FLEE_TARGETTING_DATUM = new /datum/targetting_datum/basic/of_size/larger(), // Run away from mobs bigger than we are
		BB_BASIC_MOB_FLEEING = TRUE,
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
