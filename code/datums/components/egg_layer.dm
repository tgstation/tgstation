/**
 * # egg layer component!
 *
 * Component that manages how many eggs to lay, what can be fed to the mob to make them lay more, and what is actually laid.
 * Since the only real interaction with the component is an attackby, the nice part is that we're able to make this an atom level proc.
 * egg_layer will loudly fail if you do not provide it the arguments, as to encourage explicicy(?)
 */
/datum/component/egg_layer
	/// item laid by the mob
	var/egg_type
	/// items that can be fed to the mob to make it lay more eggs
	var/list/food_types
	/// messages sent when fed
	var/list/feedMessages
	/// messages sent when laying an egg
	var/list/layMessages
	/// kind of a weird boolean, but basically egg layers usually need to make their eggs process to let them grow. and some don't want that to happen too!
	var/process_eggs
	/// how many eggs left to lay
	var/eggs_left = 0
	/// used to check for possibly too much egg laying going on (aka past a certain amount of chickens, stop making more chickens from eggs)
	var/datum/callback/egg_animal_callback

/datum/component/egg_layer/Initialize(egg_type, food_types, feedMessages, layMessages, eggs_left, process_eggs, egg_animal_callback)
	if(!isatom(parent)) //yes, you could make a tameable toolbox.
		return COMPONENT_INCOMPATIBLE

	src.egg_type = egg_type
	src.food_types = food_types
	src.feedMessages = feedMessages
	src.layMessages = layMessages
	src.eggs_left = eggs_left
	src.process_eggs = process_eggs
	src.egg_animal_callback = egg_animal_callback

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/feed_food)
	START_PROCESSING(SSobj, src)

/datum/component/egg_layer/Destroy(force, silent)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/datum/component/egg_layer/proc/feed_food(datum/source, obj/item/food, mob/living/attacker, params)
	SIGNAL_HANDLER

	var/atom/at_least_atom = parent
	if(!is_type_in_list(food, food_types))
		return
	if(isliving(at_least_atom))
		var/mob/living/potentially_dead_horse = at_least_atom
		if(potentially_dead_horse.stat == DEAD)
			to_chat(attacker, "<span class='warning'>[parent] is dead!</span>")
			return
	. = COMPONENT_CANCEL_ATTACK_CHAIN //No beating up anymore!
	if(eggs_left < 8)
		to_chat(attacker, "<span class='warning'>[parent] doesn't seem hungry!</span>")
		return
	attacker.visible_message("<span class='notice'>[attacker] hand-feeds [food] to [parent].</span>", "<span class='notice'>You hand-feed [food] to [parent].</span>")
	at_least_atom.visible_message(pick(feedMessages))
	qdel(food)
	eggs_left += min(eggs_left += rand(1, 4), 8)

/datum/component/egg_layer/process(delta_time = SSOBJ_DT)

	var/atom/at_least_atom = parent
	if(isliving(at_least_atom))
		var/mob/living/potentially_dead_horse = at_least_atom
		if(potentially_dead_horse.stat != CONSCIOUS)
			return
	if(!eggs_left || !DT_PROB(1.5, delta_time))
		return

	at_least_atom.visible_message("<span class='alertalien'>[at_least_atom] [pick(layMessages)]</span>")
	eggs_left--
	var/obj/item/egg = new egg_type(get_turf(at_least_atom))
	egg.pixel_x = rand(-6, 6)
	egg.pixel_y = rand(-6, 6)
	if(!process_eggs)
		return
	var/positive_callback_result
	if(egg_animal_callback)
		positive_callback_result = egg_animal_callback.Invoke()
	if(positive_callback_result && prob(25))
		START_PROCESSING(SSobj, egg)
