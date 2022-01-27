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
	var/list/feed_messages
	/// messages sent when laying an egg
	var/list/lay_messages
	/// how many eggs left to lay
	var/eggs_left
	/// how many eggs to lay given from food
	var/eggs_added_from_eating
	/// how many eggs can be stored
	var/max_eggs_held
	/// callback to a proc that allows the parent to modify their new eggs
	var/datum/callback/egg_laid_callback

/datum/component/egg_layer/Initialize(egg_type, food_types, feed_messages, lay_messages, eggs_left, eggs_added_from_eating, max_eggs_held, egg_laid_callback)
	if(!isatom(parent)) //yes, you could make a tameable toolbox.
		return COMPONENT_INCOMPATIBLE

	src.egg_type = egg_type
	src.food_types = food_types
	src.feed_messages = feed_messages
	src.lay_messages = lay_messages
	src.eggs_left = eggs_left
	src.eggs_added_from_eating = eggs_added_from_eating
	src.max_eggs_held = max_eggs_held
	src.egg_laid_callback = egg_laid_callback


	START_PROCESSING(SSobj, src)

/datum/component/egg_layer/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/feed_food)

/datum/component/egg_layer/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

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
			to_chat(attacker, span_warning("[parent] is dead!"))
			return COMPONENT_CANCEL_ATTACK_CHAIN
	if(eggs_left > max_eggs_held)
		to_chat(attacker, span_warning("[parent] doesn't seem hungry!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	attacker.visible_message(span_notice("[attacker] hand-feeds [food] to [parent]."), span_notice("You hand-feed [food] to [parent]."))
	at_least_atom.visible_message(pick(feed_messages))
	qdel(food)
	eggs_left += min(eggs_left + eggs_added_from_eating, max_eggs_held)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/egg_layer/process(delta_time = SSOBJ_DT)

	var/atom/at_least_atom = parent
	if(isliving(at_least_atom))
		var/mob/living/potentially_dead_horse = at_least_atom
		if(potentially_dead_horse.stat != CONSCIOUS)
			return
	if(!eggs_left || !DT_PROB(1.5, delta_time))
		return

	at_least_atom.visible_message(span_alertalien("[at_least_atom] [pick(lay_messages)]"))
	eggs_left--
	var/obj/item/egg = new egg_type(get_turf(at_least_atom))
	egg.pixel_x = rand(-6, 6)
	egg.pixel_y = rand(-6, 6)
	egg_laid_callback?.Invoke(egg)
