/datum/action/cooldown/mob_cooldown/wrap
	name = "Wrap"
	desc = "Wrap something or someone in a cocoon. \
		If it's a human or similar species, you'll also consume them. \
		Consuming a wrapped victim can empower your egg-laying abilities. \
		Activate this ability and then click on an adjacent target to begin wrapping them."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "wrap_0"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/wrap_target.dmi'
	shared_cooldown = NONE
	/// The time it takes to wrap something.
	var/wrap_time = 5 SECONDS

/datum/action/cooldown/mob_cooldown/wrap/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignals(owner, list(COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/wrap/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))

/datum/action/cooldown/mob_cooldown/wrap/IsAvailable(feedback = FALSE)
	. = ..()
	if(!. || owner.incapacitated())
		return FALSE
	if(DOING_INTERACTION(owner, DOAFTER_SOURCE_SPIDER))
		if (feedback)
			owner.balloon_alert(owner, "busy!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/wrap/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	on_who.balloon_alert(on_who, "prepared to wrap")
	button_icon_state = "wrap_1"
	build_all_button_icons()

/datum/action/cooldown/mob_cooldown/wrap/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if (refund_cooldown)
		on_who.balloon_alert(on_who, "wrap cancelled")
	button_icon_state = "wrap_0"
	build_all_button_icons()

/datum/action/cooldown/mob_cooldown/wrap/Activate(atom/to_wrap)
	if(!owner.Adjacent(to_wrap))
		owner.balloon_alert(owner, "must be closer!")
		return FALSE

	if(!ismovable(to_wrap) || to_wrap == owner)
		return FALSE

	if(isspider(to_wrap))
		owner.balloon_alert(owner, "can't wrap spiders!")
		return FALSE

	var/atom/movable/target_movable = to_wrap
	if(target_movable.anchored)
		return FALSE

	StartCooldown(wrap_time)
	INVOKE_ASYNC(src, PROC_REF(cocoon), to_wrap)
	return TRUE

/datum/action/cooldown/mob_cooldown/wrap/proc/cocoon(atom/movable/to_wrap)
	owner.visible_message(
		span_notice("[owner] begins to secrete a sticky substance around [to_wrap]."),
		span_notice("You begin wrapping [to_wrap] into a cocoon."),
	)
	if(do_after(owner, wrap_time, target = to_wrap, interaction_key = DOAFTER_SOURCE_SPIDER))
		wrap_target(to_wrap)
	else
		owner.balloon_alert(owner, "interrupted!")

/datum/action/cooldown/mob_cooldown/wrap/proc/wrap_target(atom/movable/to_wrap)
	var/obj/structure/spider/cocoon/casing = new(to_wrap.loc)
	if(isliving(to_wrap))
		var/mob/living/living_wrapped = to_wrap
		// You get a point every time you consume a living player, even if they've been consumed before.
		// You only get a point for any individual corpse once, so you can't keep breaking it out and eating it again.
		if(ishuman(living_wrapped) && (living_wrapped.stat != DEAD || !HAS_TRAIT(living_wrapped, TRAIT_SPIDER_CONSUMED)))
			var/datum/action/cooldown/mob_cooldown/lay_eggs/enriched/egg_power = locate() in owner.actions
			if(egg_power)
				egg_power.charges++
				egg_power.build_all_button_icons()
				owner.visible_message(
					span_danger("[owner] sticks a proboscis into [living_wrapped] and sucks a viscous substance out."),
					span_notice("You suck the nutriment out of [living_wrapped], feeding you enough to lay a cluster of enriched eggs."),
				)
			ADD_TRAIT(living_wrapped, TRAIT_SPIDER_CONSUMED, TRAIT_GENERIC)
			living_wrapped.investigate_log("has been killed by being wrapped in a cocoon.", INVESTIGATE_DEATHS)
			living_wrapped.death() //you just ate them, they're dead.
			log_combat(owner, living_wrapped, "spider cocooned")
		else
			to_chat(owner, span_warning("[living_wrapped] is not edible!"))

	to_wrap.forceMove(casing)
	if(to_wrap.density || ismob(to_wrap))
		casing.icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")
