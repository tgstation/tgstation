/// The most random things a goose can have inside of it
#define GOOSE_SATIATED 50

/// A mob that gets mad at people at random and tries to eat nearby objects
/mob/living/basic/goose
	name = "goose"
	desc = "It's loose."
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	faction = list(FACTION_NEUTRAL)
	maxHealth = 25
	health = 25
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_sound = "goose"
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("honks")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	ai_controller = /datum/ai_controller/basic_controller/goose
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 2)
	gold_core_spawnable = HOSTILE_SPAWN
	/// Do we actually destroy food we eat?
	var/conserve_food = FALSE
	/// Unfortunately, geese want to eat every item
	var/static/list/item_typecache = typecacheof(/obj/item)

/mob/living/basic/goose/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/content_barfer)
	AddElement(/datum/element/basic_eating, add_to_contents = conserve_food, food_types = string_list(list(/obj/item)))

	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_tried_gobbling))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(on_gobbled))

	ai_controller.set_blackboard_key(BB_BASIC_FOODS, item_typecache)

/mob/living/basic/goose/death(gibbed)
	if (!gibbed && length(contents))
		var/turf/drop_turf = drop_location()
		if (istype(drop_turf))
			playsound(drop_turf, 'sound/effects/splat.ogg', 50, TRUE)
			drop_turf.add_vomit_floor(src)
	return ..()

/// Called when we try to eat something
/mob/living/basic/goose/proc/on_tried_gobbling(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER
	if (ai_controller?.blackboard[BB_GOOSE_PANICKED])
		return COMSIG_MOB_CANCEL_EAT
	if (potential_food.has_material_type(/datum/material/plastic) || IsEdible(potential_food))
		return NONE// Geese only eat FOOD or PLASTIC
	return COMSIG_MOB_CANCEL_EAT

/// Called when we've eaten something
/mob/living/basic/goose/proc/on_gobbled(atom/source, obj/item/food, mob/feeder)
	SIGNAL_HANDLER
	if (!food.has_material_type(/datum/material/plastic))
		return NONE

	visible_message(span_boldwarning("[src] is choking on \the [food]!"))
	food.forceMove(src)
	choke(food)

	return COMSIG_MOB_TERMINATE_EAT

/// Start choking on something we just ate
/mob/living/basic/goose/proc/choke(obj/item/not_food_after_all)
	apply_status_effect(/datum/status_effect/goose_choking)

/// A less grumpy but much grosser variant of the goose, who will decorate the halls in their own special way
/mob/living/basic/goose/vomit
	name = "Birdboat"
	real_name = "Birdboat"
	desc = "It's a sick-looking goose, probably ate too much maintenance trash. Best not to move it around too much."
	gender = MALE
	faction = list(FACTION_NEUTRAL, FACTION_MAINT_CREATURES)
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/goose/calm
	conserve_food = TRUE
	/// Cooldown to make sure we can't spam chat with notifications that we are full
	COOLDOWN_DECLARE(eat_fail_feedback_cooldown)
	/// An action we use to throw up
	var/datum/action/cooldown/mob_cooldown/goose_vomit/vomit_action

/mob/living/basic/goose/vomit/Initialize(mapload)
	. = ..()

	vomit_action = new(src)
	vomit_action.Grant(src)
	RegisterSignal(src, COMSIG_MOB_ABILITY_STARTED, PROC_REF(on_started_vomiting))

	// 5% chance every round to have anarchy mode deadchat control on birdboat.
	if (!prob(5))
		return
	desc = "[initial(desc)] It's waddling more than usual. It seems to be possessed."
	deadchat_plays()

/mob/living/basic/goose/vomit/Destroy()
	. = ..()
	QDEL_NULL(vomit_action)

/mob/living/basic/goose/vomit/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/vomit_chance = ai_controller?.blackboard[BB_GOOSE_VOMIT_CHANCE] || 0
	if (prob(vomit_chance))
		vomit()

/mob/living/basic/goose/vomit/examine(mob/user)
	. = ..()
	. += span_notice("Somehow, it still looks hungry.")

/mob/living/basic/goose/vomit/on_gobbled(atom/source, obj/item/food, mob/feeder)
	if (length(contents) > GOOSE_SATIATED)
		if (COOLDOWN_FINISHED(src, eat_fail_feedback_cooldown))
			if (feeder)
				visible_message(span_notice("[src] looks too full to eat \the [food]!"))
			COOLDOWN_START(src, eat_fail_feedback_cooldown, 5 SECONDS)
		return COMSIG_MOB_TERMINATE_EAT

	. = ..()
	if (. == COMSIG_MOB_TERMINATE_EAT)
		return NONE// It's plastic, if it's not plastic we already filtered it for edible

	// This also increases my vomit chance, but we atomised this field to the inside of a component and I need to read it
	var/datum/component/edible/edible = food.GetComponent(/datum/component/edible)
	if ((edible?.foodtypes & GROSS))
		ai_controller?.add_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 3)
		vomit_action?.extra_duration += 0.2 SECONDS
	else
		ai_controller?.add_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 1)

/mob/living/basic/goose/vomit/choke(obj/item/not_food_after_all)
	if (prob(75))
		return ..()
	visible_message(span_warning("[src] is gagging on \the [not_food_after_all]!"))
	manual_emote("gags!")
	addtimer(CALLBACK(src, PROC_REF(vomit)), 5 SECONDS)

/// Start making a mess
/mob/living/basic/goose/vomit/proc/vomit()
	vomit_action?.Trigger(target = src)

/mob/living/basic/goose/vomit/proc/on_started_vomiting(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if (activated != vomit_action)
		return
	remove_status_effect(/datum/status_effect/goose_choking) // We're going to cough it out

/mob/living/basic/goose/vomit/proc/stop_deadchat_plays()
	var/initial_behaviour = initial(ai_controller?.idle_behavior)
	ai_controller?.idle_behavior = SSidle_ai_behaviors.idle_behaviors[initial_behaviour]

/mob/living/basic/goose/vomit/deadchat_plays(mode = ANARCHY_MODE, cooldown = 12 SECONDS)
	var/list/goose_inputs = list(
		"vomit" = CALLBACK(src, PROC_REF(vomit)),
		"honk" = CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), "HONK!!!"),
		"spin" = CALLBACK(src, TYPE_PROC_REF(/mob, emote), "spin"))

	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, goose_inputs, cooldown, CALLBACK(src, PROC_REF(stop_deadchat_plays)))

	if (. == COMPONENT_INCOMPATIBLE)
		return

	// Stop automated movement, retain the other behaviour so you can lead the horse to plastic and have it drink.
	ai_controller?.idle_behavior = null

#undef GOOSE_SATIATED
