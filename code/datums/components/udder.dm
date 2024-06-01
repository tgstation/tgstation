/**
 * Udder component; for farm animals to generate milk.
 *
 * Used for cows, goats, gutlunches. neat!
 */
/datum/component/udder
	///abstract item for managing reagents (further down in this file)
	var/obj/item/udder/udder
	///optional proc to callback to when the udder is milked
	var/datum/callback/on_milk_callback

//udder_type and reagent_produced_typepath are typepaths, not reference
/datum/component/udder/Initialize(udder_type = /obj/item/udder, datum/callback/on_milk_callback, datum/callback/on_generate_callback, reagent_produced_override)
	if(!isliving(parent)) //technically is possible to drop this on carbons... but you wouldn't do that to me, would you?
		return COMPONENT_INCOMPATIBLE
	udder = new udder_type(null)
	udder.add_features(parent, on_generate_callback, reagent_produced_override)
	src.on_milk_callback = on_milk_callback

/datum/component/udder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/component/udder/UnregisterFromParent()
	QDEL_NULL(udder)
	on_milk_callback = null
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACKBY))

///signal called on parent being examined
/datum/component/udder/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/mob/living/milked = parent
	if(milked.stat != CONSCIOUS)
		return //come on now

	var/udder_filled_percentage = PERCENT(udder.reagents.total_volume / udder.reagents.maximum_volume)
	switch(udder_filled_percentage)
		if(0 to 10)
			examine_list += span_notice("[parent]'s [udder] is dry.")
		if(11 to 99)
			examine_list += span_notice("[parent]'s [udder] can be milked if you have something to contain it.")
		if(100)
			examine_list += span_notice("[parent]'s [udder] is round and full, and can be milked if you have something to contain it.")


///signal called on parent being attacked with an item
/datum/component/udder/proc/on_attackby(datum/source, obj/item/milking_tool, mob/user)
	SIGNAL_HANDLER

	var/mob/living/milked = parent
	if(milked.stat == CONSCIOUS && istype(milking_tool, /obj/item/reagent_containers/cup))
		udder.milk(milking_tool, user)
		if(on_milk_callback)
			on_milk_callback.Invoke(udder.reagents.total_volume, udder.reagents.maximum_volume)
		return COMPONENT_NO_AFTERATTACK

/**
 * # udder item
 *
 * Abstract item that is held in nullspace and manages reagents. Created by udder component.
 * While perhaps reagents created by udder component COULD be managed in the mob, it would be somewhat finnicky and I actually like the abstract udders.
 */
/obj/item/udder
	name = "udder"
	///typepath of reagent produced by the udder
	var/reagent_produced_typepath = /datum/reagent/consumable/milk
	///how much the udder holds
	var/size = 50
	///the probability that the udder will produce the reagent (0 - 100)
	var/production_probability = 5
	///mob that has the udder component
	var/mob/living/udder_mob
	///optional proc to callback to when the udder generates milk
	var/datum/callback/on_generate_callback
	///do we require some food to generate milk?
	var/require_consume_type
	///how long does each food consumption allow us to make milk
	var/require_consume_timer = 2 MINUTES
	///hunger key we set to look for food
	var/hunger_key = BB_CHECK_HUNGRY

/obj/item/udder/proc/add_features(parent, callback, reagent_override)
	udder_mob = parent
	on_generate_callback = callback
	create_reagents(size, REAGENT_HOLDER_ALIVE)
	if(reagent_override)
		reagent_produced_typepath = reagent_override
	initial_conditions()
	if(isnull(require_consume_type))
		return
	RegisterSignal(udder_mob, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_mob_consume))
	RegisterSignal(udder_mob, COMSIG_ATOM_ATTACKBY, PROC_REF(on_mob_feed))
	udder_mob.ai_controller?.set_blackboard_key(BB_CHECK_HUNGRY, TRUE)

/obj/item/udder/proc/on_mob_consume(datum/source, atom/feed)
	SIGNAL_HANDLER

	if(!istype(feed, require_consume_type))
		return
	INVOKE_ASYNC(src, PROC_REF(handle_consumption), feed)
	return COMPONENT_HOSTILE_NO_ATTACK

/obj/item/udder/proc/on_mob_feed(datum/source, atom/used_item, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(used_item, require_consume_type))
		return
	INVOKE_ASYNC(src, PROC_REF(handle_consumption), used_item, user)
	return COMPONENT_NO_AFTERATTACK

