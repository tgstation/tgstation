/// An element which enables certain items to tap people on their knees to measure brain health
/datum/element/kneejerk
	element_flags = ELEMENT_DETACH

/datum/element/kneejerk/Attach(datum/target)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_item_attack)

/datum/element/kneejerk/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/kneejerk/proc/on_item_attack(datum/source, mob/living/target, mob/living/user, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)

	if((user.zone_selected == BODY_ZONE_L_LEG || user.zone_selected == BODY_ZONE_R_LEG) && LAZYACCESS(modifiers, RIGHT_CLICK) && target.buckled)
		tap_knee(source, target, user)

		return COMPONENT_SKIP_ATTACK

/datum/element/kneejerk/proc/tap_knee(obj/item/item, mob/living/target, mob/living/user)
	var/selected_zone = user.zone_selected
	var/obj/item/bodypart/r_leg = target.get_bodypart(BODY_ZONE_R_LEG)
	var/obj/item/bodypart/l_leg = target.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)

	if(!ishuman(target))
		return

	if((selected_zone == BODY_ZONE_R_LEG) && !r_leg)
		return
	if((selected_zone == BODY_ZONE_L_LEG) && !l_leg)
		return

	user.do_attack_animation(target)
	target.visible_message(span_warning("[user] gently taps [target]'s knee with [item]."), \
		span_userdanger("[user] taps your knee with [item]."))

	if(target.stat == DEAD) //dead men have no reflexes!
		return

	if(!target_brain)
		return

	var/target_brain_damage = target_brain.damage

	if(target_brain_damage < BRAIN_DAMAGE_MILD) //a healthy brain produces a normal reaction
		playsound(target, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		target.visible_message(span_danger("[target]'s leg kicks out sharply!"), \
			span_danger("Your leg kicks out sharply!"))

	else if(target_brain_damage < BRAIN_DAMAGE_SEVERE) //a mildly damaged brain produces a delayed reaction
		playsound(target, 'sound/weapons/punchmiss.ogg', 15, TRUE, -1)
		target.visible_message(span_danger("After a moment, [target]'s leg kicks out sharply!"), \
			span_danger("After a moment, your leg kicks out sharply!"))

	else if(target_brain_damage < BRAIN_DAMAGE_DEATH) //a severely damaged brain produces a delayed + weaker reaction
		playsound(target, 'sound/weapons/punchmiss.ogg', 5, TRUE, -1)
		target.visible_message(span_danger("After a moment, [target]'s leg kicks out weakly!"), \
			span_danger("After a moment, your leg kicks out weakly!"))

	return
