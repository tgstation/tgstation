## Introduction

This is a step by step guide for making an AI Controller for your atom. It teaches the basics of each part of an AI Controller so the target for this guide is someone who doesn't know anything about Controllers and wants to hop in.

### Note on examples used

At the moment the quality of ai datums has some dubious code lying all around, and I wanted to show the best examples. So while I walk through this with the basic cow ai as an example, I do swap to other datums involving items, generic instrument planning, and some other stuff to help explain singular concepts. I make it clear later in the guide when I'm getting back to following along with filling out the cow ai, so watch out for that.

## Starting out

We're simply starting out with our definition of what we're modifying. Any atom can have an ai controller.

```dm
/mob/living/basic/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
```

## Initial AI Controller Definition

Next, we'll want to define the AI Controller. This is the "brain" of the AI. It starts as a type, but is turned into an instance once the object is instanced.

### Object Declaraction

For clarity, i've included all the variables we're going to set up but haven't yet as nulls. In reality, some of these are always expected to be something and you should take a look at the base controller for which.

```dm
/mob/living/basic/cow
    name = "cow"
    desc = "Known for their milk, just don't tip them over."

    ai_controller = /datum/ai_controller/basic_controller/cow

/datum/ai_controller/basic_controller/cow
	blackboard = list()

	ai_traits = null
	ai_movement = null
	idle_behavior = null
	planning_subtrees = list()

```

### AI Movement & Idle Behavior

AI Movement is a datum that decides how the AI you're making pathfinds. This has to at least be set to dumb movement, it cannot be null. We're making a basic mob, so we're just going to go inbetween complex and simple pathfinding with the `basic_avoidance` type.

```dm
/datum/ai_controller/basic_controller/cow
	blackboard = list()

	ai_traits = null
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null
	planning_subtrees = list()

```

Idle Behavior is very similar, datum that decides what the AI should do when it decides it doesn't need to do anything (No planned behaviors, we'll walk through that later). Cows having some idle movement sounds nice, so we're going to pick that.

```dm
/datum/ai_controller/basic_controller/cow
	blackboard = list()

	ai_traits = null
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list()

```

### AI Traits 

AI traits are flags you can set to modify generic idle and movement behavior. In this case, we want farm animals to be able to be coralled, so we're going to add the `STOP_MOVING_WHEN_PULLED` flag.

```dm
/datum/ai_controller/basic_controller/cow
	blackboard = list()

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list()

```

### Blackboard?

The blackboard is the variables of the ai controller. They are set up by the subtrees that use them, or are defaults set by the ai controller that the subtrees read. As we don't have our subtrees set up, we don't know what the blackboard should have! We're going to come back to this.

## Subtrees

So we have all the fundamentals of the cow set in stone, but we do not have the actual behaviors that make cows... act like cows! We introduce these through subtrees. They're singletons that ai controllers hold references to that plan out each step of how an AI should act, loading up behaviors.

Let's take a look at a simple subtree:

```dm
/datum/ai_planning_subtree/item_throw_attack

/datum/ai_planning_subtree/item_throw_attack/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn

	if(!controller.blackboard[BB_ITEM_TARGET] || !DT_PROB(ITEM_AGGRO_ATTACK_CHANCE, delta_time))
		return //no target, or didn't aggro

	controller.queue_behavior(controller.blackboard[BB_ITEM_MOVE_AND_ATTACK_TYPE], BB_ITEM_TARGET, BB_ITEM_THROW_ATTEMPT_COUNT)
	return SUBTREE_RETURN_FINISH_PLANNING
```

This subtree takes a blackboard named `BB_ITEM_TARGET`, the target of the item set by other subtrees, and if that exists alongside a probability to aggro, the subtree queues the behavior to attack that mob.

So, neat. When you have a target, queue an attack. This item attack subtree is pretty basic, but a more complicated one may queue different attacks depending on the target. How does this fit into the subtrees?

Let's look where it's used, specifically in the subtrees variable:

```dm
/datum/ai_controller/haunted
    planning_subtrees = list(
        ///this applies aggro for picking up the item
        /datum/ai_planning_subtree/item_ghost_resist,
        ///this picks targets from the aggro list
        /datum/ai_planning_subtree/item_target_from_aggro_list,
        ///this uses the target to attack.
        /datum/ai_planning_subtree/item_throw_attack,
    )
```

As you can see the subtrees go top to bottom on their processing. `SUBTREE_RETURN_FINISH_PLANNING` will prematurely end the subtrees, so we can be sure the ai will focus on the behaviors planned so far in a "priority list" kind of way.

Let's visualize this in a case where the subtrees should stop prematurely!

```dm
/datum/ai_controller/haunted
    planning_subtrees = list(
        ///someone is currently holding the item,
        ///preventing it from attacking!
        ///resist and end planning.
        /datum/ai_planning_subtree/item_ghost_resist,
        ///this does not fire this time around
        /datum/ai_planning_subtree/item_target_from_aggro_list,
        ///this does not fire this time around
        /datum/ai_planning_subtree/item_throw_attack,
    )
```

