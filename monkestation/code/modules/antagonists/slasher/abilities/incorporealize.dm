/datum/action/cooldown/slasher/incorporealize
	name = "Incorporealize"
	desc = "Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS

	var/jaunt_type = /obj/effect/dummy/phased_mob

/datum/action/cooldown/slasher/incorporealize/Activate(atom/target)
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	var/area/owner_area = get_area(owner)
	var/turf/owner_turf = get_turf(owner)

	/**
	 * Here we start our checks
	 * We cant do it in PreActivate() since that for some reason does not work
	 */

	// Standard jaunt checks

	if(!owner_area || !owner_turf)
		return // nullspaced?

	if(owner_area.area_flags & NOTELEPORT)
		to_chat(owner, span_danger("Some dull, universal force is stopping you from going incorporeal here."))
		return

	if(owner_turf?.turf_flags & NOJAUNT)
		to_chat(owner, span_danger("An otherwordly force is preventing you from going incorporeal here."))
		return

	// Unique slasher checks

	if(!slasherdatum)
		to_chat(owner, span_warning("You should not have this ability or your slasher antagonist datum was deleted, please contact coders"))
		return

	if(slasherdatum.soul_punishment >= 2)
		to_chat(owner, span_boldwarning("The souls you have stolen are preventing you from going incorporeal!"))
		return

	for(var/mob/living/watcher in viewers(9, target))
		if(watcher == target)
			continue

		if(!watcher.mind) //only mobs with minds stop you from jaunting
			continue

		if(isdead(watcher))
			continue

		if(isaicamera(watcher))
			var/mob/camera/ai_eye/ai_eye = watcher
			var/mob/living/silicon/ai/true_ai = ai_eye.ai
			true_ai.disconnect_shell() // should never happen, lets try it anyway
			true_ai.view_core()
			to_chat(true_ai, span_warning("UNEXPECTED ENERGY SURGE -- RETURNING TO THE CORE"))
			do_sparks(3, FALSE, true_ai)
			true_ai.adjustBruteLoss(30) // same as a light explosion, to dis-encurage the AI always watching the slasher and telling their location
			continue

		target.balloon_alert(owner, "you can only vanish unseen.")
		return

	. = ..()

	if(is_jaunting(target))
		. = exit_jaunt(target)
	else
		. = enter_jaunt(target)

/datum/action/cooldown/slasher/incorporealize/proc/enter_jaunt(mob/living/jaunter)
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)

	update_the_button(jaunter)

	animate(jaunter, alpha = 0, time = 1.5 SECONDS)
	SLEEP_CHECK_DEATH(1.5 SECONDS, src)

	var/obj/effect/dummy/phased_mob/jaunt = new jaunt_type(get_turf(jaunter), jaunter)

	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(on_jaunt_exited))
	jaunter.add_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN), REF(src))
	jaunter.drop_all_held_items()
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, INNATE_TRAIT)

	// Give them some bloody hands to prevent them from doing things
	var/obj/item/bloodcrawl/left_hand = new(jaunter)
	var/obj/item/bloodcrawl/right_hand = new(jaunter)
	left_hand.icon_state = "bloodhand_right" // Icons swapped intentionally..
	right_hand.icon_state = "bloodhand_left" // ..because perspective, or something
	jaunter.put_in_hands(left_hand)
	jaunter.put_in_hands(right_hand)

	// Make sure they wont be burning for 20 seconds
	jaunter.extinguish_mob()
	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, INNATE_TRAIT)

	slasherdatum.corporeal = FALSE
	ADD_TRAIT(jaunter, TRAIT_NOBREATH, REF(src))

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(jaunter, COMSIG_MOB_ENTER_JAUNT, src, jaunt)
	return jaunt

/datum/action/cooldown/slasher/incorporealize/proc/exit_jaunt(mob/living/unjaunter)
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	var/obj/effect/dummy/phased_mob/jaunt = unjaunter.loc

	update_the_button(unjaunter)

	jaunt.eject_jaunter()

	animate(unjaunter, alpha = 255, time = 1.5 SECONDS)
	SLEEP_CHECK_DEATH(1.5 SECONDS, src)

	for(var/obj/item/bloodcrawl/blood_hand in unjaunter.held_items)
		unjaunter.temporarilyRemoveItemFromInventory(blood_hand, force = TRUE)
		qdel(blood_hand)

	slasherdatum.corporeal = TRUE
	REMOVE_TRAIT(unjaunter, TRAIT_NOBREATH, REF(src))

	return TRUE

/datum/action/cooldown/slasher/incorporealize/proc/update_the_button(atom/target)
	if(is_jaunting(target))
		name = "Incorporealize"
		desc = "Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
		button_icon_state = "incorporealize"
	else
		name = "Corporealize"
		desc = "Manifest your being from your incorporeal state."
		button_icon_state = "corporealize"
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

/datum/action/cooldown/slasher/incorporealize/proc/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	unjaunter.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN), REF(src))
	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(unjaunter, COMSIG_MOB_AFTER_EXIT_JAUNT, src)

/datum/action/cooldown/slasher/incorporealize/Remove(mob/living/remove_from)
	exit_jaunt(remove_from)
	if(!is_jaunting(remove_from)) // In case you have made exit_jaunt conditional, as in mirror walk
		return ..()
	var/obj/effect/dummy/phased_mob/jaunt = remove_from.loc
	jaunt.eject_jaunter()
	return ..()
