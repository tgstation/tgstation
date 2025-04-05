#define DOAFTER_SOURCE_FOODLIKE_DRINK "doafter_foodlike_drink"

/**
 * This element can be attached to a reagent container to make it loop after drinking like a food item
 */
/datum/element/foodlike_drink

/datum/element/foodlike_drink/Attach(datum/target)
	. = ..()
	if(!is_reagent_container(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_GLASS_DRANK, PROC_REF(on_drink))

/datum/element/foodlike_drink/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_GLASS_DRANK)

/datum/element/foodlike_drink/proc/on_drink(obj/item/reagent_containers/source, mob/living/drinker, mob/living/user)
	SIGNAL_HANDLER

	if(drinker != user)
		return

	if(DOING_INTERACTION(user, DOAFTER_SOURCE_FOODLIKE_DRINK))
		return

	INVOKE_ASYNC(src, PROC_REF(continue_drinking), source, user)

/datum/element/foodlike_drink/proc/continue_drinking(obj/item/reagent_containers/source, mob/living/user)
	if(!do_after(
		user = user,
		delay = 1.25 SECONDS,
		timed_action_flags = IGNORE_USER_LOC_CHANGE,
		extra_checks = CALLBACK(src, PROC_REF(can_keep_drinking), source, user),
		interaction_key = DOAFTER_SOURCE_FOODLIKE_DRINK,
	))
		return

	source.attack(user, user)
	user.hud_used?.hunger?.update_hunger_bar()

/datum/element/foodlike_drink/proc/can_keep_drinking(obj/item/reagent_containers/source, mob/living/user)
	if(QDELETED(source) || user.get_active_held_item() != source)
		return FALSE
	if(source.reagents.total_volume <= 0)
		return FALSE
	return TRUE

#undef DOAFTER_SOURCE_FOODLIKE_DRINK
