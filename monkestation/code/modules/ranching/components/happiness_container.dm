/datum/component/happiness_container
	///our current happiness
	var/current_happiness = 0
	///the maximum happiness for this life set to -1 to disable
	var/maxiumum_life_happiness = -1
	///reagents we like
	var/list/liked_reagents = list()
	///the reagents we dislike
	var/list/disliked_reagents = list()
	///the foods we like
	var/list/liked_foods = list()
	///the foods we dislike
	var/list/disliked_foods = list()
	///the food_types we dislike
	var/list/disliked_food_types = list()
	///this is our thresholds where we do a callback at unhappy
	var/list/unhappy_callbacks = list()

	///our applied_visual
	var/mutable_appearance/applied_visual

/datum/component/happiness_container/Initialize(maxiumum_life_happiness = -1, liked_reagents = list(), disliked_reagents = list(), liked_foods = list(), disliked_foods = list(), disliked_food_types = list(), unhappy_callbacks = list())
	. = ..()
	src.maxiumum_life_happiness = maxiumum_life_happiness
	src.liked_reagents = liked_reagents
	src.disliked_reagents = disliked_reagents
	src.liked_foods = liked_foods
	src.disliked_foods = disliked_foods
	src.disliked_food_types = disliked_food_types
	src.unhappy_callbacks = unhappy_callbacks

/datum/component/happiness_container/Destroy(force, silent)
	. = ..()
	QDEL_NULL(applied_visual)

/datum/component/happiness_container/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HAPPINESS_ADJUST, PROC_REF(adjust_happiness))
	RegisterSignal(parent, COMSIG_HAPPINESS_RETURN_VALUE, PROC_REF(return_happiness))
	RegisterSignal(parent, COMSIG_LIVING_ATE, PROC_REF(on_eat))
	RegisterSignal(parent, COMSIG_HAPPINESS_PASS_HAPPINESS, PROC_REF(pass_happiness))

/datum/component/happiness_container/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_HAPPINESS_ADJUST)
	UnregisterSignal(parent, COMSIG_HAPPINESS_RETURN_VALUE)
	UnregisterSignal(parent, COMSIG_LIVING_ATE)
	UnregisterSignal(parent, COMSIG_HAPPINESS_PASS_HAPPINESS)

/datum/component/happiness_container/proc/adjust_happiness(datum/source, adjustment, atom/came_from, natural_cause = FALSE)
	if(adjustment > 0)
		if(!natural_cause)
			add_visual("love")
		var/maximum_drain = 0
		if(maxiumum_life_happiness == -1)
			maximum_drain = adjustment
		else
			if(maxiumum_life_happiness == 0)
				return
		maximum_drain = min(maxiumum_life_happiness, adjustment)
		maxiumum_life_happiness -= maximum_drain
		current_happiness += maximum_drain
	else
		if(!natural_cause)
			add_visual("angry")
		current_happiness += adjustment
	if(came_from)
		SEND_SIGNAL(parent, COMSIG_FRIENDSHIP_CHANGE, came_from, adjustment * 0.5)

	for(var/datum/callback/callback as anything in unhappy_callbacks)
		if(current_happiness < unhappy_callbacks[callback])
			callback.Invoke()

/datum/component/happiness_container/proc/return_happiness(datum/source)
	return current_happiness

/datum/component/happiness_container/proc/on_eat(datum/source, atom/ate, atom/came_from)
	if(istype(ate, /obj/effect/chicken_feed))
		on_feed_eat(source, ate)
		return
	else
		ate_type(ate.type, came_from)
		for(var/datum/reagent/reagent  as anything in ate.reagents.reagent_list)
			if(reagent.type in liked_reagents)
				adjust_happiness(parent, liked_reagents[reagent.type] * reagent.volume, came_from)
			if(reagent.type in disliked_reagents)
				adjust_happiness(parent, disliked_reagents[reagent.type] * reagent.volume, came_from)

/datum/component/happiness_container/proc/ate_type(atom/ate)
	if(istype(ate, /obj/item/food))
		var/obj/item/food/food = ate
		for(var/food_type as anything in disliked_food_types)
			if(food_type & initial(food.foodtypes))
				adjust_happiness(parent, disliked_food_types[food_type])
	if(ate in liked_foods)
		adjust_happiness(parent, liked_foods[ate.type])
	if(ate in disliked_foods)
		adjust_happiness(parent, disliked_foods[ate.type])

/datum/component/happiness_container/proc/on_feed_eat(datum/source, obj/effect/chicken_feed/feed)
	var/list/foods = feed.held_foods
	var/list/reagents = feed.held_reagents

	for(var/atom/target as anything in foods)
		ate_type(target)

	for(var/datum/reagent/reagent  as anything in reagents)
		if(reagent in liked_reagents)
			adjust_happiness(parent, liked_reagents[reagent.type] * reagent.volume)
		if(reagent in disliked_reagents)
			adjust_happiness(parent, disliked_reagents[reagent.type] * reagent.volume)

/datum/component/happiness_container/proc/pass_happiness(datum/source, atom/target)
	if(!target.GetComponent(/datum/component/happiness_container))
		target.AddComponent(/datum/component/happiness_container)
	SEND_SIGNAL(target, COMSIG_HAPPINESS_ADJUST, current_happiness)

/datum/component/happiness_container/proc/add_visual(method)
	if(applied_visual)
		return
	var/atom/movable/parent_movable = parent
	applied_visual = mutable_appearance('monkestation/icons/effects/ranching_text.dmi', "chicken_[method]", FLOAT_LAYER, parent_movable, plane = parent_movable.plane)
	parent_movable.add_overlay(applied_visual)
	addtimer(CALLBACK(src, PROC_REF(remove_visual)), 3 SECONDS)

/datum/component/happiness_container/proc/remove_visual()
	var/atom/movable/parent_movable = parent
	parent_movable.cut_overlay(applied_visual)
	QDEL_NULL(applied_visual)
