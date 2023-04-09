#define PLANK_BARRICADE_AMOUNT 2

/datum/element/can_barricade
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

/datum/element/can_barricade/Attach(atom/target)
	. = ..()

	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_start_barricade))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/element/can_barricade/Detach(atom/target)
	UnregisterSignal(target, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))
	// We don't remove HAS_CONTEXTUAL_SCREENTIPS_1, since there could be other stuff still hooked to it,
	// and being set without signals is not dangerous, just less performant.
	// A lot of things don't do this, perhaps make a proc that checks if any signals are still set, and if not,
	// remove the flag.
	return ..()

/datum/element/can_barricade/proc/on_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER
	examine_texts += span_notice("This looks like it can be barricaded with planks of wood.")

/datum/element/can_barricade/proc/on_start_barricade(atom/source, obj/item/stack/sheet/mineral/wood/plank, mob/living/user, params)
	SIGNAL_HANDLER

	if(user.combat_mode || !istype(plank) || !istype(user))
		return

	if(plank.get_amount() < PLANK_BARRICADE_AMOUNT)
		source.balloon_alert(user, "need [PLANK_BARRICADE_AMOUNT] [plank] sheets!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	source.balloon_alert(user, "constructing barricade...")
	playsound(source, 'sound/items/hammering_wood.ogg', 50, vary = TRUE)
	INVOKE_ASYNC(src, PROC_REF(barricade), source, plank, user, params) //signal handlers can't have do_afters inside of them
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// when our element gets attacked by wooden planks it creates a barricade
/datum/element/can_barricade/proc/barricade(atom/source, obj/item/stack/sheet/mineral/wood/plank, mob/living/user, params)
	if(!do_after(user, 5 SECONDS, target = source) || !plank.use(2) || (locate(/obj/structure/barricade/wooden/crude) in source.loc))
		return

	source.balloon_alert(user, "barricade constructed")
	var/obj/structure/barricade/wooden/crude/barricade = new (source.loc)
	barricade.add_fingerprint(user)

/datum/element/can_barricade/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if(istype(held_item, /obj/item/stack/sheet/mineral/wood) && source.Adjacent(user))
		context[SCREENTIP_CONTEXT_LMB] = "Construct barricade"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

#undef PLANK_BARRICADE_AMOUNT
