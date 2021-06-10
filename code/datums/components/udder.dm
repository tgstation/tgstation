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

/datum/component/udder/Initialize(udder_type = /obj/item/udder, on_milk_callback, on_generate_callback)
	if(!isliving(parent)) //technically is possible to drop this on carbons... but you wouldn't do that to me, would you?
		return COMPONENT_INCOMPATIBLE
	udder = new udder_type(null, parent, on_generate_callback)
	src.on_milk_callback = on_milk_callback

/datum/component/udder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

/datum/component/udder/UnregisterFromParent()
	QDEL_NULL(udder)
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_PARENT_ATTACKBY))

///signal called on parent being examined
/datum/component/udder/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/mob/living/milked = parent
	if(milked.stat != CONSCIOUS)
		return //come on now

	var/udder_filled_percentage = PERCENT(udder.reagents.total_volume / udder.reagents.maximum_volume)
	switch(udder_filled_percentage)
		if(0 to 10)
			examine_list += "<span class='notice'>[parent]'s [udder] is dry.</span>"
		if(11 to 99)
			examine_list += "<span class='notice'>[parent]'s [udder] can be milked if you have something to contain it.</span>"
		if(100)
			examine_list += "<span class='notice'>[parent]'s [udder] is round and full, and can be milked if you have something to contain it.</span>"


///signal called on parent being attacked with an item
/datum/component/udder/proc/on_attackby(datum/source, obj/item/milking_tool, mob/user)
	SIGNAL_HANDLER

	var/mob/living/milked = parent
	if(milked.stat == CONSCIOUS && istype(milking_tool, /obj/item/reagent_containers/glass))
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
	///how much the udder holds
	var/size = 50
	///mob that has the udder component
	var/mob/living/udder_mob
	///optional proc to callback to when the udder generates milk
	var/datum/callback/on_generate_callback

/obj/item/udder/Initialize(mapload, udder_mob, on_generate_callback)
	src.udder_mob = udder_mob
	src.on_generate_callback = on_generate_callback
	create_reagents(size, REAGENT_HOLDER_ALIVE)
	initial_conditions()
	. = ..()

/obj/item/udder/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/udder/process(delta_time)
	if(udder_mob.stat != DEAD)
		generate() //callback is on generate() itself as sometimes generate does not add new reagents, or is not called via process

/**
 * # initial_conditions
 *
 * Proc called on creation separate from the reagent datum creation to allow for signalled milk generation instead of processing milk generation
 * also useful for changing initial amounts in reagent holder (cows start with milk, gutlunches start empty)
 */
/obj/item/udder/proc/initial_conditions()
	reagents.add_reagent(/datum/reagent/consumable/milk, 20)
	START_PROCESSING(SSobj, src)

/**
 * # generate
 *
 * Proc called every 2 seconds from SSMobs to add whatever reagent the udder is generating.
 */
/obj/item/udder/proc/generate()
	if(prob(5))
		reagents.add_reagent(/datum/reagent/consumable/milk, rand(5, 10))
		if(on_generate_callback)
			on_generate_callback.Invoke(reagents.total_volume, reagents.maximum_volume)

/**
 * # milk
 *
 * Proc called from attacking the component parent with the correct item, moves reagents into the glass basically.
 */
/obj/item/udder/proc/milk(obj/item/reagent_containers/glass/milk_holder, mob/user)
	if(milk_holder.reagents.total_volume >= milk_holder.volume)
		to_chat(user, "<span class='warning'>[milk_holder] is full.</span>")
		return
	var/transfered = reagents.trans_to(milk_holder, rand(5,10))
	if(transfered)
		user.visible_message("<span class='notice'>[user] milks [src] using \the [milk_holder].</span>", "<span class='notice'>You milk [src] using \the [milk_holder].</span>")
	else
		to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")

/**
 * # gutlunch udder subtype
 *
 * Used by gutlunches, and generates healing reagents instead of milk on eating gibs instead of a process. Starts empty!
 * Female gutlunches (ahem, guthens if you will) make babies when their udder is full under processing, instead of milk generation
 */
/obj/item/udder/gutlunch
	name = "nutrient sac"

/obj/item/udder/gutlunch/initial_conditions()
	if(udder_mob.gender == FEMALE)
		START_PROCESSING(SSobj, src)
	RegisterSignal(udder_mob, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, .proc/on_mob_attacking)

/obj/item/udder/gutlunch/Destroy()
	. = ..()
	UnregisterSignal(udder_mob, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)

/obj/item/udder/gutlunch/process(delta_time)
	var/mob/living/simple_animal/hostile/asteroid/gutlunch/gutlunch = udder_mob
	if(reagents.total_volume != reagents.maximum_volume)
		return
	if(gutlunch.make_babies())
		reagents.clear_reagents()
		//usually this would be a callback but this is a specifically gutlunch feature so fuck it, gutlunch specific proccall
		gutlunch.regenerate_icons(reagents.total_volume, reagents.maximum_volume)

///signal called on parent attacking an atom
/obj/item/udder/proc/on_mob_attacking(mob/living/simple_animal/hostile/gutlunch, atom/target)
	if(is_type_in_typecache(target, gutlunch.wanted_objects)) //we eats
		generate()
		gutlunch.visible_message("<span class='notice'>[src] slurps up [target].</span>")
		qdel(target)
	return COMPONENT_HOSTILE_NO_ATTACK //there is no longer a target to attack

/obj/item/udder/gutlunch/generate()
	var/made_something = FALSE
	if(prob(60))
		reagents.add_reagent(/datum/reagent/consumable/cream, rand(2, 5))
		made_something = TRUE
	if(prob(45))
		reagents.add_reagent(/datum/reagent/medicine/salglu_solution, rand(2,5))
		made_something = TRUE
	if(made_something && on_generate_callback)
		on_generate_callback.Invoke(reagents.total_volume, reagents.maximum_volume)