/obj/item/udder/proc/handle_consumption(atom/movable/food, mob/user)
	if(locate(food.type) in src)
		if(user)
			user.balloon_alert(user, "already full!")
		return
	playsound(udder_mob.loc,'sound/items/eatfood.ogg', 50, TRUE)
	udder_mob.visible_message(span_notice("[udder_mob] gobbles up [food]!"), span_notice("You gobble up [food]!"))
	var/atom/movable/final_food = food
	if(isstack(food)) //if stack, only consume 1
		var/obj/item/stack/food_stack = food
		final_food = food_stack.split_stack(udder_mob, 1)
	final_food.forceMove(src)

/obj/item/udder/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!istype(arrived, require_consume_type))
		return ..()

	udder_mob.ai_controller?.set_blackboard_key(hunger_key, FALSE)
	QDEL_IN(arrived, require_consume_timer)
	return ..()

/obj/item/udder/Exited(atom/movable/gone, direction)
	. = ..()
	if(!istype(gone, require_consume_type))
		return
	udder_mob.ai_controller?.set_blackboard_key(hunger_key, TRUE)


/obj/item/udder/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	udder_mob = null
	on_generate_callback = null

/obj/item/udder/process(seconds_per_tick)
	if(udder_mob.stat != DEAD)
		generate() //callback is on generate() itself as sometimes generate does not add new reagents, or is not called via process

/**
 * Proc called on creation separate from the reagent datum creation to allow for signalled milk generation instead of processing milk generation
 * also useful for changing initial amounts in reagent holder (cows start with milk, gutlunches start empty)
 */
/obj/item/udder/proc/initial_conditions()
	reagents.add_reagent(reagent_produced_typepath, 20, added_purity = 1)
	START_PROCESSING(SSobj, src)

/**
 * Proc called every 2 seconds from SSMobs to add whatever reagent the udder is generating.
 */
/obj/item/udder/proc/generate()
	if(!isnull(require_consume_type) && !(locate(require_consume_type) in src))
		return FALSE
	if(!prob(production_probability))
		return FALSE
	reagents.add_reagent(reagent_produced_typepath, rand(5, 10), added_purity = 1)
	if(on_generate_callback)
		on_generate_callback.Invoke(reagents.total_volume, reagents.maximum_volume)
	return TRUE

/**
 * Proc called from attacking the component parent with the correct item, moves reagents into the glass basically.
 *
 * Arguments:
 * * obj/item/reagent_containers/cup/milk_holder - what we are trying to transfer the reagents to
 * * mob/user - who is trying to do this
 */
/obj/item/udder/proc/milk(obj/item/reagent_containers/cup/milk_holder, mob/user)
	if(milk_holder.reagents.total_volume >= milk_holder.volume)
		to_chat(user, span_warning("[milk_holder] is full."))
		return
	var/transferred = reagents.trans_to(milk_holder, rand(5,10))
	if(transferred)
		user.visible_message(span_notice("[user] milks [udder_mob] using \the [milk_holder]."), span_notice("You milk [udder_mob] using \the [milk_holder]."))
	else
		to_chat(user, span_warning("The udder is dry. Wait a bit longer..."))

/**
 * # gutlunch udder subtype
 */

/obj/item/udder/gutlunch
	name = "nutrient sac"
	require_consume_type = /obj/item/stack/ore
	reagent_produced_typepath = /datum/reagent/medicine/mine_salve

/obj/item/udder/gutlunch/generate()
	. = ..()
	if(!.)
		return
	if(locate(/obj/item/stack/ore/gold) in src)
		reagents.add_reagent(/datum/reagent/consumable/cream, rand(2, 5), added_purity = 1)
	if(locate(/obj/item/stack/ore/bluespace_crystal) in src)
		reagents.add_reagent(/datum/reagent/medicine/salglu_solution, rand(2,5))
	if(on_generate_callback)
		on_generate_callback.Invoke(reagents.total_volume, reagents.maximum_volume)

/obj/item/udder/raptor
	name = "bird udder"

/obj/item/udder/raptor/generate()
	if(!prob(production_probability))
		return FALSE
	var/happiness_percentage = udder_mob.ai_controller?.blackboard[BB_BASIC_HAPPINESS]
	if(prob(happiness_percentage))
		reagents.add_reagent(/datum/reagent/consumable/cream, 5, added_purity = 1)
	var/minimum_bound = happiness_percentage > 0.6 ? 10 : 5
	var/upper_bound = minimum_bound + 5
	reagents.add_reagent(reagent_produced_typepath, rand(minimum_bound, upper_bound), added_purity = 1)