### Subtree Setup

Subtrees also have procs for when the mob first starts using them and when they stop. You can use this to make subtrees "react" to events via signals, and this is where we set defaults for blackboards if necessary (we want lists to be empty, not null!)

Example:

```dm
/datum/ai_planning_subtree/item_ghost_resist/SetupSubtree(datum/ai_controller/controller)
	RegisterSignal(controller.pawn, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	controller.blackboard[BB_LIKES_EQUIPPER] = FALSE
	controller.blackboard[BB_ITEM_AGGRO_LIST] = list()

/datum/ai_planning_subtree/item_ghost_resist/ForgetSubtree(datum/ai_controller/controller)
	UnregisterSignal(controller.pawn, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
```

### Lil' Subtree Warning

**Do not set blackboards on the subtree!** Subtrees are there to sort and optimize behavior selection, putting logic for setting blackboards is essentially skipping a behavior. I'm putting this here because unfortunately a lot of our current ai datum code has this exact mistake, and I'm hoping we can move on from it!

BAD:

```dm
	if(prob(50))
		var/list/possible_targets = list()
		for(var/atom/thing in view(2, living_pawn))
			if(!thing.mouse_opacity)
				continue
			if(thing.IsObscured())
				continue
			possible_targets += thing
		var/atom/target = pick(possible_targets)
		if(target)
			controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET] = target
			controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
			return
```

GOOD:

```dm
	if(!controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_nearby, BB_MONKEY_CURRENT_PRESS_TARGET)
		return

	if(prob(50))
		controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
```

As you can see we're putting the search behavior... on a behavior! and since the planning subtree passes to other subtrees afterwards, the monkey will still find things to do. The next pass, if the search behavior was successful the action can be completed.

### Behaviors for subtrees

Finally, we've reached the final stop on this controller rabbit hole: Behaviors! These are what subtrees are planning, and the AI will do **these** from first planned all the way to the end, just like it runs through subtrees.

As before, let's take a look at a basic example of one:

```dm
/datum/ai_behavior/follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/follow/perform(delta_time, datum/ai_controller/controller, follow_key, range_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/datum/weakref/follow_ref = controller.blackboard[follow_key]
	var/atom/movable/follow_target = follow_ref?.resolve()
	if(!follow_target || get_dist(living_pawn, follow_target) > controller.blackboard[range_key])
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = follow_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return

	controller.current_movement_target = living_target

/datum/ai_behavior/follow/finish_action(datum/ai_controller/controller, succeeded, follow_key, range_key)
	. = ..()
	controller.blackboard[follow_key] = null
```

This behavior makes the ai move to one tile away and finish the action, only finishing the action if the target is dead (success) or out of range (fail). When the action finishes, the follow target is unset by finish_action() regardless of success. Nice!

The last important thing to know is that behaviors take the keys from subtree planning as arguments. **They do not search for the blackboards they need themselves.**

BAD:

```dm
/datum/ai_behavior/play_instrument

/datum/ai_behavior/play_instrument/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	//bzzt! using blackboard keys directly! let the subtree pass this in!
	var/datum/song/song = controller.blackboard[BB_SONG_DATUM]

	song.start_playing(controller.pawn)
	finish_action(controller, TRUE)
```

GOOD:

```dm
/datum/ai_behavior/play_instrument

/datum/ai_behavior/play_instrument/perform(delta_time, datum/ai_controller/controller, song_datum_key)
	. = ..()

	var/datum/song/song = controller.blackboard[song_datum_key]

	song.start_playing(controller.pawn)
	finish_action(controller, TRUE) //NOTE: you may forget, but this doesn't end the proc! return after it if you have code later
```

## "Okay, back to what we were doing!"

Wow, what a tangent! But it's important to understand subtree planning as it is the core of our AI. We have a subtree for the cows to occasionally make sounds, which can be interrupted by the tipping subtree (since cows can be tipped!) The Blackboard stays empty for our cows, since the tipped subtree does not have any blackboards it needs to read that could change per-ai controller. The Tipping blackboards are handled by the subtree's setup.

```dm
/datum/ai_controller/basic_controller/cow
	blackboard = list()

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/tip_reaction,
		/datum/ai_planning_subtree/random_speech/cow,
	)
```

### Finished Product: A COW.

And... we're finished! The tip_reaction subtree hooks into signals and runs behaviors when the cow is tipped, the random speech occasionally plans speech, the idle behavior runs when no behaviors are planned, and the cow acts like a cow! We used a mob in this case because everyone knows how a cow works as it's a very simple creature, but AI Controllers work on anything! It's just as valid of a use case to make, say, the staff of animation apply AI Controllers to items.
