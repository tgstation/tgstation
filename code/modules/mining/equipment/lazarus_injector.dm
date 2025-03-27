/**
 * Players can revive simplemobs with this.
 *
 * In-game item that can be used to revive a simplemob once. This makes the mob friendly.
 * Becomes useless after use.
 * Becomes malfunctioning when EMP'd.
 * If a hostile mob is revived with a malfunctioning injector, it will be hostile to everyone except whoever revived it and gets robust searching enabled.
 */
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "lazarus_hypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	///Can this still be used?
	var/loaded = TRUE
	///Injector malf?
	var/malfunctioning = FALSE
	///So you can't revive boss monsters or robots with it
	var/revive_type = SENTIENCE_ORGANIC

/obj/item/lazarus_injector/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!loaded)
		return NONE
	if(SEND_SIGNAL(target, COMSIG_ATOM_ON_LAZARUS_INJECTOR, src, user) & LAZARUS_INJECTOR_USED)
		return ITEM_INTERACT_SUCCESS
	if(!isliving(target))
		return NONE

	var/mob/living/target_animal = target
	if(!target_animal.compare_sentience_type(revive_type)) // Will also return false if not a basic or simple mob, which are the only two we want anyway
		balloon_alert(user, "invalid creature!")
		return ITEM_INTERACT_BLOCKING
	if(target_animal.stat != DEAD)
		balloon_alert(user, "it's not dead!")
		return ITEM_INTERACT_BLOCKING

	target_animal.lazarus_revive(user, malfunctioning)
	expend(target_animal, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/lazarus_injector/proc/expend(atom/revived_target, mob/user)
	user.visible_message(span_notice("[user] injects [revived_target] with [src], reviving it."))
	SSblackbox.record_feedback("tally", "lazarus_injector", 1, revived_target.type)
	loaded = FALSE
	playsound(src,'sound/effects/refill.ogg',50,TRUE)
	icon_state = "lazarus_empty"

/obj/item/lazarus_injector/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!malfunctioning)
		malfunctioning = TRUE

/obj/item/lazarus_injector/examine(mob/user)
	. = ..()
	if(!loaded)
		. += span_info("[src] is empty.")
	if(malfunctioning)
		. += span_info("The display on [src] seems to be flickering.")
